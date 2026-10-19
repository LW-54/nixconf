{self, ...}: {
  flake.nixosModules.locale = {
    config,
    lib,
    options,
    ...
  }: let
    cfg = config.locale;
  in {
    options.locale = {
      enable = lib.mkEnableOption "locale configuration" // {default = true;};

      timeZone = lib.mkOption {
        type = lib.types.str;
        default = "Europe/Paris";
        description = "System time zone.";
      };

      defaultLocale = lib.mkOption {
        type = lib.types.str;
        default = "en_US.UTF-8";
        description = "System default locale and the default user locale.";
      };

      extraLocaleSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {
          LC_ADDRESS = "fr_FR.UTF-8";
          LC_IDENTIFICATION = "fr_FR.UTF-8";
          LC_MEASUREMENT = "fr_FR.UTF-8";
          LC_MONETARY = "fr_FR.UTF-8";
          LC_NAME = "fr_FR.UTF-8";
          LC_NUMERIC = "fr_FR.UTF-8";
          LC_PAPER = "fr_FR.UTF-8";
          LC_TELEPHONE = "fr_FR.UTF-8";
          LC_TIME = "fr_FR.UTF-8";
        };
        description = "Additional system locale settings and user defaults.";
      };
    };

    config = lib.mkIf cfg.enable {
      time.timeZone = cfg.timeZone;
      i18n.defaultLocale = cfg.defaultLocale;
      i18n.extraLocaleSettings = cfg.extraLocaleSettings;
      home.shared.sessionVariables =
        {
          LANG = cfg.defaultLocale;
        }
        // cfg.extraLocaleSettings;
    };
  };
}
