# Derivation substrate package dependency edge extractor.
{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;

  matchPackageDep = pDef: pName: drvList: let
    pnameTarget =
      pDef.pname or (
        if pDef ? name
        then lib.removeSuffix "-${pDef.version or ""}" pDef.name
        else pName
      );
  in
    builtins.any (
      inp: let
        inpName =
          inp.pname or (
            if inp ? name
            then lib.removeSuffix "-${inp.version or ""}" inp.name
            else ""
          );
      in
        inpName == pName || inpName == pnameTarget || (inp.name or "") == pName
    )
    drvList;

  extractDevShellDeps = {
    flakeDevShells,
    flakePackages,
    featurePackageNames,
  }:
    lib.concatMap (sName: let
      sDef = flakeDevShells.${sName} or {};
      shellInputs = (sDef.buildInputs or []) ++ (sDef.nativeBuildInputs or []);
      sURN = types.mkURN {
        stratum = types.strata.drv;
        kind = "devShell";
        id = sName;
      };
    in
      lib.concatMap (pName: let
        pDef = flakePackages.${pName} or null;
        isDep = pDef != null && matchPackageDep pDef pName shellInputs;
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
  }:
    lib.concatMap (hName: let
      hCfg = nixosConfigs.${hName} or null;
      sysPackages =
        if hCfg != null && hCfg ? config && hCfg.config ? environment && hCfg.config.environment ? systemPackages
        then hCfg.config.environment.systemPackages
        else [];
      cURN = types.mkURN {
        stratum = types.strata.eval;
        kind = "configuration";
        id = hName;
      };
    in
      lib.concatMap (pName: let
        pDef = flakePackages.${pName} or null;
        isDep = pDef != null && matchPackageDep pDef pName sysPackages;
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
    pkgArgs,
  }:
    lib.concatMap (fName: let
      fDef = features.${fName};
      featPkgNames =
        if fDef ? packages
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
