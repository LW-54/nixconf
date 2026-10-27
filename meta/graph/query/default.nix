{lib, ...}: let
  /**
  Selects nodes from a graph satisfying a predicate.
  */
  selectNodes = pred: graph: lib.filter pred (builtins.attrValues graph.nodes);

  /**
  Selects edges from a graph satisfying a predicate.
  */
  selectEdges = pred: graph: lib.filter pred graph.edges;

  /**
  Retrieves a single node by ID, or returns null if not found.
  */
  getNode = nodeId: graph: graph.nodes.${nodeId} or null;

  /**
  Checks if a node ID exists in the graph.
  */
  hasNode = nodeId: graph: graph.nodes ? ${nodeId};

  /**
  Retrieves all incoming edges for a target node ID.
  */
  inEdges = nodeId: graph: lib.filter (e: e.target == nodeId) graph.edges;

  /**
  Retrieves all outgoing edges for a source node ID.
  */
  outEdges = nodeId: graph: lib.filter (e: e.source == nodeId) graph.edges;

  /**
  Retrieves all immediate predecessor nodes (sources of incoming edges).
  */
  inNeighbors = nodeId: graph:
    lib.unique (
      lib.filter (n: n != null) (
        map (e: graph.nodes.${e.source} or null) (inEdges nodeId graph)
      )
    );

  /**
  Retrieves all immediate successor nodes (targets of outgoing edges).
  */
  outNeighbors = nodeId: graph:
    lib.unique (
      lib.filter (n: n != null) (
        map (e: graph.nodes.${e.target} or null) (outEdges nodeId graph)
      )
    );

  /**
  Retrieves all adjacent nodes (both in- and out-neighbors).
  */
  neighbors = nodeId: graph:
    lib.unique ((inNeighbors nodeId graph) ++ (outNeighbors nodeId graph));

  /**
  Checks if a direct edge exists between source and target, optionally filtering by relation.
  */
  hasEdge = {
    source,
    target,
    relation ? null,
  }: graph:
    lib.any (
      e:
        e.source
        == source
        && e.target == target
        && (relation == null || e.relation == relation)
    )
    graph.edges;

  /**
  Retrieves all edges between source and target.
  */
  getEdgesBetween = {
    source,
    target,
  }: graph:
    lib.filter (e: e.source == source && e.target == target) graph.edges;

  /**
  Groups a list of items by a key extractor function.
  */
  groupBy = fn: items: lib.groupBy fn items;

  /**
  Extracts the induced subgraph formed by a specific list of node IDs.
  */
  slice = nodeIds: graph: let
    nodeIdSet = lib.genAttrs nodeIds (_: true);
    subNodes = lib.filterAttrs (id: _: nodeIdSet ? ${id}) graph.nodes;
    subEdges = lib.filter (e: nodeIdSet ? ${e.source} && nodeIdSet ? ${e.target}) graph.edges;
  in {
    nodes = subNodes;
    edges = subEdges;
    meta =
      (graph.meta or {})
      // {
        sliced = true;
        nodeCount = builtins.length (builtins.attrNames subNodes);
        edgeCount = builtins.length subEdges;
      };
  };

  /**
  Finds all paths between a start node and target node up to maxDepth.
  Returns a list of edge paths: [ [ edge1, edge2 ], ... ]
  */
  findPaths = {
    from,
    to,
    relation ? null,
    maxDepth ? 5,
  }: graph: let
    search = current: target: depth: visited:
      if current == target
      then [[]]
      else if depth >= maxDepth
      then []
      else let
        candidates =
          lib.filter (
            e:
              e.source
              == current
              && (relation == null || e.relation == relation)
              && !(builtins.elem e.target visited)
          )
          graph.edges;
        extendPath = edge: let
          subPaths = search edge.target target (depth + 1) (visited ++ [edge.target]);
        in
          map (subPath: [edge] ++ subPath) subPaths;
      in
        builtins.concatMap extendPath candidates;
  in
    search from to 0 [from];

  /**
  Traverses a Directed Acyclic Graph (DAG) hierarchically from root nodes.
  Returns a nested tree structure:
  [
    {
      id = "root";
      node = { ... };
      depth = 0;
      children = [ ... ];
    }
  ]
  */
  traverseDAG = {
    rootIds,
    relation ? null,
    maxDepth ? 10,
  }: graph: let
    step = nodeId: depth: visited: let
      node = graph.nodes.${nodeId} or null;
      out =
        if depth >= maxDepth || builtins.elem nodeId visited
        then []
        else
          lib.filter (
            e:
              e.source
              == nodeId
              && (relation == null || e.relation == relation)
          )
          graph.edges;
      children = map (e: step e.target (depth + 1) (visited ++ [nodeId])) out;
    in {
      id = nodeId;
      inherit node depth children;
    };
  in
    map (rootId: step rootId 0 []) rootIds;
in {
  internal.graph.query = {
    inherit
      selectNodes
      selectEdges
      getNode
      hasNode
      inEdges
      outEdges
      inNeighbors
      outNeighbors
      neighbors
      hasEdge
      getEdgesBetween
      groupBy
      slice
      findPaths
      traverseDAG
      ;
  };
}
