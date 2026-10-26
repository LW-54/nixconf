{lib, ...}: let
  /**
  Type validating Fully Qualified Domain Names (FQDN) matching standard internet hostname format.
  */
  fqdn = lib.types.mkOptionType {
    name = "fqdn";
    description = "Fully qualified domain name";
    check = x: builtins.isString x && builtins.match "^([a-zA-Z0-9][-a-zA-Z0-9]*\\.)+[a-zA-Z]{2,}$" x != null;
    merge = lib.options.mergeOneOption;
  };

  hostSubmodule = lib.types.submodule {
    options = {
      upstream = lib.mkOption {
        type = lib.types.str;
        example = "127.0.0.1:8080";
        description = ''
          Target upstream socket, host, or IP address and port where the service
          is listening and accepting proxied HTTP/WebSocket connections.
        '';
      };

      basicAuth = lib.mkOption {
        type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
        default = null;
        example = {admin = "$2a$14$...";};
        description = ''
          Optional map of usernames to bcrypt-hashed password strings for
          HTTP Basic Authentication enforcement at the proxy boundary.
        '';
      };

      extraConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Raw backend-specific configuration directives injected directly
          into the virtual host definition (e.g. custom headers or timeouts).
        '';
      };
    };
  };
in {
  contract.reverse-proxy = {
    description = "Declarative HTTP/TLS reverse proxy virtual host ingress and routing management.";

    options = {
      enable = lib.mkEnableOption "system reverse proxy contract";

      domain = lib.mkOption {
        type = lib.types.nullOr fqdn;
        default = null;
        example = "adje.app";
        description = ''
          Base root domain name used for virtual host construction.
          Services providing a subdomain prefix will be exposed as `<subdomain>.<domain>`.
        '';
      };

      hosts = lib.mkOption {
        type = lib.types.attrsOf hostSubmodule;
        default = {};
        example = {
          "vault.example.com" = {
            upstream = "127.0.0.1:8222";
          };
        };
        description = ''
          Attribute set of virtual host fully-qualified domain names (FQDN)
          mapped to upstream backend endpoints and proxy policies.
        '';
      };
    };

    mkOption = {
      subdomain ? null,
      port ? 80,
      address ? "127.0.0.1",
      basicAuth ? null,
    }: {
      subdomain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = subdomain;
        description = "Subdomain prefix for reverse proxy";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = port;
        description = "Local service port";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = address;
        description = "Local service bind address";
      };

      basicAuth = lib.mkOption {
        type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
        default = basicAuth;
        description = "Basic auth credentials for the reverse-proxied service";
      };
    };

    mkConfig = {
      config,
      cfg,
    }: let
      domain = config.reverse-proxy.domain or null;
      enable = config.reverse-proxy.enable or false;
      fqdn =
        if cfg.subdomain != null && domain != null
        then "${cfg.subdomain}.${domain}"
        else null;
    in
      lib.mkIf (enable && fqdn != null) {
        reverse-proxy.hosts.${fqdn} = {
          upstream = "${cfg.address}:${toString cfg.port}";
          inherit (cfg) basicAuth;
        };
      };

    types = {
      host = hostSubmodule;
      inherit fqdn;
    };
  };
}
