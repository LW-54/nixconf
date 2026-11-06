# Syntactic AST Stratum extractor combining modules, contract options, and library symbols.
{config, ...}: let
  types = config.internal.graph.core.types;
  container = config.internal.graph.core.container;
  astModules = config.internal.graph.extractors.astModules;
  astContracts = config.internal.graph.extractors.astContracts;
  astSymbols = config.internal.graph.extractors.astSymbols;

  inherit (astModules) moduleProducerMap describeModule;
  inherit (astContracts) flattenOptionsTree typeMatches;

  extractAST = {}: let
    modData = astModules.extractModuleData {};
    contractData = astContracts.extractContractData {};
    symData = astSymbols.extractLibSymbolData {};

    allNodes = modData.moduleNodes // contractData.optionNodes // contractData.typeNodes // symData.symbolNodes;
    allEdges =
      modData.moduleOutputEdges
      ++ contractData.optionDeclaresEdges
      ++ contractData.typeDeclaresEdges
      ++ contractData.optionTypedByEdges
      ++ symData.symbolOutputEdges;
  in
    container.mkGraph {
      nodes = allNodes;
      edges = allEdges;
      meta = {
        stratum = types.strata.ast;
        inherit (modData) moduleProducerMap;
      };
    };
in {
  internal.graph.extractors.ast = {
    extract = extractAST;
    inherit flattenOptionsTree typeMatches describeModule moduleProducerMap;
  };
}
