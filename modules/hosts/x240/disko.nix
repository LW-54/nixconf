{ inputs, self, ... }:
let
  layout = self.lib.mkPersistentDiskoLayout {
    device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S21JNSAG400208P";
    swapSize = "16G";
    swapResume = true;
  };
in
{
  imports = [ inputs.disko.flakeModules.default ];

  flake.diskoConfigurations.x240 = layout;

  flake.nixosModules.x240Storage = { ... }:
    {
      imports = [ inputs.disko.nixosModules.disko ];
      config = layout;
    };
}
