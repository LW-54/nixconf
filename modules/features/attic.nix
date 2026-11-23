{self, ...}: {
  feature.attic = {
    description = "Self-hosted Attic Nix binary cache server with content-defined chunking deduplication, local storage, and automatic LRU garbage collection.";

    modules = {
      attic = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.services.attic-cache;
        domain = config.reverse-proxy.domain or null;
        isTest = config.testing.enable or false;

        # Valid snakeoil RS256 key so atticd boots and passes runtime checks in isolated QEMU VM tests.
        testEnvFile =
          pkgs.runCommandLocal "atticd-test.env" {
            nativeBuildInputs = [pkgs.openssl pkgs.coreutils];
          } ''
            key_b64="$(openssl genrsa -traditional 2048 2>/dev/null | base64 -w0)"
            printf 'ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=%s\n' "$key_b64" > "$out"
          '';
      in {
        options.services.attic-cache =
          {
            enable = lib.mkEnableOption "Self-hosted Attic Nix binary cache server" // {default = true;};

            retentionPeriod = lib.mkOption {
              type = lib.types.str;
              default = "60 days";
              description = "Default LRU retention period for cached store paths before garbage collection.";
            };

            gcInterval = lib.mkOption {
              type = lib.types.str;
              default = "12 hours";
              description = "Interval between automatic Attic garbage collection passes.";
            };

            zstdLevel = lib.mkOption {
              type = lib.types.int;
              default = 6;
              description = "Zstd compression level (1-22) used for uploaded chunks.";
            };
          }
          // self.lib.reverse-proxy.mkOption {
            subdomain = "cache";
            forwardAuth = false;
          }
          // self.lib.persistence.mkOption {
            directories = ["/var/lib/atticd"];
          }
          // self.lib.monitoring.mkOption {
            units = ["atticd.service"];
          }
          // self.lib.resources.mkOption {
            tier = "standard";
            memory = {
              low = "128M";
              high = "512M";
              max = "1G";
            };
          };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            # Static system user avoids systemd DynamicUser /var/lib/private migration
            # failing with EBUSY on impermanence bind-mounted /var/lib/atticd.
            users.groups.atticd = {};
            users.users.atticd = {
              isSystemUser = true;
              group = "atticd";
              home = "/var/lib/atticd";
            };

            secrets.files.attic-server-token = {
              store = "services/attic";
              key = "serverTokenRs256Base64";
            };

            secrets.templates."attic-env" = {
              content = ''
                ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64=${config.secrets.placeholder.attic-server-token}
              '';
              mode = "0400";
            };

            services.atticd = {
              enable = true;
              environmentFile =
                if isTest
                then testEnvFile
                else config.secrets.templates."attic-env".path;

              settings = {
                listen = "${cfg.address}:${toString cfg.port}";

                api-endpoint =
                  if cfg.subdomain != null && domain != null
                  then "https://${cfg.subdomain}.${domain}/"
                  else "http://${cfg.address}:${toString cfg.port}/";

                database.url = "sqlite:///var/lib/atticd/server.db?mode=rwc";

                storage = {
                  type = "local";
                  path = "/var/lib/atticd/storage";
                };

                compression = {
                  type = "zstd";
                  level = cfg.zstdLevel;
                };

                chunking = {
                  nar-size-threshold = 65536;
                  min-size = 16384;
                  avg-size = 65536;
                  max-size = 262144;
                };

                garbage-collection = {
                  interval = cfg.gcInterval;
                  default-retention-period = cfg.retentionPeriod;
                };
              };
            };

            # Ensure atticd waits for SOPS secret template activation before starting
            # and runs as a static user so impermanence bind-mounts on /var/lib/atticd work cleanly.
            systemd.services.atticd = {
              after = lib.optionals (!isTest) ["sops-install-secrets.service"];
              serviceConfig = {
                DynamicUser = lib.mkForce false;
                StateDirectoryMode = "0750";
              };
            };

            testing.attic = {
              description = "Self-hosted Attic binary cache server configuration and runtime checks";

              evalChecks.has-environment-file = {
                assertion = config.services.atticd.environmentFile != null;
                message = "`services.atticd.environmentFile` must be set when `services.attic-cache.enable` is true.";
              };

              inspectChecks.unit = {
                description = "Verify atticd.service systemd unit exists";
                priority = 220;
                script = self.lib.testing.mkInspectFile {
                  path = "$etc/systemd/system/atticd.service";
                  pattern = "atticd";
                };
              };

              vmChecks.service = {
                description = "atticd starts cleanly and listens on its configured port";
                priority = 300;
                script = ''
                  ${self.lib.testing.mkServiceCheck {
                    unit = "atticd.service";
                    timeout = 60;
                  }}
                  machine.wait_for_open_port(${toString cfg.port})
                '';
              };
            };
          }
          (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
          (self.lib.persistence.mkConfig {inherit config cfg;})
          (self.lib.monitoring.mkConfig {
            inherit config cfg;
            name = "attic";
          })
          (self.lib.resources.mkConfig {inherit config cfg;})
        ]);
      };
    };

    packages = {pkgs, ...}: {
      attic-bootstrap = pkgs.writeShellApplication {
        name = "attic-bootstrap";
        runtimeInputs = [
          pkgs.attic-client
          pkgs.coreutils
          pkgs.gawk
          pkgs.gh
          pkgs.git
          pkgs.gnugrep
          pkgs.gnused
          pkgs.sops
        ];
        meta.description = "One-command Attic binary cache and GitHub Actions SOPS bootstrap helper.";
        text = ''
          set -euo pipefail

          repo_root="$(git rev-parse --show-toplevel)"
          cd "$repo_root"

          if [[ -z "''${SOPS_AGE_KEY:-}" || -z "''${GH_TOKEN:-}" ]]; then
            echo "error: SOPS_AGE_KEY and GH_TOKEN must be set. Run via: just attic-bootstrap" >&2
            exit 1
          fi

          if ! command -v atticd-atticadm >/dev/null 2>&1; then
            echo "error: atticd-atticadm not found. Deploy astrolabe first (just switch astrolabe)." >&2
            exit 1
          fi

          endpoint="https://cache.adje.app"
          cache="nixconf"

          echo "==> [1/5] Uploading GitHub Actions SOPS age key secret (SOPS_AGE_KEY)..."
          ci_age_key="$(sops -d --extract '["ageKey"]' secrets/admin/github-ci-age.yaml)"
          printf '%s' "$ci_age_key" | gh secret set SOPS_AGE_KEY

          echo "==> [2/5] Minting Attic CI push/admin token via atticd-atticadm..."
          token="$(
            sudo atticd-atticadm make-token \
              --sub ci \
              --validity "10 years" \
              --pull "*" \
              --push "$cache" \
              --create-cache "$cache" \
              --configure-cache "$cache" \
              | tr -d '\r' | grep -E '^eyJ' | tail -n 1
          )"
          if [[ -z "$token" ]]; then
            echo "error: failed to mint Attic JWT token." >&2
            exit 1
          fi

          echo "==> [3/5] Logging into $endpoint and ensuring public cache '$cache' exists..."
          attic login "$cache" "$endpoint" "$token"
          attic cache create "$cache" --public 2>/dev/null || true
          pub_key="$(attic cache info "$cache" | awk '/Public Key:/ { print $NF }' | tr -d '\r\n')"
          if [[ -z "$pub_key" ]]; then
            echo "error: failed to read Attic cache public key." >&2
            exit 1
          fi
          echo "    Cache public key: $pub_key"

          echo "==> [4/5] Writing SOPS-encrypted secrets/ci/attic.yaml..."
          mkdir -p secrets/ci
          (
            umask 077
            printf 'endpoint: %s\ncache: %s\npublicKey: %s\ntoken: %s\n' \
              "$endpoint" "$cache" "$pub_key" "$token" > secrets/ci/attic.yaml
          )
          sops --encrypt --in-place secrets/ci/attic.yaml
          git add -N secrets/ci/attic.yaml

          echo "==> [5/5] Enabling Attic substituter in modules/features/attic.nix and syncing workflows/docs..."
          sed -i -E "s|publicKey = (null|\"[^\"]*\");|publicKey = \"$pub_key\";|" modules/features/attic.nix
          nix run .#ci -- --write
          nix run .#docs -- --write

          echo ""
          echo "Attic bootstrap complete!"
          echo "Next steps: commit & push the updated attic publicKey + secrets/ci/attic.yaml, then run 'just switch'."
        '';
      };
    };

    lib.cacheConfig = {
      docstring = ''
        Public Attic binary cache connection metadata shared across NixOS hosts and GitHub Actions workflows.

        Run `just attic-bootstrap` on `astrolabe` after deploying to populate `publicKey`, upload `SOPS_AGE_KEY` to GitHub, and write the encrypted push token to `secrets/ci/attic.yaml`.

        # Type
        ```
        cacheConfig :: { endpoint :: String, cache :: String, publicKey :: Null | String }
        ```
      '';
      value = {
        endpoint = "https://cache.adje.app";
        cache = "nixconf";
        publicKey = null;
      };
    };
  };
}
