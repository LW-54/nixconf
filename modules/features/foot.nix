{
  self,
  inputs,
  ...
}: let
  defaultSettings = {};
in {
  flake.nixosModules.foot = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.foot;
    servicePath = "${pkgs.foot}/share/systemd/user/foot-server.service";
    socketPath = "${pkgs.foot}/share/systemd/user/foot-server.socket";
  in {
    options.foot = {
      enable = lib.mkEnableOption "Foot Terminal" // {default = true;};
      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = defaultSettings;
        description = "Foot terminal settings.";
      };
      users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            enable = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "Whether Foot configuration is enabled for this user.";
            };
            settings = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = {};
              description = "User-specific Foot configuration settings overriding global defaults.";
            };
          };
        });
        default = {};
        description = "Per-user Foot configuration overrides.";
      };
      server.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to enable Foot server mode.";
      };
    };

    config = lib.mkIf cfg.enable {
      environment.systemPackages = [pkgs.foot];

      home.shared = {
        xdg.config."foot/foot.ini" = {
          generator = lib.generators.toINI {};
          value = cfg.settings;
        };

        files = lib.mkIf cfg.server.enable {
          ".config/systemd/user/foot-server.service".source = servicePath;
          ".config/systemd/user/foot-server.socket".source = socketPath;
          ".config/systemd/user/graphical-session.target.wants/foot-server.socket".source = socketPath;
        };
      };

      home.users = lib.mapAttrs (userName: uCfg:
        lib.mkIf (uCfg.enable != false) {
          xdg.config."foot/foot.ini" = {
            generator = lib.generators.toINI {};
            value = lib.recursiveUpdate cfg.settings uCfg.settings;
          };
        })
      cfg.users;

      persistence.users = self.lib.user.forNormalUsers config (_: _: {
        data.directories = [".config/foot"];
      });
    };
  };

  perSystem = {pkgs, ...}: {
    packages.foot = inputs.wrapper-modules.wrappers.foot.wrap {
      inherit pkgs;
      settings = defaultSettings;
    };
  };
}
