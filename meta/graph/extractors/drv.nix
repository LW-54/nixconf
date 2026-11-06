# Derivation substrate extractor for packages, developer shells, and build dependencies.
{
  inputs,
  self,
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  container = config.internal.graph.core.container;
  deps = config.internal.graph.extractors.drvDependencies;

  extractDRV = {system ? "x86_64-linux"}: let
    features = config.feature or {};
    implementations = config.implementation or {};
    nixosConfigs = config.flake.nixosConfigurations or {};
    metaPackageNames = ["graph" "docs" "cpg-json" "nixconf-json"];
    rawPackages = config.flake.packages.${system} or {};
    flakePackages = lib.filterAttrs (name: _: !builtins.elem name metaPackageNames) rawPackages;
    flakeDevShells = config.flake.devShells.${system} or {};

    packageNames = builtins.attrNames flakePackages;
    devShellNames = builtins.attrNames flakeDevShells;
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
      inherit system;
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
            usage = pDef.meta.usage or null;
            helpCommand =
              pDef.meta.helpCommand or (
                if pDef.meta.mainProgram or null != null
                then "${pDef.meta.mainProgram} --help"
                else "${pName} --help"
              );
            homepage = pDef.meta.homepage or null;
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
            usage = sDef.meta.usage or null;
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

    # 5. Dependency Edges
    featurePackageNames = builtins.attrNames featurePackageMap;

    devShellDependsOnPackageEdges = deps.extractDevShellDeps {
      inherit flakeDevShells flakePackages featurePackageNames;
    };

    configDependsOnPackageEdges = deps.extractConfigDeps {
      inherit hostNames nixosConfigs flakePackages featurePackageNames;
    };

    moduleDependsOnPackageEdges = deps.extractModuleDeps {
      inherit features pkgArgs;
    };

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
