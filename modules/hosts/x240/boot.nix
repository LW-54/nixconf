{ ... }:
{
  flake.nixosModules.x240Boot = {
    boot.loader.grub = {
      enable = true;
      useOSProber = true;
    };
  };
}