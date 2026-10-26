{lib, ...}: let
  /**
  Deduplicates edges preserving uniqueness by edge.id.
  */
  dedupEdges = edges: let
    grouped = lib.groupBy (e: e.id) edges;
  in
    map (id: builtins.head grouped.${id}) (builtins.attrNames grouped);

  /**
  Builds a high-performance multi-indexed Graph Container.
  */
  mkGraph = {
    nodes,
    edges,
    meta ? {},
  }: let
    nodeMap =
      if builtins.isAttrs nodes && !(nodes ? id)
      then nodes
      else lib.listToAttrs (map (n: lib.nameValuePair n.id n) nodes);

    cleanEdges = dedupEdges edges;
    edgeMap = lib.listToAttrs (map (e: lib.nameValuePair e.id e) cleanEdges);

    byStratum = lib.mapAttrs (_: es: map (e: e.id) es) (lib.groupBy (e: e.stratum or "ast") cleanEdges);
    byRelation = lib.mapAttrs (_: es: map (e: e.id) es) (lib.groupBy (e: e.relation) cleanEdges);
    byKind = lib.mapAttrs (_: ns: map (n: n.id) ns) (lib.groupBy (n: n.kind) (builtins.attrValues nodeMap));
    outgoing = lib.mapAttrs (_: es: map (e: e.id) es) (lib.groupBy (e: e.source) cleanEdges);
    incoming = lib.mapAttrs (_: es: map (e: e.id) es) (lib.groupBy (e: e.target) cleanEdges);
  in {
    version = 2;
    format = "SemanticCPG/v2";
    nodes = nodeMap;
    edges = cleanEdges;
    inherit meta;
    indices = {
      inherit
        byStratum
        byRelation
        byKind
        outgoing
        incoming
        edgeMap
        ;
    };
  };

  /**
  Empty graph representation.
  */
  emptyGraph = mkGraph {
    nodes = {};
    edges = [];
  };
in {
  internal.graph.core.container = {
    inherit
      dedupEdges
      mkGraph
      emptyGraph
      ;
  };
}
