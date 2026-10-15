{self, ...}: {
  flake.nixosModules.cosmic = {
    config,
    lib,
    ...
  }: {
    options.cosmic = {
      enable = lib.mkEnableOption "the COSMIC desktop" // {default = true;};
      greeter.enable = lib.mkEnableOption "the COSMIC greeter";
    };

    config = {
      services.desktopManager.cosmic.enable = config.cosmic.enable;
      services.displayManager.cosmic-greeter.enable = config.cosmic.greeter.enable;

      persistence.users = self.lib.mkUserPersistence {
        inherit lib config;
        userEnabled = _: config.services.desktopManager.cosmic.enable;
        data = {
          directories = [
            ".config/cosmic"
            ".config/dconf"
            ".local/state/cosmic"
            ".local/state/cosmic-comp"
          ];
        };
        cache = {
          directories = [".cache/cosmic-settings"];
        };
      };

      persistence.directories = lib.mkIf config.services.displayManager.cosmic-greeter.enable [
        "/var/lib/cosmic-greeter"
      ];
    };
  };
}
