# Documentation page of the Semantic Code Property Graph (docs/graph.md).
# Metrics, strata, relations, and node kinds are computed from the evaluated
# graph; their prose comes from the registries in core/types.nix.
{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  graphLib = config.flake.lib.graph;

  count = xs: toString (builtins.length xs);
in {
  docs.pages.graph = {
    path = "docs/graph.md";
    sections = {
      header = {
        order = 5;
        content = ctx: ''
          # Semantic Code Property Graph

          Unified pure-Nix graph merging ontological intent, syntax, evaluation, and derivation strata, powering diagrams and cross-references.

          ${ctx.backTo "readme" "Main README"}
        '';
      };

      metrics = {
        order = 10;
        content = ctx: let
          nodes = builtins.attrValues ctx.cpg.nodes;
        in ''
          ## Metrics

          ${ctx.md.table {
            headers = ["Dimension" "Value" "Description"];
            columns = [
              (r: "**${r.name}**")
              (r: r.value)
              (r: r.description)
            ];
            rows = [
              {
                name = "Nodes";
                value = count nodes;
                description = "Discrete architectural entities tracked across ontology, AST syntax, evaluation, and derivations.";
              }
              {
                name = "Edges";
                value = count ctx.cpg.edges;
                description = "Typed semantic directed edges connecting graph entities.";
              }
              {
                name = "Relations";
                value = count (lib.unique (map (e: e.relation) ctx.cpg.edges));
                description = "Unique relation kinds expressing dependencies, flows, definitions, and bindings.";
              }
              {
                name = "Node kinds";
                value = count (lib.unique (map (n: n.kind) nodes));
                description = "Structural node classifications (e.g. host, contract, feature, module, option, package).";
              }
              {
                name = "Strata";
                value = count (builtins.attrNames types.strata);
                description = "Orthogonal graph evaluation layers (Ontology, AST, Evaluation, Derivation).";
              }
            ];
          }}
        '';
      };

      strata = {
        order = 20;
        content = ctx: let
          byStratum = lib.groupBy (n: n.stratum) (builtins.attrValues ctx.cpg.nodes);
        in ''
          ## Strata

          ${ctx.md.table {
            headers = ["Stratum" "Name" "Nodes" "Description"];
            columns = [
              (s: "`${s}`")
              (s: types.strataInfo.${s}.label or "—")
              (s: count (byStratum.${s} or []))
              (s: types.strataInfo.${s}.description or "*undocumented*")
            ];
            rows = builtins.attrValues types.strata;
          }}
        '';
      };

      schema = {
        order = 25;
        content = ctx: let
          schemaId = n: "schema:${n.stratum}:${n.kind}";
          nodes = builtins.attrValues ctx.cpg.nodes;
          schemaNodes = lib.listToAttrs (map (n:
            lib.nameValuePair (schemaId n) {
              id = schemaId n;
              inherit (n) kind stratum;
              name = n.kind;
              label = n.kind;
            })
          nodes);
          schemaEdges = lib.unique (lib.concatMap (e: let
            s = ctx.cpg.nodes.${e.source} or null;
            t = ctx.cpg.nodes.${e.target} or null;
          in
            lib.optional (s != null && t != null) {
              source = schemaId s;
              target = schemaId t;
              inherit (e) relation;
            })
          ctx.cpg.edges);
        in
          ctx.md.blocks [
            "## Graph Schema"
            "Every distinct `(kind, relation, kind)` triple observed in the graph, clustered by stratum:"
            (graphLib.renderMermaid {
              graph = {
                nodes = schemaNodes;
                edges = schemaEdges;
              };
              layout = "LR";
              clusterBy = "stratum";
            })
          ];
      };

      relations = {
        order = 30;
        content = ctx: let
          byRelation = lib.groupBy (e: e.relation) ctx.cpg.edges;
        in ''
          ## Relations

          ${ctx.md.table {
            headers = ["Relation" "Strata" "Edges" "Meaning" "Grounding"];
            columns = [
              (r: "`${r}`")
              (r: let
                strata = lib.unique (map (e: e.stratum) (byRelation.${r} or []));
              in
                if strata == []
                then "—"
                else lib.concatMapStringsSep ", " (s: "`${s}`") strata)
              (r: count (byRelation.${r} or []))
              (r: types.relationInfo.${r}.description or "*undocumented*")
              (r: types.relationInfo.${r}.grounding or "—")
            ];
            rows = lib.unique (builtins.attrValues types.relations ++ builtins.attrNames byRelation);
          }}
        '';
      };

      kinds = {
        order = 40;
        content = ctx: let
          byKind = lib.groupBy (n: n.kind) (lib.sort (a: b: a.id < b.id) (builtins.attrValues ctx.cpg.nodes));
        in ''
          ## Node Kinds

          ${ctx.md.table {
            headers = ["Kind" "Strata" "Nodes" "Example URN" "Description"];
            columns = [
              (k: "`${k}`")
              (k: lib.concatMapStringsSep ", " (s: "`${s}`") (lib.unique (map (n: n.stratum) byKind.${k})))
              (k: count byKind.${k})
              (k: "`${(builtins.head byKind.${k}).id}`")
              (k: types.kindInfo.${k} or "*undocumented*")
            ];
            rows = builtins.attrNames byKind;
          }}
        '';
      };

      inspecting = {
        order = 50;
        content = ctx: let
          firstId = kind: fallback: (lib.findFirst (_: true) {id = fallback;} (ctx.nodes kind)).id;
          contract = firstId "contract" "urn:nixconf:onto:contract:<name>";
          configuration = firstId "configuration" "urn:nixconf:eval:configuration:<host>";
          option = firstId "option" "urn:nixconf:ast:option:<path>";
        in ''
          ## Querying & Inspecting the Graph

          Graph algorithms, traversal engines, and Mermaid exporters are implemented as pure Nix functions in ${ctx.pageLink "lib/graph" "flake.lib.graph"}.

          ### Pure Nix Query API

          - `graphLib.getNeighborhood { graph, nodeId, depth }`: Extracts the local subgraph within `depth` hops of `nodeId`.
          - `graphLib.filterGraph { nodeFilter, edgeFilter } graph`: Applies arbitrary predicate filters to prune nodes and relations.
          - `graphLib.findConsumers { graph, contractId }`: Returns all features and host configurations writing options under a contract.
          - `graphLib.forwardSlice { cpg, nodeId, maxDepth }`: Computes all reachable downstream dependencies from a given node.
          - `graphLib.backwardSlice { cpg, nodeId, maxDepth }`: Computes all upstream providers and writers influencing a node.

          ### CLI Tools

          ${ctx.md.code "bash" ''
            # Output the full Semantic Code Property Graph as JSON directly
            nix run .#nixconf-json

            # Summary of nodes, edges and relation counts
            nix run .#docs -- --json | jq '{nodes: (.nodes | length), edges: (.edges | length)}'

            # Inspect every option write with source file provenance
            nix run .#docs -- --json | jq '.edges[] | select(.relation == "writes") | {source, target, file: .meta.file}'

            # Render the Mermaid neighborhood of a specific entity
            nix run .#docs -- --subgraph ${contract}
          ''}

          ### Evaluation Queries

          ${ctx.md.code "bash" ''
            # Forward slice from a configuration (reachable dependencies)
            nix eval --json --apply 'l: builtins.attrNames (l.graph.forwardSlice { cpg = l.graph.buildCPG {}; nodeId = "${configuration}"; maxDepth = 2; }).nodes' .#lib

            # Backward slice from an option (writers and consumers)
            nix eval --json --apply 'l: builtins.attrNames (l.graph.backwardSlice { cpg = l.graph.buildCPG {}; nodeId = "${option}"; maxDepth = 2; }).nodes' .#lib
          ''}
        '';
      };
    };
  };
}
