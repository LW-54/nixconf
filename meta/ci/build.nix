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

    buildMissingStep = {
      name,
      outLink,
      targets,
      extraBuildFlags ? "",
    }: {
      inherit name;
      env = {
        IS_PR = "\${{ github.event_name == 'pull_request' }}";
      };
      run = ''
        set -euo pipefail
        ATTIC_URL="${atticCfg.endpoint}/${atticCfg.cache}"
        CACHIX_URL="https://lw-54.cachix.org"
        NIXOS_URL="https://cache.nixos.org"

        nix derivation show ${lib.concatStringsSep " \\\n          " targets} \
          | jq -r '(.derivations // .) | to_entries[] | [(.key | if startswith("/nix/store/") then . else "/nix/store/" + . end), ((.value.outputs.out // (.value.outputs | to_entries[0].value)).path | if startswith("/nix/store/") then . else "/nix/store/" + . end)] | @tsv' \
          > /tmp/ci-targets.tsv

        rm -rf /tmp/ci-miss
        mkdir -p /tmp/ci-miss
        while IFS=$'\t' read -r drv out; do
          hash="''${out#/nix/store/}"
          hash="''${hash%%-*}"
          (
            in_nixos=0
            in_attic=0
            in_cachix=0
            curl -fsI --max-time 5 "''${NIXOS_URL}/''${hash}.narinfo" >/dev/null 2>&1 && in_nixos=1
            if [ "$in_nixos" -eq 0 ]; then
              curl -fsI --max-time 5 "''${ATTIC_URL}/''${hash}.narinfo" >/dev/null 2>&1 && in_attic=1
              curl -fsI --max-time 5 "''${CACHIX_URL}/''${hash}.narinfo" >/dev/null 2>&1 && in_cachix=1
            fi
            if [ "$in_nixos" -eq 1 ]; then
              echo "  [cached:nixos] $out"
            elif [ "''${IS_PR:-false}" = "true" ] && { [ "$in_attic" -eq 1 ] || [ "$in_cachix" -eq 1 ]; }; then
              echo "  [cached:pr] $out"
            elif [ "$in_attic" -eq 1 ] && [ "$in_cachix" -eq 1 ]; then
              echo "  [cached:attic+cachix] $out"
            else
              echo "  [build:attic=$in_attic cachix=$in_cachix] $out"
              printf '%s^*\n' "$drv" > "/tmp/ci-miss/''${hash}"
            fi
          ) &
        done < /tmp/ci-targets.tsv
        wait

        shopt -s nullglob
        miss_files=(/tmp/ci-miss/*)
        if [ "''${#miss_files[@]}" -eq 0 ]; then
          echo "All targets already cached in Attic & Cachix — skipping multi-GB download."
        else
          mapfile -t MISSING < <(cat "''${miss_files[@]}")
          echo "Building ''${#MISSING[@]} uncached target(s)..."
          nix build --out-link ${outLink} ${extraBuildFlags} -L "''${MISSING[@]}"
        fi
      '';
    };

    atticPushStep = outLink: {
      name = "Push to Attic binary cache (SOPS)";
      "if" = "github.event_name != 'pull_request'";
      env = {
        SOPS_AGE_KEY = "\${{ secrets.SOPS_AGE_KEY }}";
      };
      run = ''
        shopt -s nullglob
        outs=(${outLink}*)
        if [ "''${#outs[@]}" -eq 0 ]; then
          echo "No new outputs built; skipping Attic push."
          exit 0
        fi
        if [ -z "''${SOPS_AGE_KEY:-}" ] || [ ! -f secrets/ci/attic.yaml ]; then
          echo "SOPS_AGE_KEY or secrets/ci/attic.yaml not configured; skipping Attic push."
          exit 0
        fi
        tools="$(nix build --no-link --print-out-paths .#legacyPackages.${runnerSystem}.ciAtticTools)"
        ATTIC_TOKEN="$("$tools/bin/sops" -d --extract '["token"]' secrets/ci/attic.yaml)"
        echo "::add-mask::$ATTIC_TOKEN"
        "$tools/bin/attic" login ${atticCfg.cache} "${atticCfg.endpoint}" "$ATTIC_TOKEN"
        "$tools/bin/attic" push -j 16 ${atticCfg.cache} "''${outs[@]}"
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
              ((buildMissingStep {
                  name = "Evaluate, inspect, and build uncached host outputs";
                  outLink = "/tmp/host-out";
                  targets = [
                    ''".#checks.${runnerSystem}.eval-''${HOST}"''
                    ''".#checks.${runnerSystem}.inspect-''${HOST}"''
                    ''".#nixosConfigurations.''${HOST}.config.system.build.toplevel"''
                  ];
                })
                // {
                  env = {
                    IS_PR = "\${{ github.event_name == 'pull_request' }}";
                    HOST = "\${{ matrix.host }}";
                  };
                })
              (atticPushStep "/tmp/host-out")
            ];
        };

        packages-and-shells = {
          name = "Packages & DevShells (Single Eval)";
          runs-on = "ubuntu-latest";
          steps =
            setupSteps
            ++ [
              (buildMissingStep {
                name = "Build & cache uncached packages and devShells in one evaluation";
                outLink = "/tmp/pkg-out";
                extraBuildFlags = "--keep-going";
                targets = packagesAndShellsTargets;
              })
              (atticPushStep "/tmp/pkg-out")
            ];
        };
      };
    };
  };
}
