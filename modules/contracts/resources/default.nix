{
  config,
  lib,
  ...
}: let
  types = config.contract.resources.types;
  helpers = config.internal.resources.helpers;
  profiles = config.internal.resources.profiles;

  formatLimits = cfg: let
    parts =
      lib.optional ((cfg.cpu.weight or null) != null) "CPU:${toString cfg.cpu.weight}"
      ++ lib.optional ((cfg.cpu.quota or null) != null) "Quota:${cfg.cpu.quota}"
      ++ lib.optional ((cfg.io.weight or null) != null) "IO:${toString cfg.io.weight}"
      ++ lib.optional ((cfg.memory.min or null) != null) "MemMin:${toString cfg.memory.min}"
      ++ lib.optional ((cfg.memory.low or null) != null) "MemLow:${toString cfg.memory.low}"
      ++ lib.optional ((cfg.memory.high or null) != null) "MemHigh:${toString cfg.memory.high}"
      ++ lib.optional ((cfg.memory.max or null) != null) "MemMax:${toString cfg.memory.max}"
      ++ lib.optional ((cfg.oom.preference or null) != null && cfg.oom.preference != "none") "OOM:${cfg.oom.preference}"
      ++ lib.optional ((cfg.oom.kill or null) == true) "OOMKill:${
        if (cfg.oom.pressureLimit or null) != null
        then cfg.oom.pressureLimit
        else "default"
      }"
      ++ lib.optional ((cfg.oom.scoreAdjust or null) != null) "Score:${toString cfg.oom.scoreAdjust}";
  in
    if parts == []
    then "—"
    else lib.concatStringsSep ", " parts;
