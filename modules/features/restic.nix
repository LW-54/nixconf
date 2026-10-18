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
        description = "Path to environment file containing S3/B2 credentials.";
      };

      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to file containing Restic repository password.";
      };
    };

    config = lib.mkIf (cfg.enable && resticCfg.repository != null) {
      services.restic.backups.main = {
        repository = resticCfg.repository;
        environmentFile = resticCfg.environmentFile;
        passwordFile = resticCfg.passwordFile;
        paths = cfg.paths;
        exclude = cfg.exclude;
        pruneOpts = cfg.pruneOpts;
        timerConfig = cfg.timerConfig;
        initialize = true;
      };
    };
  };
}
