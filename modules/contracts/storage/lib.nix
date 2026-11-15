{
  config,
  lib,
  ...
}: let
  helpers = config.internal.storage.helpers;

  evalDriverSettingsFn = {
    driver,
    providerName,
    providerCfg,
  }:
    (lib.evalModules {
      modules = [
        driver.settingsModule
        {
          _file = "storage.providers.${providerName}.settings";
          config = providerCfg.settings;
        }
      ];
    })
    .config;

  resolveProviderDriver = storageCfg: providerName: providerCfg: let
    driverName =
      if providerCfg.driver != null
      then providerCfg.driver
      else throw "storage.providers.${providerName}: `driver` must be set.";
    driver =
      storageCfg.drivers.${driverName}
      or (throw "storage.providers.${providerName}: unknown driver '${driverName}'.");
    settings = evalDriverSettingsFn {
      inherit driver providerName providerCfg;
    };
  in {
    inherit driverName driver settings;
  };

  dedupSecrets = secrets: let
    step = acc: item: let
      id = "${item.store}:${item.key}";
    in
      if builtins.elem id acc.seen
      then acc
      else {
        seen = acc.seen ++ [id];
        list = acc.list ++ [item];
      };
  in
    (builtins.foldl' step {
        seen = [];
        list = [];
      }
      secrets)
    .list;

  dedupReconcile = items: let
    step = acc: item: let
      id =
        if item.kind == "hetzner-snapshot-plan"
        then "plan:${item.providerName}:${item.boxId}"
        else if item.kind == "hetzner-subaccount"
        then "sub:${item.providerName}:${item.boxId}:${item.subaccount.description}"
        else "sops:${item.providerName or "none"}:${item.sliceName}:${item.secretStore}";
    in
      if builtins.elem id acc.seen
      then acc
      else {
        seen = acc.seen ++ [id];
        list = acc.list ++ [item];
      };
  in
    (builtins.foldl' step {
        seen = [];
        list = [];
      }
      items)
    .list;

  remoteTargetFor = slice: let
    subdir = slice.rcloneRemote.subdir or null;
  in
    if subdir != null && subdir != ""
    then "${slice.rcloneRemoteName}:${subdir}"
    else "${slice.rcloneRemoteName}:";

  resolveSliceInner = {
    storageCfg,
    sliceName,
    hostName,
    placeholders ? (store: key: "<sops:${store}:${key}>"),
    visited ? [],
  }: let
    _cycleCheck =
      if builtins.elem sliceName visited
      then throw "storage: cyclic slice reference detected at '${sliceName}' (chain: ${lib.concatStringsSep " -> " (visited ++ [sliceName])})."
      else true;
    sliceCfg =
      storageCfg.slices.${sliceName}
      or (throw "storage: unknown slice '${sliceName}' referenced on host '${hostName}'.");
    rcloneRemoteName = sliceName;
    defaultSecretStore =
      if sliceCfg.secretStore != null
      then sliceCfg.secretStore
      else if sliceCfg.scope == "per-host"
      then "storage/hosts/${hostName}/${sliceName}"
      else "storage/slices/${sliceName}";
  in
    assert _cycleCheck;
      if sliceCfg.kind == "direct"
      then let
        providerName =
          if sliceCfg.provider != null
          then sliceCfg.provider
          else throw "storage.slices.${sliceName}: `provider` must be set when `kind = \"direct\"`.";
        providerCfg =
          storageCfg.providers.${providerName}
          or (throw "storage.slices.${sliceName}: unknown provider '${providerName}'.");
        resolvedDriver = resolveProviderDriver storageCfg providerName providerCfg;
        inherit (resolvedDriver) driver settings;
        resolveFn =
          if driver.resolveSlice != null
          then driver.resolveSlice
          else throw "storage.drivers.${resolvedDriver.driverName}: `resolveSlice` must be defined.";
        resolvedPath =
          if sliceCfg.scope == "per-host"
          then helpers.subpathJoin sliceCfg.path hostName
          else helpers.cleanRelPath sliceCfg.path;
      in
        resolveFn {
          inherit (resolvedDriver) driverName;
          inherit providerName providerCfg settings sliceName sliceCfg hostName placeholders resolvedPath rcloneRemoteName;
          secretStore = defaultSecretStore;
        }
      else if sliceCfg.kind == "crypt"
      then let
        baseName =
          if sliceCfg.baseSlice != null
          then sliceCfg.baseSlice
          else throw "storage.slices.${sliceName}: `baseSlice` must be set when `kind = \"crypt\"`.";
        base = resolveSliceInner {
          inherit storageCfg hostName placeholders;
          sliceName = baseName;
          visited = visited ++ [sliceName];
        };
        cryptSecrets = [
          {
            store = defaultSecretStore;
            key = "crypt-password";
            inherit (sliceCfg) scope;
            optional = false;
            generate = "random-password";
            description = "Rclone crypt primary password for slice '${sliceName}'.";
          }
          {
            store = defaultSecretStore;
            key = "crypt-password2";
            inherit (sliceCfg) scope;
            optional = false;
            generate = "random-password";
            description = "Rclone crypt salt password (password2) for slice '${sliceName}'.";
          }
        ];
        cryptTargetSubpath =
          if sliceCfg.scope == "per-host"
          then helpers.subpathJoin sliceCfg.path hostName
          else helpers.cleanRelPath sliceCfg.path;
        baseSubdir =
          helpers.subpathJoin (
            if (base.rcloneRemote.subdir or null) != null
            then base.rcloneRemote.subdir
            else ""
          )
          cryptTargetSubpath;
        baseRemoteTarget =
          if baseSubdir == ""
          then "${base.rcloneRemoteName}:"
          else "${base.rcloneRemoteName}:${baseSubdir}";
      in {
        driverName = "crypt";
        inherit (base) providerName;
        inherit sliceName rcloneRemoteName;
        secretStore = defaultSecretStore;
        resolvedPath = helpers.subpathJoin base.resolvedPath cryptTargetSubpath;
        inherit (sliceCfg) scope kind;
        hostName =
          if sliceCfg.scope == "per-host"
          then hostName
          else null;
        rcloneRemote = {
          name = rcloneRemoteName;
          type = "crypt";
          subdir = null;
          options = {
            remote = baseRemoteTarget;
            filename_encryption = sliceCfg.crypt.filenameEncryption;
            directory_name_encryption = lib.boolToString sliceCfg.crypt.directoryNameEncryption;
            password = placeholders defaultSecretStore "crypt-password";
            password2 = placeholders defaultSecretStore "crypt-password2";
          };
        };
        endpoints = {
          rclone = "${rcloneRemoteName}:";
          restic = "rclone:${rcloneRemoteName}:";
          sftp = null;
          webdav = null;
          smb = null;
        };
        secrets = dedupSecrets (base.secrets ++ cryptSecrets);
        reconcile =
          base.reconcile
          ++ [
            {
              kind = "sops-secret";
              inherit (base) providerName;
              inherit sliceName;
              secretStore = defaultSecretStore;
              secrets = cryptSecrets;
            }
          ];
      }
      else let
        upstreamNames =
          if sliceCfg.upstreams != []
          then sliceCfg.upstreams
          else throw "storage.slices.${sliceName}: `upstreams` must be non-empty when `kind = \"union\"`.";
        resolvedUpstreams =
          map (
            uName:
              resolveSliceInner {
                inherit storageCfg hostName placeholders;
                sliceName = uName;
                visited = visited ++ [sliceName];
              }
          )
          upstreamNames;
      in {
        driverName = "union";
        providerName = "composite(${lib.concatStringsSep "," upstreamNames})";
        inherit sliceName rcloneRemoteName;
        secretStore = defaultSecretStore;
        resolvedPath = "";
        inherit (sliceCfg) scope kind;
        hostName =
          if sliceCfg.scope == "per-host"
          then hostName
          else null;
        rcloneRemote = {
          name = rcloneRemoteName;
          type = "union";
          subdir = null;
          options = {
            upstreams = lib.concatStringsSep " " (map remoteTargetFor resolvedUpstreams);
            action_policy = sliceCfg.union.actionPolicy;
            create_policy = sliceCfg.union.createPolicy;
            search_policy = sliceCfg.union.searchPolicy;
          };
        };
        endpoints = {
          rclone = "${rcloneRemoteName}:";
          restic = "rclone:${rcloneRemoteName}:";
          sftp = null;
          webdav = null;
          smb = null;
        };
        secrets = dedupSecrets (lib.concatMap (u: u.secrets) resolvedUpstreams);
        reconcile = dedupReconcile (lib.concatMap (u: u.reconcile) resolvedUpstreams);
      };

  resolveHostStorageFn = {
    storageCfg,
    hostName,
    placeholders ? (store: key: "<sops:${store}:${key}>"),
  }: let
    allSliceNames = builtins.attrNames storageCfg.slices;
    resolvedSlices = lib.genAttrs allSliceNames (
      sliceName:
        resolveSliceInner {
          inherit storageCfg sliceName hostName placeholders;
        }
    );
    providersInfo =
      lib.mapAttrs (
        pName: pCfg: let
          resolved = resolveProviderDriver storageCfg pName pCfg;
        in {
          driver = resolved.driverName;
          inherit (pCfg) secretStore;
          inherit (resolved) settings;
        }
      )
      storageCfg.providers;
    enabledMounts = lib.filterAttrs (_: m: m.enable) storageCfg.mounts;
    mountedSlices = lib.mapAttrsToList (_: m: m.slice) enabledMounts;
    demandedSliceNames = lib.unique (storageCfg.activeSlices ++ mountedSlices);
  in {
    inherit hostName demandedSliceNames;
    inherit (storageCfg) enable;
    providers = providersInfo;
    slices = resolvedSlices;
    mounts = enabledMounts;
    allSecrets = dedupSecrets (lib.concatMap (s: s.secrets) (builtins.attrValues resolvedSlices));
    allReconcile = dedupReconcile (lib.concatMap (s: s.reconcile) (builtins.attrValues resolvedSlices));
    driverHooks =
      lib.mapAttrs (_: d: d.reconcileHook)
      (lib.filterAttrs (_: d: d.reconcileHook != null) storageCfg.drivers);
  };
