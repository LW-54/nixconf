{ ... }:
{
  flake.nixosModules.x240Boot = {
    boot.loader.grub = {
      enable = true;
      device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S21JNSAG400208P";
      useOSProber = true;
    };
  };
}