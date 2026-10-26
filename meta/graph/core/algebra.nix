{
  lib,
  config,
  ...
}: let
  container = config.internal.graph.core.container;
  types = config.internal.graph.core.types;

  /**
  Overlays (unions) two graphs: V = V1 ∪ V2, E = E1 ∪ E2.
  */
  overlay = g1: g2:
    container.mkGraph {
      nodes = g1.nodes // g2.nodes;
      edges = g1.edges ++ g2.edges;
      meta = (g1.meta or {}) // (g2.meta or {});
    };

  /**
  Overlays a list of graphs.
  */
  overlayList = graphs:
    builtins.foldl' overlay container.emptyGraph graphs;

  /**
  Filters a graph by node predicate, producing an induced subgraph.
  */
  selectNodes = pred: g: let
    filteredNodes = lib.filterAttrs (_: pred) g.nodes;
    validNodeIds = builtins.attrNames filteredNodes;
    filteredEdges = lib.filter (e: builtins.elem e.source validNodeIds && builtins.elem e.target validNodeIds) g.edges;
  in
    container.mkGraph {
      nodes = filteredNodes;
      edges = filteredEdges;
      meta = g.meta or {};
    };

  /**
  Filters graph edges by predicate.
  */
  selectEdges = pred: g:
    container.mkGraph {
      nodes = g.nodes;
      edges = lib.filter pred g.edges;
      meta = g.meta or {};
    };

  /**
  General graph filtering applying both node and edge predicates.
  */
  filterGraph = {
    nodeFilter ? (_: true),
    edgeFilter ? (_: true),
  }: g: let
    filteredNodes = lib.filterAttrs (_: nodeFilter) g.nodes;
    validNodeIds = builtins.attrNames filteredNodes;
    filteredEdges =
      lib.filter (
        e:
          builtins.elem e.source validNodeIds
          && builtins.elem e.target validNodeIds
          && edgeFilter e
      )
      g.edges;
  in
    container.mkGraph {
      nodes = filteredNodes;
      edges = filteredEdges;
      meta = g.meta or {};
    };

  /**
  Computes a Homomorphic Graph Quotient (Graph Contraction).
  Given an equivalence mapping q: V -> V_macro:
  - Contracts fine-grained nodes into macro equivalence classes.
  - Contracts fine-grained edges into macro relational edges.
  - Deduplicates self-loops and parallel edges.
  */
  quotient = {
    quotientNodeFn, # (node -> { id, label, kind, stratum, meta })
    contractEdgeFn ? (e: qSrc: qTgt: {
      source = qSrc.id;
      target = qTgt.id;
      relation = e.relation;
      stratum = e.stratum or "onto";
      meta = e.meta or {};
    }),
  }: g: let
    # Map all original nodes to quotient node definitions
    quotientMap = lib.mapAttrs (_: n: quotientNodeFn n) g.nodes;

    # Collect distinct quotient nodes
    uniqueQuotientNodes = lib.listToAttrs (
      map (qn: lib.nameValuePair qn.id qn) (builtins.attrValues quotientMap)
    );

    # Contract edges
    contractedEdges = lib.concatMap (e: let
      qSrc = quotientMap.${e.source} or null;
      qTgt = quotientMap.${e.target} or null;
    in
      if qSrc != null && qTgt != null && qSrc.id != qTgt.id
      then let
        newEdge = contractEdgeFn e qSrc qTgt;
        edgeId = "${newEdge.source}--[${newEdge.stratum}:${newEdge.relation}]-->${newEdge.target}";
      in [
        (newEdge // {id = edgeId;})
      ]
      else [])
    g.edges;
  in
    container.mkGraph {
      nodes = uniqueQuotientNodes;
      edges = contractedEdges;
      meta = {
        isQuotient = true;
        baseGraph = g.format or "unknown";
      };
    };

  /**
  Computes transitive reachability from a set of starting nodes.
  Supports forward and backward traversals with optional relation/stratum filtering.
  */
  reachable = {
    from,
    viaRelations ? null,
    viaStrata ? null,
    reverse ? false,
    maxDepth ? 100,
  }: g: let
    adjIndex =
      if reverse
      then g.indices.incoming or {}
      else g.indices.outgoing or {};
    edgeMap = g.indices.edgeMap or (lib.listToAttrs (map (e: lib.nameValuePair e.id e) g.edges));

    step = currentIds: visitedIds: visitedEdgeIds: depth:
      if depth <= 0 || currentIds == []
      then {
        nodeIds = visitedIds;
        edgeIds = visitedEdgeIds;
      }
      else let
        incidentEdgeIds = lib.unique (
          lib.concatMap (
            nId: let
              rawIds = adjIndex.${nId} or [];
            in
              lib.filter (eId: let
                e = edgeMap.${eId};
                relOk = viaRelations == null || builtins.elem e.relation viaRelations;
                stratOk = viaStrata == null || builtins.elem e.stratum stratOk;
              in
                relOk && stratOk)
              rawIds
          )
          currentIds
        );
        newEdges = map (eId: edgeMap.${eId}) incidentEdgeIds;
        neighborIds = lib.unique (map (e:
          if reverse
          then e.source
          else e.target)
        newEdges);
        nextCurrentIds = lib.filter (id: !builtins.elem id visitedIds) neighborIds;
      in
        step nextCurrentIds (lib.unique (visitedIds ++ neighborIds)) (lib.unique (visitedEdgeIds ++ incidentEdgeIds)) (depth - 1);

    initialIds =
      if builtins.isList from
      then from
      else [from];
    validInitials = lib.filter (id: g.nodes ? ${id}) initialIds;
    res = step validInitials validInitials [] maxDepth;
  in {
    nodeIds = res.nodeIds;
    edgeIds = res.edgeIds;
    subgraph = container.mkGraph {
      nodes = lib.filterAttrs (id: _: builtins.elem id res.nodeIds) g.nodes;
      edges = map (eId: edgeMap.${eId}) res.edgeIds;
      meta = {
        reachabilityOrigin = initialIds;
        inherit reverse;
      };
    };
  };

  /**
  Computes a forward or backward program slice.
  */
  slice = {
    target,
    direction ? "backward",
    relations ? null,
    strata ? null,
    maxDepth ? 10,
  }: g: let
    reverse = direction == "backward";
    res =
      reachable {
        from = target;
        viaRelations = relations;
        viaStrata = strata;
        inherit reverse maxDepth;
      }
      g;
  in
    res.subgraph;

  /**
  Extracts an undirected k-hop neighborhood (ego network).
  */
  neighborhood = {
    center,
    radius ? 1,
  }: g: let
    findNeighbors = currentIds: let
      incidentEdges = lib.filter (e: builtins.elem e.source currentIds || builtins.elem e.target currentIds) g.edges;
      neighborIds = lib.unique (builtins.concatMap (e: [e.source e.target]) incidentEdges);
    in
      lib.unique (currentIds ++ neighborIds);

    expand = d: currentIds:
      if d <= 0
      then currentIds
      else expand (d - 1) (findNeighbors currentIds);

    initial =
      if builtins.isList center
      then center
      else [center];
    allNeighborIds = expand radius initial;
  in
    selectNodes (n: builtins.elem n.id allNeighborIds) g;
in {
  internal.graph.core.algebra = {
    inherit
      overlay
      overlayList
      selectNodes
      selectEdges
      filterGraph
      quotient
      reachable
      slice
      neighborhood
      ;
  };
}
