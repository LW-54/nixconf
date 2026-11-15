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
        })

        {
          testing.restic = testingSuite;
        }
      ];
    };
  };
}
