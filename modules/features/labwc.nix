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
    defaultEnvironment = ''
      XKB_DEFAULT_LAYOUT=fr
      XKB_DEFAULT_VARIANT=
      XKB_DEFAULT_OPTIONS=
      XCURSOR_THEME=Adwaita
      XCURSOR_SIZE=24
    '';
  in {
    imports = [
      (self.lib.users.mkHjemUserProjection {
        inherit lib;
        name = "labwc";
        description = "Labwc";
        userOptions = {
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
      })
    ];

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
    };

    config = {
      programs.labwc.enable = true;
      environment.systemPackages = [pkgs.adwaita-icon-theme];

      hjem.extraModules = [
        ({name, ...}: let
          user = lib.attrByPath [name] {} cfg.users;
          userRc = user.rc or null;
          userEnvironment = user.environment or null;
          rc =
            if userRc == null
            then cfg.rc
            else userRc;
          environment =
            if userEnvironment == null
            then cfg.environment
            else userEnvironment;
        in {
          files =
            (lib.optionalAttrs (rc != null) {
              ".config/labwc/rc.xml".text = rc;
            })
            // (lib.optionalAttrs (environment != null) {
              ".config/labwc/environment".text = environment;
            });
        })
      ];

      persistence.users = self.lib.users.mkUserPersistence {
        inherit lib config;
        data.directories = [".config/labwc"];
      };
    };
  };
}
