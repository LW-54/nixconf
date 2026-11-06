{config, ...}: let
  pipeline = config.internal.graph.pipeline;
in {
  lib.graph = {
    description = "Canonical Semantic Code Property Graph (CPG) framework, algebraic calculus, and architectural projection functors.";
    symbols = {
      buildCPG = pipeline.buildCPG;

      buildSpine = pipeline.buildSpine;

      buildSpineGraph = {
        docstring = ''
          Builds the lightweight architectural graph (LPG) from the structural spine without evaluating NixOS configuration fixpoints.

          # Inputs

          `system`
          : Architecture target system string (defaults to "x86_64-linux").

          # Type
          ```
          buildSpineGraph :: AttrSet -> AttrSet
          ```
        '';
        value = pipeline.buildSpineGraphFn;
      };

      buildGraph = {
        docstring = ''
          Builds the complete macro architectural graph directly from evaluated flake declarations.

          # Inputs

          `spineOnly`
          : Boolean flag to restrict graph construction to the lightweight structural spine (defaults to false).

          `system`
          : Architecture target system string (defaults to "x86_64-linux").

          # Type
          ```
          buildGraph :: AttrSet -> AttrSet
          ```
        '';
        value = pipeline.buildGraphFn;
      };

      toArchitectureLPG = {
        docstring = ''
          Projects the fine-grained Semantic CPG into the macro architectural graph (LPG).

          # Inputs

          `cpg`
          : The evaluated Semantic Code Property Graph attribute set.

          # Type
          ```
          toArchitectureLPG :: AttrSet -> AttrSet
          ```
        '';
        value = pipeline.toArchitectureLPGFn;
      };

      filterGraph = {
        docstring = ''
          Filters a labeled property graph by applying node and edge predicate functions.

          # Inputs

          `nodeFilter`
          : Predicate function filtering nodes by attributes (defaults to keeping all nodes).

          `edgeFilter`
          : Predicate function filtering edges by attributes (defaults to keeping all edges).

          `graph`
          : The input labeled property graph attribute set.

          # Type
          ```
          filterGraph :: AttrSet -> AttrSet -> AttrSet
          ```
        '';
        value = pipeline.filterGraphFn;
      };

      getNeighborhood = {
        docstring = ''
          Extracts an undirected k-hop neighborhood surrounding a center node up to the specified traversal depth.

          # Inputs

          `depth`
          : Graph traversal depth radius (defaults to 1).

          `graph`
          : The complete labeled property graph attribute set.

          `nodeId`
          : Canonical identifier of the center node.

          # Type
          ```
          getNeighborhood :: AttrSet -> AttrSet
          ```
        '';
        value = pipeline.getNeighborhoodFn;
      };

      forwardSlice = {
        docstring = ''
          Computes a forward program slice along outgoing edges up to maxDepth.

          # Inputs

          `cpg`
          : Semantic Code Property Graph attribute set.

          `nodeId`
          : Canonical identifier of the starting node.

          `maxDepth`
          : Maximum traversal depth (defaults to 10).

          `layers`
          : List of CPG strata to traverse (optional, defaults to all).

          `relations`
          : Optional list of specific relations to filter traversal (defaults to null for all).

          # Type
          ```
          forwardSlice :: AttrSet -> AttrSet
          ```
        '';
        value = pipeline.forwardSliceFn;
      };

      backwardSlice = {
        docstring = ''
          Computes a backward program slice along incoming edges up to maxDepth.

          # Inputs

          `cpg`
          : Semantic Code Property Graph attribute set.

          `nodeId`
          : Canonical identifier of the target node.

          `maxDepth`
          : Maximum traversal depth (defaults to 10).

          `layers`
          : List of CPG strata to traverse (optional, defaults to all).

          `relations`
          : Optional list of specific relations to filter traversal (defaults to null for all).

          # Type
          ```
          backwardSlice :: AttrSet -> AttrSet
          ```
        '';
        value = pipeline.backwardSliceFn;
      };

      findImplementers = {
        docstring = ''
          Finds all active implementers fulfilling a target contract.

          # Inputs

          `cpg`
          : Semantic Code Property Graph attribute set.

          `contractId`
          : Canonical identifier of the contract (e.g. "persistence" or "contract:persistence").

          # Type
          ```
          findImplementers :: AttrSet -> AttrSet
          ```
        '';
        value = pipeline.findImplementersFn;
      };

      findConsumers = {
        docstring = ''
          Finds all consumer instances defining options or sending data into a target contract.

          # Inputs

          `cpg`
          : Semantic Code Property Graph attribute set.

          `contractId`
          : Canonical identifier of the contract (e.g. "persistence" or "contract:persistence").

          # Type
          ```
          findConsumers :: AttrSet -> AttrSet
          ```
        '';
        value = pipeline.findConsumersFn;
      };

      findOptionFlows = {
        docstring = ''
          Extracts the dataflow channels and writer/reader nodes for a specific option path.

          # Inputs

          `cpg`
          : Semantic Code Property Graph attribute set.

          `optionPath`
          : Option path string (e.g. "secrets.files").

          # Type
          ```
          findOptionFlows :: AttrSet -> AttrSet
          ```
        '';
        value = pipeline.findOptionFlowsFn;
      };

      getOptionValue = {
        docstring = ''
          Retrieves the scalar resolved value for a contract option on a specific host from the CPG.

          # Inputs

          `cpg`
          : Semantic Code Property Graph attribute set.

          `host`
          : Host identifier string.

          `optionPath`
          : Option path string (e.g. "default-user.username").

          # Type
          ```
          getOptionValue :: AttrSet -> Any
          ```
        '';
        value = pipeline.getOptionValueFn;
      };

      query = {
        docstring = ''
          Fluent graph query selectors, pathfinding, and DAG hierarchy traversal.

          # Type
          ```
          query :: AttrSet
          ```
        '';
        value = pipeline.query;
      };

      render = {
        docstring = ''
          Universal presentation engine for rendering any graph into Markdown tables, trees, matrices, entity sheets, and styled Mermaid flowcharts.

          # Type
          ```
          render :: AttrSet
          ```
        '';
        value = pipeline.render;
      };

      renderTable = {
        docstring = ''
          Universal markdown table generator with configurable column extractors, alignments, and sorting.

          # Inputs

          `align`
          : List of column alignments ("left", "center", "right") (optional, defaults to empty).

          `columns`
          : List of column extraction functions or attribute names.

          `headers`
          : List of column header title strings.

          `reverse`
          : Boolean flag to reverse row ordering (optional, defaults to false).

          `rows`
          : List of row data items or entity attribute sets.

          `sortBy`
          : Optional sorting key lambda (Row -> Comparable) (defaults to null).

          # Type
          ```
          renderTable :: AttrSet -> String
          ```
        '';
        value = pipeline.render.table;
      };

      renderMatrix = {
        docstring = ''
          Two-dimensional cross-tabulation and relationship matrix markdown generator.

          # Inputs

          `cellFn`
          : Custom cell renderer function receiving `{ row, col, edges, matched }` (optional, defaults to null).

          `colLabel`
          : Display title extractor for column entities (optional, defaults to `c.name or c.id`).

          `cols`
          : List of column entities or nodes.

          `graph`
          : Graph attribute set containing edges to match (optional, defaults to null).

          `relation`
          : Optional edge relation name filter (e.g. "implements", "CONSUMES") (defaults to null).

          `rowHeader`
          : Header title for the row index column (defaults to "Entity").

          `rowLabel`
          : Display title extractor for row entities (optional, defaults to `r.name or r.id`).

          `rows`
          : List of row entities or nodes.

          # Type
          ```
          renderMatrix :: AttrSet -> String
          ```
        '';
        value = pipeline.render.matrix;
      };

      renderTree = {
        docstring = ''
          Hierarchical tree generator supporting markdown bullet lists and ASCII tree formats.

          # Inputs

          `format`
          : Optional format style alias ("markdown" or "ascii") (defaults to null).

          `formatNode`
          : Optional node display formatting function (defaults to null).

          `graph`
          : The labeled property graph attribute set.

          `maxDepth`
          : Maximum recursion depth for tree traversal (defaults to 10).

          `relation`
          : Optional edge relation name filter (defaults to null).

          `roots`
          : List of root node IDs or root node attribute sets.

          `style`
          : Formatting style ("markdown" or "ascii") (defaults to "markdown").

          # Type
          ```
          renderTree :: AttrSet -> String
          ```
        '';
        value = pipeline.render.tree;
      };

      renderEntity = {
        docstring = ''
          Entity sheet generator providing comprehensive markdown inspection cards for graph nodes.

          # Inputs

          `graph`
          : The labeled property graph containing the node.

          `includeNeighborhoodDiagram`
          : Boolean flag to embed a Mermaid 1-hop neighborhood diagram (defaults to true).

          `mermaidRenderer`
          : Optional custom function to render a Mermaid diagram from a subgraph (defaults to null).

          `node`
          : The target node attribute set to inspect.

          # Type
          ```
          renderEntity :: AttrSet -> String
          ```
        '';
        value = pipeline.render.entity;
      };

      renderMermaid = {
        docstring = ''
          Advanced Mermaid flowchart renderer with clustering, hyperlinked click events, and semantic class styling.

          # Inputs

          `clusterBy`
          : Optional clustering criterion (e.g. "stratum", "kind", or a grouping lambda) (defaults to null).

          `customEdgeFormatter`
          : Optional custom formatting function for graph edges (defaults to null).

          `customNodeFormatter`
          : Optional custom formatting function for graph nodes (defaults to null).

          `graph`
          : The labeled property graph attribute set.

          `includeTheme`
          : Boolean flag to append semantic CSS class definitions (defaults to true).

          `layout`
          : Flowchart orientation direction ("TD", "LR", "TB", etc.) (defaults to "TD").

          `linkFn`
          : Optional function returning an interactive URL string for a node (defaults to null).

          `raw`
          : Boolean flag to suppress markdown code block fence wrapping (defaults to false).

          `title`
          : Optional flowchart diagram title string (defaults to null).

          `tooltipFn`
          : Optional function returning tooltip hover text for a node (defaults to null).

          `wrapCodeBlock`
          : Boolean flag to enclose flowchart in a markdown ```mermaid code block (defaults to true).

          # Type
          ```
          renderMermaid :: AttrSet -> String
          ```
        '';
        value = pipeline.renderFlowchart;
      };
    };
  };
}
