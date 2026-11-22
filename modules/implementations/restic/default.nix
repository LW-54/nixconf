{
  config,
  lib,
  ...
}: let
  internalRestic = config.internal.restic;
in {
  options.internal.restic = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Internal builder helpers for restic backup jobs, boot-time restore units, and testing checks.";
  };

  config.implementation.restic = {
    contract = "backup";
    description = "Multi-provider restic backup implementation backed by rclone storage slices, per-provider schedules/retention, and boot-time most-recent auto-restore.";

    module = {
      config,
      pkgs,
      self,
      ...
    }: let
      cfg = config.backup;
      backupActive = cfg.enable;
      passwordFile = config.secrets.files.restic-password.path;

      jobs = internalRestic.mkJobs {
        inherit config lib pkgs passwordFile;
        backupLib = self.lib.backup;
        storageLib = self.lib.storage;
      };

      restore = internalRestic.mkRestore {
        inherit config lib pkgs passwordFile;
        inherit (jobs) resolvedUnits;
      };

      testingSuite = internalRestic.mkTesting {
        inherit config lib jobs restore;
      };
      cacheDirs = map (j: "/var/cache/restic-backups-${j.jobName}") jobs.allJobsList;
      backupServiceUnits = map (jName: "restic-backups-${jName}.service") (builtins.attrNames jobs.jobs);
      backupTimerUnits = map (jName: "restic-backups-${jName}.timer") (builtins.attrNames jobs.jobs);
      restoreServiceUnits = map (uName: "${uName}.service") (builtins.attrNames restore.restoreServices);
      allBackupUnits = backupServiceUnits ++ backupTimerUnits ++ restoreServiceUnits;
    in {
      config = lib.mkMerge [
        (lib.mkIf backupActive {
          secrets.files.restic-password = {
            store = "backup/restic";
            key = "password";
            testValue = "test-restic-password";
          };

          storage.activeSlices = jobs.activeSlices;
          persistence.directories = ["/var/lib/nixconf-backup"] ++ cacheDirs;
          backup.exclude = cacheDirs;
          environment.systemPackages = [pkgs.restic] ++ restore.restorePackages;
          services.restic.backups = jobs.jobs;
          systemd.services = jobs.jobServiceOrdering // restore.restoreServices;

          testing.vm.allowedFailedUnits =
            ["restic-backups-*.service"] ++ restore.restoreAllowedFailedUnits;

          monitoring = lib.mkIf (config.monitoring.enable or false) {
            watchedUnits = allBackupUnits;
            logs.journal.units = backupServiceUnits ++ restoreServiceUnits;
            rules.restic = {
              backend = "metrics";
              interval = "1m";
              rules = [
                {
                  alert = "ResticBackupUnitFailed";
                  expr = ''node_systemd_unit_state{name=~"restic-(backups|restore)-.*\\.service",state="failed"} == 1'';
                  "for" = "1m";
                  labels.severity = "critical";
                  annotations = {
                    summary = "Restic unit {{ $labels.name }} failed on {{ $labels.host }}";
                    description = "Restic backup or restore unit {{ $labels.name }} entered failed state on {{ $labels.host }}.";
                  };
                }
                {
                  alert = "ResticBackupStale";
                  expr = ''time() - (node_systemd_timer_last_trigger_seconds{name=~"restic-backups-.*\\.timer"} or vector(time())) > 2 * 24 * 3600'';
                  "for" = "1h";
                  labels.severity = "warning";
                  annotations = {
                    summary = "Restic backup timer {{ $labels.name }} is stale on {{ $labels.host }}";
                    description = "Restic backup timer {{ $labels.name }} has not triggered in over 48 hours on {{ $labels.host }}. It may be permanently deferred due to missing AC power.";
                  };
                }
              ];
            };
            dashboards.backups = {
              title = "Storage & Backups";
              folder = "02 · Infrastructure";
              json = internalRestic.mkDashboard self.lib.monitoring.dashboard;
            };
          };

          resources.units = lib.mkIf (config.resources.enable or false) (
            builtins.listToAttrs (map (jName: {
              name = "restic-backups-${jName}.service";
              value = {
                tier = lib.mkDefault "background";
                deferOnBattery = lib.mkDefault true;
              };
            }) (builtins.attrNames jobs.jobs))
          );
        })

        {
          testing.restic = testingSuite;
        }
      ];
    };
  };
}
