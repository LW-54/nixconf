{ inputs, ... }:
{
  flake.nixosModules.nix = { ... }:
    {
      imports = [
        inputs.nix-index-database.nixosModules.nix-index
      ];
      programs.nix-index-database.comma.enable = true;

      nix.settings.experimental-features = ["nix-command" "flakes"];
      programs.nix-ld.enable = true;
      nixpkgs.config.allowUnfree = true;
    };
}