{
  inputs,
  self,
  ...
}: {
  feature.nix = {
    description = "Nix package manager daemon settings, binary caches, garbage collection, and nix-ld.";
    modules = {
      nix = {
        config,
        lib,
        pkgs,
        ...
      }: {
        imports = [
          inputs.nix-index-database.nixosModules.nix-index
        ];

        options.nix = {
          cachixWatchStore = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to enable cachix-watch-store service and its SOPS secret.";
          };

          attic = let
            defaults =
              self.lib.attic.cacheConfig
              or {
                endpoint = "https://cache.adje.app";
                cache = "nixconf";
                publicKey = null;
              };
          in {
            enable =
              lib.mkEnableOption "Self-hosted Attic binary cache substituter"
              // {
                default = defaults.publicKey != null;
              };

            endpoint = lib.mkOption {
              type = lib.types.str;
              default = defaults.endpoint;
              description = "Base HTTPS URL of the Attic binary cache server.";
            };

            cacheName = lib.mkOption {
              type = lib.types.str;
              default = defaults.cache;
              description = "Name of the public Attic cache to substitute from.";
            };

            publicKey = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = defaults.publicKey;
              description = "Public signing key of the Attic cache (populated by `just attic-bootstrap`).";
            };
          };
        };

        config = {
          programs.nix-index-database.comma.enable = true;

          secrets.files = lib.mkIf config.nix.cachixWatchStore {
            cachix-token = {
              file = ../../secrets/cachix/cachix.yaml;
              key = "token";
            };
          };

          nix = {
            daemonCPUSchedPolicy = lib.mkDefault "idle";
            daemonIOSchedClass = lib.mkDefault "idle";

            settings = {
              cores = lib.mkDefault 0;
              max-jobs = lib.mkDefault "auto";
              experimental-features = ["nix-command" "flakes"];
              auto-optimise-store = true;
              extra-substituters =
                [
                  "https://lw-54.cachix.org"
                ]
                ++ lib.optional (config.nix.attic.enable && config.nix.attic.publicKey != null)
                "${config.nix.attic.endpoint}/${config.nix.attic.cacheName}";
              extra-trusted-public-keys =
                [
                  "lw-54.cachix.org-1:1sScTQ6+QH/OBn5bCQEWz7LP090BE7njdpYTpxe5l0o="
                ]
                ++ lib.optional (config.nix.attic.enable && config.nix.attic.publicKey != null)
                config.nix.attic.publicKey;
              trusted-users = ["root" "@wheel"];
            };

            optimise.automatic = true;

            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 30d";
            };
          };
          programs.nix-ld = {
            enable = true;
            libraries = with pkgs; [
              stdenv.cc.cc
              zlib
              openssl
              curl
              glib
            ];
          };
          services.cachix-watch-store = lib.mkIf config.nix.cachixWatchStore {
            enable = true;
            cacheName = "lw-54";
            cachixTokenFile = config.secrets.files.cachix-token.path;
          };
          systemd.services.cachix-watch-store-agent.serviceConfig.KillMode = lib.mkIf config.nix.cachixWatchStore (lib.mkForce "control-group");
          # Pushing to the binary cache needs the real token and internet access, neither of
          # which exists in the isolated test network.
          testing.vm.allowedFailedUnits = lib.mkIf config.nix.cachixWatchStore ["cachix-watch-store-agent.service"];
          # allowUnfree is configured centrally on the shared pkgs instance (meta/pkgs.nix & primitives/host/default.nix).
          environment.systemPackages = [pkgs.nixd];

          persistence.users = self.lib.user.forNormalUsers config (_: _: {
            cache.directories = [
              ".cache/nix"
              ".cache/nix-index"
            ];
          });

          monitoring = lib.mkIf (config.monitoring.enable or false) {
            watchedUnits =
              ["nix-daemon.service" "nix-gc.service"]
              ++ lib.optional config.nix.cachixWatchStore "cachix-watch-store-agent.service";
            logs.journal.units =
              ["nix-daemon.service" "nix-gc.service"]
              ++ lib.optional config.nix.cachixWatchStore "cachix-watch-store-agent.service";
          };

          resources.units = lib.mkIf (config.resources.enable or false) (
            {
              "nix-daemon.service".tier = lib.mkDefault "background";
              "nix-gc.service" = {
                tier = lib.mkDefault "background";
                deferOnBattery = lib.mkDefault true;
              };
              "nix-optimise.service" = {
                tier = lib.mkDefault "background";
                deferOnBattery = lib.mkDefault true;
              };
            }
            // lib.optionalAttrs config.nix.cachixWatchStore {
              "cachix-watch-store-agent.service".tier = lib.mkDefault "background";
            }
          );
        };
      };
    };
  };
}
