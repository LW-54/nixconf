{ inputs, ... }:
{
  flake.nixosModules.secrets = { config, lib, ... }:
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      sops.age.keyFile = lib.mkDefault "/persist/sops-nix/key.txt";
    };
}