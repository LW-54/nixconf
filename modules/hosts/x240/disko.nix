{
  config,
  inputs,
  self,
  ...
}: let
  flakeLib = config.flake.lib;
  layout = flakeLib.disko.mkLayout {
    device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S21JNSAG400208P";
    swapSize = "16G";
    swapResume = true;
  };
in {
  flake.nixosModules.x240Storage = {...}: {
    imports = [inputs.disko.nixosModules.disko];
    config = layout;
  };
}
