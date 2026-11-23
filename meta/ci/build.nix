{
  self,
  lib,
  ...
}: {
  perSystem = {
    system,
    pkgs,
    config,
    ...
  }: let
    runnerSystem = "x86_64-linux";
    ciLib = self.lib.ci or self.lib;
    allBuildables = ciLib.collectBuildables system;

    hosts = builtins.attrNames (self.nixosConfigurations or {});
    atticCfg =
      self.lib.attic.cacheConfig
      or {
        endpoint = "https://cache.adje.app";
        cache = "nixconf";
        publicKey = null;
      };
    extraSubstituters = lib.concatStringsSep " " (
      ["https://lw-54.cachix.org"]
      ++ lib.optional (atticCfg.publicKey != null) "${atticCfg.endpoint}/${atticCfg.cache}"
    );
    extraPublicKeys = lib.concatStringsSep " " (
      ["lw-54.cachix.org-1:1sScTQ6+QH/OBn5bCQEWz7LP090BE7njdpYTpxe5l0o="]
      ++ lib.optional (atticCfg.publicKey != null) atticCfg.publicKey
    );

    # Lightweight packages, devShells, and formatter built in a single shared-eval CI job
    # (checks and hosts have their own dedicated parallel jobs to eliminate duplicate builds).
    isPkgOrShell = name:
      !(lib.hasPrefix "checks-" name || lib.hasPrefix "host-" name);
    packagesAndShells = lib.filterAttrs (name: _: isPkgOrShell name) allBuildables;

    packagesAndShellsTargets =
      map (name: ".#legacyPackages.${runnerSystem}.ciPackagesAndShells.\"${name}\"")
      (builtins.attrNames (lib.filterAttrs (name: _: isPkgOrShell name) (ciLib.collectBuildables runnerSystem)));

    baseNixSteps = [
      {
        name = "Checkout repository";
        uses = "actions/checkout@v4";
      }
      {
        name = "Cache Nix fetcher & eval cache";
        uses = "actions/cache@v4";
        "with" = {
          path = "~/.cache/nix";
          key = "nix-cache-\${{ runner.os }}-\${{ hashFiles('.tack/pins.lock.json', 'flake.lock') }}";
          restore-keys = "nix-cache-\${{ runner.os }}-";
        };
      }
      {
        name = "Install Nix";
        uses = "cachix/install-nix-action@v31";
        "with".extra_nix_config = ''
          extra-substituters = ${extraSubstituters}
          extra-trusted-public-keys = ${extraPublicKeys}
        '';
      }
    ];

    setupSteps =
      baseNixSteps
      ++ [
        {
          name = "Setup Cachix";
          uses = "cachix/cachix-action@v17";
          "with" = {
            name = "lw-54";
            authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
          };
        }
      ];

    atticPushStep = targetExpr: {
      name = "Push to Attic binary cache (SOPS)";
      "if" = "github.event_name != 'pull_request'";
      env = {
        SOPS_AGE_KEY = "\${{ secrets.SOPS_AGE_KEY }}";
      };
      run = ''
        if [ -z "''${SOPS_AGE_KEY:-}" ] || [ ! -f secrets/ci/attic.yaml ]; then
          echo "SOPS_AGE_KEY or secrets/ci/attic.yaml not configured; skipping Attic push."
          exit 0
        fi
        tools="$(nix build --no-link --print-out-paths .#legacyPackages.${runnerSystem}.ciAtticTools)"
        ATTIC_TOKEN="$("$tools/bin/sops" -d --extract '["token"]' secrets/ci/attic.yaml)"
        echo "::add-mask::$ATTIC_TOKEN"
        "$tools/bin/attic" login ${atticCfg.cache} "${atticCfg.endpoint}" "$ATTIC_TOKEN"
        "$tools/bin/attic" push -j 16 ${atticCfg.cache} ${targetExpr}
      '';
    };
  in {
    legacyPackages.ciBuildables = allBuildables;
    legacyPackages.ciPackagesAndShells = packagesAndShells;
    legacyPackages.ciAtticTools = pkgs.symlinkJoin {
      name = "ci-attic-tools";
      paths = [pkgs.attic-client pkgs.sops];
    };

    workflow.build = {
      name = "CI & Binary Cache Push";

      on = {
        push.branches = ["main"];
        pull_request.branches = ["main"];
        workflow_dispatch = {};
      };

      concurrency = {
        group = "\${{ github.workflow }}-\${{ github.ref }}";
        cancel-in-progress = true;
      };

      jobs = {
        lint = {
          name = "Formatting (Alejandra)";
          runs-on = "ubuntu-latest";
          steps =
            baseNixSteps
            ++ [
              {
                name = "Check Nix formatting";
                run = "nix run .#formatter.${runnerSystem} -- --check .";
              }
            ];
        };

        checks-meta = {
          name = "Meta Checks (schemas, docs, ci)";
          runs-on = "ubuntu-latest";
          steps =
            setupSteps
            ++ [
              {
                name = "Build meta checks in one shared evaluation";
                run = lib.concatStringsSep " \\\n  " [
                  "nix build --no-link -L"
                  ".#checks.${runnerSystem}.schemas"
                  ".#checks.${runnerSystem}.docs"
                  ".#checks.${runnerSystem}.ci"
                ];
              }
            ];
        };

        host = {
          name = "Host (\${{ matrix.host }})";
          runs-on = "ubuntu-latest";
          strategy = {
            fail-fast = false;
            matrix.host = hosts;
          };
          steps =
            setupSteps
            ++ [
              {
                name = "Evaluate, inspect, and build host toplevel";
                run = lib.concatStringsSep " \\\n  " [
                  "nix build --out-link /tmp/host-out -L"
                  ''".#checks.${runnerSystem}.eval-''${{ matrix.host }}"''
                  ''".#checks.${runnerSystem}.inspect-''${{ matrix.host }}"''
                  ''".#nixosConfigurations.''${{ matrix.host }}.config.system.build.toplevel"''
                ];
              }
              (atticPushStep "/tmp/host-out*")
            ];
        };

        packages-and-shells = {
          name = "Packages & DevShells (Single Eval)";
          runs-on = "ubuntu-latest";
          steps =
            setupSteps
            ++ [
              {
                name = "Build & cache all packages and devShells in one evaluation";
                run = lib.concatStringsSep " \\\n  " (
                  ["nix build --out-link /tmp/pkg-out --keep-going -L"]
                  ++ packagesAndShellsTargets
                );
              }
              (atticPushStep "/tmp/pkg-out*")
            ];
        };
      };
    };
  };
}
