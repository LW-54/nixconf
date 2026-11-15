{
  internal.restic.mkJobs = {
    config,
    lib,
    pkgs,
    backupLib,
    storageLib,
    passwordFile,
    legacyEnvironmentFile,
  }: let
    cfg = config.backup;
    resticCfg = config.services.resticBackup;

    enabledDeclaredUnits = lib.filterAttrs (_: u: u.enable && u.paths != []) cfg.units;
    allDeclaredUnitPaths = lib.unique (lib.concatMap (u: u.paths) (builtins.attrValues cfg.units));
    unclaimedPaths = builtins.filter (p: !(builtins.elem p allDeclaredUnitPaths)) cfg.paths;

    effectiveUnits =
      enabledDeclaredUnits
      // lib.optionalAttrs (unclaimedPaths != []) (let
        synthName =
          if cfg.units ? system
          then "host"
          else "system";
      in {
        ${synthName} = {
          enable = true;
          paths = unclaimedPaths;
          exclude = [];
          scope = "host";
          destinations = null;
          destinationOverrides = {};
          autoRestore = false;
          beforeUnits = [];
        };
      });

    resolveUnit = uName: uCfg: let
      candNames =
        if uCfg.destinations != null
        then builtins.filter (d: cfg.destinations ? ${d}) uCfg.destinations
        else
          builtins.filter (
            d: cfg.destinations.${d}.scope == uCfg.scope
          ) (builtins.attrNames cfg.destinations);

      destEntries =
        lib.sort (
          a: b:
            if a.priority != b.priority
            then a.priority < b.priority
            else a.dName < b.dName
        ) (
          builtins.concatMap (dName: let
            dCfg = cfg.destinations.${dName};
            ov = uCfg.destinationOverrides.${dName} or {};
            ovEnable = ov.enable or null;
            effEnable =
              if ovEnable != null
              then ovEnable
              else dCfg.enable;
            ovSched =
              if (ov.schedule or null) != null
              then lib.filterAttrs (_: v: v != null) ov.schedule
              else {};
            ovRet =
              if (ov.retention or null) != null
              then lib.filterAttrs (_: v: v != null) ov.retention
              else {};
            effSchedule = dCfg.schedule // ovSched;
            effRetention = dCfg.retention // ovRet;
            repoSubpath =
              if uCfg.scope == "shared"
              then "services/${uName}"
              else "units/${uName}";
            baseRclone =
              if (config.storage.slices or {}) ? ${dCfg.slice}
              then
                (storageLib.resolveSlice {
                  storageCfg = config.storage;
                  sliceName = dCfg.slice;
                  hostName = config.networking.hostName;
                })
                .endpoints
                .rclone
              else "${dCfg.slice}:";
            repository =
              if lib.hasSuffix ":" baseRclone
              then "rclone:${baseRclone}${repoSubpath}"
              else "rclone:${baseRclone}/${repoSubpath}";
          in
            lib.optional effEnable {
              inherit uName dName uCfg dCfg effSchedule effRetention repoSubpath repository;
              inherit (dCfg) slice priority;
              jobName = "${uName}-${dName}";
              timerConfig = backupLib.scheduleToTimerConfig effSchedule;
              pruneOpts = backupLib.retentionToPruneOpts effRetention;
            })
          candNames
        );
    in {
      unit = uCfg;
      destinations = destEntries;
    };

    resolvedUnits = lib.mapAttrs resolveUnit effectiveUnits;
    allJobsList = lib.concatMap (u: u.destinations) (builtins.attrValues resolvedUnits);

    jobAttrs = builtins.listToAttrs (map (j: {
        name = j.jobName;
        value = {
          inherit (j) repository timerConfig pruneOpts;
          inherit passwordFile;
          initialize = true;
          paths = j.uCfg.paths;
          exclude = lib.unique (cfg.exclude ++ j.uCfg.exclude);
          extraOptions = ["rclone.program=${pkgs.rclone}/bin/rclone"];
          rcloneOptions = {
            b2-hard-delete = true;
          };
          extraBackupArgs = [
            "--tag"
            "unit:${j.uName}"
            "--tag"
            "scope:${j.uCfg.scope}"
          ];
        };
      })
      allJobsList);

    legacyJob = lib.optionalAttrs (resticCfg.repository != null) {
      main = {
        inherit (resticCfg) repository;
        inherit passwordFile;
        environmentFile = legacyEnvironmentFile;
        initialize = true;
        inherit (cfg) paths exclude timerConfig pruneOpts;
      };
    };

    jobServiceOrdering =
      builtins.listToAttrs (map (j: {
          name = "restic-backups-${j.jobName}";
          value = {
            after =
              [
                "rclone-config.service"
                "sops-install-secrets.service"
              ]
              ++ lib.optional j.uCfg.autoRestore "restic-restore-${j.uName}.service";
            requires = ["rclone-config.service"];
            environment = {
              RCLONE_CONFIG = "/etc/rclone/rclone.conf";
            };
          };
        })
        allJobsList)
      // lib.optionalAttrs (resticCfg.repository != null) {
        "restic-backups-main" = {
          after = ["sops-install-secrets.service"];
        };
      };

    activeSlices = lib.unique (map (j: j.slice) allJobsList);
  in {
    inherit
      resolvedUnits
      allJobsList
      activeSlices
      jobServiceOrdering
      ;
    jobs = jobAttrs // legacyJob;
  };
}
