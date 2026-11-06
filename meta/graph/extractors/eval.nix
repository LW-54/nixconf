# Operational fixpoint PDG extractor for NixOS host configurations and dataflow channels.
{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  container = config.internal.graph.core.container;
  dataflow = config.internal.graph.extractors.evalDataflow;

  inherit (dataflow) cleanSourcePath parseViaOption extractScalarValue extractHostDataFlow;
  collectHostImportedModules = config.flake.lib.host.collectHostImportedModules;

  extractEval = {
    system ? "x86_64-linux",
    includeDataFlow ? true,
  }: let
    hosts = config.host or {};
    implementations = config.implementation or {};
    nixosConfigs = config.flake.nixosConfigurations or {};
    flakeModules = config.flake.nixosModules or {};

    hostNames = builtins.attrNames hosts;
    contractNames = builtins.attrNames (config.contract or {});

    # 1. System Configuration Nodes
    configurationNodes = lib.mapAttrs' (hName: _: let
      urn = types.mkURN {
        stratum = types.strata.eval;
        kind = "configuration";
        id = hName;
      };
      node = types.mkNode {
        stratum = types.strata.eval;
        kind = "configuration";
        id = hName;
        label = "nixosConfiguration/${hName}";
        origin = {
          stratum = types.strata.onto;
          kind = "host";
          instance = hName;
          facet = "configuration";
        };
        meta = {
          host = hName;
          inherit system;
        };
      };
    in
      lib.nameValuePair urn node)
    hosts;

    # 2. Host outputs Configuration Edges
    hostOutputsConfigEdges = map (hName: let
      hURN = types.mkURN {
        stratum = types.strata.onto;
        kind = "host";
        id = hName;
      };
      cURN = types.mkURN {
        stratum = types.strata.eval;
        kind = "configuration";
        id = hName;
      };
    in
      types.mkEdge {
        source = hURN;
        target = cURN;
        relation = types.relations.OUTPUTS;
        stratum = types.strata.ast;
        meta = {facet = "configuration";};
      })
    hostNames;

    # 3. Configuration IMPORTS Module Edges
    configImportModuleEdges = lib.concatMap (hName: let
      h = hosts.${hName};
      importedModuleNames = collectHostImportedModules h;
      cURN = types.mkURN {
        stratum = types.strata.eval;
        kind = "configuration";
        id = hName;
      };
      validModules = lib.filter (m: flakeModules ? ${m}) importedModuleNames;
    in
      map (mName: let
        mURN = types.mkURN {
          stratum = types.strata.ast;
          kind = "module";
          id = mName;
        };
      in
        types.mkEdge {
          source = cURN;
          target = mURN;
          relation = types.relations.IMPORTS;
          stratum = types.strata.eval;
          meta = {
            host = hName;
            module = mName;
          };
        })
      validModules)
    hostNames;

    # Map contract -> active implementation module name per host
    activeContractImplementersByHost = lib.genAttrs hostNames (hName: let
      h = hosts.${hName};
      importedModuleNames = collectHostImportedModules h;
    in
      lib.concatMapAttrs (implName: impl:
        if builtins.elem implName importedModuleNames
        then {${impl.contract} = implName;}
        else {})
      implementations);

    # 4. Pure Option Data Flow Extraction (WRITES, READS, FLOWS_TO)
    hostDataFlow =
      if includeDataFlow
      then
        container.dedupEdges (lib.concatMap (hName:
          extractHostDataFlow {
            inherit hName nixosConfigs activeContractImplementersByHost contractNames flakeModules;
          })
        hostNames)
      else [];

    allNodes = configurationNodes;
    allEdges =
      hostOutputsConfigEdges
      ++ configImportModuleEdges
      ++ hostDataFlow;
  in
    container.mkGraph {
      nodes = allNodes;
      edges = allEdges;
      meta = {
        stratum = types.strata.eval;
        inherit activeContractImplementersByHost;
      };
    };
in {
  internal.graph.extractors.eval = {
    extract = extractEval;
    extractHostDataFlow = hName:
      extractHostDataFlow {
        inherit hName;
        activeContractImplementersByHost = (extractEval {includeDataFlow = false;}).meta.activeContractImplementersByHost;
      };
    inherit cleanSourcePath parseViaOption collectHostImportedModules extractScalarValue;
  };
}
