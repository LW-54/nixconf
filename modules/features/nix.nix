{ inputs, ... }:
{
  flake.nixosModules.nix = { ... }:
    {
      imports = [
        inputs.nix-index-database.nixosModules.nix-index
      ];
      programs.nix-index-database.comma.enable = true;

      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        extra-substituters = [ "https://lw-54.cachix.org" ];
        extra-trusted-public-keys = [
          "lw-54.cachix.org-1:1sScTQ6+QH/OBn5bCQEWz7LP090BE7njdpYTpxe5l0o="
        ];
      };
      programs.nix-ld.enable = true;
      nixpkgs.config.allowUnfree = true;
    };
}