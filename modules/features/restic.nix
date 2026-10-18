{self, ...}: {
  flake.nixosModules.restic = {
    config,
    lib,
    ...
  }: let
    cfg = config.backup;
    resticCfg = config.services.resticBackup;
  in {
    imports = [self.nixosModules.backup];

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

    config = lib.mkIf (cfg.enable && resticCfg.repository != null) {
      sops.secrets.restic-env = lib.mkIf (resticCfg.environmentFile == null) {
        sopsFile = ../../secrets/backup/restic.yaml;
        key = "env";
      };

      sops.secrets.restic-password = lib.mkIf (resticCfg.passwordFile == null) {
        sopsFile = ../../secrets/backup/restic.yaml;
        key = "password";
      };

      services.restic.backups.main = {
        repository = resticCfg.repository;
        environmentFile =
          if resticCfg.environmentFile != null
          then resticCfg.environmentFile
          else config.sops.secrets.restic-env.path;
        passwordFile =
          if resticCfg.passwordFile != null
          then resticCfg.passwordFile
          else config.sops.secrets.restic-password.path;
        paths = cfg.paths;
        exclude = cfg.exclude;
        pruneOpts = cfg.pruneOpts;
        timerConfig = cfg.timerConfig;
        initialize = true;
      };
    };
  };
}
