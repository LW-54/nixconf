{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  container = config.internal.graph.core.container;

  cleanContractURN = contractId:
    if lib.hasPrefix "urn:nixconf:onto:contract:" contractId
    then contractId
    else if lib.hasPrefix "contract:" contractId
    then
      types.mkURN {
        stratum = types.strata.onto;
        kind = "contract";
        id = lib.removePrefix "contract:" contractId;
      }
    else
      types.mkURN {
        stratum = types.strata.onto;
        kind = "contract";
        id = contractId;
      };

  /**
  Finds all active implementers fulfilling a target contract.
  */
  findImplementersFn = {
    cpg,
    contractId,
  }: let
    cURN = cleanContractURN contractId;
    incoming = cpg.indices.incoming.${cURN} or [];
    edgeMap = cpg.indices.edgeMap or {};
    matchingEdges = lib.filter (eId: let e = edgeMap.${eId} or {}; in e.relation == types.relations.IMPLEMENTS) incoming;
    implURNs = map (eId: (edgeMap.${eId}).source) matchingEdges;
  in
    lib.filterAttrs (id: _: builtins.elem id implURNs) cpg.nodes;

  /**
  Finds all consumer modules/features writing to a target contract.
  */
  findConsumersFn = {
    cpg,
    contractId,
  }: let
    cURN = cleanContractURN contractId;
    cName = (types.parseURN cURN).id;
    writesEdges =
      lib.filter (
        e:
          e.relation
          == types.relations.WRITES
          && (e.meta.path or "" != "")
          && lib.hasPrefix "${cName}." e.meta.path
      )
      cpg.edges;
    consumerURNs = lib.unique (map (e: e.source) writesEdges);
  in
    lib.filterAttrs (id: _: builtins.elem id consumerURNs) cpg.nodes;

  /**
  Extracts the complete bipartite contract subgraph for a target contract.
  */
  contractNeighborhoodFn = {
    cpg,
    contractId,
  }: let
    cURN = cleanContractURN contractId;
    implementers = findImplementersFn {inherit cpg contractId;};
    consumers = findConsumersFn {inherit cpg contractId;};
    implIds = builtins.attrNames implementers;
    consumerIds = builtins.attrNames consumers;
    activeNodeIds = lib.unique ([cURN] ++ implIds ++ consumerIds);

    subNodes = lib.filterAttrs (id: _: builtins.elem id activeNodeIds) cpg.nodes;
    subEdges =
      lib.filter (
        e:
          builtins.elem e.source activeNodeIds
          && builtins.elem e.target activeNodeIds
      )
      cpg.edges;
  in
    container.mkGraph {
      nodes = subNodes;
      edges = subEdges;
      meta = {
        projection = "CapabilityContract";
        contract = cURN;
      };
    };
in {
  internal.graph.projections.capabilities = {
    findImplementers = findImplementersFn;
    findConsumers = findConsumersFn;
    contractNeighborhood = contractNeighborhoodFn;
  };
}
