{lib, ...}: {
  contract.backup = {
    description = "Automated snapshot backup configuration, inclusion paths, exclusions, and retention rules.";

    options = {
      enable = lib.mkEnableOption "system backup automation contract";

      paths = lib.mkOption {
        type = lib.types.listOf lib.types.path;
        default = [];
        example = ["/var/lib/example-service"];
        description = ''
          List of absolute filesystem directory or file paths to include in the backup snapshot.
          Aggregated across all active service modules via `mkConfig`.
        '';
      };

      exclude = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["**/.cache"];
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

    lib = {
      defaultTimerConfig = {
        docstring = ''
          Default systemd timer configuration for automated backup operations.
          Executes daily at 04:00 with persistent timer catch-up.

          # Type
          ```
          defaultTimerConfig :: AttrSet
          ```
        '';
        value = {
          OnCalendar = "04:00";
          Persistent = true;
        };
      };

      defaultPruneOpts = {
        docstring = ''
          Default snapshot retention rules passed to the restic prune command.
          Preserves 7 daily, 4 weekly, and 12 monthly snapshots.

          # Type
          ```
          defaultPruneOpts :: [String]
          ```
        '';
        value = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
        ];
      };
    };
  };
}
