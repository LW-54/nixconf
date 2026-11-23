{
  self,
  lib,
  ...
}: {
  perSystem = {...}: let
    runnerSystem = "x86_64-linux";
    hostDefs = self.host or {};
    cooldownHours = 4;
    cooldownSeconds = toString (cooldownHours * 3600);
    hostsWithVm = builtins.attrNames (lib.filterAttrs (_: h: h.vmTest or true) hostDefs);
    hostsWithInstall = builtins.attrNames (lib.filterAttrs (_: h: h.installTest or true) hostDefs);
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

    hostFilter = "github.event_name != 'workflow_dispatch' || github.event.inputs.host == 'all' || github.event.inputs.host == matrix.host";

    cachedTestStep = {
      name,
      tier,
      condition,
      outLink,
      postScript ? "",
    }: {
      inherit name;
      "if" = condition;
      env = {
        HOST = "\${{ matrix.host }}";
      };
      run = ''
        set -euo pipefail
        ATTIC_URL="${atticCfg.endpoint}/${atticCfg.cache}"
        CACHIX_URL="https://lw-54.cachix.org"

        t_start="$(date +%s)"
        read -r drv out < <(
          nix derivation show ".#legacyPackages.${runnerSystem}.hostTests.''${HOST}.${tier}" \
            | jq -r '(.derivations // .) | to_entries[0] | [(.key | if startswith("/nix/store/") then . else "/nix/store/" + . end), ((.value.outputs.out // (.value.outputs | to_entries[0].value)).path | if startswith("/nix/store/") then . else "/nix/store/" + . end)] | @tsv'
        )
        hash="''${out#/nix/store/}"
        hash="''${hash%%-*}"

        in_attic=0
        in_cachix=0
        curl -fsI --max-time 5 "''${ATTIC_URL}/''${hash}.narinfo" >/dev/null 2>&1 && in_attic=1
        curl -fsI --max-time 5 "''${CACHIX_URL}/''${hash}.narinfo" >/dev/null 2>&1 && in_cachix=1

        if [ "$in_attic" -eq 1 ] && [ "$in_cachix" -eq 1 ]; then
          echo "Test ${tier} for ''${HOST} already cached in Attic & Cachix ($out) — skipping VM download/run."
          status="cached (attic+cachix)"
        else
          echo "Running ${tier} for ''${HOST} (attic=$in_attic cachix=$in_cachix)..."
          nix build --out-link ${outLink} -L "''${drv}^*"
          status="built (attic=$in_attic cachix=$in_cachix)"
        fi
        ${postScript}
        t_dur=$(( $(date +%s) - t_start ))
        if [ -n "''${GITHUB_STEP_SUMMARY:-}" ]; then
          {
            echo "### ${name} (''${HOST})"
            echo ""
            echo "| Host | Tier | Status | Duration |"
            echo "| :--- | :--- | :--- | ---: |"
            echo "| ''${HOST} | ${tier} | $status | ''${t_dur}s |"
          } >> "$GITHUB_STEP_SUMMARY"
        fi
      '';
    };

    atticPushStep = {
      condition,
      outLink,
    }: {
      name = "Push test result to Attic binary cache (SOPS)";
      "if" = "(${condition}) && github.event_name != 'pull_request'";
      env = {
        SOPS_AGE_KEY = "\${{ secrets.SOPS_AGE_KEY }}";
      };
      run = ''
        shopt -s nullglob
        outs=(${outLink}*)
        if [ "''${#outs[@]}" -eq 0 ]; then
          echo "No new test outputs built; skipping Attic push."
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

    kvmAndNixSteps = [
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
        name = "Enable KVM permissions";
        run = ''
          echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules
          sudo udevadm control --reload-rules
          sudo udevadm trigger --name-match=kvm
          [ -e /dev/kvm ] && sudo chmod 666 /dev/kvm || true
        '';
      }
      {
        name = "Install Nix";
        uses = "cachix/install-nix-action@v31";
        "with".extra_nix_config = ''
          system-features = nixos-test benchmark big-parallel kvm
          extra-substituters = ${extraSubstituters}
          extra-trusted-public-keys = ${extraPublicKeys}
        '';
      }
      {
        name = "Setup Cachix";
        uses = "cachix/cachix-action@v17";
        "with" = {
          name = "lw-54";
          authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
        };
      }
    ];
  in {
    workflow.host-tests = {
      name = "Host Verification & VM Tests";

      on = {
        push.branches = [
          "main"
          "feat/**"
        ];
        schedule = [{cron = "0 3 * * *";}];
        workflow_dispatch.inputs = {
          tier = {
            description = "Test tier to execute";
            required = true;
            default = "vm";
            type = "choice";
            options = ["all" "static" "vm" "install"];
          };
          host = {
            description = "Host to test";
            required = true;
            default = "all";
            type = "choice";
            options = ["all"] ++ hostsWithVm;
          };
        };
      };

      concurrency = {
        group = "\${{ github.workflow }}-\${{ github.ref }}";
        cancel-in-progress = true;
      };

      permissions.contents = "write";

      jobs = {
        # Parallel VM Runtime Tests (direct nix build avoids double flake eval of `nix run .#test`)
        vm-tests = {
          name = "VM Tests (\${{ matrix.host }})";
          runs-on = "ubuntu-latest";
          "if" = "github.event_name == 'schedule' || github.event_name == 'push' || (github.event_name == 'workflow_dispatch' && (github.event.inputs.tier == 'all' || github.event.inputs.tier == 'vm'))";
          strategy = {
            fail-fast = false;
            matrix.host = hostsWithVm;
          };
          steps =
            [
              {
                name = "Checkout repository";
                "if" = hostFilter;
                uses = "actions/checkout@v4";
              }
            ]
            ++ map (s: s // {"if" = hostFilter;}) kvmAndNixSteps
            ++ [
              (cachedTestStep {
                name = "Run VM Runtime Tests (vm)";
                tier = "vm";
                condition = hostFilter;
                outLink = "/tmp/vm-test-out";
              })
              (atticPushStep {
                condition = hostFilter;
                outLink = "/tmp/vm-test-out";
              })
            ];
        };

        # Independent Parallel Install & Disko Lifecycle Tests (runs concurrently with vm-tests!)
        install-tests = {
          name = "Install Tests (\${{ matrix.host }})";
          runs-on = "ubuntu-latest";
          "if" = "github.event_name == 'schedule' || github.event_name == 'push' || (github.event_name == 'workflow_dispatch' && (github.event.inputs.tier == 'all' || github.event.inputs.tier == 'install'))";
          strategy = {
            fail-fast = false;
            matrix.host = hostsWithInstall;
          };
          steps =
            [
              {
                name = "Checkout repository";
                "if" = hostFilter;
                uses = "actions/checkout@v4";
                "with".fetch-depth = 2;
              }
              {
                name = "Detect disk configuration changes";
                id = "disk-diff";
                "if" = "(${hostFilter}) && github.event_name == 'push'";
                run = ''
                  if git rev-parse HEAD~1 >/dev/null 2>&1; then
                    if git diff --name-only HEAD~1 HEAD | grep -E '(disko|impermanence|disk)' >/dev/null; then
                      echo "changed=true" >> "$GITHUB_OUTPUT"
                      echo "Disk configuration changed in this push; install tier will be triggered."
                      exit 0
                    fi
                  fi
                  echo "changed=false" >> "$GITHUB_OUTPUT"
                '';
              }
              {
                name = "Compute cooldown key";
                id = "cooldown-key";
                "if" = hostFilter;
                run = ''
                  bucket=$(( $(date -u +%s) / ${cooldownSeconds} ))
                  echo "key=install-cooldown-''${{ matrix.host }}-$bucket" >> "$GITHUB_OUTPUT"
                '';
              }
              {
                name = "Check install tier cooldown cache";
                id = "cooldown";
                "if" = "(${hostFilter}) && github.event_name == 'push' && github.ref == 'refs/heads/main'";
                uses = "actions/cache@v4";
                "with" = {
                  path = "/tmp/install-cooldown-marker";
                  key = "\${{ steps.cooldown-key.outputs.key }}";
                };
              }
              {
                name = "Determine whether install tier should run";
                id = "should-run";
                "if" = hostFilter;
                run = ''
                  if [ "''${{ github.event_name }}" = "schedule" ] || [ "''${{ github.event_name }}" = "workflow_dispatch" ]; then
                    echo "run=true" >> "$GITHUB_OUTPUT"
                  elif [ "''${{ steps.disk-diff.outputs.changed }}" = "true" ]; then
                    echo "run=true" >> "$GITHUB_OUTPUT"
                  elif [ "''${{ github.ref }}" = "refs/heads/main" ] && [ "''${{ steps.cooldown.outputs.cache-hit }}" != "true" ]; then
                    echo "run=true" >> "$GITHUB_OUTPUT"
                  else
                    echo "run=false" >> "$GITHUB_OUTPUT"
                  fi
                '';
              }
            ]
            ++ map (s: s // {"if" = "steps.should-run.outputs.run == 'true'";}) kvmAndNixSteps
            ++ [
              (cachedTestStep {
                name = "Run Install & Storage Lifecycle Tests (install)";
                tier = "install";
                condition = "steps.should-run.outputs.run == 'true'";
                outLink = "/tmp/install-test-out";
                postScript = ''
                  mkdir -p /tmp/install-cooldown-marker
                  date -u > /tmp/install-cooldown-marker/timestamp
                '';
              })
              (atticPushStep {
                condition = "steps.should-run.outputs.run == 'true'";
                outLink = "/tmp/install-test-out";
              })
            ];
        };

        # On-demand Static Verification (eval & inspect) for schedule / manual dispatch
        static-tests = {
          name = "Static Verification (\${{ matrix.host }})";
          runs-on = "ubuntu-latest";
          "if" = "github.event_name == 'schedule' || (github.event_name == 'workflow_dispatch' && (github.event.inputs.tier == 'all' || github.event.inputs.tier == 'static'))";
          strategy = {
            fail-fast = false;
            matrix.host = hostsWithVm;
          };
          steps = [
            {
              name = "Checkout repository";
              "if" = hostFilter;
              uses = "actions/checkout@v4";
            }
            {
              name = "Cache Nix fetcher & eval cache";
              "if" = hostFilter;
              uses = "actions/cache@v4";
              "with" = {
                path = "~/.cache/nix";
                key = "nix-cache-\${{ runner.os }}-\${{ hashFiles('.tack/pins.lock.json', 'flake.lock') }}";
                restore-keys = "nix-cache-\${{ runner.os }}-";
              };
            }
            {
              name = "Install Nix";
              "if" = hostFilter;
              uses = "cachix/install-nix-action@v31";
              "with".extra_nix_config = ''
                extra-substituters = ${extraSubstituters}
                extra-trusted-public-keys = ${extraPublicKeys}
              '';
            }
            {
              name = "Setup Cachix";
              "if" = hostFilter;
              uses = "cachix/cachix-action@v17";
              "with" = {
                name = "lw-54";
                authToken = "\${{ secrets.CACHIX_AUTH_TOKEN }}";
              };
            }
            {
              name = "Run eval & inspect checks";
              "if" = hostFilter;
              run = ''nix build --no-link -L ".#checks.${runnerSystem}.eval-''${{ matrix.host }}" ".#checks.${runnerSystem}.inspect-''${{ matrix.host }}"'';
            }
          ];
        };
      };
    };
  };
}
