{...}: {
  flake.nixosModules.vaultwarden = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.vaultwarden-server;
    domain = config.services.reverseProxy.domain;
    fqdn =
      if cfg.subdomain != null && domain != null
      then "${cfg.subdomain}.${domain}"
      else null;
  in {
    options.services.vaultwarden-server = {
      enable = lib.mkEnableOption "Vaultwarden password manager server" // {default = true;};

      subdomain = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "vaultwarden";
        description = "Subdomain prefix for reverse proxy";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8222;
        description = "Local port for Rocket";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Local bind address for Rocket";
      };
    };

    config = lib.mkIf cfg.enable {
      services.vaultwarden = {
        enable = true;
        config = {
          DOMAIN = lib.optionalString (fqdn != null) "https://${fqdn}";
          ROCKET_ADDRESS = cfg.address;
          ROCKET_PORT = cfg.port;
          WEB_VAULT_ENABLED = true;
        };
      };

      # Auto-register with reverse proxy if enabled
      services.reverseProxy.hosts = lib.mkIf (config.services.reverseProxy.enable && fqdn != null) {
        "${fqdn}" = {
          upstream = "${cfg.address}:${toString cfg.port}";
        };
      };

      # Auto-persist state directory if persistence is enabled
      persistence.directories = lib.mkIf (config.persistence ? enable && config.persistence.enable) [
        "/var/lib/vaultwarden"
      ];

      # Auto-include in backups if backup contract is enabled
      backup.paths = lib.mkIf (config.backup ? enable && config.backup.enable) [
        "/var/lib/vaultwarden"
      ];
    };
  };
}
