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
    defaultSettings = {
      accessibility.ui_scale = 0.9;
      bar.default = {
        capsule_group = [];
        end = ["tray" "keyboard_layout" "battery" "network" "bluetooth" "session"];
        margin_ends = 0;
        radius = 0;
        scale = 0.9;
        start = ["launcher" "workspaces"];
        thickness = 30;
        widget_spacing = 7;
        dead_zone.actions.left = "panel-toggle control-center system";
      };
      location.auto_locate = true;
      lockscreen_widgets = {
        enabled = false;
        schema_version = 2;
        widget_order = ["lockscreen-login-box@eDP-1"];
        grid = {
          cell_size = 16;
          major_interval = 4;
          visible = true;
        };
        widget."lockscreen-login-box@eDP-1" = {
          box_height = 196.0;
          box_width = 810.0;
          cx = 683.0;
          cy = 586.0;
          output = "eDP-1";
          placement_height = 768.0;
          placement_width = 1366.0;
          rotation = 0;
          type = "login_box";
          settings = {
            background_color = "surface_variant";
            background_opacity = 0.88;
            background_radius = 12.0;
            center_password_text = false;
            input_opacity = 1.0;
            input_radius = 6.0;
            layout = "regular";
            show_caps_lock = true;
            show_keyboard_layout = true;
            show_login_button = true;
            show_media = true;
            show_password_reveal = true;
            show_session_buttons = true;
            show_unlock_hint = true;
            show_weather = true;
          };
        };
      };
      shell = {
        corner_radius_scale = 0.0;
        font_family = "JetBrains Mono";
        launch_apps_as_systemd_services = true;
      };
      theme = {
        builtin = "Nord";
        community_palette = "Oxocarbon";
        mode = "dark";
        pure_black_dark = true;
        source = "builtin";
        wallpaper_scheme = "m3-content";
        templates.builtin_ids = ["foot" "labwc"];
      };
      widget.network.show_label = false;
      widget.workspaces.style = "minimal";
    };
  in {
    options.noctalia = {
      enable = lib.mkEnableOption "Noctalia Shell" // {default = true;};
      systemd.enable = lib.mkEnableOption "the Noctalia user service" // {default = true;};
      systemd.target = lib.mkOption {
        type = lib.types.str;
        default = "graphical-session.target";
        description = "The user systemd target that starts Noctalia.";
      };
      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = defaultSettings;
        description = "Global Noctalia settings inherited by users.";
      };
      customPalettes = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Global Noctalia palettes inherited by users.";
      };

      users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
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
            systemd.target = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              description = "The user systemd target that starts Noctalia.";
            };
            settings = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Noctalia settings for this user.";
            };
            customPalettes = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.anything);
              default = null;
              description = "Custom Noctalia palettes for this user.";
            };
          };
        });
        default = {};
        description = "Per-user Noctalia overrides.";
      };
    };

    config = {
      hardware.bluetooth.enable = lib.mkDefault true;
      services.upower.enable = lib.mkDefault true;
      services.power-profiles-daemon.enable = lib.mkDefault true;

      hjem.extraModules = [
        inputs.noctalia.hjemModules.default
        ({name, ...}: let
          user = lib.attrByPath [name] {} cfg.users;
        in {
          programs.noctalia = {
            enable = lib.mkDefault (user.enable or cfg.enable);
            systemd.enable = lib.mkDefault (user.systemd.enable or cfg.systemd.enable);
            systemd.target = lib.mkDefault (user.systemd.target or cfg.systemd.target);
            settings = lib.mkDefault (
              if user.settings or null == null
              then cfg.settings
              else lib.recursiveUpdate cfg.settings user.settings
            );
            customPalettes = lib.mkDefault (
              if user.customPalettes or null == null
              then cfg.customPalettes
              else lib.recursiveUpdate cfg.customPalettes user.customPalettes
            );
          };
        })
      ];

      persistence.users = self.lib.users.mkPersistence {
        inherit lib config;
        global = cfg.enable;
        userOverrides = cfg.users;
        data.directories = [
          ".config/noctalia"
          ".local/state/noctalia"
          "Pictures/Wallpapers"
        ];
      };
    };
  };
}
