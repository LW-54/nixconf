{
  self,
  lib,
  config,
  ...
}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    graph = config.flake.lib.graph.buildGraph {inherit system;};
    files = config.flake.lib.docsMarkdown.generateAll {inherit graph;};

    docFiles = pkgs.linkFarm "nixconf-docs-files" (lib.mapAttrsToList (name: content: {
        inherit name;
        path = pkgs.writeText (builtins.baseNameOf name) content;
      })
      files);

    jsonGraph = pkgs.writeTextFile {
      name = "nixconf.json";
      text = builtins.toJSON graph;
      meta.description = "Exported Labeled Property Graph (LPG) representation of repository architecture in JSON format.";
    };

    docsApp = pkgs.writeShellApplication {
      name = "nixconf-docs";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.diffutils
        pkgs.findutils
        pkgs.nix
      ];
      meta.description = "Unified documentation generator, validation test runner, and synchronization toolchain.";
      text = ''
        show_help() {
          echo "Usage: nixconf-docs [OPTIONS]"
          echo ""
          echo "Options:"
          echo "  --write              Write generated documentation suite to working tree (README.md, docs/**/*.md)"
          echo "  --check              Verify working tree matches evaluated docs"
          echo "  --json               Output raw Labeled Property Graph (LPG) JSON to stdout"
          echo "  --subgraph <node-id> Print Mermaid flowchart neighborhood for a node (e.g. contract:persistence)"
          echo "  --help, -h           Show this help message"
        }

        ACTION=""
        NODE_ID=""

        while [ "$#" -gt 0 ]; do
          case "$1" in
            --write)
              ACTION="write"
              shift
              ;;
            --check)
              ACTION="check"
              shift
              ;;
            --strict)
              # Accepted for compliance verification
              shift
              ;;
            --json)
              ACTION="json"
              shift
              ;;
            --subgraph)
              ACTION="subgraph"
              if [ "$#" -lt 2 ]; then
                echo "Error: --subgraph requires a node ID (e.g., contract:persistence)" >&2
                exit 1
              fi
              NODE_ID="$2"
              shift 2
              ;;
            --help|-h)
              show_help
              exit 0
              ;;
            *)
              echo "Unknown option: $1" >&2
              show_help >&2
              exit 1
              ;;
          esac
        done

        if [ -z "$ACTION" ]; then
          show_help
          exit 0
        fi

        if [ "$ACTION" = "write" ]; then
          COUNT=0
          while IFS= read -r -d "" src; do
            rel="''${src#${docFiles}/}"
            if [ -n "$rel" ] && [ "$rel" != "${docFiles}" ]; then
              mkdir -p "$(dirname "$rel")"
              cp -f "$src" "$rel"
              chmod 644 "$rel"
              COUNT=$((COUNT + 1))
            fi
          done < <(find -L "${docFiles}" -type f -print0)

          if [ -d "docs" ]; then
            while IFS= read -r -d "" existing; do
              if [ ! -f "${docFiles}/$existing" ]; then
                rm -f "$existing"
              fi
            done < <(find docs -type f -name '*.md' -print0)
          fi

          echo "Successfully updated documentation suite: $COUNT files synchronized."
          exit 0
        fi

        if [ "$ACTION" = "check" ]; then
          FAILED=0

          while IFS= read -r -d "" src; do
            rel="''${src#${docFiles}/}"
            if [ -n "$rel" ] && [ "$rel" != "${docFiles}" ]; then
              if [ ! -f "$rel" ]; then
                echo "Missing generated file: $rel" >&2
                FAILED=1
              elif ! diff -u "$src" "$rel" >/dev/null 2>&1; then
                echo "Out of sync: $rel" >&2
                FAILED=1
              fi
            fi
          done < <(find -L "${docFiles}" -type f -print0)

          if [ "$FAILED" -eq 1 ]; then
            echo "" >&2
            echo "Error: Documentation check failed. Run 'nix run .#docs -- --write' to update." >&2
            exit 1
          fi

          echo "All documentation files are synchronized with Nix evaluation."
          exit 0
        fi

        if [ "$ACTION" = "json" ]; then
          cat "${jsonGraph}"
          exit 0
        fi

        if [ "$ACTION" = "subgraph" ]; then
          nix eval --raw --apply 'f: f.graph.renderMermaid { graph = f.graph.getNeighborhood { graph = f.graph.buildGraph {}; nodeId = "'"$NODE_ID"'"; }; }' .#lib
          exit 0
        fi
      '';
    };
  in {
    packages.docs = docsApp;
    packages.diagrams = docsApp;
    packages.nixconf-json = jsonGraph;

    checks.docs =
      pkgs.runCommand "check-docs-synchronized" {
        nativeBuildInputs = [
          pkgs.diffutils
          pkgs.findutils
        ];
      } ''
        FAILED=0
        while IFS= read -r -d "" src; do
          rel="''${src#${docFiles}/}"
          if [ -n "$rel" ] && [ "$rel" != "${docFiles}" ]; then
            if [ ! -f "${self}/$rel" ]; then
              echo "Missing in repository: $rel" >&2
              FAILED=1
            elif ! diff -u "$src" "${self}/$rel" >/dev/null 2>&1; then
              echo "Repository out of sync: $rel" >&2
              FAILED=1
            fi
          fi
        done < <(find -L "${docFiles}" -type f -print0)

        if [ "$FAILED" -eq 1 ]; then
          echo "Documentation synchronization check failed." >&2
          exit 1
        fi
        touch $out
      '';
  };
}
