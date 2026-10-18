{...}: {
  flake.nixosModules.backup = {
    lib,
    ...
  }: {
    key = "contracts-backup";

    options.backup = {
      enable = lib.mkEnableOption "system backup automation";

      paths = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
        description = "List of filesystem paths to include in automated backups.";
      };

      exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "List of file/directory patterns to exclude from backups.";
      };

      timerConfig = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {
          OnCalendar = "04:00";
          Persistent = true;
        };
        description = "Systemd timer configuration for automated backups.";
      };

      pruneOpts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
        ];
        description = "Snapshot retention and prune rules.";
      };
    };
  };
}
