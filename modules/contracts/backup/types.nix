{
  config,
  lib,
  ...
}: let
  mergeBuiltinDefaults = defaults: user:
    (lib.filterAttrs (k: _: !(user ? ${k})) defaults) // user;

  optDefault = allowNull: key: fallback: attrs:
    if allowNull
    then null
    else attrs.${key} or fallback;

  optType = allowNull: baseType:
    if allowNull
    then lib.types.nullOr baseType
    else baseType;

  mkScheduleSubmodule = {
    allowNull ? false,
    defaults ? {},
  }:
    lib.types.submodule {
      options = {
        onCalendar = lib.mkOption {
          type = optType allowNull lib.types.str;
          default = optDefault allowNull "onCalendar" "hourly" defaults;
          description = "Systemd OnCalendar schedule expression controlling when backups run.";
        };
        randomizedDelaySec = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = optDefault allowNull "randomizedDelaySec" "10m" defaults;
          description = "Maximum random delay added before starting the scheduled backup timer (null to disable or leave unset).";
        };
        persistent = lib.mkOption {
          type = optType allowNull lib.types.bool;
          default = optDefault allowNull "persistent" true defaults;
          description = "Whether missed timer runs while the host was offline run immediately on boot.";
        };
      };
    };

  mkRetentionSubmodule = {
    allowNull ? false,
    defaults ? {},
  }: let
    tierOpt = key: fallback: desc:
      lib.mkOption {
        type = lib.types.nullOr lib.types.ints.unsigned;
        default = optDefault allowNull key fallback defaults;
        description = desc;
      };
  in
    lib.types.submodule {
      options = {
        last = tierOpt "last" null "Number of most recent snapshots to keep regardless of age (null or 0 to omit).";
        hourly = tierOpt "hourly" null "Number of hourly snapshots to keep (null or 0 to omit).";
        daily = tierOpt "daily" 7 "Number of daily snapshots to keep (null or 0 to omit).";
        weekly = tierOpt "weekly" 4 "Number of weekly snapshots to keep (null or 0 to omit).";
        monthly = tierOpt "monthly" 6 "Number of monthly snapshots to keep (null or 0 to omit).";
        yearly = tierOpt "yearly" null "Number of yearly snapshots to keep (null or 0 to omit).";
        within = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = optDefault allowNull "within" null defaults;
          description = "Restic duration string preserving all snapshots newer than this age (e.g. \"1y2m\").";
        };
      };
    };

  normalizeDestination = d:
    {
      enable = true;
      scope = "host";
      priority = 100;
    }
    // (builtins.removeAttrs d ["schedule" "retention"])
    // {
      schedule =
        {
          onCalendar = "hourly";
          randomizedDelaySec = "10m";
          persistent = true;
        }
        // (d.schedule or {});
      retention =
        {
          last = null;
          hourly = null;
          daily = 7;
          weekly = 4;
          monthly = 6;
          yearly = null;
          within = null;
        }
        // (d.retention or {});
    };

  scheduleToTimerConfig = sched:
    {
      OnCalendar = sched.onCalendar;
      Persistent = sched.persistent;
    }
    // lib.optionalAttrs ((sched.randomizedDelaySec or null) != null) {
      RandomizedDelaySec = sched.randomizedDelaySec;
    };

  retentionToPruneOpts = ret:
    lib.optionals ((ret.last or null) != null && ret.last != 0) ["--keep-last" (toString ret.last)]
    ++ lib.optionals ((ret.hourly or null) != null && ret.hourly != 0) ["--keep-hourly" (toString ret.hourly)]
    ++ lib.optionals ((ret.daily or null) != null && ret.daily != 0) ["--keep-daily" (toString ret.daily)]
    ++ lib.optionals ((ret.weekly or null) != null && ret.weekly != 0) ["--keep-weekly" (toString ret.weekly)]
    ++ lib.optionals ((ret.monthly or null) != null && ret.monthly != 0) ["--keep-monthly" (toString ret.monthly)]
    ++ lib.optionals ((ret.yearly or null) != null && ret.yearly != 0) ["--keep-yearly" (toString ret.yearly)]
    ++ lib.optionals ((ret.within or null) != null && ret.within != "") ["--keep-within" ret.within];

  scheduleSubmodule = mkScheduleSubmodule {};
  retentionSubmodule = mkRetentionSubmodule {};

  destinationSubmodule = lib.types.submodule ({name, ...}: let
    dd = config.internal.backup.defaults.destinations.${name} or {};
  in {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = dd.enable or true;
        description = "Whether this backup destination is active by default for matching-scope units.";
      };
      slice = lib.mkOption (
        {
          type = lib.types.str;
          description = "Logical storage slice name (`storage.slices.<name>`) used as the backup repository backend.";
        }
        // lib.optionalAttrs (dd ? slice) {default = dd.slice;}
      );
      scope = lib.mkOption {
        type = lib.types.enum ["host" "shared"];
        default = dd.scope or "host";
        description = "Repository topology scope: `host` isolates backups per hostname, while `shared` stores portable service state across hosts.";
      };
      priority = lib.mkOption {
        type = lib.types.int;
        default = dd.priority or 100;
        description = "Destination priority (lower wins as tie-breaker when multiple destinations hold equally recent snapshots during auto-restore).";
      };
      schedule = lib.mkOption {
        type = mkScheduleSubmodule {defaults = dd.schedule or {};};
        default = {};
        description = "Timer schedule configuration for backups written to this destination.";
      };
      retention = lib.mkOption {
        type = mkRetentionSubmodule {defaults = dd.retention or {};};
        default = {};
        description = "Snapshot retention policy (`restic forget --prune`) enforced on this destination.";
      };
    };
  });

  destinationOverrideSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Per-unit override enabling or disabling this destination independently of its global `enable` setting.";
      };
      schedule = lib.mkOption {
        type = lib.types.nullOr (mkScheduleSubmodule {allowNull = true;});
        default = null;
        description = "Per-unit schedule overrides merged on top of the destination's schedule.";
      };
      retention = lib.mkOption {
        type = lib.types.nullOr (mkRetentionSubmodule {allowNull = true;});
        default = null;
        description = "Per-unit retention overrides merged on top of the destination's retention policy.";
      };
    };
  };

  unitSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether backup jobs and auto-restore (if enabled) are generated for this unit.";
      };
      paths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Filesystem paths included in this unit's backup snapshots.";
      };
      exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Glob patterns excluded from this unit's backups (in addition to global `backup.exclude`).";
      };
      scope = lib.mkOption {
        type = lib.types.enum ["host" "shared"];
        default = "host";
        description = "Backup repository scope used when selecting destinations and repository paths (`host` vs `shared`).";
      };
      destinations = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = null;
        description = "Explicit destination names to target (null selects all enabled destinations matching `scope`, plus any enabled via `destinationOverrides`).";
      };
      destinationOverrides = lib.mkOption {
        type = lib.types.attrsOf destinationOverrideSubmodule;
        default = {};
        description = "Per-destination enablement, schedule, and retention overrides scoped to this backup unit.";
      };
      autoRestore = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to generate a boot-time systemd restore unit that checks each declared path individually (and completion/incomplete tokens in `/var/lib/nixconf-backup/units/<unit>.json`) and selectively restores missing, empty, or interrupted paths from the most recent snapshot across configured destinations.";
      };
      beforeUnits = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["${name}.service"];
        description = "Systemd units ordered after this unit's restore service so service startup waits for state recovery.";
      };
      prepareCommand = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
        description = "Optional shell script executed before each backup snapshot run (for creating consistent database or TSDB snapshots).";
      };
      cleanupCommand = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default = null;
        description = "Optional shell script executed after each backup snapshot run to clean up temporary snapshots or locks.";
      };
    };
  });
in {
  config = {
    internal.backup.helpers = {
      inherit
        mergeBuiltinDefaults
        mkRetentionSubmodule
        mkScheduleSubmodule
        normalizeDestination
        retentionToPruneOpts
        scheduleToTimerConfig
        ;
    };

    contract.backup.types = {
      schedule = scheduleSubmodule;
      retention = retentionSubmodule;
      destination = destinationSubmodule;
      destinationOverride = destinationOverrideSubmodule;
      unit = unitSubmodule;
    };
  };
}
