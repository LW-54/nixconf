{config, ...}: let
  ontoExtractor = config.internal.graph.extractors.onto;
  astExtractor = config.internal.graph.extractors.ast;
  evalExtractor = config.internal.graph.extractors.eval;
  drvExtractor = config.internal.graph.extractors.drv;
  algebra = config.internal.graph.core.algebra;

  /**
  Builds the lightweight structural spine of the repository graph.
  Unites:
  - Stratum 1: Ontological Intent (onto)
  - Stratum 2: Lexical & Syntactic AST (ast)
  - Stratum 3: Structural System Configurations & Imports (eval without full dataflow fixpoints)
  Evaluates in < 0.4s without forcing heavy NixOS options trees.
  */
  buildSpineFn = {system ? "x86_64-linux"}: let
    ontoGraph = ontoExtractor.extract {};
    astGraph = astExtractor.extract {};
    evalGraph = evalExtractor.extract {
      inherit system;
      includeDataFlow = false;
    };
  in
    algebra.overlayList [
      ontoGraph
      astGraph
      evalGraph
    ];

  /**
  Builds the complete multi-strata Semantic Code Property Graph (CPG).
  Unites:
  - Stratum 1: Ontological Intent (onto)
  - Stratum 2: Lexical & Syntactic AST (ast)
  - Stratum 3: Operational Fixpoint PDG (eval)
  - Stratum 4: Derivation Materialization DAG (drv)
  */
  buildCPGFn = {
    system ? "x86_64-linux",
    includeDataFlow ? true,
  }: let
    ontoGraph = ontoExtractor.extract {};
    astGraph = astExtractor.extract {};
    evalGraph = evalExtractor.extract {
      inherit system;
      inherit includeDataFlow;
    };
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

      `includeDataFlow`
      : Boolean flag indicating whether to extract fine-grained contract option dataflow edges (defaults to true).

      # Type
      ```
      buildCPG :: AttrSet -> AttrSet
      ```
    '';
    value = buildCPGFn;
  };

  buildSpine = {
    docstring = ''
      Extracts the lightweight structural spine (Onto, AST, and Structural Configurations) without evaluating full machine module fixpoints.

      # Inputs

      `system`
      : Architecture target system string (defaults to "x86_64-linux").

      # Type
      ```
      buildSpine :: AttrSet -> AttrSet
      ```
    '';
    value = buildSpineFn;
  };
in {
  internal.graph.extractors.cpg = {
    inherit
      buildSpineFn
      buildSpine
      buildCPGFn
      buildCPG
      ;
  };
}
