# Ontological Intent Stratum extractor (primitives, instances, contracts, implementations).
{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  container = config.internal.graph.core.container;
  source = config.internal.graph.extractors.source;
  ontoMeta = config.internal.graph.extractors.ontoMetadata;
  inherit (source) relativeSource referenceConfiguration instanceDefinitions resolveFile instanceSourceText attrSourceCode;

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
        extraMeta = ontoMeta.computeInstanceMeta {inherit pName iName iDef;};
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
    inherit relativeSource instanceDefinitions resolveFile instanceSourceText attrSourceCode referenceConfiguration;
  };
}
