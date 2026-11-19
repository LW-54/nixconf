{...}: {
  /**
  Automated TLS virtual host reverse proxy implementation using Caddy.
  */
  implementation.caddy = {
    contract = "reverse-proxy";
    description = "Automated TLS virtual host reverse proxy implementation using Caddy.";
    module = {
      config,
      lib,
      self,
      ...
    }: let
      cfg = config.reverse-proxy;
      conflicts = self.lib.reverse-proxy.findPortConflicts cfg.ports;
      formatConflict = c: "${c.protocol}/${toString c.port} claimed by ${lib.concatStringsSep ", " c.owners}";
    in {
      assertions = [
        {
          assertion = conflicts == [];
          message = "Reverse proxy port conflict(s) detected: ${lib.concatMapStringsSep "; " formatConflict conflicts}.";
        }
      ];

      services.caddy = {
        enable = true;
        virtualHosts =
          lib.mapAttrs (_: hostCfg: {
            extraConfig = lib.concatStringsSep "\n" (
              lib.filter (s: s != "") [
                (lib.optionalString (hostCfg.basicAuth != null) ''
                  basicauth / {
                    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (user: hash: "${user} ${hash}") hostCfg.basicAuth)}
                  }
                '')
                "reverse_proxy ${hostCfg.upstream}"
                hostCfg.extraConfig
              ]
            );
          })
          cfg.hosts;
      };

      networking.firewall.allowedTCPPorts = [80 443];

      persistence.directories = lib.mkIf (config.persistence.enable or false) [
        "/var/lib/caddy"
      ];
    };
  };
}
