{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  container = config.internal.graph.core.container;

  rawParseDocstring =
    if config ? primitive && config.primitive ? primitive && config.primitive.primitive ? lib && config.primitive.primitive.lib ? parser
    then config.primitive.primitive.lib.parser.value.parseDocstring
    else if config ? flake && config.flake ? lib && config.flake.lib ? core && config.flake.lib.core ? parseDocstring
    then config.flake.lib.core.parseDocstring
    else null;
  parseDocstring =
    if rawParseDocstring == null
    then (_: {})
    else if builtins.isAttrs rawParseDocstring && rawParseDocstring ? value
    then rawParseDocstring.value
    else rawParseDocstring;

  flattenOptionsTree = prefix: attrs:
    lib.concatMap (k: let
      v = attrs.${k};
      currPath =
        if prefix == ""
        then k
        else "${prefix}.${k}";
    in
      if builtins.isAttrs v && (v ? type || (v ? _type && v._type == "option"))
      then [
        {
          path = currPath;
          option = v;
        }
      ]
      else if builtins.isAttrs v && k != "_module"
      then flattenOptionsTree currPath v
      else []) (builtins.attrNames attrs);

  typeMatches = optType: cType:
    if optType == null || cType == null
    then false
    else if optType == cType
    then true
    else if optType ? nestedTypes && optType.nestedTypes ? elemType
    then typeMatches optType.nestedTypes.elemType cType
    else if (optType.description or "") != "" && (cType.description or "") != "" && optType.description == cType.description
    then true
    else false;

  extractAST = {}: let
    contracts = config.contract or {};
    implementations = config.implementation or {};
    features = config.feature or {};
    hosts = config.host or {};
    libs = config.lib or {};
    flakeModules = config.flake.nixosModules or {};

    moduleNames = builtins.attrNames flakeModules;
    contractNames = builtins.attrNames contracts;

    # 1. Generative Provenance Mapping for Modules
    moduleProducerMap =
      (lib.concatMapAttrs (
          iName: iDef:
            if iDef ? module
            then {
              ${iName} = {
                primitive = "implementation";
                instance = iName;
                facet = "module";
              };
            }
            else {}
        )
        implementations)
      // (lib.concatMapAttrs (
          hName: hDef:
            (lib.optionalAttrs (hDef ? configuration) {
              ${hName} = {
                primitive = "host";
                instance = hName;
                facet = "configuration";
              };
            })
            // (lib.mapAttrs (_: _: {
              primitive = "host";
              instance = hName;
              facet = "subModules";
            }) (hDef.subModules or {}))
        )
        hosts)
      // (lib.concatMapAttrs (
          fName: fDef:
            (lib.optionalAttrs (fDef ? module) {
              ${fName} = {
                primitive = "feature";
                instance = fName;
                facet = "module";
              };
            })
            // (lib.concatMapAttrs (mKey: _: {
              ${
                if mKey == "default"
                then fName
                else mKey
              } = {
                primitive = "feature";
                instance = fName;
                facet = "modules";
              };
            }) (fDef.modules or {}))
        )
        features)
      // (lib.concatMapAttrs (
          cName: cDef:
            if cDef ? module
            then {
              ${cName} = {
                primitive = "contract";
                instance = cName;
                facet = "module";
              };
            }
            else {}
        )
        contracts);

    # 2. Module Nodes & OUTPUTS Edges from defining primitives
    moduleData =
      map (mName: let
        producer =
          moduleProducerMap.${
            mName
          } or {
            primitive = "workspace";
            instance = "nixosModules";
            facet = mName;
          };
        urn = types.mkURN {
          stratum = types.strata.ast;
          kind = "module";
          id = mName;
        };
        resolveModuleDesc = name:
          if contracts ? ${name}
          then "Contract interface defining '${name}' option schemas and custom types."
          else if implementations ? ${name}
          then implementations.${name}.description
          else if features ? ${name}
          then features.${name}.description
          else if name == "contracts"
          then "Central contract registry importing all declared contract interfaces."
          else if hosts ? ${name}
          then "Unified NixOS system configuration root module for host '${name}'."
          else let
            featureMatch = lib.filter (fName: builtins.hasAttr name (features.${fName}.modules or {})) (builtins.attrNames features);
            hostMatch = lib.filter (hName: builtins.hasAttr name (hosts.${hName}.subModules or {}) || lib.hasPrefix "${hName}-" name) (builtins.attrNames hosts);
          in
            if featureMatch != []
            then let f = builtins.head featureMatch; in "System service module exported by the '${f}' feature."
            else if hostMatch != []
            then let
              h = builtins.head hostMatch;
              sub = lib.removePrefix "${h}-" name;
            in
              if sub == "hardware"
              then "Hardware profile, kernel modules, and bootloader configuration for ${h}."
              else if sub == "disk"
              then "Storage partition layout, Btrfs subvolumes, and swap configuration for ${h}."
              else "Host configuration submodule for ${h}."
            else "Exported NixOS system module ${name}.";

        importingHosts = lib.filter (
          hName: let
            hostFile = ../../../modules/hosts/${hName}.nix;
            hostContent =
              if builtins.pathExists hostFile
              then builtins.readFile hostFile
              else "";
          in
            lib.hasInfix "nixosModules.${mName}" hostContent
            || builtins.elem (config.flake.nixosModules.${mName} or null) ((hosts.${hName} or {}).modules or [])
        ) (builtins.attrNames hosts);

        hostConfigurations = lib.genAttrs importingHosts (hName: let
          hostFile = ../../../modules/hosts/${hName}.nix;
          hostContent =
            if builtins.pathExists hostFile
            then builtins.readFile hostFile
            else "";
          lines = lib.splitString "\n" hostContent;
          countChars = char: s: builtins.length (lib.filter (c: c == char) (lib.stringToCharacters s));
          isMatch = line: lib.hasInfix "${mName}." line || lib.hasInfix "self.nixosModules.${mName}" line;
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
          else extractBlockFrom (builtins.head matchingIndices));

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
            if (config.flake.nixosConfigurations or {}) ? astrolabe
            then config.flake.nixosConfigurations.astrolabe.options or {}
            else {};
          matchingTree = optsAstrolabe.${name} or null;
        in
          if matchingTree != null && builtins.isAttrs matchingTree
          then findInTree name matchingTree
          else [];

        node = types.mkNode {
          stratum = types.strata.ast;
          kind = "module";
          id = mName;
          label = "nixosModule/${mName}";
          origin = producer;
          meta = {
            producerPrimitive = producer.primitive;
            producerInstance = producer.instance;
            description = resolveModuleDesc mName;
            inherit importingHosts hostConfigurations;
            options = findModuleOptions mName;
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
              meta = {facet = producer.facet;};
            })
          ]
          else [];
      in {
        inherit node outputEdge;
      })
      moduleNames;

    moduleNodes = lib.listToAttrs (map (d: lib.nameValuePair d.node.id d.node) moduleData);
    moduleOutputEdges = lib.concatMap (d: d.outputEdge) moduleData;

    # 3. Contract Options & DECLARES Edges
    contractOptionData = lib.concatMap (cName: let
      c = contracts.${cName};
      flatOpts = flattenOptionsTree cName (c.options or {});
      cURN = types.mkURN {
        stratum = types.strata.onto;
        kind = "contract";
        id = cName;
      };
    in
      map ({
        path,
        option,
      }: let
        urn = types.mkURN {
          stratum = types.strata.ast;
          kind = "option";
          id = path;
        };
        node = types.mkNode {
          stratum = types.strata.ast;
          kind = "option";
          id = path;
          label = path;
          origin = {
            stratum = types.strata.onto;
            kind = "contract";
            instance = cName;
            facet = "options";
          };
          meta = {
            contract = cName;
            description = option.description or "";
            type = option.type.description or (option.type.name or "anything");
            default =
              if option ? default
              then
                if builtins.isFunction option.default
                then "<function>"
                else option.default
              else null;
            example =
              if option ? example
              then
                if builtins.isFunction option.example
                then "<function>"
                else option.example
              else null;
          };
        };
        declaresEdge = types.mkEdge {
          source = cURN;
          target = urn;
          relation = types.relations.DECLARES;
          stratum = types.strata.ast;
          meta = {facet = "options";};
        };
      in {
        inherit node declaresEdge;
        contract = cName;
        rawType = option.type or null;
      })
      flatOpts)
    contractNames;

    optionNodes = lib.listToAttrs (map (d: lib.nameValuePair d.node.id d.node) contractOptionData);
    optionDeclaresEdges = map (d: d.declaresEdge) contractOptionData;

    # 4. Contract Types & DECLARES Edges
    contractTypeData = lib.concatMap (cName: let
      c = contracts.${cName};
      cTypes = c.types or {};
      cURN = types.mkURN {
        stratum = types.strata.onto;
        kind = "contract";
        id = cName;
      };
    in
      lib.mapAttrsToList (tName: tDef: let
        fullTypeName = "${cName}.${tName}";
        urn = types.mkURN {
          stratum = types.strata.ast;
          kind = "type";
          id = fullTypeName;
        };
        node = types.mkNode {
          stratum = types.strata.ast;
          kind = "type";
          id = fullTypeName;
          label = fullTypeName;
          origin = {
            stratum = types.strata.onto;
            kind = "contract";
            instance = cName;
            facet = "types";
          };
          meta = {
            contract = cName;
            description = tDef.description or "Type ${tName}";
          };
        };
        declaresEdge = types.mkEdge {
          source = cURN;
          target = urn;
          relation = types.relations.DECLARES;
          stratum = types.strata.ast;
          meta = {facet = "types";};
        };
      in {
        inherit node declaresEdge;
      })
      cTypes)
    contractNames;

    typeNodes = lib.listToAttrs (map (d: lib.nameValuePair d.node.id d.node) contractTypeData);
    typeDeclaresEdges = map (d: d.declaresEdge) contractTypeData;

    # 5. TYPED_BY Edges: option -> type (Structural type matching)
    optionTypedByEdges = lib.concatMap (d: let
      optNode = d.node;
      optRawType = d.rawType;
      cName = d.contract;
      cTypes = contracts.${cName}.types or {};
      matchedTypes = lib.filterAttrs (_: tDef: typeMatches optRawType tDef) cTypes;
    in
      lib.mapAttrsToList (tName: _: let
        typeURN = types.mkURN {
          stratum = types.strata.ast;
          kind = "type";
          id = "${cName}.${tName}";
        };
      in
        types.mkEdge {
          source = optNode.id;
          target = typeURN;
          relation = types.relations.TYPED_BY;
          stratum = types.strata.ast;
          meta = {
            contract = cName;
            typeName = tName;
            typeDescription = optNode.meta.type;
          };
        })
      matchedTypes)
    contractOptionData;

    # 6. Library Symbols & OUTPUTS Edges
    libSymbolData = lib.concatMap (ns: let
      l = libs.${ns};
      symAttrs = l.symbols or {};
      libURN = types.mkURN {
        stratum = types.strata.onto;
        kind = "lib";
        id = ns;
      };
    in
      lib.concatMap (symName: let
        rawSym = symAttrs.${symName};
        val =
          if builtins.isAttrs rawSym && rawSym ? value
          then rawSym.value
          else rawSym;
        docstring =
          if builtins.isAttrs rawSym && rawSym ? docstring
          then rawSym.docstring
          else null;
        parsedDoc =
          if parseDocstring != null && docstring != null
          then parseDocstring docstring
          else null;
        kind =
          if builtins.isFunction val
          then "function"
          else "symbol";
        fullName = "${ns}.${symName}";
        urn = types.mkURN {
          stratum = types.strata.ast;
          inherit kind;
          id = fullName;
        };
      in
        if symName == "types" || symName == "options"
        then []
        else [
          {
            node = types.mkNode {
              stratum = types.strata.ast;
              inherit kind;
              id = fullName;
              label = fullName;
              origin = {
                stratum = types.strata.onto;
                kind = "lib";
                instance = ns;
                facet = "symbols";
              };
              meta = {
                summary =
                  if parsedDoc != null
                  then parsedDoc.summary
                  else "";
                body =
                  if parsedDoc != null
                  then parsedDoc.body
                  else "";
                inputs =
                  if parsedDoc != null
                  then parsedDoc.inputs
                  else [];
                typeSignature =
                  if parsedDoc != null
                  then parsedDoc.typeSignature
                  else "";
                examples =
                  if parsedDoc != null
                  then parsedDoc.examples
                  else "";
              };
            };
            outputEdge = types.mkEdge {
              source = libURN;
              target = urn;
              relation = types.relations.OUTPUTS;
              stratum = types.strata.ast;
              meta = {facet = "symbols";};
            };
          }
        ]) (builtins.attrNames symAttrs))
    (builtins.attrNames libs);

    symbolNodes = lib.listToAttrs (map (d: lib.nameValuePair d.node.id d.node) libSymbolData);
    symbolOutputEdges = map (d: d.outputEdge) libSymbolData;

    allNodes = moduleNodes // optionNodes // typeNodes // symbolNodes;
    allEdges =
      moduleOutputEdges
      ++ optionDeclaresEdges
      ++ typeDeclaresEdges
      ++ optionTypedByEdges
      ++ symbolOutputEdges;
  in
    container.mkGraph {
      nodes = allNodes;
      edges = allEdges;
      meta = {
        stratum = types.strata.ast;
        inherit moduleProducerMap;
      };
    };
in {
  internal.graph.extractors.ast = {
    extract = extractAST;
    inherit flattenOptionsTree typeMatches;
  };
}
