# Core graph pipeline construction, algebraic traversal, and rendering engine.
{config, ...}: let
  cpgExtractor = config.internal.graph.extractors.cpg;
  architectureProj = config.internal.graph.projections.architecture;
  capabilitiesProj = config.internal.graph.projections.capabilities;
  dataflowProj = config.internal.graph.projections.dataflow;
  algebra = config.internal.graph.core.algebra;
  query = config.internal.graph.query;
  markdownTable = config.internal.graph.render.markdown.table;
  markdownMatrix = config.internal.graph.render.markdown.matrix;
  markdownTree = config.internal.graph.render.markdown.tree;
  markdownEntity = config.internal.graph.render.markdown.entity;
  mermaidTheme = config.internal.graph.render.mermaid.theme;
  mermaidFlowchart = config.internal.graph.render.mermaid.flowchart;

  renderMarkdown = {
    inherit (markdownTable) renderTable renderNodeTable renderEdgeTable escapeCell;
    inherit (markdownMatrix) renderMatrix;
    inherit (markdownTree) renderMarkdownBullets renderAsciiTree renderTree;
    inherit (markdownEntity) renderEntity;
  };

  renderMermaid = {
    inherit (mermaidTheme) sanitizeId escapeLabel classDefs getNodeClass formatNode formatEdge;
    inherit (mermaidFlowchart) renderFlowchart;
  };

  render = {
    markdown = renderMarkdown;
    mermaid = renderMermaid;

    # Universal presentation shortcuts
    table = markdownTable.renderTable;
    nodeTable = markdownTable.renderNodeTable;
    edgeTable = markdownTable.renderEdgeTable;
    matrix = markdownMatrix.renderMatrix;
    tree = markdownTree.renderTree;
    entity = markdownEntity.renderEntity;
    flowchart = mermaidFlowchart.renderFlowchart;
  };

  serializers = {
    json = config.internal.graph.serializers.json;
    mermaid = config.internal.graph.serializers.mermaid;
    dot = config.internal.graph.serializers.dot;
  };

  /**
  Builds the complete multi-strata Semantic Code Property Graph (CPG).
  */
  buildCPGFn = cpgExtractor.buildCPGFn;

  /**
  Builds the lightweight structural spine of the repository graph.
  */
  buildSpineFn = cpgExtractor.buildSpineFn;

  /**
  Projects the fine-grained CPG into the macro Labeled Property Graph (LPG) format.
  */
  toArchitectureLPGFn = architectureProj.toArchitectureLPG;

  buildSpineGraphFn = {system ? "x86_64-linux"}: let
    spine = buildSpineFn {inherit system;};
    arch = toArchitectureLPGFn {cpg = spine;};
  in
    algebra.overlay arch spine;

  buildGraphFn = {
    system ? "x86_64-linux",
    spineOnly ? false,
  }:
    if spineOnly
    then buildSpineGraphFn {inherit system;}
    else let
      cpg = buildCPGFn {inherit system;};
      arch = toArchitectureLPGFn {inherit cpg;};
    in
      algebra.overlay arch cpg;

  /**
  Filters a graph using node and edge predicates.
  */
  filterGraphFn = {
    nodeFilter ? (_: true),
    edgeFilter ? (_: true),
    graph ? null,
  }: let
    apply = g: algebra.filterGraph {inherit nodeFilter edgeFilter;} g;
  in
    if graph != null
    then apply graph
    else g: apply g;

  /**
  Extracts an undirected k-hop neighborhood surrounding a center node.
  */
  getNeighborhoodFn = {
    graph,
    nodeId,
    depth ? 1,
  }:
    algebra.neighborhood {
      center = nodeId;
      radius = depth;
    }
    graph;

  /**
  Computes a forward program slice along outgoing edges.
  */
  forwardSliceFn = {
    cpg,
    nodeId,
    maxDepth ? 10,
    layers ? null,
    relations ? null,
  }:
    algebra.slice {
      target = nodeId;
      direction = "forward";
      strata = layers;
      inherit relations maxDepth;
    }
    cpg;

  /**
  Computes a backward program slice along incoming edges.
  */
  backwardSliceFn = {
    cpg,
    nodeId,
    maxDepth ? 10,
    layers ? null,
    relations ? null,
  }:
    algebra.slice {
      target = nodeId;
      direction = "backward";
      strata = layers;
      inherit relations maxDepth;
    }
    cpg;

  /**
  Finds all active implementers fulfilling a target contract.
  */
  findImplementersFn = capabilitiesProj.findImplementers;

  /**
  Finds all consumer instances defining options or sending data into a target contract.
  */
  findConsumersFn = capabilitiesProj.findConsumers;

  /**
  Extracts the dataflow channels for an option path.
  */
  findOptionFlowsFn = dataflowProj.findOptionFlows;

  /**
  Retrieves the scalar resolved value for a contract option on a specific host from the CPG.
  */
  getOptionValueFn = dataflowProj.getOptionValue;
in {
  internal.graph.pipeline = {
    inherit
      render
      renderMarkdown
      renderMermaid
      serializers
      query
      buildCPGFn
      buildSpineFn
      toArchitectureLPGFn
      buildSpineGraphFn
      buildGraphFn
      filterGraphFn
      getNeighborhoodFn
      forwardSliceFn
      backwardSliceFn
      findImplementersFn
      findConsumersFn
      findOptionFlowsFn
      getOptionValueFn
      ;
    inherit (cpgExtractor) buildCPG buildSpine;
    inherit (mermaidFlowchart) renderFlowchart;
  };
}
