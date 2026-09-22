{ inputs, ... }:

{
  flake.nixosModules.sops = {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];
  };

  flake.nixosModules.sops-tools = { pkgs, ... }:
    {
      environment.systemPackages = [
        pkgs.sops
        pkgs.age
      ];
    };
}