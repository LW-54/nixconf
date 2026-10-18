{self, ...}: {
  flake.nixosModules.labwc = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.labwc;
    defaultRc = ''
      <?xml version="1.0"?>
      <labwc_config>
        <core>
          <gap>10</gap>
        </core>
        <windowSwitcher preview="no" outlines="yes">
          <osd style="thumbnail" />
        </windowSwitcher>
        <keyboard>
          <default />
          <keybind key="W-Space">
            <action name="Execute" command="noctalia msg panel-toggle launcher" />
          </keybind>
          <keybind key="W-c">
            <action name="Execute" command="noctalia msg panel-toggle clipboard" />
          </keybind>
          <keybind key="W-w">
            <action name="Execute" command="noctalia msg panel-toggle wallpaper" />
          </keybind>
          <keybind key="W-n">
            <action name="Execute" command="noctalia msg panel-toggle notifications" />
          </keybind>
          <keybind key="W-s">
            <action name="Execute" command="noctalia msg panel-toggle control-center" />
          </keybind>
          <keybind key="W-comma">
            <action name="Execute" command="noctalia msg settings-toggle" />
          </keybind>
          <keybind key="XF86AudioRaiseVolume">
            <action name="Execute" command="noctalia msg volume-up" />
          </keybind>
          <keybind key="XF86AudioLowerVolume">
            <action name="Execute" command="noctalia msg volume-down" />
          </keybind>
          <keybind key="XF86AudioMute">
            <action name="Execute" command="noctalia msg volume-mute" />
          </keybind>
          <keybind key="XF86MonBrightnessUp">
            <action name="Execute" command="noctalia msg brightness-up" />
          </keybind>
          <keybind key="XF86MonBrightnessDown">
            <action name="Execute" command="noctalia msg brightness-down" />
          </keybind>
        </keyboard>
      </labwc_config>
    '';
    defaultEnvironment = "";
  in {
    options.labwc = {
      rc = lib.mkOption {
        type = lib.types.lines;
        default = defaultRc;
        description = "Global Labwc rc.xml content inherited by users.";
      };

      environment = lib.mkOption {
        type = lib.types.lines;
        default = defaultEnvironment;
        description = "Global Labwc environment inherited by users.";
      };

      users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            rc = lib.mkOption {
              type = lib.types.nullOr lib.types.lines;
              default = null;
              description = "Labwc rc.xml content for this user.";
            };

            environment = lib.mkOption {
              type = lib.types.nullOr lib.types.lines;
              default = null;
              description = "Labwc environment variables for this user.";
            };
          };
        });
        default = {};
        description = "Per-user Labwc overrides.";
      };
    };

    config = {
      programs.uwsm.waylandCompositors.labwc = {
        prettyName = "Labwc";
        comment = "Labwc managed by UWSM";
        binPath = lib.getExe pkgs.labwc;
      };
      environment.systemPackages = [pkgs.labwc];

      users.home =
        lib.mapAttrs (
          userName: _: let
            user = lib.attrByPath [userName] {} cfg.users;
            rc = user.rc or cfg.rc;
            environment = user.environment or cfg.environment;
          in {
            files =
              (lib.optionalAttrs (rc != null) {
                ".config/labwc/rc.xml".text = rc;
              })
              // (lib.optionalAttrs (environment != null) {
                ".config/labwc/environment".text = environment;
              });
          }
        )
        config.users.account;

      persistence.users = self.lib.users.mkPersistence {
        inherit lib config;
        data.directories = [".config/labwc"];
      };
    };
  };
}
