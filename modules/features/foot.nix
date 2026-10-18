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
    ...
  }: let
    settings = {
      global = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = defaultSettings;
        description = "Foot terminal settings";
      };
      user = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Per-user Foot terminal settings.";
      };
    };
    server = {
      global = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Foot server mode";
      };
      user = lib.mkOption {
        type = lib.types.nullOr lib.types.bool;
        default = null;
        description = "Per-user Foot server mode.";
      };
    };
  in {
    imports = [
      (self.lib.users.mkFeature {
        inherit lib;
        name = "foot";
        description = "Foot Terminal";
        package = pkgs: pkgs.foot;

        featureOptions.settings = settings.global;
        featureOptions.server.enable = server.global;
        userOptions.settings = settings.user;
        userOptions.server.enable = server.user;

        home = {
          cfg,
          user,
          lib,
          pkgs,
          ...
        }: let
          serverOverride = lib.attrByPath ["server" "enable"] null user;
          serverEnabled =
            if serverOverride == null
            then cfg.server.enable
            else serverOverride;
          servicePath = "${pkgs.foot}/share/systemd/user/foot-server.service";
          socketPath = "${pkgs.foot}/share/systemd/user/foot-server.socket";
        in {
          xdg.config."foot/foot.ini" = {
            generator = lib.generators.toINI {};
            value = lib.recursiveUpdate cfg.settings (user.settings or {});
          };

          files = lib.mkIf serverEnabled {
            ".config/systemd/user/foot-server.service".source = servicePath;
            ".config/systemd/user/foot-server.socket".source = socketPath;
            ".config/systemd/user/graphical-session.target.wants/foot-server.socket".source = socketPath;
          };
        };
      })
    ];

    config.persistence.users = self.lib.users.mkPersistence {
      inherit lib config;
      global = config.foot.enable;
      userOverrides = config.foot.users;
      data.directories = [".config/foot"];
    };
  };

  perSystem = {pkgs, ...}: {
    packages.foot = inputs.wrapper-modules.wrappers.foot.wrap {
      inherit pkgs;
      settings = defaultSettings;
    };
  };
}
