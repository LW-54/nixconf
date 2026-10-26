{
  inputs,
  self,
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  container = config.internal.graph.core.container;

  extractDRV = {system ? "x86_64-linux"}: let
    features = config.feature or {};
    implementations = config.implementation or {};
    nixosConfigs = config.flake.nixosConfigurations or {};
    flakePackages = config.flake.packages.${system} or {};
    flakeDevShells = config.flake.devShells.${system} or {};

    packageNames = builtins.attrNames flakePackages;
    devShellNames = builtins.attrNames flakeDevShells;
    featureNames = builtins.attrNames features;
    hostNames = builtins.attrNames (config.host or {});

    pkgs =
      if inputs ? nixpkgs && inputs.nixpkgs ? legacyPackages && inputs.nixpkgs.legacyPackages ? ${system}
      then inputs.nixpkgs.legacyPackages.${system}
      else {};

    pkgArgs = {
      inherit pkgs self;
      self' = {
        packages = flakePackages;
        devShells = flakeDevShells;
      };
      system = system;
    };

    # 1. Generative Provenance Mapping for Packages
    featurePackageMap =
      lib.concatMapAttrs (
        fName: fDef:
          if fDef ? packages
          then let
            pkgsSet =
              if builtins.isFunction fDef.packages
              then fDef.packages pkgArgs
              else fDef.packages;
          in
            lib.genAttrs (builtins.attrNames pkgsSet) (_: {
              primitive = "feature";
              instance = fName;
              facet = "packages";
            })
          else {}
      )
      features;

    findPackageProducer = pName:
      featurePackageMap.${
        pName
      } or {
        primitive = "workspace";
        instance = "packages";
        facet = pName;
      };

    # 2. Package Nodes & OUTPUTS Edges
    packageData =
      map (pName: let
        producer = findPackageProducer pName;
        pDef = flakePackages.${pName} or {};
        urn = types.mkURN {
          stratum = types.strata.drv;
          kind = "package";
          id = pName;
        };
        node = types.mkNode {
          stratum = types.strata.drv;
          kind = "package";
          id = pName;
          label = "package/${pName}";
          origin = producer;
          meta = {
            pname = pDef.pname or (pDef.name or pName);
            version = pDef.version or "";
            description = pDef.meta.description or (pDef.description or "Application package ${pName}.");
            runCommand = "nix run .#${pName}";
            buildCommand = "nix build .#${pName}";
          };
        };
        outputEdge =
          if producer.primitive == "feature"
          then [
            (types.mkEdge {
              source = types.mkURN {
                stratum = types.strata.onto;
                kind = "feature";
                id = producer.instance;
              };
              target = urn;
              relation = types.relations.OUTPUTS;
              stratum = types.strata.ast;
              meta = {facet = "packages";};
            })
          ]
          else [];
      in {
        inherit node outputEdge;
      })
      packageNames;

    packageNodes = lib.listToAttrs (map (d: lib.nameValuePair d.node.id d.node) packageData);
    packageOutputEdges = lib.concatMap (d: d.outputEdge) packageData;

    # 3. Generative Provenance Mapping for DevShells
    devShellProducerMap =
      (lib.concatMapAttrs (
          fName: fDef:
            if fDef ? devShells
            then let
              shellsSet =
                if builtins.isFunction fDef.devShells
                then fDef.devShells pkgArgs
                else fDef.devShells;
            in
              lib.genAttrs (builtins.attrNames shellsSet) (_: {
                primitive = "feature";
                instance = fName;
                facet = "devShells";
              })
            else {}
        )
        features)
      // (lib.concatMapAttrs (
          iName: iDef:
            if iDef ? devShells
            then let
              shellsSet =
                if builtins.isFunction iDef.devShells
                then iDef.devShells pkgArgs
                else iDef.devShells;
            in
              lib.genAttrs (builtins.attrNames shellsSet) (_: {
                primitive = "implementation";
                instance = iName;
                facet = "devShells";
              })
            else {}
        )
        implementations);

    findDevShellProducer = sName:
      devShellProducerMap.${
        sName
      } or {
        primitive = "workspace";
        instance = "devShells";
        facet = sName;
      };

    # 4. DevShell Nodes & OUTPUTS Edges
    devShellData =
      map (sName: let
        producer = findDevShellProducer sName;
        sDef = flakeDevShells.${sName} or {};
        urn = types.mkURN {
          stratum = types.strata.drv;
          kind = "devShell";
          id = sName;
        };
        node = types.mkNode {
          stratum = types.strata.drv;
          kind = "devShell";
          id = sName;
          label = "devShell/${sName}";
          origin = producer;
          meta = {
            description = sDef.meta.description or "Development shell ${sName}.";
            developCommand = "nix develop .#${sName}";
          };
        };
        outputEdge =
          if producer.primitive != "workspace"
          then [
            (types.mkEdge {
              source = types.mkURN {
                stratum = types.strata.onto;
                kind = producer.primitive;
                id = producer.instance;
              };
              target = urn;
              relation = types.relations.OUTPUTS;
              stratum = types.strata.ast;
              meta = {facet = "devShells";};
            })
          ]
          else [];
      in {
        inherit node outputEdge;
      })
      devShellNames;

    devShellNodes = lib.listToAttrs (map (d: lib.nameValuePair d.node.id d.node) devShellData);
    devShellOutputEdges = lib.concatMap (d: d.outputEdge) devShellData;

    # 5. Pure Package Dependency Matching Helper
    featurePackageNames = builtins.attrNames featurePackageMap;

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

    # 6. DevShell DEPENDS_ON Package Edges
    devShellDependsOnPackageEdges = lib.concatMap (sName: let
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
    devShellNames;

    # 7. Configuration DEPENDS_ON Package Edges
    configDependsOnPackageEdges = lib.concatMap (hName: let
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

    # 8. Feature Module DEPENDS_ON Package Edges
    moduleDependsOnPackageEdges = lib.concatMap (fName: let
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
    featureNames;

    allNodes = packageNodes // devShellNodes;
    allEdges =
      packageOutputEdges
      ++ devShellOutputEdges
      ++ devShellDependsOnPackageEdges
      ++ configDependsOnPackageEdges
      ++ moduleDependsOnPackageEdges;
  in
    container.mkGraph {
      nodes = allNodes;
      edges = allEdges;
      meta = {
        stratum = types.strata.drv;
        inherit featurePackageMap devShellProducerMap;
      };
    };
in {
  internal.graph.extractors.drv = {
    extract = extractDRV;
  };
}
