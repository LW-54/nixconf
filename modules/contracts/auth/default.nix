{
  config,
  lib,
  ...
}: let
  types = config.contract.auth.types;
  mkPort = config.contract.reverse-proxy.lib.mkPort.value;
in {
  contract.auth = {
    description = "Declarative single sign-on (SSO), forward authentication, access control policy, and LDAP directory contract.";

    options = {
      enable = lib.mkEnableOption "centralized authentication, directory, and single sign-on contract";

      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "auth";
        example = "auth";
        description = "Subdomain prefix under `reverse-proxy.domain` exposing the SSO login portal.";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        example = "127.0.0.1";
        description = "Local bind address for the SSO authentication server.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = mkPort "auth";
        example = 9091;
        description = "Local TCP port on which the SSO authentication server listens.";
      };

      defaultPolicy = lib.mkOption {
        type = types.policy;
        default = "one_factor";
        example = "two_factor";
        description = "Default access control policy enforced across SSO-protected virtual hosts.";
      };

      adminGroup = lib.mkOption {
        type = lib.types.str;
        default = "lldap_admin";
        example = "lldap_admin";
        description = "Directory group name granted administrative privileges across integrated services.";
      };

      directory = lib.mkOption {
        type = types.directory;
        default = {};
        example = {
          adminUser = "admin";
        };
        description = "Backing LDAP directory service configuration and administrative account settings.";
      };

      rules = lib.mkOption {
        type = lib.types.attrsOf types.rule;
        default = {};
        example = {
          "ttyd.adje.app" = {
            domain = "ttyd.adje.app";
            policy = "two_factor";
          };
        };
        description = "Attribute set of explicit access control rules evaluated before the fallback domain policy.";
      };
    };

    mkOption = {
      policy ? null,
      subject ? [],
      resources ? [],
    }: {
      auth = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Whether this service participates in centralized SSO access control rules.";
        };

        policy = lib.mkOption {
          type = lib.types.nullOr types.policy;
          default = policy;
          description = "Optional access control policy override (`bypass`, `one_factor`, `two_factor`, or `deny`) for this service.";
        };

        subject = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = subject;
          description = "Optional user or group subject constraints required to access this service.";
        };

        resources = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = resources;
          description = "Optional regex path patterns scoping this access control rule.";
        };
      };
    };

    mkConfig = {
      config,
      cfg,
    }: let
      domain = config.reverse-proxy.domain or null;
      authEnabled = config.auth.enable or false;
      fqdn =
        if (cfg.subdomain or null) != null && domain != null
        then "${cfg.subdomain}.${domain}"
        else null;
      ruleCfg = cfg.auth or {};
      hasCustomRule =
        (ruleCfg.enable or false)
        && fqdn != null
        && (
          (ruleCfg.policy or null)
          != null
          || (ruleCfg.subject or []) != []
          || (ruleCfg.resources or []) != []
        );
    in
      lib.mkIf (authEnabled && hasCustomRule) {
        auth.rules.${fqdn} = {
          domain = fqdn;
          policy =
            if (ruleCfg.policy or null) != null
            then ruleCfg.policy
            else config.auth.defaultPolicy;
          subject = ruleCfg.subject or [];
          resources = ruleCfg.resources or [];
        };
      };
  };
}
