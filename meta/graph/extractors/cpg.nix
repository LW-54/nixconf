{config, ...}: let
  ontoExtractor = config.internal.graph.extractors.onto;
  astExtractor = config.internal.graph.extractors.ast;
  evalExtractor = config.internal.graph.extractors.eval;
  drvExtractor = config.internal.graph.extractors.drv;
  algebra = config.internal.graph.core.algebra;

  /**
  Builds the complete multi-strata Semantic Code Property Graph (CPG).
  Unites:
  - Stratum 1: Ontological Intent (onto)
  - Stratum 2: Lexical & Syntactic AST (ast)
  - Stratum 3: Operational Fixpoint PDG (eval)
  - Stratum 4: Derivation Materialization DAG (drv)
  */
  buildCPGFn = {system ? "x86_64-linux"}: let
    ontoGraph = ontoExtractor.extract {};
    astGraph = astExtractor.extract {};
    evalGraph = evalExtractor.extract {inherit system;};
    drvGraph = drvExtractor.extract {inherit system;};

    fullCPG = algebra.overlayList [
      ontoGraph
      astGraph
      evalGraph
      drvGraph
    ];
  in
    fullCPG
    // {
      meta = {
        description = "Unified Multi-Strata Semantic Code Property Graph (CPG)";
        system = system;
        strata = ["onto" "ast" "eval" "drv"];
      };
    };

  buildCPG = {
    docstring = ''
      Extracts and constructs the unified Semantic Code Property Graph (CPG) merging Ontological, AST, Evaluation/PDG, and Derivation strata.

      # Inputs

      `system`
      : Architecture target system string (defaults to "x86_64-linux").

      # Type
      ```
      buildCPG :: AttrSet -> AttrSet
      ```
    '';
    value = buildCPGFn;
  };
in {
  internal.graph.extractors.cpg = {
    inherit
      buildCPGFn
      buildCPG
      ;
  };
}
