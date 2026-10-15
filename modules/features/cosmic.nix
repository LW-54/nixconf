{self, ...}: {
  flake.nixosModules.cosmic = {
    config,
    lib,
    ...
  }: {
    config = {
      services.desktopManager.cosmic.enable = true;
      services.displayManager.cosmic-greeter.enable = true;

      persistence.users = self.lib.mkUserPersistence {
        inherit lib config;
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

      persistence.directories = ["/var/lib/cosmic-greeter"];
    };
  };
}
