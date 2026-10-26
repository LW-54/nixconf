{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  container = config.internal.graph.core.container;

  /**
  Extracts the end-to-end dataflow subgraph for a specific option path or prefix.
  */
  findOptionFlowsFn = {
    cpg,
    optionPath,
  }: let
    matchingWrites =
      lib.filter (
        e:
          e.relation
          == types.relations.WRITES
          && (e.meta.path or "" != "")
          && (e.meta.path == optionPath || lib.hasPrefix "${optionPath}." e.meta.path)
      )
      cpg.edges;

    matchingReads =
      lib.filter (
        e:
          e.relation
          == types.relations.READS
          && (e.meta.path or "" != "")
          && (e.meta.path == optionPath || lib.hasPrefix "${optionPath}." e.meta.path)
      )
      cpg.edges;

    matchingFlows =
      lib.filter (
        e:
          e.relation
          == types.relations.FLOWS_TO
          && (e.meta.viaOption or "" != "")
          && (e.meta.viaOption == optionPath || lib.hasPrefix "${optionPath}." e.meta.viaOption)
      )
      cpg.edges;

    relevantEdges = container.dedupEdges (matchingWrites ++ matchingReads ++ matchingFlows);
    relevantNodeIds = lib.unique (builtins.concatMap (e: [e.source e.target]) relevantEdges);
    relevantNodes = lib.filterAttrs (id: _: builtins.elem id relevantNodeIds) cpg.nodes;
  in
    container.mkGraph {
      nodes = relevantNodes;
      edges = relevantEdges;
      meta = {
        projection = "OptionDataFlow";
        path = optionPath;
      };
    };

  /**
  Retrieves the scalar resolved value for a contract option on a specific host from the CPG.
  */
  getOptionValueFn = {
    cpg,
    host,
    optionPath,
  }: let
    matchingWrites =
      lib.filter (
        e:
          e.relation
          == types.relations.WRITES
          && (e.meta.host or "") == host
          && (e.meta.path or "") == optionPath
          && e.meta ? resolvedValue
      )
      cpg.edges;
  in
    if matchingWrites != []
    then (builtins.head matchingWrites).meta.resolvedValue
    else null;
in {
  internal.graph.projections.dataflow = {
    findOptionFlows = findOptionFlowsFn;
    getOptionValue = getOptionValueFn;
  };
}
