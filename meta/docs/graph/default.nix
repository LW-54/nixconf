{
  lib,
  config,
  ...
}: let
  discovery = config.internal.docs.graph.discovery;
  nodes = config.internal.docs.graph.nodes;
  edges = config.internal.docs.graph.edges;
  spec = config.flake.lib.docsSpec;
  parser = config.flake.lib.docsParser;

  filterGraph = {
    nodeFilter ? (_: true),
    edgeFilter ? (_: true),
  }: graph: let
    filteredNodes = lib.filterAttrs (_: nodeFilter) graph.nodes;
    validNodeIds = builtins.attrNames filteredNodes;
    filteredEdges =
      lib.filter (
        e:
          builtins.elem e.source validNodeIds
          && builtins.elem e.target validNodeIds
          && edgeFilter e
      )
      graph.edges;
  in {
    nodes = filteredNodes;
    edges = filteredEdges;
    diagnostics = graph.diagnostics;
  };

  getNeighborhood = {
    graph,
    nodeId,
    depth ? 1,
  }: let
    findConnected = currentIds: let
      incidentEdges = lib.filter (e: builtins.elem e.source currentIds || builtins.elem e.target currentIds) graph.edges;
      adjacentNodeIds = lib.unique (builtins.concatMap (e: [e.source e.target]) incidentEdges);
    in
      lib.unique (currentIds ++ adjacentNodeIds);

    expand = d: currentIds:
      if d <= 0
      then currentIds
      else expand (d - 1) (findConnected currentIds);

    targetNodeIds =
      if graph.nodes ? ${nodeId}
      then expand depth [nodeId]
      else [];
  in
    filterGraph {
      nodeFilter = n: builtins.elem n.id targetNodeIds;
    }
    graph;

  /**
  Builds the complete labeled property graph IR from evaluated flake declarations.

  # Inputs

  `strict`
  : When true, asserts zero technical debt and throws on any non-conformance.

  `system`
  : Architecture target system string (defaults to "x86_64-linux").

  # Type
  ```
  buildGraph :: AttrSet -> AttrSet
  ```
  */
  buildGraph = {
    system ? "x86_64-linux",
    strict ? false,
  }: let
    hosts = config.host;
    contracts = config.contract;
    implementations = config.implementation;
    features = config.feature;
    libs = config.lib;

    hostNames = builtins.attrNames hosts;
    hostConfigs = lib.genAttrs hostNames (name: config.flake.nixosConfigurations.${name});
    contractNames = builtins.attrNames contracts;

    # 1. Build Host Nodes
    hostNodes = nodes.buildHostNodes {
      inherit hosts hostConfigs implementations contracts features;
    };

    # 2. Build Contract Nodes
    contractNodes = nodes.buildContractNodes {
      inherit contracts implementations system hostConfigs;
    };

    # 3. Build Implementation Nodes
    implNodes = nodes.buildImplNodes {
      inherit implementations contracts hosts system hostConfigs;
    };

    # 4. Build Feature Nodes
    featureNodes = nodes.buildFeatureNodes {
      inherit features hosts system hostConfigs;
    };

    # 4b. Build Library Nodes
    libNodes = nodes.buildLibNodes {
      inherit libs;
    };

    # 5. Build Options & Types from Contracts
    collectContractOptions = contractName: prefix: attrs:
      lib.concatMap (k: let
        v = attrs.${k};
        currPath =
          if prefix == ""
          then k
          else "${prefix}.${k}";
      in
        if builtins.isAttrs v && (v ? type || (v ? _type && v._type == "option"))
        then let
          optPath = "${contractName}.${currPath}";
          optNodeId = "opt:${optPath}";
          optDesc = v.description or "";
          typeStr = v.type.description or (v.type.name or "anything");
          defVal =
            if v ? default
            then v.default
            else null;
          exVal =
            if v ? example
            then v.example
            else null;
          optionTodos = spec.validateOption {
            path = optPath;
            option = v;
            isContract = true;
            file = "modules/contracts/${contractName}.nix";
            line = 1;
          };
        in [
          {
            inherit optionTodos;
            node = {
              kind = "opt";
              id = optNodeId;
              name = optPath;
              properties = {
                type = typeStr;
                description = optDesc;
                default = defVal;
                example = exVal;
                contract = contractName;
              };
            };
            hasOptionEdge = {
              id = "${contractName}-has-opt-${builtins.replaceStrings ["."] ["-"] currPath}";
              source = "contract:${contractName}";
              target = optNodeId;
              kind = "HAS_OPTION";
              properties = {};
            };
          }
        ]
        else if builtins.isAttrs v
        then collectContractOptions contractName currPath v
        else []) (builtins.attrNames attrs);

    contractOptionData =
      lib.concatMap (
        contractName:
          collectContractOptions contractName "" contracts.${contractName}.options
      )
      contractNames;

    contractOptionNodes = lib.listToAttrs (map (d: lib.nameValuePair d.node.id d.node) contractOptionData);
    contractHasOptionEdges = map (d: d.hasOptionEdge) contractOptionData;
    contractOptionTodos = builtins.concatMap (d: d.optionTodos) contractOptionData;

    # Collect custom types from contracts
    contractTypeData = lib.concatMap (contractName: let
      contract = contracts.${contractName};
      cTypes = contract.types or {};
      typeNames = builtins.attrNames cTypes;
    in
      map (typeName: let
        t = cTypes.${typeName};
        typeNodeId = "type:${contractName}.${typeName}";
        desc = t.description or "Type ${typeName}";
      in {
        node = {
          kind = "type";
          id = typeNodeId;
          name = "${contractName}.${typeName}";
          properties = {
            contract = contractName;
            description = desc;
          };
        };
        edge = {
          id = "${contractName}-has-type-${typeName}";
          source = "contract:${contractName}";
          target = typeNodeId;
          kind = "HAS_TYPE";
          properties = {};
        };
      })
      typeNames)
    contractNames;

    contractTypeNodes = lib.listToAttrs (map (d: lib.nameValuePair d.node.id d.node) contractTypeData);
    contractHasTypeEdges = map (d: d.edge) contractTypeData;

    validOptionPaths = map (d: d.node.name) contractOptionData;

    # 6. Build Module Nodes
    findModuleOptions = name: let
      findInTree = path: attrs:
        lib.concatMap (k: let
          v = attrs.${k};
          currPath =
            if path == ""
            then k
            else "${path}.${k}";
        in
          if builtins.isAttrs v && (v ? type || (v ? _type && v._type == "option"))
          then [
            {
              path = currPath;
              type = v.type.description or (v.type.name or "anything");
              description = v.description or "";
            }
          ]
          else if builtins.isAttrs v
          then findInTree currPath v
          else []) (builtins.attrNames attrs);
      optsAstrolabe =
        if hostConfigs ? astrolabe
        then hostConfigs.astrolabe.options or {}
        else {};
      matchingTree = optsAstrolabe.${name} or null;
    in
      if matchingTree != null && builtins.isAttrs matchingTree
      then findInTree name matchingTree
      else [];

    extractHostConfigSnippet = {
      hostContent,
      moduleName,
    }: let
      lines = lib.splitString "\n" hostContent;
      countChars = char: s: builtins.length (lib.filter (c: c == char) (lib.stringToCharacters s));
      isMatch = line: lib.hasInfix "${moduleName}." line || lib.hasInfix "self.nixosModules.${moduleName}" line;
      matchingIndices = lib.filter (i: isMatch (builtins.elemAt lines i)) (lib.range 0 (builtins.length lines - 1));
      extractBlockFrom = startIdx: let
        rem = lib.sublist startIdx (builtins.length lines - startIdx) lines;
        folder = acc: line:
          if acc.done
          then acc
          else let
            opens = (countChars "{" line) + (countChars "(" line);
            closes = (countChars "}" line) + (countChars ")" line);
            newDepth = acc.depth + opens - closes;
            hasSemi = lib.hasSuffix ";" (lib.removeSuffix " " line);
            done = (acc.depth > 0 && newDepth <= 0) || (acc.depth == 0 && opens > 0 && opens == closes) || (acc.depth == 0 && hasSemi);
          in {
            depth = newDepth;
            lines = acc.lines ++ [line];
            done = done;
          };
        res =
          lib.foldl' folder {
            depth = 0;
            lines = [];
            done = false;
          }
          rem;
      in
        lib.concatStringsSep "\n" res.lines;
    in
      if matchingIndices == []
      then ""
      else let
        firstIdx = builtins.head matchingIndices;
        block = extractBlockFrom firstIdx;
      in
        parser.stripLeadingIndentation block;

    moduleNodes = nodes.buildModuleNodes {
      inherit contracts implementations features hosts findModuleOptions extractHostConfigSnippet;
    };

    # 7. Build Package Nodes & Shell Nodes
    packageNodes = nodes.buildPackageNodes {inherit system;};
    shellNodes = nodes.buildShellNodes {inherit system;};

    # 8. Collect ALL Library Symbols (Functions AND Non-Function Values) from config.lib
    collectAllSymbols = libs:
      lib.concatMap (
        ns: let
          l = libs.${ns};
          symAttrs = l.symbols or {};
        in
          lib.concatMap (
            symName: let
              rawSym = symAttrs.${symName};
              sourceInfo = discovery.resolveSymbolSource {
                inherit ns symName contracts implementations features hosts;
              };
              docRes = discovery.resolveSymbolDoc {
                currName = "${ns}.${symName}";
                inherit rawSym sourceInfo spec parser;
              };
            in
              if symName == "types" || symName == "options"
              then []
              else [docRes]
          ) (builtins.attrNames symAttrs)
      ) (builtins.attrNames libs);

    symbolData = collectAllSymbols libs;
    symbolNodes = lib.listToAttrs (map (d: let
      nodeId = "fn:${d.name}";
    in
      lib.nameValuePair nodeId {
        kind = d.kind;
        id = nodeId;
        name = d.name;
        properties = {
          summary = d.parsedDoc.summary or "";
          body = d.parsedDoc.body or "";
          inputs = d.parsedDoc.inputs or [];
          typeSignature = d.parsedDoc.typeSignature or "";
          examples = d.parsedDoc.examples or "";
          inherit (d) file line;
        };
      })
    symbolData);
    symbolTodos = builtins.concatMap (d: d.todos) symbolData;

    # 9. Directed Graph Edges
    importEdges = edges.buildImportEdges {
      inherit hosts implementations features;
    };

    implementsEdges = edges.buildImplementsEdges {
      inherit implementations;
    };

    consumesEdges = edges.buildConsumesEdges {
      inherit hosts features implementations contractNames validOptionPaths;
    };

    providesEdges = edges.buildProvidesEdges {
      inherit contracts implementations features libs;
    };

    libHasSymbolEdges = lib.concatMap (
      ns: let
        l = libs.${ns};
        symAttrs = l.symbols or {};
      in
        lib.concatMap (
          symName:
            if symName == "types" || symName == "options"
            then []
            else [
              {
                id = "lib-${ns}-has-symbol-${symName}";
                source = "lib:${ns}";
                target = "fn:${ns}.${symName}";
                kind = "EXPORTS";
                properties = {};
              }
            ]
        ) (builtins.attrNames symAttrs)
    ) (builtins.attrNames libs);

    allNodes =
      hostNodes
      // contractNodes
      // implNodes
      // featureNodes
      // libNodes
      // moduleNodes
      // packageNodes
      // shellNodes
      // symbolNodes
      // contractOptionNodes
      // contractTypeNodes;

    allEdges =
      importEdges
      ++ implementsEdges
      ++ consumesEdges
      ++ providesEdges
      ++ contractHasOptionEdges
      ++ contractHasTypeEdges
      ++ libHasSymbolEdges;

    primitiveTodos =
      (lib.concatMap (name:
        spec.validatePrimitive {
          kind = "host";
          inherit name;
          primitive = hosts.${name};
        }) (builtins.attrNames hosts))
      ++ (lib.concatMap (name:
        spec.validatePrimitive {
          kind = "contract";
          inherit name;
          primitive = contracts.${name};
        }) (builtins.attrNames contracts))
      ++ (lib.concatMap (name:
        spec.validatePrimitive {
          kind = "implementation";
          inherit name;
          primitive = implementations.${name};
        }) (builtins.attrNames implementations))
      ++ (lib.concatMap (name:
        spec.validatePrimitive {
          kind = "feature";
          inherit name;
          primitive = features.${name};
        }) (builtins.attrNames features));

    allTodos = symbolTodos ++ contractOptionTodos ++ primitiveTodos;
  in
    assert strict -> allTodos == []; {
      format = "LabeledPropertyGraph/v1";
      nodes = allNodes;
      edges = allEdges;
      diagnostics = {
        todos = allTodos;
        todoCount = builtins.length allTodos;
      };
    };
in {
  flake.lib.docsGraph = {
    inherit
      buildGraph
      filterGraph
      getNeighborhood
      ;
  };
}
