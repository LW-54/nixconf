{
  config,
  lib,
  ...
}: let
  helpers = config.internal.storage.helpers;
  types = config.contract.storage.types;
  normalizedDrivers = builtins.mapAttrs (_: helpers.normalizeDriver) config.internal.storage.drivers;
  normalizedSlices = builtins.mapAttrs (_: helpers.normalizeSlice) config.internal.storage.defaults.slices;
in {
  options.internal.storage = {
    drivers = lib.mkOption {
      type = lib.types.attrsOf lib.types.raw;
      default = {};
      description = "Built-in storage drivers registered by internal driver modules.";
    };
    defaults = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      description = "Default provider and slice catalog definitions.";
    };
    helpers = lib.mkOption {
      type = lib.types.lazyAttrsOf lib.types.raw;
      default = {};
      description = "Shared path and normalization helpers for the storage contract.";
    };
  };

  config = {
    contract.storage = {
      description = "Declarative multi-provider storage contract separating open driver definitions, logical providers, host/shared slices, and mount requests.";

      options = {
        enable = lib.mkEnableOption "declarative multi-provider storage management";

        drivers = lib.mkOption {
          type = lib.types.attrsOf types.driver;
          default = {};
          apply = helpers.mergeBuiltinDefaults normalizedDrivers;
          defaultText = lib.literalExpression "{ hetzner-box = ...; gdrive = ...; b2 = ...; s3 = ...; }";
          example = lib.literalExpression "{ garage = { description = \"...\"; settingsModule = ...; resolveSlice = ...; }; }";
          description = "Open registry of storage driver modules implementing `settingsModule` and `resolveSlice` (pre-seeded with built-in drivers).";
        };

        providers = lib.mkOption {
          type = lib.types.attrsOf types.provider;
          default = {};
          apply = helpers.mergeBuiltinDefaults config.internal.storage.defaults.providers;
          defaultText = lib.literalExpression "{ hbox = ...; gdrive = ...; b2 = ...; }";
          example = lib.literalExpression "{ hbox-archive = { driver = \"hetzner-box\"; settings.boxId = \"u999999\"; }; }";
          description = "Named storage provider instances parameterized by an open `driver` and isolated per-instance SOPS secret store.";
        };

        slices = lib.mkOption {
          type = lib.types.attrsOf types.slice;
          default = {};
          apply = helpers.mergeBuiltinDefaults normalizedSlices;
          defaultText = lib.literalExpression "{ uchiyomi = ...; hbox-backup-host = ...; hbox-backup-shared = ...; gdrive = ...; gdrive-backup-host = ...; gdrive-backup-shared = ...; b2 = ...; b2-backup-host = ...; b2-backup-shared = ...; }";
          example = lib.literalExpression "{ shared-docs = { kind = \"direct\"; scope = \"shared\"; provider = \"hbox\"; path = \"docs\"; }; }";
          description = "Logical storage slices across direct providers, rclone crypt layers, and union tiers, with `shared` or `per-host` scoping.";
        };

        mounts = lib.mkOption {
          type = lib.types.attrsOf types.mount;
          default = {};
          example = {
            manga = {
              slice = "manga";
              mountPoint = "/mnt/storage/manga";
              protocol = "rclone";
            };
          };
          description = "Declarative POSIX mount requests consumed by storage implementations (`implementation.rclone`).";
        };

        activeSlices = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          example = ["hbox-backup-host"];
          description = "Additional non-mounted slices required on this host (such as direct `restic` backup targets).";
        };

        driftCheck = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "Whether to enable periodic drift verification for declared storage providers and SOPS secret stores.";
          };
          onCalendar = lib.mkOption {
            type = lib.types.str;
            default = "daily";
            description = "Systemd OnCalendar expression controlling periodic storage drift checks.";
          };
        };
      };

      mkOption = {
        enable ? false,
        slice ? null,
        mountPoint ? null,
        protocol ? "auto",
        readOnly ? false,
        automount ? true,
        vfsCacheMode ? "writes",
        uid ? null,
        gid ? null,
        umask ? null,
      }: {
        storage = {
          enable = lib.mkEnableOption "declarative remote storage integration for this service" // {default = enable;};
          slice = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = slice;
            example = "uchiyomi";
            description = "Logical storage slice name from `storage.slices` consumed by this service.";
          };
          mountPoint = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = mountPoint;
            example = "/var/lib/example/media";
            description = "Absolute path where this service expects its storage slice mounted.";
          };
          protocol = lib.mkOption {
            type = lib.types.enum ["auto" "rclone" "sftp" "webdav" "smb"];
            default = protocol;
            description = "Preferred transport protocol when mounting this service's storage slice.";
          };
          readOnly = lib.mkOption {
            type = lib.types.bool;
            default = readOnly;
            description = "Whether the service mount should enforce read-only access.";
          };
          automount = lib.mkOption {
            type = lib.types.bool;
            default = automount;
            description = "Whether systemd should lazily mount this storage slice on directory access.";
          };
          vfsCacheMode = lib.mkOption {
            type = lib.types.enum ["off" "minimal" "writes" "full"];
            default = vfsCacheMode;
            description = "Rclone VFS cache mode for this service's storage mount.";
          };
          uid = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = uid;
            example = 10002;
            description = "Optional numeric user ID owning files inside this service's storage mount.";
          };
          gid = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = gid;
            example = 10002;
            description = "Optional numeric group ID owning files inside this service's storage mount.";
          };
          umask = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = umask;
            example = "002";
            description = "Optional octal umask applied to files and directories inside this service's storage mount.";
          };
        };
      };

      mkConfig = {
        config,
        cfg,
        name ? null,
      }: let
        sCfg = cfg.storage or {};
        enabled = sCfg.enable or false;
        mountName =
          if name != null
          then name
          else sCfg.slice or "storage";
      in
        lib.mkIf enabled {
          assertions = [
            {
              assertion = sCfg.slice != null && sCfg.mountPoint != null;
              message = "Service using `storage.mkConfig` requires both `storage.slice` and `storage.mountPoint` when enabled (host: ${config.networking.hostName}).";
            }
          ];
          storage = {
            enable = lib.mkDefault true;
            mounts.${mountName} = {
              enable = true;
              inherit (sCfg) slice mountPoint protocol readOnly automount vfsCacheMode uid gid umask;
            };
          };
        };
    };
  };
}
