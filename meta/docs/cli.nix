# `nix run .#docs` CLI and the `checks.docs` flake check. Command-line flags
# are declared once in `commands` and reused for `--help` and the docs page.
{
  self,
  lib,
  config,
  ...
}: let
  md = config.internal.docs.md;
  audit = config.internal.docs.audit;

  commands = [
    {
      flag = "--write";
      description = "Write the generated documentation (README.md, docs/**/*.md) to the working tree and delete stale pages.";
    }
    {
      flag = "--check";
      description = "Verify that the working tree matches evaluated documentation. Prints 1-line health summary if coverage < 100%.";
    }
    {
      flag = "--strict";
      description = "Enforce 100% documentation coverage. When combined with --check, exits 1 on any documentation warning.";
    }
    {
      flag = "--health";
      description = "Print documentation health metrics, coverage percentage, and itemized warning count.";
    }
    {
      flag = "--list";
      description = "List the files produced by the generator.";
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

      The `docs` flake check (part of `nix flake check`) verifies that committed documentation is bit-for-bit synchronized with Nix evaluation.
    '';
  };

  perSystem = {
    pkgs,
    system,
    ...
  }: let
    files = config.flake.lib.docs.generateAll {inherit system;};

    # Native zero-dependency Rust helper for docs materialization, diff-aware sync, and drift check.
    # Compiled once from isolated ./sync.rs and cached in the Nix store.
    docsSyncBin =
      pkgs.runCommandCC "nixconf-docs-sync" {
        nativeBuildInputs = [pkgs.rustc];
      } ''
        mkdir -p $out/bin
        rustc -C opt-level=3 --edition=2021 ${./sync.rs} -o $out/bin/nixconf-docs-sync
      '';

    # Single-derivation store materialization:
    # Streams all generated pages from a single JSON manifest in ~2ms via native Rust,
    # eliminating per-page writeText derivations and Python runtime dependencies.
    docFiles =
      pkgs.runCommandLocal "nixconf-docs-tree" {
        manifest = builtins.toFile "docs-manifest.json" (builtins.toJSON files);
      } ''
        ${docsSyncBin}/bin/nixconf-docs-sync materialize "$manifest" "$out"
      '';

    docsApp =
      (pkgs.writeShellScriptBin "nixconf-docs" ''
        set -euo pipefail

        show_help() {
          cat <<'HELP'
        ${helpText}
        HELP
        }

        # Parse flags
        DO_WRITE=0
        DO_CHECK=0
        DO_LIST=0
        DO_HEALTH=0
        UNDOCUMENTED="${toString audit.undocumentedItems}"
        STRICT_MODE=${
          if config.docs.strict
          then "1"
          else "0"
        }

        if [ "$#" -eq 0 ]; then
          show_help
          exit 0
        fi

        for arg in "$@"; do
          case "$arg" in
            --write)
              DO_WRITE=1
              ;;
            --check)
              DO_CHECK=1
              ;;
            --strict)
              STRICT_MODE=1
              ;;
            --health)
              DO_HEALTH=1
              ;;
            --list)
              DO_LIST=1
              ;;
            --help|-h)
              show_help
              exit 0
              ;;
            *)
              echo "Unknown option: $arg" >&2
              show_help >&2
              exit 1
              ;;
          esac
        done

        if [ "$DO_LIST" -eq 1 ]; then
          ${lib.concatMapStringsSep "\n" (f: "echo ${lib.escapeShellArg f}") (builtins.attrNames files)}
          exit 0
        fi

        if [ "$DO_HEALTH" -eq 1 ]; then
          echo "Documentation Health Overview:"
          echo "  Score:        ${audit.scoreString}"
          echo "  Documented:   ${toString audit.documentedItems} / ${toString audit.totalItems} items"
          echo "  Warnings:     $UNDOCUMENTED"
          echo "  Dashboard:    docs/coverage.md"
          if [ "$STRICT_MODE" -eq 1 ] && [ "$UNDOCUMENTED" -gt 0 ]; then
            echo "" >&2
            echo "Error: Strict mode enabled and documentation health is not 100%." >&2
            exit 1
          fi
          exit 0
        fi

        if [ "$DO_WRITE" -eq 1 ]; then
          ${docsSyncBin}/bin/nixconf-docs-sync write "${docFiles}" "."
          ${
          if !audit.isPerfect
          then ''echo "${audit.summaryLine}" >&2''
          else ""
        }
          exit 0
        fi

        if [ "$DO_CHECK" -eq 1 ]; then
          if ! ${docsSyncBin}/bin/nixconf-docs-sync check "${docFiles}" "."; then
            echo "" >&2
            echo "Documentation is out of date. Run 'nix run .#docs -- --write' to update it." >&2
            exit 1
          fi

          # Unix Rule of Silence: If Health is 100%, print nothing on success!
          # If Health < 100%, print 1-line health summary to stderr.
          ${
          if !audit.isPerfect
          then ''echo "${audit.summaryLine}" >&2''
          else ""
        }

          if [ "$STRICT_MODE" -eq 1 ] && [ "$UNDOCUMENTED" -gt 0 ]; then
            echo "Error: Strict mode enabled and documentation has $UNDOCUMENTED warnings." >&2
            exit 1
          fi

          exit 0
        fi
      '')
      // {
        meta = {
          description = "Unified documentation generator, validation test runner, and quality audit toolchain.";
          mainProgram = "nixconf-docs";
          usage = ''
            Documentation generator and validator suite CLI.

            ```bash
            # Write generated markdown documentation to repository tree
            nix run .#docs -- --write

            # Verify committed documentation matches evaluated specification
            nix run .#docs -- --check

            # Check documentation with strict 100% coverage enforcement
            nix run .#docs -- --check --strict

            # Inspect documentation health metrics and warnings
            nix run .#docs -- --health

            # List all generated documentation target files
            nix run .#docs -- --list
            ```
          '';
          helpCommand = "nixconf-docs --help";
        };
      };
    committedDocsSrc = lib.fileset.toSource {
      root = ../..;
      fileset = lib.fileset.unions [
        ../../README.md
        ../../docs
      ];
    };
  in {
    packages.docs = docsApp;

    checks.docs = pkgs.runCommandLocal "check-docs-synchronized" {} ''
      if ! ${docsSyncBin}/bin/nixconf-docs-sync check "${docFiles}" "${committedDocsSrc}"; then
        echo "Documentation synchronization check failed. Run 'nix run .#docs -- --write'." >&2
        exit 1
      fi
      ${
        if !audit.isPerfect
        then ''echo "${audit.summaryLine}" >&2''
        else ""
      }
      ${
        if config.docs.strict && !audit.isPerfect
        then ''
          echo "Strict documentation check failed: ${toString audit.undocumentedItems} warnings present." >&2
          exit 1
        ''
        else ""
      }
      touch $out
    '';
  };
}