in {
  contract.resources = {
    description = "Declarative compute tiering, cgroups v2 limits, OOM ordering, power-aware throttling, local disk volumes, and remote storage budgets.";

    options = {
      enable = lib.mkEnableOption "declarative system resource allocation contract";

      profile = lib.mkOption {
        type = types.profile;
        default = "server";
        example = "workstation";
        description = "Host workload profile preset (`server` or `workstation`) seeding default tier weights and power policy.";
      };

      tiers = lib.mkOption {
        type = lib.types.attrsOf types.tier;
        default = {};
        example = {
          background.memory.high = "40%";
        };
        description = "Workload resource tiers mapped directly to top-level systemd `.slice` units under `-.slice`.";
      };

      units = lib.mkOption {
        type = lib.types.attrsOf types.unit;
        default = {};
        example = {
          "loki.service" = {
            tier = "standard";
            memory.max = "1G";
          };
        };
        description = "Per-systemd-unit resource allocations assigning `.service` or `.mount` units to workload tiers with optional overrides.";
      };

      oom = lib.mkOption {
        type = types.oom;
        default = {};
        example = {
          enable = true;
          swapKill = true;
        };
        description = "Host-wide `systemd-oomd` userspace out-of-memory killer configuration.";
      };

      power = lib.mkOption {
        type = types.power;
        default = {};
        example = {
          enable = true;
        };
        description = "Power-aware battery throttling and `deferOnBattery` gating configuration.";
      };

      disk = lib.mkOption {
        type = types.disk;
        default = {};
        example = {
          journalMaxSize = "512M";
          nixMinFree = "1G";
        };
        description = "System-wide local disk caps and minimum free-space headroom policies for journald and Nix.";
      };

      volumes = lib.mkOption {
        type = lib.types.attrsOf types.volume;
        default = {};
        example = {
          headroom = {
            mode = "reserved";
            size = "5G";
          };
          loki-data = {
            mode = "reserved";
            size = "10G";
            mountPoint = "/var/lib/loki";
          };
        };
        description = "Dedicated local disk space allocations, preallocated quota volumes, and unmounted space reservations.";
      };

      storageBudgets = lib.mkOption {
        type = lib.types.attrsOf types.storageBudget;
        default = {};
        example = {
          hbox-backup-host = {
            maxSize = "500G";
            warnPercent = 85;
          };
        };
        description = "Declarative capacity budgets and alerting thresholds for remote `storage.slices`.";
      };
    };

    mkOption = {
      enable ? true,
      tier ? "standard",
      units ? null,
      deferOnBattery ? false,
      cpu ? {},
      memory ? {},
      io ? {},
      tasksMax ? null,
      oom ? {},
    }: {
      resources =
        {
          enable = lib.mkEnableOption "resource allocation for this service" // {default = enable;};

          tier = lib.mkOption {
            type = lib.types.str;
            default = tier;
            description = "Workload resource tier (`resources.tiers.<name>`) assigned to this service's systemd unit(s).";
          };

          units = lib.mkOption {
            type = lib.types.nullOr (lib.types.listOf lib.types.str);
            default = units;
            description = "Explicit systemd unit names managed for this service (`null` infers from `monitoring.units`).";
          };

          deferOnBattery = lib.mkOption {
            type = lib.types.bool;
            default = deferOnBattery;
            description = "Whether to defer execution of this service's unit(s) while running on battery power.";
          };
        }
        // helpers.mkLimitsOptions {
          defaults = {inherit cpu memory io tasksMax oom;};
        };
    };

    mkConfig = {
      config,
      cfg,
      units ? null,
    }: let
      res = cfg.resources or {};
      enabled = (config.resources.enable or false) && (cfg.enable or true) && (res.enable or false);
      targetUnits =
        if (res.units or null) != null
        then res.units
        else if units != null
        then units
        else (cfg.monitoring.units or []);
    in
      lib.mkIf (enabled && targetUnits != []) {
        resources.units = lib.genAttrs targetUnits (_: {
          enable = true;
          inherit (res) tier deferOnBattery cpu memory io tasksMax oom;
        });
      };

    lib = {
      profiles = {
        docstring = ''
          Built-in host workload resource tier profiles (`server` and `workstation`) mapped to systemd slices.

          # Type
          ```
          profiles :: AttrSet
          ```
        '';
        value = profiles;
      };

      sliceName = {
        docstring = ''
          Normalize a resource tier name into its canonical systemd `.slice` unit name.

          # Inputs

          `tier`
          : Workload tier name (with or without `.slice` suffix).

          # Type
          ```
          sliceName :: String -> String
          ```

          # Examples
          ```nix
          resources.sliceName "critical" # => "critical.slice"
          ```
        '';
        value = helpers.sliceName;
      };

      toBytes = {
        docstring = ''
          Convert an integer or byte-size string (`B`, `K`, `M`, `G`, `T`, `P`) into an exact integer byte count.

          # Inputs

          `x`
          : Non-negative integer bytes or size string such as `"512M"` or `"1.5G"`.

          # Type
          ```
          toBytes :: (Int | String) -> Int
          ```

          # Examples
          ```nix
          resources.toBytes "512M" # => 536870912
          ```
        '';
        value = helpers.toBytes;
      };
    };
  };

  docs.sections.host.resources = {
    order = 47;
    content = ctx: let
      res = ctx.query.eval ctx.name ["resources"] {};
      enabled = res.enable or false;
      tiers = res.tiers or {};
      units = lib.filterAttrs (_: u: u.enable or true) (res.units or {});
      volumes = lib.filterAttrs (_: v: v.enable or true) (res.volumes or {});
      budgets = lib.filterAttrs (_: b: b.enable or true) (res.storageBudgets or {});
      unitNamesForTier = tName:
        lib.sort (a: b: a < b) (builtins.attrNames (lib.filterAttrs (_: u: (u.tier or "standard") == tName) units));
      tierNames = lib.sort (
        a: b: let
          wa =
            if (tiers.${a}.cpu.weight or null) != null
            then tiers.${a}.cpu.weight
            else 100;
          wb =
            if (tiers.${b}.cpu.weight or null) != null
            then tiers.${b}.cpu.weight
            else 100;
        in
          if wa != wb
          then wa > wb
          else a < b
      ) (builtins.attrNames tiers);
    in
      if !enabled || tiers == {}
      then null
      else
        ctx.md.blocks [
          ''
            ## Resource Allocation

            Workload tiering, OOM protection, and capacity policies enforced via ${ctx.instanceLink "contract" "resources"}:

            ${ctx.md.bullets [
              "**Profile**: `${res.profile or "server"}`"
              "**Power-Aware Throttling**: `${lib.boolToString (res.power.enable or false)}`"
              "**systemd-oomd**: `${lib.boolToString (res.oom.enable or true)}` (swap kill: `${lib.boolToString (res.oom.swapKill or true)}`)"
            ]}

            ### Workload Tiers

            ${ctx.md.table {
              headers = ["Tier (`Slice`)" "Policy" "On Battery" "Assigned Units"];
              columns = [
                (t: "`${helpers.sliceName t}`")
                (t: formatLimits tiers.${t})
                (t:
                  if tiers.${t}.onBattery.enable or false
                  then formatLimits tiers.${t}.onBattery
                  else "—")
                (t: let
                  uList = unitNamesForTier t;
                in
                  if uList == []
                  then "—"
                  else lib.concatMapStringsSep ", " (u: "`${u}`") uList)
              ];
              rows = tierNames;
            }}
          ''
          (
            if volumes == {}
            then null
            else ''
              ### Local Disk Volumes

              ${ctx.md.table {
                headers = ["Volume" "Mode" "Size" "Mountpoint"];
                columns = [
                  (v: "`${v}`")
                  (v: "`${volumes.${v}.mode}`")
                  (v: "`${toString volumes.${v}.size}`")
                  (v:
                    if (volumes.${v}.mountPoint or null) != null
                    then "`${volumes.${v}.mountPoint}`"
                    else "*unmounted reservation*")
                ];
                rows = builtins.attrNames volumes;
              }}
            ''
          )
          (
            if budgets == {}
            then null
            else ''
              ### Remote Storage Budgets

              ${ctx.md.table {
                headers = ["Storage Slice" "Budget" "Warn Threshold" "Check Interval"];
                columns = [
                  (b: "`${b}`")
                  (b: "`${toString budgets.${b}.maxSize}`")
                  (b: "`${toString budgets.${b}.warnPercent}%`")
                  (b: "`${budgets.${b}.interval}`")
                ];
                rows = builtins.attrNames budgets;
              }}
            ''
          )
        ];
  };
}
