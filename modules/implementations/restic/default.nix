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
      resticCfg = config.services.resticBackup;
      backupActive = cfg.enable || resticCfg.repository != null;

      passwordFile =
        if resticCfg.passwordFile != null
        then resticCfg.passwordFile
        else config.secrets.files.restic-password.path;

      legacyEnvironmentFile =
        if resticCfg.environmentFile != null
        then resticCfg.environmentFile
        else config.secrets.files.restic-env.path;

      jobs = internalRestic.mkJobs {
        inherit config lib pkgs passwordFile legacyEnvironmentFile;
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
    in {
      options.services.resticBackup = {
        repository = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Optional legacy monolithic restic repository URL (`restic-backups-main`).";
        };
        environmentFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Environment file passed to legacy monolithic `restic-backups-main` (defaults to SOPS `backup/restic` `env` secret).";
        };
        passwordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Password file used to encrypt restic repositories (defaults to SOPS `backup/restic` `password` secret).";
        };
      };

      config = lib.mkMerge [
        (lib.mkIf backupActive {
          secrets.files =
            lib.optionalAttrs (resticCfg.passwordFile == null) {
              restic-password = {
                store = "backup/restic";
                key = "password";
                testValue = "test-restic-password";
              };
            }
            // lib.optionalAttrs (resticCfg.repository != null && resticCfg.environmentFile == null) {
              restic-env = {
                store = "backup/restic";
                key = "env";
                testValue = "RESTIC_TEST=1";
              };
            };

          storage.activeSlices = jobs.activeSlices;
          persistence.directories = ["/var/lib/nixconf-backup"];
          environment.systemPackages = restore.restorePackages;
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
