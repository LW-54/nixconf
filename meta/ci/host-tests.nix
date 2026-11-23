{
  self,
  lib,
  ...
}: {
  perSystem = {config, ...}: let
    runnerSystem = "x86_64-linux";
    hostTests = config.legacyPackages.hostTests or {};
    cooldownHours = 4;
    cooldownSeconds = toString (cooldownHours * 3600);
    hostsWithVm = builtins.attrNames (lib.filterAttrs (_: t: t ? vm) hostTests);
    hostsWithInstall = builtins.attrNames (lib.filterAttrs (_: t: t ? install) hostTests);
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
              {
                name = "Run VM Runtime Tests (vm)";
                "if" = hostFilter;
                run = ''nix build --no-link -L ".#legacyPackages.${runnerSystem}.hostTests.''${{ matrix.host }}.vm"'';
              }
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
              {
                name = "Run Install & Storage Lifecycle Tests (install)";
                "if" = "steps.should-run.outputs.run == 'true'";
                run = ''
                  nix build --no-link -L ".#legacyPackages.${runnerSystem}.hostTests.''${{ matrix.host }}.install"
                  mkdir -p /tmp/install-cooldown-marker
                  date -u > /tmp/install-cooldown-marker/timestamp
                '';
              }
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
