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
        description = "Encrypted file containing this secret (defaults to `secrets.defaultFile`).";
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
    };
  };
}
