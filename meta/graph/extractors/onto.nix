{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  container = config.internal.graph.core.container;

  /**
  Extracts the Ontological Intent Stratum (primitives, instances, contracts, implementations).
  */
  extractOnto = {}: let
    primitives = config.primitive or {};
    implementations = config.implementation or {};
    contracts = config.contract or {};

    # Meta-Primitive Nodes (primitive:feature, primitive:host, ...)
    primitiveNodes = lib.mapAttrs' (pName: pDef: let
      urn = types.mkURN {
        stratum = types.strata.onto;
        kind = "primitive";
        id = pName;
      };
      node = types.mkNode {
        stratum = types.strata.onto;
        kind = "primitive";
        id = pName;
        label = pDef.schema.what or pName;
        origin = {
          stratum = types.strata.onto;
          kind = "primitive";
          instance = pName;
          facet = "definition";
        };
        meta = {
          doc = pDef.schema.doc or "";
          relationships = lib.mapAttrs (_: r: builtins.removeAttrs r ["resolve"]) (pDef.relationships or {});
        };
      };
    in
      lib.nameValuePair urn node)
    primitives;

    resolveFile = pName: iName:
      if pName == "host"
      then "modules/hosts/${iName}.nix"
      else if pName == "implementation"
      then "modules/implementations/${iName}.nix"
      else if pName == "lib"
      then "modules/lib/${iName}.nix"
      else if pName == "contract"
      then
        if builtins.pathExists ../../../modules/contracts/${iName}/default.nix
        then "modules/contracts/${iName}/default.nix"
        else "modules/contracts/${iName}.nix"
      else if pName == "feature"
      then
        if builtins.pathExists ../../../modules/features/${iName}/default.nix
        then "modules/features/${iName}/default.nix"
        else if builtins.pathExists ../../../modules/features/${iName}.nix
        then "modules/features/${iName}.nix"
        else if iName == "wifi-eduroam" && builtins.pathExists ../../../modules/features/wifi.nix
        then "modules/features/wifi.nix"
        else if iName == "vscode" && builtins.pathExists ../../../modules/features/vcode.nix
        then "modules/features/vcode.nix"
        else "modules/features/${iName}.nix"
      else "modules/${pName}s/${iName}.nix";

    # Primitive Instance Nodes (host:x240, feature:git, contract:secrets, ...)
    instanceNodes = lib.concatMapAttrs (pName: _: let
      instances = config.${pName} or {};
    in
      lib.mapAttrs' (iName: iDef: let
        urn = types.mkURN {
          stratum = types.strata.onto;
          kind = pName;
          id = iName;
        };
        file = resolveFile pName iName;
        baseMeta = {
          inherit file;
          description = iDef.description or (iDef.schema.doc or "${pName} instance '${iName}'.");
        };
        extraMeta =
          if pName == "contract"
          then {
            implementers = lib.mapAttrsToList (implName: impl: {
              name = implName;
              description = impl.description;
              file = "modules/implementations/${implName}.nix";
            }) (lib.filterAttrs (_: impl: impl.contract == iName) (config.implementation or {}));
            types = builtins.attrNames (iDef.types or {});
            lib =
              (
                if iDef.mkOption != null
                then ["mkOption"]
                else []
              )
              ++ (
                if iDef.mkConfig != null
                then ["mkConfig"]
                else []
              )
              ++ (
                if (iDef.types or {}) != {}
                then ["types"]
                else []
              )
              ++ builtins.attrNames (iDef.lib or {});
            packages = builtins.attrNames (
              if builtins.isFunction (iDef.packages or {})
              then
                iDef.packages {
                  pkgs = (config.flake.nixosConfigurations.astrolabe or {}).pkgs;
                  self' = {};
                }
              else (iDef.packages or {})
            );
            devShells = builtins.attrNames (
              if builtins.isFunction (iDef.devShells or {})
              then
                iDef.devShells {
                  pkgs = (config.flake.nixosConfigurations.astrolabe or {}).pkgs;
                  self' = {};
                }
              else (iDef.devShells or {})
            );
          }
          else if pName == "implementation"
          then let
            cDef = config.contract.${iDef.contract} or {};
          in {
            contract = iDef.contract;
            contractDescription = cDef.description or "";
            modules = [iName];
            lib = builtins.attrNames (iDef.lib or {});
            packages = builtins.attrNames (
              if builtins.isFunction (iDef.packages or {})
              then
                iDef.packages {
                  pkgs = (config.flake.nixosConfigurations.astrolabe or {}).pkgs;
                  self' = {};
                }
              else (iDef.packages or {})
            );
            devShells = builtins.attrNames (
              if builtins.isFunction (iDef.devShells or {})
              then
                iDef.devShells {
                  pkgs = (config.flake.nixosConfigurations.astrolabe or {}).pkgs;
                  self' = {};
                }
              else (iDef.devShells or {})
            );
            importingHosts = lib.filter (
              hName: let
                hostFile = ../../../modules/hosts/${hName}.nix;
                hostContent =
                  if builtins.pathExists hostFile
                  then builtins.readFile hostFile
                  else "";
              in
                lib.hasInfix "nixosModules.${iName}" hostContent
                || builtins.elem (config.flake.nixosModules.${iName} or null) ((config.host.${hName} or {}).modules or [])
            ) (builtins.attrNames (config.host or {}));
          }
          else if pName == "feature"
          then {
            modules = builtins.attrNames (iDef.modules or {});
            types = builtins.attrNames (iDef.types or {});
            lib = builtins.attrNames (iDef.lib or {});
            packages = builtins.attrNames (
              if builtins.isFunction (iDef.packages or {})
              then
                iDef.packages {
                  pkgs = (config.flake.nixosConfigurations.astrolabe or {}).pkgs;
                  self' = {};
                }
              else (iDef.packages or {})
            );
            devShells = builtins.attrNames (
              if builtins.isFunction (iDef.devShells or {})
              then
                iDef.devShells {
                  pkgs = (config.flake.nixosConfigurations.astrolabe or {}).pkgs;
                  self' = {};
                }
              else (iDef.devShells or {})
            );
            importingHosts = lib.filter (
              hName: let
                hostFile = ../../../modules/hosts/${hName}.nix;
                hostContent =
                  if builtins.pathExists hostFile
                  then builtins.readFile hostFile
                  else "";
              in
                lib.hasInfix "nixosModules.${iName}" hostContent
                || builtins.any (
                  mName: let
                    actualName =
                      if mName == "default"
                      then iName
                      else mName;
                  in
                    lib.hasInfix "nixosModules.${actualName}" hostContent
                    || builtins.elem (config.flake.nixosModules.${actualName} or null) ((config.host.${hName} or {}).modules or [])
                ) (builtins.attrNames (iDef.modules or {}))
            ) (builtins.attrNames (config.host or {}));
          }
          else if pName == "host"
          then let
            hCfg = config.flake.nixosConfigurations.${iName} or null;
            hostFile = ../../../modules/hosts/${iName}.nix;
            hostContent =
              if builtins.pathExists hostFile
              then builtins.readFile hostFile
              else "";
            activeImpls = lib.filter (
              implName:
                lib.hasInfix "nixosModules.${implName}" hostContent
                || builtins.elem (config.flake.nixosModules.${implName} or null) (iDef.modules or [])
            ) (builtins.attrNames (config.implementation or {}));
            activeContracts =
              map (implName: let
                impl = config.implementation.${implName};
                contract = config.contract.${impl.contract};
              in {
                contract = impl.contract;
                contractDescription = contract.description;
                implementation = implName;
                implementationDescription = impl.description;
              })
              activeImpls;
            activeFeatures = lib.filterAttrs (
              featName: feat:
                lib.hasInfix "nixosModules.${featName}" hostContent
                || builtins.any (
                  mName: let
                    actualName =
                      if mName == "default"
                      then featName
                      else mName;
                  in
                    lib.hasInfix "nixosModules.${actualName}" hostContent
                    || builtins.elem (config.flake.nixosModules.${actualName} or null) (iDef.modules or [])
                ) (builtins.attrNames feat.modules)
            ) (config.feature or {});
            featureList =
              lib.mapAttrsToList (featName: feat: {
                name = featName;
                description = feat.description;
                modules = builtins.attrNames feat.modules;
                outputs = lib.concatStringsSep ", " (
                  (builtins.attrNames feat.modules)
                  ++ (builtins.attrNames (
                    if builtins.isFunction feat.packages
                    then
                      feat.packages {
                        pkgs =
                          if hCfg != null
                          then hCfg.pkgs
                          else null;
                        self' = {};
                      }
                    else feat.packages
                  ))
                );
              })
              activeFeatures;
            subModulesList = map (subName: {
              name = subName;
              code = let
                lines = lib.splitString "\n" hostContent;
                indexed = lib.imap1 (i: l: {inherit i l;}) lines;
                startMatches = lib.filter (x: lib.hasInfix "${subName} =" x.l) indexed;
              in
                if startMatches == []
                then ""
                else let
                  startLine = (builtins.head startMatches).i;
                  rem = lib.sublist (startLine - 1) (builtins.length lines) lines;
                  countChars = char: s: builtins.length (lib.filter (c: c == char) (lib.stringToCharacters s));
                  folder = acc: line:
                    if acc.isFinished
                    then acc
                    else let
                      opens = countChars "{" line;
                      closes = countChars "}" line;
                      newDepth = acc.depth + opens - closes;
                      newLines = acc.lines ++ [line];
                      isDone = acc.depth > 0 && newDepth <= 0;
                    in {
                      depth = newDepth;
                      lines = newLines;
                      isFinished = isDone;
                    };
                  scan =
                    lib.foldl' folder {
                      depth = 0;
                      lines = [];
                      isFinished = false;
                    }
                    rem;
                in
                  lib.concatStringsSep "\n" scan.lines;
            }) (builtins.attrNames (iDef.subModules or {}));
          in {
            system =
              if hCfg != null
              then hCfg.pkgs.system
              else (iDef.system or "x86_64-linux");
            stateVersion =
              if hCfg != null
              then hCfg.config.system.stateVersion
              else "25.11";
            inherit activeContracts featureList subModulesList;
            lib = builtins.attrNames (iDef.lib or {});
            packages = builtins.attrNames (
              if builtins.isFunction (iDef.packages or {})
              then
                iDef.packages {
                  pkgs =
                    if hCfg != null
                    then hCfg.pkgs
                    else null;
                  self' = {};
                }
              else (iDef.packages or {})
            );
            devShells = builtins.attrNames (
              if builtins.isFunction (iDef.devShells or {})
              then
                iDef.devShells {
                  pkgs =
                    if hCfg != null
                    then hCfg.pkgs
                    else null;
                  self' = {};
                }
              else (iDef.devShells or {})
            );
          }
          else if pName == "lib"
          then {
            symbols = builtins.attrNames (iDef.symbols or {});
          }
          else {};
        node = types.mkNode {
          stratum = types.strata.onto;
          kind = pName;
          id = iName;
          label = iName;
          origin = {
            stratum = types.strata.onto;
            kind = pName;
            instance = iName;
            facet = "instance";
          };
          meta = baseMeta // extraMeta;
        };
      in
        lib.nameValuePair urn node)
      instances)
    (lib.filterAttrs (n: _: n != "primitive") primitives);

    # CONTAINS Edges: primitive:kind -> kind:instance
    containsEdges = lib.concatMap (pName: let
      instances = config.${pName} or {};
      pURN = types.mkURN {
        stratum = types.strata.onto;
        kind = "primitive";
        id = pName;
      };
    in
      map (iName: let
        iURN = types.mkURN {
          stratum = types.strata.onto;
          kind = pName;
          id = iName;
        };
      in
        types.mkEdge {
          source = pURN;
          target = iURN;
          relation = types.relations.CONTAINS;
          stratum = types.strata.onto;
        }) (builtins.attrNames instances))
    (lib.filter (n: n != "primitive") (builtins.attrNames primitives));

    # IMPLEMENTS Edges: implementation:inst -> contract:inst
    implementsEdges = lib.concatMap (iName: let
      impl = implementations.${iName};
      cName = impl.contract or null;
      iURN = types.mkURN {
        stratum = types.strata.onto;
        kind = "implementation";
        id = iName;
      };
      cURN = types.mkURN {
        stratum = types.strata.onto;
        kind = "contract";
        id = cName;
      };
    in
      if cName != null && contracts ? ${cName}
      then [
        (types.mkEdge {
          source = iURN;
          target = cURN;
          relation = types.relations.IMPLEMENTS;
          stratum = types.strata.onto;
          meta = {
            implementation = iName;
            contract = cName;
          };
        })
      ]
      else [])
    (builtins.attrNames implementations);

    allNodes = primitiveNodes // instanceNodes;
    allEdges = containsEdges ++ implementsEdges;
  in
    container.mkGraph {
      nodes = allNodes;
      edges = allEdges;
      meta = {stratum = types.strata.onto;};
    };
in {
  internal.graph.extractors.onto = {
    extract = extractOnto;
  };
}
