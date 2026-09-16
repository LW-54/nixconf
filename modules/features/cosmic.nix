{ self, inputs, ... }: {
  flake.nixosModules.cosmic = { pkgs, ... }: {
    services.desktopManager.cosmic.enable = true;
    services.displayManager.cosmic-greeter.enable = true;
  };
}