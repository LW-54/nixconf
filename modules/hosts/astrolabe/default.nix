{self, ...}: {
  host.astrolabe = {
    description = "Headless VPS Server (adje.app public edge and core services).";
    configuration = {
      imports = [
        self.nixosModules.astrolabe-hardware
        self.nixosModules.astrolabe-disk
        self.nixosModules.astrolabe-system
        self.nixosModules.astrolabe-services
        self.nixosModules.astrolabe-resources
      ];
    };
  };
}
