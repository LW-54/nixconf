{
  internal.rclone.mkHostState = {
    self,
    config,
    lib,
  }: let
    cfg = config.storage;
    enabledMounts = lib.filterAttrs (_: m: m.enable) cfg.mounts;
    mountNames = lib.sort (a: b: a < b) (builtins.attrNames enabledMounts);
    mountedSliceNames = map (mName: enabledMounts.${mName}.slice) mountNames;

    hasSliceCycle = visited: name:
      if builtins.elem name visited
      then true
      else if !(cfg.slices ? ${name})
      then false
      else let
        s = cfg.slices.${name};
        nextVisited = visited ++ [name];
      in
        if s.kind == "crypt" && s.baseSlice != null
        then hasSliceCycle nextVisited s.baseSlice
        else if s.kind == "union"
        then lib.any (hasSliceCycle nextVisited) s.upstreams
        else false;

    sliceClosure = visited: name:
      if builtins.elem name visited || !(cfg.slices ? ${name})
      then []
      else let
        s = cfg.slices.${name};
        nextVisited = visited ++ [name];
        deps =
          if s.kind == "crypt" && s.baseSlice != null
          then sliceClosure nextVisited s.baseSlice
          else if s.kind == "union"
          then lib.concatMap (sliceClosure nextVisited) s.upstreams
          else [];
      in
        deps ++ [name];

    requiredSliceNames = lib.unique (
      lib.concatMap (sliceClosure []) (cfg.activeSlices ++ mountedSliceNames)
    );

    secretId = store: key: "storage-${builtins.replaceStrings ["/" "."] ["-" "-"] store}-${key}";
    placeholderFor = store: key: config.secrets.placeholder.${secretId store key};

    resolved = self.lib.storage.resolveHostStorage {
      storageCfg = cfg;
      hostName = config.networking.hostName;
      placeholders = placeholderFor;
    };

    sliceSecrets =
      lib.concatMap (
        sName: (resolved.slices.${sName} or {secrets = [];}).secrets
      )
      requiredSliceNames;

    driftSecrets = lib.optionals cfg.driftCheck.enable (
      lib.concatMap (
        pCfg:
          lib.optional (pCfg.driver == "hetzner-box") {
            store = pCfg.secretStore;
            key = pCfg.settings.apiTokenKey;
            optional = false;
          }
      ) (builtins.attrValues resolved.providers)
    );

    requiredSecrets = lib.filter (s: !(s.optional or false)) (sliceSecrets ++ driftSecrets);

    secretFileAttrs = builtins.listToAttrs (
      map (s: {
        name = secretId s.store s.key;
        value = {
          inherit (s) store key;
        };
      })
      requiredSecrets
    );

    compositeSliceValid = name: s:
      if hasSliceCycle [] name
      then false
      else if s.kind == "direct"
      then s.provider != null && (cfg.providers ? ${s.provider})
      else if s.kind == "crypt"
      then s.baseSlice != null && (cfg.slices ? ${s.baseSlice})
      else s.upstreams != [] && lib.all (u: cfg.slices ? ${u}) s.upstreams;
  in {
    inherit
      cfg
      enabledMounts
      mountNames
      mountedSliceNames
      hasSliceCycle
      requiredSliceNames
      secretId
      placeholderFor
      resolved
      secretFileAttrs
      compositeSliceValid
      ;
  };
}
