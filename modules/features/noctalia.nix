{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.noctalia = {
    config,
    lib,
    ...
  }: let
    cfg = config.noctalia;
  in {
    imports = [
      (self.lib.mkHjemUserProjection {
        inherit lib;
        name = "noctalia";
        description = "Noctalia Shell";
        userOptions = {
          enable = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "Whether this user receives Noctalia, overriding the global setting.";
          };

          systemd.enable = lib.mkOption {
            type = lib.types.nullOr lib.types.bool;
            default = null;
            description = "Whether Noctalia starts through the user systemd service.";
          };

          settings = lib.mkOption {
            type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
            default = null;
            description = "Noctalia settings for this user.";
          };

          customPalettes = lib.mkOption {
            type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
            default = null;
            description = "Custom Noctalia color palettes for this user.";
          };
        };

        userEnabled = _: true;

        userModule = {user, ...}: let
          userEnable = user.enable or null;
          userSystemdEnable = user.systemd.enable or null;
          userSettings = user.settings or null;
          userCustomPalettes = user.customPalettes or null;
          enabled =
            if userEnable == null
            then cfg.enable
            else userEnable;
          systemdEnabled =
            if userSystemdEnable == null
            then cfg.systemd.enable
            else userSystemdEnable;
          settings =
            if userSettings == null
            then cfg.settings
            else lib.recursiveUpdate cfg.settings userSettings;
          customPalettes =
            if userCustomPalettes == null
            then cfg.customPalettes
            else lib.recursiveUpdate cfg.customPalettes userCustomPalettes;
        in {
          programs.noctalia = {
            enable = enabled;
            systemd.enable = systemdEnabled;
            inherit settings customPalettes;
          };
        };
      })
    ];

    options.noctalia = {
      enable = lib.mkEnableOption "Noctalia Shell" // {default = true;};
      systemd.enable = lib.mkEnableOption "the Noctalia user service" // {default = true;};
      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Global Noctalia settings inherited by users.";
      };
      customPalettes = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Global Noctalia palettes inherited by users.";
      };
    };

    config = {
      hjem.extraModules = [
        inputs.noctalia.hjemModules.default
        ({...}: {
          programs.noctalia = {
            enable = lib.mkDefault cfg.enable;
            systemd.enable = lib.mkDefault cfg.systemd.enable;
            settings = lib.mkDefault cfg.settings;
            customPalettes = lib.mkDefault cfg.customPalettes;
          };
        })
      ];

      persistence.users = self.lib.mkUserPersistence {
        inherit lib config;
        userEnabled = userName:
          self.lib.resolveUserOption {
            inherit lib;
            global = cfg.enable;
            users = cfg.users;
            inherit userName;
          };
        data.directories = [".config/noctalia"];
      };
    };
  };
}
