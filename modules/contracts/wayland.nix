{lib, ...}: let
  compositorSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      prettyName = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Human-readable display name of the Wayland compositor.";
      };
      comment = lib.mkOption {
        type = lib.types.str;
        default = "${name} Wayland compositor";
        description = "Description or comment for session entry.";
      };
      binPath = lib.mkOption {
        type = lib.types.str;
        description = "Path to the compositor executable binary.";
      };
    };
  });
in {
  mkContract.wayland = {
    options = {
      enable =
        lib.mkEnableOption "Wayland session management contract"
        // {
          description = ''
            Whether to enable system-level Wayland session orchestration.
            When enabled, Wayland compositor backends (such as UWSM) will configure
            systemd graphical session targets, environment variables, and startup units.
          '';
        };

      compositors = lib.mkOption {
        type = lib.types.attrsOf compositorSubmodule;
        default = {};
        description = "Declarative Wayland compositor registrations managed by the session manager.";
      };
    };

    mkOption = {name}: {
      wayland = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether to enable Wayland session management for ${name}.";
        };
      };
    };

    mkConfig = {
      config,
      cfg,
    }:
      lib.mkIf ((config.wayland.enable or false) && cfg ? wayland && cfg.wayland.enable) {};

    types = {
      compositor = compositorSubmodule;
    };
  };
}
