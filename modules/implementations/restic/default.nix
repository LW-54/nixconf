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
        inherit lib pkgs passwordFile;
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

      promTarget = refId: expr: legendFormat: {
        inherit expr legendFormat refId;
        datasource = {
          type = "prometheus";
          uid = "prometheus";
        };
      };

      lokiTarget = refId: expr: legendFormat: {
        inherit expr legendFormat refId;
        datasource = {
          type = "loki";
          uid = "loki";
        };
      };

      backupsDashboard = {
        uid = "nixconf-backups-storage";
        title = "Backup & Storage Health";
        tags = ["nixconf" "restic" "snapshot" "rclone"];
        timezone = "browser";
        schemaVersion = 39;
        refresh = "1m";
        time = {
          from = "now-24h";
          to = "now";
        };
        panels = [
          {
            id = 1;
            title = "Failed Backup, Snapshot & Mount Units";
            type = "table";
            gridPos = {
              h = 7;
              w = 12;
              x = 0;
              y = 0;
            };
            targets = [
              (promTarget "A" ''node_systemd_unit_state{name=~"(restic-.*|host-snapshot-.*|rclone-config|storage-drift-check)\\.service|.*\\.mount",state="failed"} == 1'' "{{host}}: {{name}}")
            ];
          }
          {
            id = 2;
            title = "Active Backup & Snapshot Timers";
            type = "table";
            gridPos = {
              h = 7;
              w = 12;
              x = 12;
              y = 0;
            };
            targets = [
              (promTarget "A" ''node_systemd_unit_state{name=~"(restic-backups-.*|host-snapshot-.*)\\.timer",state="active"} == 1'' "{{host}}: {{name}}")
            ];
          }
          {
            id = 3;
            title = "Backup, Snapshot & Storage Logs";
            type = "logs";
            gridPos = {
              h = 12;
              w = 24;
              x = 0;
              y = 7;
            };
            options = {
              showTime = true;
              showLabels = true;
              enableLogDetails = true;
              wrapLogMessage = true;
            };
            targets = [
              (lokiTarget "A" ''{job="systemd-journal", unit=~"(restic-.*|host-snapshot-.*|rclone-config|storage-drift-check)\\.service"}'' "")
            ];
          }
        ];
      };
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
              backend = "prometheus";
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
              ];
            };
            dashboards.backups = {
              title = "Backup & Storage Health";
              folder = "Storage & Backups";
              json = backupsDashboard;
            };
          };
        })

        {
          testing.restic = testingSuite;
        }
      ];
    };
  };
}
