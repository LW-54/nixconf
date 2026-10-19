{...}: {
  flake.nixosModules.caddy = {
    config,
    lib,
    ...
  }: let
    cfg = config.reverse-proxy;
  in {
    config = lib.mkIf (cfg.enable or false) {
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

      resources.services.caddy = lib.mkIf (config.resources.enable or false) {
        profile = "critical";
        memory.low = "32M";
        memory.high = "256M";
        memory.max = "512M";
      };
    };
  };
}
