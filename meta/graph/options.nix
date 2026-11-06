{lib, ...}: {
  options.internal.graph = {
    core = {
      types = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Core graph types and URN generators.";
      };
      container = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Multi-indexed graph container.";
      };
      algebra = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Pure algebraic graph calculus.";
      };
    };
    pipeline = lib.mkOption {
      type = lib.types.raw;
      default = {};
      description = "Core graph construction and pipeline query operations.";
    };
    extractors = {
      source = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Source file resolution and AST syntax extraction utilities.";
      };
      onto = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Ontological Intent stratum extractor.";
      };
      ontoMetadata = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Ontological instance metadata builder.";
      };
      ast = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Syntactic AST stratum extractor.";
      };
      astModules = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Syntactic AST module node and edge extractor.";
      };
      astContracts = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Syntactic AST contract option and type extractor.";
      };
      astSymbols = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Syntactic AST library symbol extractor.";
      };
      eval = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Operational fixpoint PDG extractor.";
      };
      evalDataflow = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Operational fixpoint dataflow channel extractor.";
      };
      drv = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Derivation substrate extractor.";
      };
      drvDependencies = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Derivation dependency edge extractor.";
      };
      cpg = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Unified multi-strata Semantic CPG extractor.";
      };
    };
    projections = {
      architecture = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Architecture quotient functor.";
      };
      capabilities = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Contract bipartite projection.";
      };
      dataflow = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Data flow channels projection.";
      };
    };
    serializers = {
      json = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "JSON Graph Format (JGF) serializer.";
      };
      mermaid = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Mermaid flowchart serializer.";
      };
      dot = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Graphviz DOT serializer.";
      };
    };
    query = lib.mkOption {
      type = lib.types.raw;
      default = {};
      description = "Fluent graph query selectors, pathfinding, and DAG hierarchy traversal.";
    };
    render = {
      markdown = {
        table = lib.mkOption {
          type = lib.types.raw;
          default = {};
          description = "Markdown table rendering utilities.";
        };
        matrix = lib.mkOption {
          type = lib.types.raw;
          default = {};
          description = "Markdown matrix rendering utilities.";
        };
        tree = lib.mkOption {
          type = lib.types.raw;
          default = {};
          description = "Markdown tree rendering utilities.";
        };
        entity = lib.mkOption {
          type = lib.types.raw;
          default = {};
          description = "Markdown entity inspection sheet rendering utilities.";
        };
      };
      mermaid = {
        theme = lib.mkOption {
          type = lib.types.raw;
          default = {};
          description = "Mermaid flowchart styling themes and node formatters.";
        };
        flowchart = lib.mkOption {
          type = lib.types.raw;
          default = {};
          description = "Mermaid flowchart diagram rendering utilities.";
        };
      };
    };
  };
}
