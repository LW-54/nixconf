{inputs, ...}: {
  flake.nixosModules.nix = {
    config,
    lib,
    ...
  }: {
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];

    options.nix.cachixWatchStore = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to enable cachix-watch-store service and its SOPS secret.";
    };

    config = {
      programs.nix-index-database.comma.enable = true;

      sops.secrets = lib.mkIf config.nix.cachixWatchStore {
        cachix-token = {
          sopsFile = ../../secrets/cachix/cachix.yaml;
          key = "token";
        };
      };

      nix = {
        settings = {
          experimental-features = ["nix-command" "flakes"];
          auto-optimise-store = true;
          extra-substituters = ["https://lw-54.cachix.org"];
          extra-trusted-public-keys = [
            "lw-54.cachix.org-1:1sScTQ6+QH/OBn5bCQEWz7LP090BE7njdpYTpxe5l0o="
          ];
          trusted-users = lib.attrNames (lib.filterAttrs (_: user: lib.elem "wheel" (user.extraGroups or [])) config.users.account);
        };

        optimise.automatic = true;

        gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 30d";
        };
      };
      programs.nix-ld.enable = true;
      services.cachix-watch-store = lib.mkIf config.nix.cachixWatchStore {
        enable = true;
        cacheName = "lw-54";
        cachixTokenFile = config.sops.secrets.cachix-token.path;
      };
      systemd.services.cachix-watch-store-agent.serviceConfig.KillMode = lib.mkIf config.nix.cachixWatchStore (lib.mkForce "control-group");
      nixpkgs.config.allowUnfree = true;
    };
  };
}
