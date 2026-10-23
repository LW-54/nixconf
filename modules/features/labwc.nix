{self, ...}: let
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
        <keybind key="W-v">
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
  feature.labwc = {
    description = "Labwc stacking Wayland compositor with window manager keybindings and XDG autostart.";

    modules = {
      labwc = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.labwc;
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
          wayland.compositors.labwc = {
            prettyName = "Labwc";
            comment = "Labwc Wayland compositor";
            binPath = lib.getExe pkgs.labwc;
          };
          environment.systemPackages = [pkgs.labwc];

          home.shared.xdg.config =
            (lib.optionalAttrs (cfg.rc != null) {
              "labwc/rc.xml".text = cfg.rc;
            })
            // (lib.optionalAttrs (cfg.environment != null) {
              "labwc/environment".text = cfg.environment;
            });

          home.users =
            lib.mapAttrs (userName: uCfg: {
              xdg.config =
                (lib.optionalAttrs (uCfg.rc != null) {
                  "labwc/rc.xml".text = uCfg.rc;
                })
                // (lib.optionalAttrs (uCfg.environment != null) {
                  "labwc/environment".text = uCfg.environment;
                });
            })
            cfg.users;

          persistence.users = self.lib.user.forNormalUsers config (_: _: {
            data.directories = [".config/labwc"];
          });
        };
      };
    };
  };
}
