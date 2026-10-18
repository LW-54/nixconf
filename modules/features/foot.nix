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
    settings = self.lib.users.mkOptionWithUserOverride {
      inherit lib;
      type = lib.types.attrsOf lib.types.anything;
      default = defaultSettings;
      userDefault = {};
      merge = lib.recursiveUpdate;
      description = "Foot terminal settings";
    };
    server = self.lib.users.mkOptionWithUserOverride {
      inherit lib;
      type = lib.types.bool;
      default = true;
      userDefault = null;
      description = "Foot server mode";
    };
  in {
    imports = [
      (self.lib.users.mkUserFeature {
        inherit lib;
        name = "foot";
        description = "Foot Terminal";
        package = pkgs: pkgs.foot;

        featureOptions.settings = settings.global;
        featureOptions.server.enable = server.global;
        userOptions.settings = settings.user;
        userOptions.server.enable = server.user;

        userModule = {
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
          xdg.config.files."foot/foot.ini" = {
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

    config.persistence.users = self.lib.users.mkUserPersistence {
      inherit lib config;
      userEnabled = userName:
        self.lib.users.resolveUserOption {
          inherit lib;
          global = config.foot.enable;
          users = config.foot.users;
          inherit userName;
        };
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
