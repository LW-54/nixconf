{self, ...}: {
  feature.vaultwarden = {
    description = "Self-hosted Bitwarden compatible password manager server.";
    modules = {
      vaultwarden = {
        config,
        lib,
        ...
      }: let
        cfg = config.services.vaultwarden-server;
      in {
        options.services.vaultwarden-server =
          {
            enable = lib.mkEnableOption "Vaultwarden password manager server" // {default = true;};
          }
          // self.lib.reverse-proxy.mkOption {
            subdomain = "vaultwarden";
            port = 8222;
          }
          // self.lib.persistence.mkOption {
            directories = ["/var/lib/vaultwarden"];
          }
          // self.lib.backup.mkOption {
            paths = ["/var/lib/vaultwarden"];
          };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            services.vaultwarden = {
              enable = true;
              config = {
                DOMAIN = let
                  domain = config.reverse-proxy.domain or null;
                in
                  lib.optionalString (cfg.subdomain != null && domain != null) "https://${cfg.subdomain}.${domain}";
                ROCKET_ADDRESS = cfg.address;
                ROCKET_PORT = cfg.port;
                WEB_VAULT_ENABLED = true;
              };
            };
          }
          (self.lib.reverse-proxy.mkConfig {inherit config cfg;})
          (self.lib.persistence.mkConfig {
            inherit config;
            cfg = cfg.persistence;
          })
          (self.lib.backup.mkConfig {
            inherit config;
            cfg = cfg.backup;
          })
        ]);
      };
    };
  };
}
