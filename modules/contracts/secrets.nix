{ inputs, ... }:
{
  flake.nixosModules.secrets = { lib, ... }:
    {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];

      sops.age.keyFile = lib.mkDefault "/var/lib/sops-nix/key.txt";
    };
}

