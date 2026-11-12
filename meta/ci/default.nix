{
  self,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: let
    ciLib = self.lib.ci or self.lib;
    compiledWorkflows = lib.mapAttrs (name: wfData: ciLib.toYAML pkgs name wfData) config.workflow;
  in {
    packages.ci = pkgs.writeShellApplication {
      name = "nixconf-ci";
      runtimeInputs = [pkgs.diffutils pkgs.coreutils pkgs.findutils];
      meta = {
        description = "GitHub Actions CI workflow synchronization and drift verification CLI";
      };
      text = ''
        REPO_ROOT="''${DEVENV_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
        WORKFLOWS_DIR="$REPO_ROOT/.github/workflows"
        mkdir -p "$WORKFLOWS_DIR"

        ACTION="''${1:---check}"

        case "$ACTION" in
          --write)
            echo "==> [ci] Synchronizing GitHub Actions workflows..."
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: drv: ''
            cp -f "${drv}" "$WORKFLOWS_DIR/${name}.yml"
            echo "  - Synchronized $WORKFLOWS_DIR/${name}.yml"
          '')
          compiledWorkflows)}

            # Remove stale workflows not declared in config.workflow
            while IFS= read -r -d "" existing; do
              rel="''${existing#"$WORKFLOWS_DIR"/}"
              base="''${rel%.yml}"
              case "$base" in
                ${lib.concatStringsSep "|" (builtins.attrNames compiledWorkflows)}) ;;
                *)
                  echo "  - Removing stale workflow: $WORKFLOWS_DIR/$rel"
                  rm -f "$existing"
                  ;;
              esac
            done < <(find "$WORKFLOWS_DIR" -maxdepth 1 -type f -name '*.yml' -print0)

            echo "==> [ci] Workflows synchronized and validated successfully."
            ;;
          --check)
            echo "==> [ci] Verifying workflow synchronization..."
            FAILED=0
            ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: drv: ''
            if [ ! -f "$WORKFLOWS_DIR/${name}.yml" ]; then
              echo "Missing workflow: .github/workflows/${name}.yml" >&2
              FAILED=1
            elif ! diff -u "${drv}" "$WORKFLOWS_DIR/${name}.yml"; then
              echo "Out of sync: .github/workflows/${name}.yml does not match evaluated Nix workflow." >&2
              FAILED=1
            fi
          '')
          compiledWorkflows)}

            # Check for stale files
            while IFS= read -r -d "" existing; do
              rel="''${existing#"$WORKFLOWS_DIR"/}"
              base="''${rel%.yml}"
              case "$base" in
                ${lib.concatStringsSep "|" (builtins.attrNames compiledWorkflows)}) ;;
                *)
                  echo "Stale workflow file present: .github/workflows/$rel" >&2
                  FAILED=1
                  ;;
              esac
            done < <(find "$WORKFLOWS_DIR" -maxdepth 1 -type f -name '*.yml' -print0)

            if [ "$FAILED" -ne 0 ]; then
              echo "Run 'nix run .#ci -- --write' to synchronize." >&2
              exit 1
            fi
            echo "==> [ci] All workflows synchronized and compliant."
            ;;
          --help|-h)
            echo "Usage: nix run .#ci -- [--write|--check|--help]"
            echo ""
            echo "Options:"
            echo "  --write  Synchronize compiled GitHub Actions workflows to .github/workflows/"
            echo "  --check  Verify that .github/workflows/ matches evaluated Nix workflows"
            echo "  --help   Show this help message"
            exit 0
            ;;
          *)
            echo "Usage: nix run .#ci -- [--write|--check|--help]" >&2
            exit 1
            ;;
        esac
      '';
    };

    checks.ci =
      pkgs.runCommand "check-ci-workflows" {
        nativeBuildInputs = [pkgs.diffutils];
      } ''
        FAILED=0
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: drv: ''
            if [ ! -f "${self}/.github/workflows/${name}.yml" ]; then
              echo "Missing committed workflow: .github/workflows/${name}.yml" >&2
              FAILED=1
            elif ! diff -u "${drv}" "${self}/.github/workflows/${name}.yml"; then
              echo "Committed workflow .github/workflows/${name}.yml is out of sync with evaluated Nix workflow." >&2
              FAILED=1
            fi
          '')
          compiledWorkflows)}

        if [ "$FAILED" -ne 0 ]; then
          echo "Error: Workflows out of sync. Run 'nix run .#ci -- --write' to update." >&2
          exit 1
        fi
        touch $out
      '';
  };
}
