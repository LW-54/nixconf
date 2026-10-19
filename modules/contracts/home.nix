{lib, ...}: let
  /**
  Type validating relative home directory file or directory paths.
  Enforces that paths never start with '/' and never contain '..' traversal components.
  */
  relativeHomePath = lib.types.mkOptionType {
    name = "relativeHomePath";
    description = "Relative path within home directory (no leading '/' or '..')";
    check = x: builtins.isString x && !lib.hasPrefix "/" x && !lib.hasInfix ".." x;
    merge = lib.options.mergeOneOption;
  };

  /**
  Submodule defining a single managed file or symlink in the user's home directory.
  */
  fileSubmodule = lib.types.submodule ({config, ...}: {
    freeformType = lib.types.attrsOf lib.types.anything;
    options = {
      source = lib.mkOption {
        type = lib.types.nullOr lib.types.anything;
        default = null;
        description = ''
          Filesystem path or store path of the source file to link into the home directory.
          Mutually exclusive with `text`.
        '';
      };

      text = lib.mkOption {
        type = lib.types.nullOr lib.types.lines;
        default =
          if config.generator != null && config.value != null
          then config.generator config.value
          else null;
        description = ''
          Literal string or multiline text content to write into the target managed file.
          Mutually exclusive with `source`.
        '';
      };

      generator = lib.mkOption {
        type = lib.types.nullOr (lib.types.functionTo lib.types.lines);
        default = null;
        description = ''
          Optional serializer function (e.g. `lib.generators.toINI {}`) transforming
          `value` into declarative file text.
        '';
      };

      value = lib.mkOption {
        type = lib.types.nullOr lib.types.anything;
        default = null;
        description = ''
          Structured Nix data passed to `generator` to dynamically serialize file content.
        '';
      };

      executable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether the managed file should have executable permission bits set (`+x`).
        '';
      };

      force = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          Whether the backend interpreter is permitted to overwrite an existing,
          unmanaged file at the target path.
        '';
      };
    };

    config.assertions = [
      {
        assertion = config.source == null || config.text == null;
        message = "A home file must define either `source` or `text`, not both.";
      }
    ];
  });

  filesType = lib.types.attrsOf fileSubmodule;

  xdgSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "XDG directory and configuration file management" // {default = true;};

      cache = lib.mkOption {
        type = filesType;
        default = {};
        description = "Files mapped relative to `$XDG_CACHE_HOME` (`~/.cache`).";
      };

      config = lib.mkOption {
        type = filesType;
        default = {};
        description = "Files mapped relative to `$XDG_CONFIG_HOME` (`~/.config`).";
      };

      data = lib.mkOption {
        type = filesType;
        default = {};
        description = "Files mapped relative to `$XDG_DATA_HOME` (`~/.local/share`).";
      };

      state = lib.mkOption {
        type = filesType;
        default = {};
        description = "Files mapped relative to `$XDG_STATE_HOME` (`~/.local/state`).";
      };

      bin = lib.mkOption {
        type = filesType;
        default = {};
        description = "Files mapped relative to `$XDG_BIN_HOME` (`~/.local/bin`).";
      };
    };
  };

  userHomeSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether home management is enabled for this user.";
      };

      packages = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [];
        description = "Packages installed in this user's profile.";
      };

      files = lib.mkOption {
        type = filesType;
        default = {};
        description = "Arbitrary dotfiles and configuration files mapped relative to `/home/${name}`.";
      };

      xdg = lib.mkOption {
        type = xdgSubmodule;
        default = {};
        description = "Standard XDG Base Directory specification paths for ${name}.";
      };

      sessionVariables = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Environment variables set in the user's session.";
      };

      systemd.services = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Per-user systemd service unit configurations.";
      };
    };
  });
in {
  mkContract.home = {
    options = {
      enable = lib.mkEnableOption "declarative user home dotfile and environment contract" // {default = true;};

      shared = lib.mkOption {
        type = userHomeSubmodule;
        default = {};
        description = ''
          Shared dotfile tree and environment configurations applied across all managed users.
        '';
      };

      users = lib.mkOption {
        type = lib.types.attrsOf userHomeSubmodule;
        default = {};
        description = ''
          Per-user dotfile tree and environment configurations mapped to active backend interpreters (e.g. Hjem).
        '';
      };
    };

    mkOption = {
      lib ? null,
      name,
      description,
      defaultEnable ? true,
      userOptions ? {},
    }: {
      options.${name} = {
        enable = lib.mkEnableOption description // {default = defaultEnable;};
        users = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options =
              {
                enable = lib.mkOption {
                  type = lib.types.nullOr lib.types.bool;
                  default = null;
                  description = "Whether to enable ${description} for this user.";
                };
              }
              // userOptions;
          });
          default = {};
          description = "Per-user configuration overrides for ${description}.";
        };
      };
    };

    mkConfig = {
      config,
      lib ? null,
      homeConfig,
    }:
      lib.mkIf (config.home.enable or false) {
        home.users = lib.mapAttrs (
          userName: _: homeConfig userName
        ) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
      };

    types = {
      file = fileSubmodule;
      files = filesType;
      xdg = xdgSubmodule;
      userHome = userHomeSubmodule;
      inherit relativeHomePath;
    };
  };
}
