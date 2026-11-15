{
  config,
  lib,
  ...
}: let
  helpers = config.internal.backup.helpers;
  types = config.contract.backup.types;
  normalizedDestinations =
    builtins.mapAttrs (_: helpers.normalizeDestination) config.internal.backup.defaults.destinations;
in {
  options.internal.backup = {
    defaults = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      description = "Default destination presets seeded into `backup.destinations`.";
    };
    helpers = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      description = "Shared schedule, retention, and normalization helpers for the backup contract.";
    };
  };

  config = {
    contract.backup = {
      description = "Declarative multi-provider backup contract separating per-provider schedules/retention, host vs shared repository scopes, per-service units, and boot-time most-recent auto-restore.";

      options = {
        enable = lib.mkEnableOption "declarative backup configuration";

        paths = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          example = ["/persist/etc"];
          description = "Host-level filesystem paths included in synthetic `system` backups when not claimed by any declared `backup.units` entry.";
        };

        exclude = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          example = ["*.tmp" "cache/*"];
          description = "Global exclusion patterns applied across backup units.";
        };

        destinations = lib.mkOption {
          type = lib.types.attrsOf types.destination;
          default = {};
          apply = helpers.mergeBuiltinDefaults normalizedDestinations;
          defaultText = lib.literalExpression "{ hbox-host = ...; gdrive-host = ...; b2-host = { enable = false; ... }; hbox-shared = ...; gdrive-shared = ...; b2-shared = { enable = false; ... }; }";
          example = lib.literalExpression "{ b2-shared.enable = true; gdrive-host.retention.daily = 60; }";
          description = "Named backup destinations parameterized by backing storage slice, `host`/`shared` scope, priority, schedule, and per-tier retention.";
        };

        units = lib.mkOption {
          type = lib.types.attrsOf types.unit;
          default = {};
          example = lib.literalExpression "{ vaultwarden = { scope = \"shared\"; paths = [\"/var/lib/vaultwarden\"]; destinationOverrides.b2-shared.enable = true; }; }";
          description = "Logical backup units with independent paths, scopes, destination overrides, and boot-time most-recent auto-restore configuration.";
        };
      };

      mkOption = {
        enable ? true,
        paths ? [],
        exclude ? [],
        scope ? "host",
        destinations ? null,
        destinationOverrides ? {},
        autoRestore ? true,
        beforeUnits ? null,
      }: {
        backup = {
          enable =
            lib.mkEnableOption "automated backups for this service"
            // {default = enable;};

          paths = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = paths;
            description = "Filesystem paths belonging to this service to include in backups.";
          };

          exclude = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = exclude;
            description = "Glob patterns excluded from backups for this service.";
          };

          scope = lib.mkOption {
            type = lib.types.enum ["host" "shared"];
            default = scope;
            description = "Repository scope (`host` per-machine vs `shared` portable across hosts) used when selecting backup destinations.";
          };

          destinations = lib.mkOption {
            type = lib.types.nullOr (lib.types.listOf lib.types.str);
            default = destinations;
            description = "Explicit destination names overriding scope-based destination selection (null selects enabled destinations matching `scope`).";
          };

          destinationOverrides = lib.mkOption {
            type = lib.types.attrsOf types.destinationOverride;
            default = destinationOverrides;
            description = "Per-destination enablement, schedule, and retention overrides for this service.";
          };

          autoRestore = lib.mkOption {
            type = lib.types.bool;
            default = autoRestore;
            description = "Whether to automatically restore missing, empty, or interrupted service paths on boot from the most recent snapshot across configured destinations.";
          };

          beforeUnits = lib.mkOption {
            type = lib.types.nullOr (lib.types.listOf lib.types.str);
            default = beforeUnits;
            description = "Systemd units ordered after this service's boot-time restore unit (null defaults to `[ \"<unit>.service\" ]`).";
          };
        };
      };

      mkConfig = {
        cfg,
        name ? null,
        ...
      }: let
        b = cfg.backup;
        unitName =
          if name != null
          then name
          else if (cfg.subdomain or null) != null && cfg.subdomain != ""
          then cfg.subdomain
          else if b.paths != []
          then builtins.baseNameOf (builtins.head b.paths)
          else throw "backup.mkConfig: cannot infer unit name when `name`, `cfg.subdomain`, and `cfg.backup.paths` are all empty.";
      in
        lib.mkIf ((cfg.enable or true) && b.enable) {
          backup = {
            enable = lib.mkDefault true;
            paths = lib.optionals (b.scope == "host") b.paths;
            inherit (b) exclude;
            units.${unitName} =
              {
                inherit (b) enable paths exclude scope destinations destinationOverrides autoRestore;
              }
              // lib.optionalAttrs (b.beforeUnits != null) {
                inherit (b) beforeUnits;
              };
          };
        };

      lib = {
        retentionToPruneOpts = {
          docstring = ''
            Convert a structured retention policy attrset into `restic forget --prune` CLI flags.

            # Type
            ```
            retentionToPruneOpts :: Retention -> [String]
            ```
          '';
          value = helpers.retentionToPruneOpts;
        };

        scheduleToTimerConfig = {
          docstring = ''
            Convert a structured backup schedule attrset into systemd `timerConfig` attributes.

            # Type
            ```
            scheduleToTimerConfig :: Schedule -> Attrs
            ```
          '';
          value = helpers.scheduleToTimerConfig;
        };
      };
    };
  };
}
