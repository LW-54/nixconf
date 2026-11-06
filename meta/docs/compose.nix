# Documentation Composition & Synthesis Engine
# Automatically synthesizes docs/coverage.md (Quality & Coverage Dashboard)
# and injects the condensed health status card into docs/documentation.md.
{
  lib,
  config,
  ...
}: let
  audit = config.internal.docs.audit;
in {
  docs.pages = {
    coverage = {
      path = "docs/coverage.md";
      sections = {
        header = {
          order = 5;
          content = ctx: ''
            # Documentation Coverage & Quality Audit

            Automated quality and completeness audit tracking documentation health across primitives, library symbols, and schema options.

            ${ctx.backTo "documentation" "Documentation Guide"} | ${ctx.backTo "readme" "Main README"}
          '';
        };

        status = {
          order = 10;
          content = ctx: ''
            ## Health Overview

            ${
              if audit.isPerfect
              then ''
                > [!TIP]
                > **Documentation Health**: **100.0%** — All ${toString audit.totalItems} audited architectural entities are fully documented with descriptions, docstrings, and type specifications.
              ''
              else ''
                > [!WARNING]
                > **Documentation Health**: **${audit.scoreString}** (${toString audit.documentedItems}/${toString audit.totalItems} items documented, **${toString audit.undocumentedItems} warnings**).
                > Missing or incomplete docstrings are cataloged in the registry below.
              ''
            }

            ${ctx.md.table {
              headers = ["Metric" "Value" "Description"];
              columns = [
                (r: "**${r.name}**")
                (r: "`${r.value}`")
                (r: r.desc)
              ];
              rows = [
                {
                  name = "Overall Health Score";
                  value = audit.scoreString;
                  desc = "Percentage of audited entities satisfying documentation completeness criteria.";
                }
                {
                  name = "Total Audited Items";
                  value = toString audit.totalItems;
                  desc = "Combined count of primitives, exported library functions/symbols, and schema options.";
                }
                {
                  name = "Fully Documented";
                  value = toString audit.documentedItems;
                  desc = "Entities with valid, non-placeholder descriptions and type signatures.";
                }
                {
                  name = "Audit Warnings";
                  value = toString audit.undocumentedItems;
                  desc = "Entities requiring docstrings, option descriptions, or type signatures.";
                }
              ];
            }}
          '';
        };

        breakdown = {
          order = 20;
          content = ctx: let
            cats = [
              {
                category = "Primitives (Hosts, Features, Contracts, Libs)";
                data = audit.byCategory.primitives;
                desc = "Domain ontology declarations across modules/ and primitives/.";
              }
              {
                category = "Library Symbols & Functions";
                data = audit.byCategory.symbols;
                desc = "Exported symbols, helper utilities, and types in lib.<name>.";
              }
              {
                category = "Primitive Schema Options";
                data = audit.byCategory.options;
                desc = "Declarative options defined by primitives in primitives/*/default.nix.";
              }
            ];
          in ''
            ## Category Breakdown

            ${ctx.md.table {
              headers = ["Subsystem" "Documented" "Total" "Health" "Warnings"];
              columns = [
                (c: "**${c.category}**")
                (c: "${toString c.data.documented}")
                (c: "${toString c.data.total}")
                (c: let
                  pct =
                    if c.data.total == 0
                    then 1000
                    else (c.data.documented * 1000) / c.data.total;
                  whole = toString (pct / 10);
                  frac = toString (pct - ((pct / 10) * 10));
                in "`${whole}.${frac}%`")
                (c:
                  if (builtins.length c.data.warnings) == 0
                  then "✅ None"
                  else "⚠️ `${toString (builtins.length c.data.warnings)}`")
              ];
              rows = cats;
            }}
          '';
        };

        registry = {
          order = 30;
          content = ctx:
            if audit.isPerfect
            then ''
              ## Missing Documentation Registry

              *No documentation warnings. All repository entities are fully documented.*
            ''
            else ''
              ## Missing Documentation Registry

              The following entities have missing or incomplete documentation:

              ${ctx.md.table {
                headers = ["Category" "Entity Target" "Source File" "Missing Field" "Remediation"];
                columns = [
                  (w: "`${w.category}`")
                  (w: "`${w.target}`")
                  (w:
                    if w.file != null
                    then ctx.sourceLink w.file
                    else "*unknown*")
                  (w: "**${w.missing}**")
                  (w: w.suggestedFix)
                ];
                rows = audit.warnings;
              }}
            '';
        };

        remediation = {
          order = 40;
          content = ctx: ''
            ## Remediation Guide

            To resolve documentation warnings and achieve 100% health:

            ### 1. Documenting Primitives & Features
            Add a clear `description` string explaining what the component provides:
            ```nix
            feature.myFeature = {
              description = "Brief summary of what this system feature configures.";
              ...
            };
            ```

            ### 2. Documenting Library Functions & Symbols
            Provide a markdown `# Docstring` including `# Inputs`, `# Type`, and `# Examples`:
            ```nix
            lib.myLib = {
              symbols.myFunction = {
                docstring = \'\'
                  Calculates something useful.

                  # Inputs
                  `x`: Description of parameter x.

                  # Type
                  ```
                  myFunction :: Int -> String
                  ```
                \'\';
                value = x: toString x;
              };
            };
            ```

            ### 3. Documenting Schema Options
            Ensure every `lib.mkOption` declaration has an explanatory `description`:
            ```nix
            myOption = lib.mkOption {
              type = lib.types.str;
              description = "Human-readable description of this configuration knob.";
            };
            ```
          '';
        };
      };
    };
  };

  # Condensed health summary card in docs/documentation.md
  docs.pages.documentation.sections.health = {
    order = 8;
    content = ctx:
      if audit.isPerfect
      then ''
        > [!TIP]
        > **Documentation Health**: **100.0%** (${toString audit.totalItems}/${toString audit.totalItems} items documented).
        > See the full [Documentation Coverage & Quality Audit](coverage.md).
      ''
      else ''
        > [!TIP]
        > **Documentation Health**: **${audit.scoreString}** (${toString audit.documentedItems}/${toString audit.totalItems} items documented, **${toString audit.undocumentedItems} warnings**).
        > See the full [Documentation Coverage & Quality Audit](coverage.md) for detailed metrics and the missing documentation registry.
      '';
  };
}
