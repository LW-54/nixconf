{lib, ...}: let
  /**
  List of directory or file paths to persist, either strings or custom bind-mount attribute sets.

  # Type
  ```
  entries :: Type
  ```
  */
  entries = lib.types.listOf (lib.types.either lib.types.str (lib.types.attrsOf lib.types.anything));

  scope = subject: {
    directories = lib.mkOption {
      type = entries;
      default = [];
      example = ["/var/log"];
      description = ''
        List of directory paths to persist across reboots, ${subject}.
        Can be string paths or attribute sets defining custom ownership and bind-mount modes.
      '';
    };

    files = lib.mkOption {
      type = entries;
      default = [];
      example = ["/etc/machine-id"];
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
  contract.persistence = {
    description = "Declarative state preservation across ephemeral reboots for system and user directories.";

    options =
      {
        enable = lib.mkEnableOption "declarative filesystem persistence contract mapped to impermanence" // {default = true;};

        users = lib.mkOption {
          type = lib.types.attrsOf userSubmodule;
          default = {};
          example = {
            lw = {
              data.directories = [".ssh"];
            };
          };
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

    lib = {
      entries = {
        docstring = ''
          List of directory or file paths to persist, either strings or custom bind-mount attribute sets.

          # Type
          ```
          entries :: Type
          ```
        '';
        value = entries;
      };
    };
  };
}
