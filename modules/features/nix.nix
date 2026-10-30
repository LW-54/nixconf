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
          self.nixosModules.testing
        ];

        options.nix.cachixWatchStore = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable cachix-watch-store service and its SOPS secret.";
        };

        config = {
          nix.settings = {
            experimental-features = ["nix-command" "flakes"];
            auto-optimise-store = true;
            warn-dirty = false;
            substituters = [
              "https://cache.nixos.org"
              "https://nix-community.cachix.org"
              "https://lw-54.cachix.org"
            ];
            trusted-public-keys = [
              "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
              "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              "lw-54.cachix.org-1:a5Wv+u8l245k7c+O6dK8/vT71E36TjXU/7a2q4lWn1Q="
            ];
          };
          secrets.files.cachix-token = lib.mkIf config.nix.cachixWatchStore {
            file = ../../secrets/cachix/cachix.yaml;
            key = "authToken";
            owner = "root";
            group = "root";
            mode = "0400";
          };
          nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
          };
          programs.nix-ld.enable = true;
          services.cachix-watch-store = lib.mkIf config.nix.cachixWatchStore {
            enable = true;
            cacheName = "lw-54";
            cachixTokenFile = config.secrets.files.cachix-token.path;
          };
          systemd.services.cachix-watch-store-agent.serviceConfig.KillMode = lib.mkIf config.nix.cachixWatchStore (lib.mkForce "control-group");
          # Pushing to the binary cache needs the real token and internet access, neither of
          # which exists in the isolated test network.
          testing.vm.allowedFailedUnits = lib.mkIf config.nix.cachixWatchStore ["cachix-watch-store-agent.service"];
          nixpkgs.config.allowUnfree = true;
          environment.systemPackages = [pkgs.nixd];
        };
      };
    };
  };
}
