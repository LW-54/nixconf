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

      The `docs` flake check (part of `nix flake check`) verifies that committed documentation is bit-for-bit synchronized with Nix evaluation.
    '';
  };

  perSystem = {
    pkgs,
    system,
    ...
  }: let
    files = config.flake.lib.docs.generateAll {inherit system;};

    # Single-derivation store materialization:
    # Streams all generated pages from a single JSON manifest in ~0.04s,
    # eliminating 128 individual writeText derivations and store fragmentation.
    docFiles =
      pkgs.runCommandLocal "nixconf-docs-tree" {
        manifest = builtins.toFile "docs-manifest.json" (builtins.toJSON files);
        nativeBuildInputs = [pkgs.coreutils pkgs.python3Minimal];
      } ''
        mkdir -p $out
        ${pkgs.python3Minimal}/bin/python3 -c '
        import json, os, sys
        with open(os.environ["manifest"], "r", encoding="utf-8") as fh:
            file_map = json.load(fh)
        out_dir = sys.argv[1]
        for rel_path, content in file_map.items():
            target = os.path.join(out_dir, rel_path)
            os.makedirs(os.path.dirname(target), exist_ok=True)
            with open(target, "w", encoding="utf-8") as out:
                out.write(content)
        ' "$out"
      '';

    docsApp = pkgs.writeShellApplication {
      name = "nixconf-docs";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.diffutils
        pkgs.findutils
      ];
      meta = {
        description = "Unified documentation generator, validation test runner, and quality audit toolchain.";
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
      text = ''
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
          ${
          if !audit.isPerfect
          then ''echo "${audit.summaryLine}" >&2''
          else ""
        }
          exit 0
        fi

        if [ "$DO_CHECK" -eq 1 ]; then
          ${compareScript docFiles "."}
          if [ "$FAILED" -eq 1 ]; then
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
      '';
    };
  in {
    packages.docs = docsApp;

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
