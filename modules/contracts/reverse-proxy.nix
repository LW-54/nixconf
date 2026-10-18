{lib, ...}: {
  flake.nixosModules.reverse-proxy = {lib, ...}: {
    key = "contracts-reverse-proxy";

    options.services.reverseProxy = {
      enable = lib.mkEnableOption "system reverse proxy" // {default = true;};

      domain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Base domain name for reverse-proxied services (e.g. adje.app).";
      };

      hosts = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            upstream = lib.mkOption {
              type = lib.types.str;
              example = "127.0.0.1:8222";
              description = "Upstream address:port to proxy requests to.";
            };

            basicAuth = lib.mkOption {
              type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
              default = null;
              example = {admin = "$2a$14$...";};
              description = "Attribute set of username to bcrypt hashed password.";
            };

            extraConfig = lib.mkOption {
              type = lib.types.lines;
              default = "";
              description = "Extra reverse proxy directives.";
            };
          };
        });
        default = {};
        description = "Virtual host configurations mapped to upstream targets.";
      };
    };
  };

  flake.lib.reverse-proxy = {
    mkOptions = {
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
      domain = config.services.reverseProxy.domain;
      fqdn =
        if cfg.subdomain != null && domain != null
        then "${cfg.subdomain}.${domain}"
        else null;
    in
      lib.mkIf (config.services.reverseProxy.enable && fqdn != null) {
        services.reverseProxy.hosts.${fqdn} = {
          upstream = "${cfg.address}:${toString cfg.port}";
          inherit (cfg) basicAuth;
        };
      };
  };
}
