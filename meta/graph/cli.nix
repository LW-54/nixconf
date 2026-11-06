# `nix run .#graph` CLI and serialized JSON graph artifacts.
{config, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    graphLib = config.flake.lib.graph;
    graph = graphLib.buildGraph {inherit system;};
    cpg = graphLib.buildCPG {inherit system;};

    jsonCPG = pkgs.writeText "nixconf-cpg.json" (builtins.toJSON cpg);
    jsonGraph = pkgs.writeText "nixconf-graph.json" (builtins.toJSON graph);

    graphCli = pkgs.writeShellApplication {
      name = "nixconf-graph";
      runtimeInputs = [pkgs.coreutils];
      text = ''
        show_help() {
          echo "Usage: nixconf-graph [OPTION]"
          echo ""
          echo "Options:"
          echo "  --json             Print the architecture LPG as JSON"
          echo "  --cpg-json         Print the full multi-strata CPG as JSON"
          echo "  --subgraph <urn>   Print the Mermaid neighborhood for a node URN"
          echo "  --stats            Print graph node/edge/relation counts"
          echo "  --help, -h         Show this help message"
        }

        case "''${1:-}" in
          --json)
            cat "${jsonGraph}"
            ;;
          --cpg-json)
            cat "${jsonCPG}"
            ;;
          --subgraph)
            if [ "$#" -lt 2 ]; then
              echo "Error: --subgraph requires a node URN (e.g. urn:nixconf:onto:contract:persistence)" >&2
              exit 1
            fi
            nix eval --raw --apply "f: f.graph.renderMermaid { graph = f.graph.getNeighborhood { graph = f.graph.buildGraph {}; nodeId = \"$2\"; }; }" .#lib
            ;;
          --stats)
            echo "Architecture LPG: ${toString (builtins.length (builtins.attrValues graph.nodes))} nodes, ${toString (builtins.length graph.edges)} edges"
            echo "Multi-Strata CPG: ${toString (builtins.length (builtins.attrValues cpg.nodes))} nodes, ${toString (builtins.length cpg.edges)} edges"
            ;;
          --help|-h|"")
            show_help
            ;;
          *)
            echo "Unknown option: $1" >&2
            show_help >&2
            exit 1
            ;;
        esac
      '';
    };
  in {
    packages.graph = graphCli;
    packages.cpg-json = jsonCPG;
    packages.nixconf-json = jsonGraph;
  };
}
