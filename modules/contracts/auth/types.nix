{
  config,
  lib,
  ...
}: let
  mkPort = config.contract.reverse-proxy.lib.mkPort.value;

  policy = lib.types.enum ["bypass" "one_factor" "two_factor" "deny"];

  ruleSubmodule = lib.types.submodule {
    options = {
      domain = lib.mkOption {
        type = lib.types.str;
        example = "ttyd.adje.app";
        description = "Target virtual host domain or wildcard pattern governed by this rule.";
      };

      policy = lib.mkOption {
        type = policy;
        default = "one_factor";
        description = "Authentication factor policy required to access matching resources.";
      };

      subject = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["group:lldap_admin"];
        description = "Optional user or group subject constraints (`user:<name>` or `group:<name>`) required for access.";
      };

      resources = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["^/admin([/?].*)?$"];
        description = "Optional regular expression path patterns scoping this rule to specific URL resources.";
      };
    };
  };

  directorySubmodule = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "backing LDAP user and group directory service" // {default = true;};

      subdomain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "lldap";
        example = "lldap";
        description = "Subdomain prefix under `reverse-proxy.domain` exposing the directory web administration UI.";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        example = "127.0.0.1";
        description = "Local bind address for the LDAP directory HTTP and LDAP listeners.";
      };

      httpPort = lib.mkOption {
        type = lib.types.port;
        default = mkPort "lldap";
        example = 17170;
        description = "Local TCP port on which the directory web administration UI listens.";
      };

      ldapPort = lib.mkOption {
        type = lib.types.port;
        default = 3890;
        example = 3890;
        description = "Local TCP port on which the LDAP directory server listens for bind and search queries.";
      };

      baseDn = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "dc=adje,dc=app";
        description = "Base Distinguished Name (DN) for the LDAP tree (automatically derived from `reverse-proxy.domain` when null).";
      };

      adminUser = lib.mkOption {
        type = lib.types.str;
        default = "admin";
        example = "admin";
        description = "Primary LDAP directory administrator username.";
      };

      adminEmail = lib.mkOption {
        type = lib.types.str;
        default = "admin@example.com";
        example = "admin@adje.app";
        description = "Primary email address assigned to the LDAP directory administrator account.";
      };
    };
  };
in {
  contract.auth.types = {
    inherit policy;
    rule = ruleSubmodule;
    directory = directorySubmodule;
  };
}
