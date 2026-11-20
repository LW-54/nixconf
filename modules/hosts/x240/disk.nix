{self, ...}: {
  host.x240.subModules = {
    x240-disk = {config, ...}: {
      imports = [
        self.nixosModules.disko
        self.nixosModules.impermanence
      ];

      config =
        self.lib.disko.mkLayout {
          device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S21JNSAG400208P";
          swapSize =
            if (config.testing.enable or false)
            then "512M"
            else "16G";
          swapResume = !(config.testing.enable or false);
        }
        // {
          zramSwap.enable = true;
        };
    };
  };
}
