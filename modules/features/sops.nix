{ inputs, ... }:

{
  flake.nixosModules.sops-tools = { config, pkgs, ... }:
    {
      environment.sessionVariables.SOPS_AGE_KEY_FILE = config.sops.age.keyFile;

      environment.systemPackages = [
        pkgs.sops
        pkgs.age
      ];
    };
}