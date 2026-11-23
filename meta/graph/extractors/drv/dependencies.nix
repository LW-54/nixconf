# Derivation substrate package dependency edge extractor.
{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;

  drvBaseName = drv:
    drv.pname or (
      if drv ? name
      then lib.removeSuffix "-${drv.version or ""}" drv.name
      else ""
    );

  mkDrvNameSet = drvList:
    builtins.listToAttrs (lib.concatMap (inp: let
      base = drvBaseName inp;
      raw = inp.name or "";
    in
      lib.optional (base != "") {
        name = base;
        value = true;
      }
      ++ lib.optional (raw != "" && raw != base) {
        name = raw;
        value = true;
      })
    drvList);

  matchPackageDep = pDef: pName: drvList: let
    pnameTarget =
      pDef.pname or (
        if pDef ? name
        then lib.removeSuffix "-${pDef.version or ""}" pDef.name
        else pName
      );
    nameSet = mkDrvNameSet drvList;
  in
    nameSet ? ${pName} || (pnameTarget != "" && nameSet ? ${pnameTarget});

  mkPackageTargets = flakePackages: featurePackageNames:
    lib.genAttrs featurePackageNames (pName: let
      pDef = flakePackages.${pName} or null;
    in
      if pDef == null
      then null
      else
        pDef.pname or (
          if pDef ? name
          then lib.removeSuffix "-${pDef.version or ""}" pDef.name
          else pName
        ));

  extractDevShellDeps = {
    flakeDevShells,
    flakePackages,
    featurePackageNames,
  }: let
    pkgTargets = mkPackageTargets flakePackages featurePackageNames;
  in
    lib.concatMap (sName: let
      sDef = flakeDevShells.${sName} or {};
      shellNameSet = mkDrvNameSet ((sDef.buildInputs or []) ++ (sDef.nativeBuildInputs or []));
      sURN = types.mkURN {
        stratum = types.strata.drv;
        kind = "devShell";
        id = sName;
      };
    in
      lib.concatMap (pName: let
        pnameTarget = pkgTargets.${pName};
        isDep =
          pnameTarget
          != null
          && (shellNameSet ? ${pName} || (pnameTarget != "" && shellNameSet ? ${pnameTarget}));
        pURN = types.mkURN {
          stratum = types.strata.drv;
          kind = "package";
          id = pName;
        };
      in
        if isDep
        then [
          (types.mkEdge {
            source = sURN;
            target = pURN;
            relation = types.relations.DEPENDS_ON;
            stratum = types.strata.drv;
            meta = {
              devShell = sName;
              package = pName;
            };
          })
        ]
        else [])
      featurePackageNames)
    (builtins.attrNames flakeDevShells);

  extractConfigDeps = {
    hostNames,
    nixosConfigs,
    flakePackages,
    featurePackageNames,
  }: let
    pkgTargets = mkPackageTargets flakePackages featurePackageNames;
  in
    lib.concatMap (hName: let
      hCfg = nixosConfigs.${hName} or null;
      sysNameSet = mkDrvNameSet (
        if hCfg != null && hCfg ? config && hCfg.config ? environment && hCfg.config.environment ? systemPackages
        then hCfg.config.environment.systemPackages
        else []
      );
      cURN = types.mkURN {
        stratum = types.strata.eval;
        kind = "configuration";
        id = hName;
      };
    in
      lib.concatMap (pName: let
        pnameTarget = pkgTargets.${pName};
        isDep =
          pnameTarget
          != null
          && (sysNameSet ? ${pName} || (pnameTarget != "" && sysNameSet ? ${pnameTarget}));
        pURN = types.mkURN {
          stratum = types.strata.drv;
          kind = "package";
          id = pName;
        };
      in
        if isDep
        then [
          (types.mkEdge {
            source = cURN;
            target = pURN;
            relation = types.relations.DEPENDS_ON;
            stratum = types.strata.drv;
            meta = {
              host = hName;
              package = pName;
            };
          })
        ]
        else [])
      featurePackageNames)
    hostNames;

  extractModuleDeps = {
    features,
    featurePackageMap ? {},
    pkgArgs ? {},
  }: let
    pkgsByFeature = lib.foldl' (acc: pName: let
      prod = featurePackageMap.${pName};
    in
      if prod.primitive == "feature"
      then acc // {${prod.instance} = (acc.${prod.instance} or []) ++ [pName];}
      else acc) {} (builtins.attrNames featurePackageMap);
  in
    lib.concatMap (fName: let
      fDef = features.${fName};
      featPkgNames =
        if featurePackageMap != {}
        then pkgsByFeature.${fName} or []
        else if fDef ? packages
        then
          builtins.attrNames (
            if builtins.isFunction fDef.packages
            then fDef.packages pkgArgs
            else fDef.packages
          )
        else [];
      featModNames =
        (
          if fDef ? module
          then [fName]
          else []
        )
        ++ (map (m:
          if m == "default"
          then fName
          else m) (builtins.attrNames (fDef.modules or {})));
    in
      lib.concatMap (mName:
        lib.concatMap (pName: let
          mURN = types.mkURN {
            stratum = types.strata.ast;
            kind = "module";
            id = mName;
          };
          pURN = types.mkURN {
            stratum = types.strata.drv;
            kind = "package";
            id = pName;
          };
        in [
          (types.mkEdge {
            source = mURN;
            target = pURN;
            relation = types.relations.DEPENDS_ON;
            stratum = types.strata.drv;
            meta = {
              feature = fName;
              module = mName;
              package = pName;
            };
          })
        ])
        featPkgNames)
      featModNames)
    (builtins.attrNames features);
in {
  internal.graph.extractors.drvDependencies = {
    inherit matchPackageDep extractDevShellDeps extractConfigDeps extractModuleDeps;
  };
}
