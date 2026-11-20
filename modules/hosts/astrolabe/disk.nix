{self, ...}: {
  host.astrolabe.subModules = {
    astrolabe-disk = {...}: {
      imports = [
        self.nixosModules.disko
        self.nixosModules.impermanence
      ];

      config =
        self.lib.disko.mkLayout {
          device = "/dev/sda";
          espSize = "512M";
          biosBootSize = "1M";
        }
        // {
          zramSwap.enable = true;
        };
    };
  };
}
