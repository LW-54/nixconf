{lib, ...}: let
  entries = lib.types.listOf (lib.types.either lib.types.str (lib.types.attrsOf lib.types.anything));

  scope = subject: {
    directories = lib.mkOption {
      type = entries;
      default = [];
      description = ''
        List of directory paths to persist across reboots, ${subject}.
        Can be string paths or attribute sets defining custom ownership and bind-mount modes.
      '';
    };

    files = lib.mkOption {
      type = entries;
      default = [];
      description = ''
        List of individual file paths to persist across reboots, ${subject}.
        Can be string paths or attribute sets defining custom ownership and bind-mount modes.
      '';
    };
  };
  userSubmodule = lib.types.submodule {
    options = {
      data = lib.mkOption {
        type = lib.types.submodule {
          options = scope "relative to `/home/<name>`, persisted under `/persist/users/<name>/data`";
        };
        default = {};
      };
      cache = lib.mkOption {
        type = lib.types.submodule {
          options = scope "relative to `/home/<name>`, persisted under `/persist/users/<name>/cache`";
        };
        default = {};
      };
    };
  };
in {
  mkContract.persistence = {
    options =
      {
        enable = lib.mkEnableOption "declarative filesystem persistence contract mapped to impermanence" // {default = true;};

        users = lib.mkOption {
          type = lib.types.attrsOf userSubmodule;
          default = {};
          description = ''
            Per-user persistence declarations keyed by username.
            `data` and `cache` root names are repository conventions, not upstream impermanence requirements.
          '';
        };
      }
      // scope "as absolute system paths under `/persist/system`";

    types = {
      inherit entries;
      user = userSubmodule;
    };

    extraLib = {
      inherit entries;
    };
  };
}
