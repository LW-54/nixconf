{lib, ...}: {
  mkContract.backup = {
    options = {
      enable = lib.mkEnableOption "system backup automation contract" // {default = true;};

      paths = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
        description = ''
          List of absolute filesystem directory or file paths to include in the backup snapshot.
          Aggregated across all active service modules via `mkConfig`.
        '';
      };

      exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = ''
          List of glob patterns, file paths, or directories to explicitly exclude
          from backup snapshots (e.g. cache directories, transient sockets).
        '';
      };

      timerConfig = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {
          OnCalendar = "04:00";
          Persistent = true;
        };
        description = ''
          Systemd timer specification governing when automated backup snapshots run.
          Defaults to executing daily at 04:00 with persistence enabled.
        '';
      };

      pruneOpts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
        ];
        description = ''
          Command-line argument rules passed to the backup backend pruning command
          to enforce snapshot retention and prevent unbounded remote storage usage.
        '';
      };
    };

    extraLib = {
      defaultTimerConfig = {
        OnCalendar = "04:00";
        Persistent = true;
      };
      defaultPruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 4"
        "--keep-monthly 12"
      ];
    };
  };
}
