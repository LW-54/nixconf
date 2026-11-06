{self, ...}: {
  feature.cosmic = {
    description = "Next-generation COSMIC desktop environment and greeter.";
    modules = {
      cosmic = {
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

          persistence.users = lib.mkIf config.cosmic.enable (self.lib.user.forNormalUsers config (_: _: {
            data.directories = [
              ".config/cosmic"
              ".config/dconf"
              ".local/state/cosmic"
              ".local/state/cosmic-comp"
            ];
            cache.directories = [".cache/cosmic-settings"];
          }));

          persistence.directories = lib.mkIf config.services.displayManager.cosmic-greeter.enable [
            "/var/lib/cosmic-greeter"
          ];
        };
      };
    };
  };
}
