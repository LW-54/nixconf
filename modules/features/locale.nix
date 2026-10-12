{ self, ... }:
{
  flake.nixosModules.locale = { config, lib, ... }:
    let
      localeSettings = {
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
    in
    {
      imports = [ (self.lib.mkUserFeature {
        inherit lib;
        name = "locale";
        description = "locale configuration";
        package = _: null;
        featureOptions = localeSettings;

        userOptions = {
          defaultLocale = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "This user's locale, overriding locale.defaultLocale.";
          };

          extraLocaleSettings = lib.mkOption {
            type = lib.types.attrsOf lib.types.str;
            default = { };
            description = "This user's locale settings, merged over global values.";
          };
        };

        userModule = { cfg, user, lib, ... }:
          let
            defaultLocale = user.defaultLocale or cfg.defaultLocale;
            extraLocaleSettings = user.extraLocaleSettings or { };
          in
          {
            environment.sessionVariables = {
              LANG = defaultLocale;
            } // lib.recursiveUpdate cfg.extraLocaleSettings extraLocaleSettings;
          };
      }) ];

      config = lib.mkIf config.locale.enable {
        time.timeZone = config.locale.timeZone;
        i18n.defaultLocale = config.locale.defaultLocale;
        i18n.extraLocaleSettings = config.locale.extraLocaleSettings;
      };
    };
}
