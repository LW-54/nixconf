{lib, ...}: let
  secretSubmodule = lib.types.submodule ({
    name,
    config,
    ...
  }: {
    options = {
      file = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Encrypted file containing this secret (defaults to resolved `store` or `secrets.defaultFile`).";
      };

      store = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "storage/hbox";
        description = "Logical secret store path relative to `secrets/` (resolved by the active secrets implementation, e.g. `secrets/<store>.yaml`).";
      };

      key = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Key path within the encrypted secret file.";
      };

      owner = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = "User owner of the decrypted secret file.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = "Group owner of the decrypted secret file.";
      };

      mode = lib.mkOption {
        type = lib.types.str;
        default = "0400";
        description = "Permission bits mode for the decrypted secret file.";
      };

      neededForUsers = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether the secret must be decrypted before user accounts are created.";
      };

      path = lib.mkOption {
        type = lib.types.str;
        default =
          if config.neededForUsers
          then "/run/secrets-for-users/${name}"
          else "/run/secrets/${name}";
        description = "Decrypted filesystem path where the secret is exposed on the host.";
      };

      testValue = lib.mkOption {
        type = lib.types.str;
        default = "nixconf-test-secret:${name}";
        example = "KEY=value";
        description = ''
          Non-sensitive stand-in plaintext provisioned instead of the real secret when the host runs
          under `testing.enable` (VM and install tests), so tests never need the real decryption keys.
          Override it when consumers expect a specific format (password hash, SSH key, env file).
        '';
      };
    };
  });

  templateSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      content = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Template content interpolating `secrets.placeholder.<name>` tokens.";
      };

      owner = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = "User owner of the rendered template file.";
      };

      group = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = "Group owner of the rendered template file.";
      };

      mode = lib.mkOption {
        type = lib.types.str;
        default = "0400";
        description = "Permission bits mode for the rendered template file.";
      };

      path = lib.mkOption {
        type = lib.types.str;
        default = "/run/secrets/rendered/${name}";
        description = "Filesystem path where the rendered template is exposed on the host.";
      };
    };
  });
in {
  contract.secrets = {
    description = "Declarative encrypted secrets provisioning, filesystem mounting, and permission management.";

    options = {
      enable = lib.mkEnableOption "system secrets management contract" // {default = true;};

      defaultFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        example = lib.literalExpression "./secrets/secrets.yaml";
        description = ''
          Default YAML/JSON file containing encrypted secrets for this host.
          Can be overridden on a per-secret basis by consumer features.
        '';
      };

      files = lib.mkOption {
        type = lib.types.attrsOf secretSubmodule;
        default = {};
        example = {
          "service/env" = {
            owner = "root";
          };
        };
        description = ''
          Attribute set of declarative secret items required by system services.
          Mapped to the active secrets provider implementation (e.g. SOPS).
        '';
      };

      templates = lib.mkOption {
        type = lib.types.attrsOf templateSubmodule;
        default = {};
        example = {
          "service.env" = {
            content = "TOKEN=placeholder";
          };
        };
        description = ''
          Attribute set of rendered secret-interpolated configuration files managed
          by the active secrets provider implementation.
        '';
      };

      placeholder = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        example = {
          "service/token" = "<SOPS:service/token:placeholder>";
        };
        description = ''
          Map of secret names to placeholder tokens for safe interpolation
          inside `secrets.templates.<name>.content`.
        '';
      };
    };

    mkOption = {secrets ? []}: {
      secrets = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether secret provisioning is enabled for this service.";
        };

        required = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = secrets;
          description = "Secret identifiers required by this service.";
        };
      };
    };

    mkConfig = {
      config,
      cfg,
      secrets ? {},
    }:
      lib.mkIf ((config.secrets.enable or false) && cfg ? secrets && cfg.secrets.enable) {
        secrets.files = secrets;
      };

    types = {
      secret = secretSubmodule;
      template = templateSubmodule;
    };
  };
}
