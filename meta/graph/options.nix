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
    extractors = {
      onto = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Ontological Intent stratum extractor.";
      };
      ast = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Syntactic AST stratum extractor.";
      };
      eval = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Operational fixpoint PDG extractor.";
      };
      drv = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Derivation substrate extractor.";
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
  };
}
