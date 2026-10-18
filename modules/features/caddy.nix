{self, ...}: {
  flake.nixosModules.caddy = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.reverseProxy;
  in {
    imports = [self.nixosModules.reverse-proxy];

    config = lib.mkIf cfg.enable {
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

      persistence.directories = lib.mkIf (config.persistence ? enable && config.persistence.enable) [
        "/var/lib/caddy"
      ];
    };
  };
}
