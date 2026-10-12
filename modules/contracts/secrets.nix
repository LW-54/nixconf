{ inputs, ... }:
{
  flake.nixosModules.secrets = { 
    imports = [
      inputs.sops-nix.nixosModules.sops
    ];
  };
}

/*
  This file is a placeholder for a potential secrets contract abstracting sops.
  it would expose something like options.secrets 
*/
