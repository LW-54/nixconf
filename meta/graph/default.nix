{
  lib,
  config,
  ...
}: let
  cpgExtractor = config.internal.graph.extractors.cpg;
  architectureProj = config.internal.graph.projections.architecture;
  capabilitiesProj = config.internal.graph.projections.capabilities;
  dataflowProj = config.internal.graph.projections.dataflow;
  algebra = config.internal.graph.core.algebra;
  types = config.internal.graph.core.types;
  container = config.internal.graph.core.container;
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
  Projects the fine-grained CPG into the macro Labeled Property Graph (LPG) format.
  */
  toArchitectureLPGFn = architectureProj.toArchitectureLPG;

  buildGraphFn = {system ? "x86_64-linux"}: let
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
  lib.graph = {
    description = "Canonical Semantic Code Property Graph (CPG) framework, algebraic calculus, and architectural projection functors.";
    symbols = {
      buildCPG = cpgExtractor.buildCPG;

      buildGraph = {
        docstring = ''
          Builds the complete macro architectural graph directly from evaluated flake declarations.

          # Inputs

          `system`
          : Architecture target system string (defaults to "x86_64-linux").

          # Type
          ```
          buildGraph :: AttrSet -> AttrSet
          ```
        '';
        value = buildGraphFn;
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
        value = toArchitectureLPGFn;
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
        value = filterGraphFn;
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
        value = getNeighborhoodFn;
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
        value = forwardSliceFn;
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
        value = backwardSliceFn;
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
        value = findImplementersFn;
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
        value = findConsumersFn;
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
        value = findOptionFlowsFn;
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
        value = getOptionValueFn;
      };
    };
  };
}
