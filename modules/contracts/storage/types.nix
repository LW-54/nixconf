{
  config,
  lib,
  ...
}: let
  cleanRelPath = p:
    lib.removePrefix "/" (lib.removeSuffix "/" p);

  subpathJoin = base: rel: let
    b = cleanRelPath base;
    r = cleanRelPath rel;
  in
    if b == ""
    then r
    else if r == ""
    then b
    else "${b}/${r}";

  mergeBuiltinDefaults = defaults: user:
    (lib.filterAttrs (k: _: !(user ? ${k})) defaults) // user;

  normalizeDriver = d: {reconcileHook = null;} // d;

  normalizeSlice = s:
    {
      kind = "direct";
      scope = "shared";
      provider = null;
      baseSlice = null;
      upstreams = [];
      path = "";
      readOnly = false;
      secretStore = null;
      protocols =
        {
          ssh = true;
          webdav = false;
          samba = false;
        }
        // (s.protocols or {});
      crypt =
        {
          filenameEncryption = "standard";
          directoryNameEncryption = true;
        }
        // (s.crypt or {});
      union =
        {
          actionPolicy = "epall";
          createPolicy = "epff";
          searchPolicy = "ff";
        }
        // (s.union or {});
    }
    // (builtins.removeAttrs s ["protocols" "crypt" "union"]);

  driverSubmodule = lib.types.submodule ({name, ...}: let
    dd = config.internal.storage.drivers.${name} or {};
  in {
    options = {
      description = lib.mkOption {
        type = lib.types.str;
        default = dd.description or "Custom storage driver '${name}'.";
        description = "Human-readable description of the storage driver capabilities.";
      };
      settingsModule = lib.mkOption {
        type = lib.types.deferredModule;
        default = dd.settingsModule or (_: {});
        defaultText = lib.literalExpression "{...}: {}";
        example = lib.literalExpression "{lib, ...}: { options.bucket = lib.mkOption { type = lib.types.str; }; }";
        description = "NixOS submodule defining strongly typed provider settings for this driver.";
      };
      resolveSlice = lib.mkOption {
        type = lib.types.nullOr (lib.types.functionTo lib.types.raw);
        default = dd.resolveSlice or null;
        example = lib.literalExpression "args: { ... }";
        description = "Function resolving a slice backed by this driver into secrets, rclone configuration, endpoints, and reconciler payloads.";
      };
      reconcileHook = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = dd.reconcileHook or null;
        example = "echo 'Verifying custom storage driver state'";
        description = "Optional bash snippet invoked by `nixconf-storage` during `--check` or `--write` for external custom drivers.";
      };
    };
  });

  providerSubmodule = lib.types.submodule ({name, ...}: let
    dp = config.internal.storage.defaults.providers.${name} or {};
  in {
    options = {
      driver = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = dp.driver or null;
        example = "hetzner-box";
        description = "Name of a registered driver in `storage.drivers` backing this provider instance.";
      };
      secretStore = lib.mkOption {
        type = lib.types.str;
        default = dp.secretStore or "storage/providers/${name}";
        description = "Logical SOPS secret store path (without `secrets/` or `.yaml`) for provider-level credentials.";
      };
      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        apply = s: lib.recursiveUpdate (dp.settings or {}) s;
        example = {boxId = "u711975";};
        description = "Driver-specific settings validated against `storage.drivers.<driver>.settingsModule`.";
      };
    };
  });

  sliceSubmodule = lib.types.submodule ({name, ...}: let
    ds = config.internal.storage.defaults.slices.${name} or {};
  in {
    options = {
      kind = lib.mkOption {
        type = lib.types.enum ["direct" "crypt" "union"];
        default = ds.kind or "direct";
        description = "Slice composition kind: direct provider backing, rclone crypt overlay, or rclone union tiering.";
      };
      scope = lib.mkOption {
        type = lib.types.enum ["shared" "per-host"];
        default = ds.scope or "shared";
        description = "Whether all hosts share one path and credential (`shared`) or isolate paths and SOPS keys per host (`per-host`).";
      };
      provider = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = ds.provider or null;
        example = "hbox";
        description = "Provider instance name from `storage.providers` when `kind` is `direct`.";
      };
      baseSlice = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = ds.baseSlice or null;
        example = "media-cold-raw";
        description = "Underlying slice name encrypted by this layer when `kind` is `crypt`.";
      };
      upstreams = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ds.upstreams or [];
        example = ["media-hot" "media-cold"];
        description = "Ordered list of upstream slice names merged when `kind` is `union`.";
      };
      path = lib.mkOption {
        type = lib.types.str;
        default = ds.path or "";
        example = "media/manga";
        description = "Relative directory or key prefix inside the provider (suffixed by `<hostName>` when `scope` is `per-host`).";
      };
      readOnly = lib.mkOption {
        type = lib.types.bool;
        default = ds.readOnly or false;
        description = "Whether access to this slice is restricted to read-only operations.";
      };
      secretStore = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = ds.secretStore or null;
        example = "storage/slices/manga";
        description = "Optional override for the logical SOPS secret store used by this slice.";
      };
      protocols = {
        ssh = lib.mkOption {
          type = lib.types.bool;
          default = (ds.protocols or {}).ssh or true;
          description = "Whether SSH/SFTP access should be enabled for direct slices supporting protocol flags.";
        };
        webdav = lib.mkOption {
          type = lib.types.bool;
          default = (ds.protocols or {}).webdav or false;
          description = "Whether WebDAV access should be enabled for direct slices supporting protocol flags.";
        };
        samba = lib.mkOption {
          type = lib.types.bool;
          default = (ds.protocols or {}).samba or false;
          description = "Whether SMB/Samba access should be enabled for direct slices supporting protocol flags.";
        };
      };
      crypt = {
        filenameEncryption = lib.mkOption {
          type = lib.types.enum ["standard" "obfuscate" "off"];
          default = (ds.crypt or {}).filenameEncryption or "standard";
          description = "Filename encryption mode applied by `kind = \"crypt\"` slices.";
        };
        directoryNameEncryption = lib.mkOption {
          type = lib.types.bool;
          default = (ds.crypt or {}).directoryNameEncryption or true;
          description = "Whether to encrypt directory names on `kind = \"crypt\"` slices.";
        };
      };
      union = {
        actionPolicy = lib.mkOption {
          type = lib.types.str;
          default = (ds.union or {}).actionPolicy or "epall";
          description = "Rclone union policy governing operations on existing files across upstreams.";
        };
        createPolicy = lib.mkOption {
          type = lib.types.str;
          default = (ds.union or {}).createPolicy or "epff";
          description = "Rclone union policy selecting which upstream receives newly created files and directories.";
        };
        searchPolicy = lib.mkOption {
          type = lib.types.str;
          default = (ds.union or {}).searchPolicy or "ff";
          description = "Rclone union policy selecting which upstream serves reads (`ff` checks fastest/first tier first).";
        };
      };
    };
  });

  mountSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this declarative storage mount should be activated on the host.";
      };
      slice = lib.mkOption {
        type = lib.types.str;
        example = "manga";
        description = "Logical slice name from `storage.slices` to mount at `mountPoint`.";
      };
      mountPoint = lib.mkOption {
        type = lib.types.str;
        example = "/mnt/storage/manga";
        description = "Absolute local filesystem path where the slice will be mounted.";
      };
      protocol = lib.mkOption {
        type = lib.types.enum ["auto" "rclone" "sftp" "webdav" "smb"];
        default = "auto";
        description = "Mount transport preference; `auto` lets the storage implementation pick the optimal protocol.";
      };
      readOnly = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to mount this slice read-only on the local filesystem.";
      };
      automount = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to use systemd on-demand automounting instead of blocking boot.";
      };
      vfsCacheMode = lib.mkOption {
        type = lib.types.enum ["off" "minimal" "writes" "full"];
        default = "writes";
        description = "Rclone VFS cache mode controlling local read/write caching under `/var/cache/rclone`.";
      };
      vfsCacheMaxSize = lib.mkOption {
        type = lib.types.str;
        default = "10G";
        description = "Maximum local disk space allocated to this mount's VFS cache.";
      };
      vfsCacheMaxAge = lib.mkOption {
        type = lib.types.str;
        default = "24h";
        description = "Maximum age before unused objects in the VFS cache are evicted.";
      };
      uid = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        example = 10002;
        description = "Optional numeric user ID owning files inside the mounted FUSE filesystem.";
      };
      gid = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        example = 10002;
        description = "Optional numeric group ID owning files inside the mounted FUSE filesystem.";
      };
      umask = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "002";
        description = "Optional octal umask applied to files and directories inside the FUSE mount.";
      };
    };
  };
in {
  internal.storage.helpers = {
    inherit cleanRelPath subpathJoin mergeBuiltinDefaults normalizeDriver normalizeSlice;
  };

  contract.storage.types = {
    driver = driverSubmodule;
    provider = providerSubmodule;
    slice = sliceSubmodule;
    mount = mountSubmodule;
  };
}
