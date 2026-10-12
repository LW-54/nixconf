{ inputs, ... }:
{
  flake.nixosModules.secrets = { config, lib, ... }: {
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];

    sops.age.keyFile = lib.mkDefault "/var/lib/sops-nix/key.txt";

    persistence.files = lib.mkDefault [
      config.sops.age.keyFile
    ];
  };
}