in {
  contract.storage.lib = {
    evalDriverSettings = {
      docstring = ''
        Evaluates a storage provider instance's `settings` attribute set against its driver's `settingsModule`, returning typed settings and defaults.

        # Inputs

        `driver`
        : Driver definition attribute set from `storage.drivers`.

        `providerName`
        : Provider instance name used for error attribution.

        `providerCfg`
        : Provider instance configuration from `storage.providers`.

        # Type

        ```
        evalDriverSettings :: { driver :: Driver, providerName :: String, providerCfg :: Provider } -> AttrSet
        ```

        # Examples

        ```nix
        self.lib.storage.evalDriverSettings {
          driver = config.storage.drivers.hetzner-box;
          providerName = "hbox";
          providerCfg = config.storage.providers.hbox;
        }
        ```
      '';
      value = evalDriverSettingsFn;
    };

    resolveSlice = {
      docstring = ''
        Recursively resolves a logical slice (`direct`, `crypt`, or `union` across `shared` or `per-host` scope) for a given host into SOPS secret requirements, rclone remote definitions, protocol endpoints, and provider reconciliation items.

        # Inputs

        `storageCfg`
        : Evaluated `config.storage` attribute set.

        `sliceName`
        : Name of the slice declared in `storage.slices`.

        `hostName`
        : Host name used when resolving `per-host` slice paths and secret stores.

        `placeholders`
        : Optional function `(store -> key -> string)` emitting runtime SOPS placeholders (defaults to `<sops:store:key>`).

        `visited`
        : Internal accumulator of visited slice names used to detect reference cycles.

        # Type

        ```
        resolveSlice :: { storageCfg :: AttrSet, sliceName :: String, hostName :: String, placeholders? :: (String -> String -> String), visited? :: [String] } -> AttrSet
        ```

        # Examples

        ```nix
        self.lib.storage.resolveSlice {
          storageCfg = config.storage;
          sliceName = "hbox-backup-host";
          hostName = "astrolabe";
        }
        ```
      '';
      value = resolveSliceInner;
    };

    resolveHostStorage = {
      docstring = ''
        Resolves all providers, slices, mounts, deduplicated SOPS secrets, and reconciler payloads for a single host configuration.

        # Inputs

        `storageCfg`
        : Evaluated `config.storage` attribute set for the target host.

        `hostName`
        : Name of the NixOS host being evaluated.

        `placeholders`
        : Optional function `(store -> key -> string)` emitting runtime SOPS placeholders.

        # Type

        ```
        resolveHostStorage :: { storageCfg :: AttrSet, hostName :: String, placeholders? :: (String -> String -> String) } -> AttrSet
        ```

        # Examples

        ```nix
        self.lib.storage.resolveHostStorage {
          storageCfg = config.storage;
          hostName = "astrolabe";
        }
        ```
      '';
      value = resolveHostStorageFn;
    };
  };
}
