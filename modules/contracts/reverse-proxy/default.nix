{
  config,
  lib,
  ...
}: let
  types = config.contract.reverse-proxy.types;
  mkPort = config.contract.reverse-proxy.lib.mkPort.value;
in {
  contract.reverse-proxy = {
    description = "Declarative HTTP/TLS reverse proxy virtual host ingress and routing management.";

    options = {
      enable = lib.mkEnableOption "system reverse proxy contract";

      domain = lib.mkOption {
        type = lib.types.nullOr types.fqdn;
        default = null;
        example = "adje.app";
        description = ''
          Base root domain name used for virtual host construction.
          Services providing a subdomain prefix will be exposed as `<subdomain>.<domain>`.
        '';
      };

      hosts = lib.mkOption {
        type = lib.types.attrsOf types.host;
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

      ports = lib.mkOption {
        type = lib.types.listOf types.portAllocation;
        default = [];
        example = [
          {
            owner = "vault.example.com";
            address = "127.0.0.1";
            port = 23469;
            protocol = "tcp";
          }
        ];
        description = ''
          Declarative registry of provisioned service port allocations used to verify
          non-conflicting local endpoint bindings across the host at evaluation time.
        '';
      };
    };

    mkOption = {
      subdomain ? null,
      port ? null,
      address ? "127.0.0.1",
      basicAuth ? null,
    }: {
      subdomain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = subdomain;
        description = "Subdomain prefix for reverse proxy.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default =
          if port != null
          then port
          else if subdomain != null
          then mkPort subdomain
          else 80;
        description = "Local service port (automatically provisioned from `subdomain` when omitted).";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = address;
        description = "Local service bind address.";
      };

      basicAuth = lib.mkOption {
        type = lib.types.nullOr (lib.types.attrsOf lib.types.str);
        default = basicAuth;
        description = "Basic auth credentials for the reverse-proxied service.";
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
      owner =
        if fqdn != null
        then fqdn
        else if (cfg.subdomain or null) != null
        then cfg.subdomain
        else "${cfg.address}:${toString cfg.port}";
    in
      lib.mkIf (enable && fqdn != null) {
        reverse-proxy = {
          ports = [
            {
              inherit owner;
              inherit (cfg) address port;
              protocol = "tcp";
            }
          ];
          hosts.${fqdn} = {
            upstream = "${cfg.address}:${toString cfg.port}";
            inherit (cfg) basicAuth;
          };
        };
      };
  };
}
