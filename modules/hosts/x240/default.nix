{self, ...}: {
  host.x240 = {
    description = "ThinkPad Laptop Workstation (Desktop graphical workstation).";
    configuration = {
      imports = [
        self.nixosModules.x240-hardware
        self.nixosModules.x240-disk
        self.nixosModules.x240-system
        self.nixosModules.x240-desktop
        self.nixosModules.x240-resources
      ];
    };
  };
}
