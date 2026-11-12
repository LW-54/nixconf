# Documentation page for Continuous Integration & Automation (docs/ci.md).
{config, ...}: {
  docs.pages.ci = {
    path = "docs/ci.md";
    sections = {
      header = {
        order = 5;
        content = ctx: ''
          # Continuous Integration & Automation

          Declarative GitHub Actions workflow compilation, Cachix binary cache synchronization, and drift verification engine.

          ${ctx.backTo "readme" "Main README"}
        '';
      };

      overview = {
        order = 10;
        content = ctx: ''
          ## Overview

          CI workflows in `nixconf` are declared natively in pure Nix under `config.workflow.<name>` rather than being hand-maintained in YAML. Workflows are:
          1. **Declarative**: Expressed as Nix attribute sets or inline YAML parsed via ${ctx.instanceLink "lib" "ci"} (`lib.ci.fromYAML`).
          2. **Linted & Validated**: Validated at build time with `actionlint` and formatted with `yamlfmt` via `lib.ci.toYAML`.
          3. **Drift-Protected**: The flake check `checks.ci` validates that `.github/workflows/*.yml` in the working tree match evaluated Nix specifications.
        '';
      };

      cli = {
        order = 20;
        content = ctx: ''
          ## CLI Usage (`ci`)

          The repository exports a dedicated `ci` package (${ctx.link ctx.pages.packages.path}#ci) to synchronize and verify GitHub Actions workflows:

          ```bash
          # Verify that committed workflows match evaluated Nix specifications (used in CI)
          nix run .#ci -- --check

          # Compile and synchronize workflows into .github/workflows/ (removing stale ones)
          nix run .#ci -- --write
          ```
        '';
      };

      workflows = {
        order = 30;
        content = ctx: let
          wfMap = (config.allSystems.${ctx.system} or {}).workflow or {};
          hasWorkflows = wfMap != {};
        in ''
          ## Declared Workflows

          ${
            if hasWorkflows
            then
              ctx.md.table {
                headers = ["Workflow" "Target File" "Description"];
                columns = [
                  (w: "**`${w}`**")
                  (w: "`.github/workflows/${w}.yml`")
                  (w: wfMap.${w}.name or w)
                ];
                rows = builtins.attrNames wfMap;
              }
            else ""
          }

          ### Workflow Details

          - **`build`** ([`meta/ci/build.nix`](../meta/ci/build.nix)): Runs on pull requests and pushes to `main`. Executes `nix flake check`, collects all buildable derivations via `lib.ci.collectBuildables`, and builds targets in parallel while pushing artifacts to the `lw-54` Cachix binary cache.
          - **`host-tests`** ([`meta/ci/host-tests.nix`](../meta/ci/host-tests.nix)): Automated matrix verification testing host closures and running VM tests on supported targets.
        '';
      };

      library = {
        order = 40;
        content = ctx: ''
          ## Library Reference

          CI compilation and reflection utilities are exposed under the pure library namespace:

          - **${ctx.pageLink "lib/ci" "flake.lib.ci"}**: Documented functions including `fromYAML`, `toYAML`, and `collectBuildables`.
        '';
      };
    };
  };
}
