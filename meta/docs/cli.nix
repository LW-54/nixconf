# `nix run .#docs` CLI and the `checks.docs` flake check. Command-line flags
# are declared once in `commands` and reused for `--help` and the docs page.
{
  self,
  lib,
  config,
  ...
}: let
  md = config.internal.docs.md;

  commands = [
    {
      flag = "--write";
      description = "Write the generated documentation (README.md, docs/**/*.md) to the working tree and delete stale pages.";
    }
    {
      flag = "--check";
      description = "Verify that the working tree matches the evaluated documentation (missing, outdated, or stale pages).";
    }
    {
      flag = "--list";
      description = "List the files produced by the generator.";
    }
    {
      flag = "--json";
      description = "Print the architecture graph as JSON.";
    }
    {
      flag = "--subgraph";
      arg = "<urn>";
      description = "Print the Mermaid neighborhood of a graph node (e.g. urn:nixconf:onto:contract:persistence).";
    }
    {
      flag = "--help";
      description = "Show this help message.";
    }
  ];

  usage = cmd: "${cmd.flag}${lib.optionalString (cmd ? arg) " ${cmd.arg}"}";

  helpText = lib.concatStringsSep "\n" (
    ["Usage: nixconf-docs [OPTION]" "" "Options:"]
    ++ map (cmd: let
      u = usage cmd;
    in "  ${u}${lib.concatStrings (lib.genList (_: " ") (lib.max 1 (22 - builtins.stringLength u)))}${cmd.description}")
    commands
  );

  # Compares a generated tree against a repository root; shared by the CLI and the flake check.
  compareScript = generated: root: ''
    FAILED=0
    while IFS= read -r -d "" src; do
      rel="''${src#${generated}/}"
      if [ ! -f "${root}/$rel" ]; then
        echo "Missing generated file: $rel" >&2
        FAILED=1
      elif ! diff -q "$src" "${root}/$rel" >/dev/null 2>&1; then
        echo "Out of sync: $rel" >&2
        FAILED=1
      fi
    done < <(find -L "${generated}" -type f -print0)

    if [ -d "${root}/docs" ]; then
      while IFS= read -r -d "" existing; do
        rel="''${existing#${root}/}"
        if [ ! -f "${generated}/$rel" ]; then
          echo "Stale file (no longer generated): $rel" >&2
          FAILED=1
        fi
      done < <(find "${root}/docs" -type f -name '*.md' -print0)
    fi
  '';
in {
  docs.pages.documentation.sections.cli = {
    order = 60;
    content = ctx: ''
      ## Command Reference

      ${md.table {
        headers = ["Command" "Description"];
        columns = [
          (cmd: "`nix run .#docs -- ${usage cmd}`")
          (cmd: cmd.description)
        ];
        rows = commands;
      }}

      The `docs` flake check (part of `nix flake check`) fails whenever the committed documentation differs from the generated one.
    '';
  };

  perSystem = {
    pkgs,
    system,
    ...
  }: let
    graph = config.flake.lib.graph.buildGraph {inherit system;};
    files = config.flake.lib.docs.generateAll {inherit graph system;};

    docFiles = pkgs.linkFarm "nixconf-docs-files" (lib.mapAttrsToList (name: content: {
        inherit name;
        path = pkgs.writeText (builtins.baseNameOf name) content;
      })
      files);

    jsonGraph = pkgs.writeTextFile {
      name = "nixconf.json";
      text = builtins.toJSON graph;
    };

    jsonScript = pkgs.writeShellApplication {
      name = "nixconf-json";
      runtimeInputs = [pkgs.coreutils];
      meta = {
        description = "Exported Labeled Property Graph (LPG) representation of repository architecture in JSON format.";
        usage = ''
          Semantic Code Property Graph JSON exporter. Directly outputs the complete graph containing all syntax, ontology, evaluation, and derivation nodes and edges.

          ```bash
          # Query all package nodes with jq
          nix run .#nixconf-json | jq '.nodes[] | select(.kind == "package")'
          ```
        '';
        helpCommand = "nixconf-json --help";
      };
      text = ''
        if [ "''${1:-}" = "--help" ] || [ "''${1:-}" = "-h" ]; then
          echo "Usage: nixconf-json"
          echo "Print repository LPG architecture graph in JSON format to stdout."
          exit 0
        fi
        cat "${jsonGraph}"
      '';
    };

    docsApp = pkgs.writeShellApplication {
      name = "nixconf-docs";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.diffutils
        pkgs.findutils
        pkgs.nix
      ];
      meta = {
        description = "Unified documentation generator, validation test runner, and synchronization toolchain.";
        usage = ''
          Documentation generator and validator suite CLI.

          ```bash
          # Write generated markdown documentation to repository tree
          nix run .#docs -- --write

          # Verify committed documentation matches evaluated specification
          nix run .#docs -- --check

          # List all generated documentation target files
          nix run .#docs -- --list

          # Export full semantic architecture graph as JSON
          nix run .#docs -- --json

          # Render Mermaid architecture diagram of a specific graph node
          nix run .#docs -- --subgraph urn:nixconf:onto:contract:persistence
          ```
        '';
        helpCommand = "nixconf-docs --help";
      };
      text = ''
        show_help() {
          cat <<'HELP'
        ${helpText}
        HELP
        }

        case "''${1:-}" in
          --write)
            COUNT=0
            while IFS= read -r -d "" src; do
              rel="''${src#${docFiles}/}"
              mkdir -p "$(dirname "$rel")"
              cp -f "$src" "$rel"
              chmod 644 "$rel"
              COUNT=$((COUNT + 1))
            done < <(find -L "${docFiles}" -type f -print0)

            if [ -d docs ]; then
              while IFS= read -r -d "" existing; do
                if [ ! -f "${docFiles}/$existing" ]; then
                  rm -f "$existing"
                  echo "Removed stale file: $existing"
                fi
              done < <(find docs -type f -name '*.md' -print0)
              find docs -type d -empty -delete
            fi

            echo "Documentation synchronized: $COUNT files written."
            ;;
          --check)
            ${compareScript docFiles "."}
            if [ "$FAILED" -eq 1 ]; then
              echo "" >&2
              echo "Documentation is out of date. Run 'nix run .#docs -- --write' to update it." >&2
              exit 1
            fi
            echo "All documentation files are synchronized with Nix evaluation."
            ;;
          --list)
            ${lib.concatMapStringsSep "\n" (f: "echo ${lib.escapeShellArg f}") (builtins.attrNames files)}
            ;;
          --json)
            cat "${jsonGraph}"
            ;;
          --subgraph)
            if [ "$#" -lt 2 ]; then
              echo "Error: --subgraph requires a node URN (e.g. urn:nixconf:onto:contract:persistence)" >&2
              exit 1
            fi
            nix eval --raw --apply "f: f.graph.renderMermaid { graph = f.graph.getNeighborhood { graph = f.graph.buildGraph {}; nodeId = \"$2\"; }; }" .#lib
            ;;
          --help | -h | "")
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
    packages.docs = docsApp;
    packages.nixconf-json = jsonScript;

    checks.docs =
      pkgs.runCommand "check-docs-synchronized" {
        nativeBuildInputs = [
          pkgs.diffutils
          pkgs.findutils
        ];
      } ''
        ${compareScript docFiles self}
        if [ "$FAILED" -eq 1 ]; then
          echo "Documentation synchronization check failed. Run 'nix run .#docs -- --write'." >&2
          exit 1
        fi
        touch $out
      '';
  };
}
