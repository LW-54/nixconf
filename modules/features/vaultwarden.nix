{self, ...}: {
  flake.nixosModules.vaultwarden = {
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
      // self.lib."reverse-proxy".mkOptions {
        subdomain = "vaultwarden";
        port = 8222;
      };

    config = lib.mkIf cfg.enable ({
        services.vaultwarden = {
          enable = true;
          config = {
            DOMAIN = lib.optionalString (cfg.subdomain != null && config.services.reverseProxy.domain != null) "https://${cfg.subdomain}.${config.services.reverseProxy.domain}";
            ROCKET_ADDRESS = cfg.address;
            ROCKET_PORT = cfg.port;
            WEB_VAULT_ENABLED = true;
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
      }
      // self.lib."reverse-proxy".mkConfig {inherit config cfg;});
  };
}
