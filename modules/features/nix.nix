{inputs, ...}: {
  flake.nixosModules.nix = {config, ...}: {
    imports = [
      inputs.nix-index-database.nixosModules.nix-index
    ];
    programs.nix-index-database.comma.enable = true;

    sops.secrets.cachix-token = {
      sopsFile = ../../secrets/cachix/cachix.yaml;
      key = "token";
    };

    nix = {
      settings = {
        experimental-features = ["nix-command" "flakes"];
        auto-optimise-store = true;
        extra-substituters = ["https://lw-54.cachix.org"];
        extra-trusted-public-keys = [
          "lw-54.cachix.org-1:1sScTQ6+QH/OBn5bCQEWz7LP090BE7njdpYTpxe5l0o="
        ];
      };

      optimise.automatic = true;

      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };
    programs.nix-ld.enable = true;
    services.cachix-watch-store = {
      enable = true;
      cacheName = "lw-54";
      cachixTokenFile = config.sops.secrets.cachix-token.path;
    };
    nixpkgs.config.allowUnfree = true;
  };
}
