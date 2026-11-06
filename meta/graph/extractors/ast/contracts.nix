# Syntactic AST contract option and type extractor.
{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;

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

  extractContractData = {}: let
    contracts = config.contract or {};
    contractNames = builtins.attrNames contracts;

    # Contract Options & DECLARES Edges
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

    # Contract Types & DECLARES Edges
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

    # TYPED_BY Edges: option -> type (Structural type matching)
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
  in {
    inherit optionNodes optionDeclaresEdges typeNodes typeDeclaresEdges optionTypedByEdges contractOptionData;
  };
in {
  internal.graph.extractors.astContracts = {
    inherit extractContractData flattenOptionsTree typeMatches;
  };
}
