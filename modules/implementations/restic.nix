{...}: {
  /**
  Automated snapshot backup, encryption, deduplication, and retention management via Restic.
  */
  implementation.restic = {
    contract = "backup";
    description = "Automated encrypted remote backups using Restic and systemd timers.";
    module = {
      config,
      lib,
      ...
    }: let
      cfg = config.backup;
      resticCfg = config.services.resticBackup;
    in {
      options.services.resticBackup = {
        repository = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Restic repository location URL.";
        };

        environmentFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Path to environment file containing S3/B2 credentials (defaults to SOPS secret).";
        };

        passwordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = "Path to file containing Restic repository password (defaults to SOPS secret).";
        };
      };

      config = lib.mkMerge [
        {
          backup.enable = lib.mkDefault true;
        }
        (lib.mkIf (cfg.enable && resticCfg.repository != null) {
          secrets.files = {
            restic-env = lib.mkIf (resticCfg.environmentFile == null) {
              file = ../../secrets/backup/restic.yaml;
              key = "env";
            };

            restic-password = lib.mkIf (resticCfg.passwordFile == null) {
              file = ../../secrets/backup/restic.yaml;
              key = "password";
            };
          };

          services.restic.backups.main = {
            repository = resticCfg.repository;
            environmentFile =
              if resticCfg.environmentFile != null
              then resticCfg.environmentFile
              else config.secrets.files.restic-env.path;
            passwordFile =
              if resticCfg.passwordFile != null
              then resticCfg.passwordFile
              else config.secrets.files.restic-password.path;
            paths = cfg.paths;
            exclude = cfg.exclude;
            pruneOpts = cfg.pruneOpts;
            timerConfig = cfg.timerConfig;
            initialize = true;
          };

          resources.services.restic-backups-main = lib.mkIf (config.resources.enable or false) {
            profile = "background";
            memory.high = "512M";
            battery = {
              throttleOnBattery = true;
              pauseOnBattery = true;
            };
          };
        })
      ];
    };
  };
}
