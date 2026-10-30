{self, ...}: {
  /**
  Automated TLS virtual host reverse proxy implementation using Caddy.
  */
  implementation.caddy = {
    contract = "reverse-proxy";
    description = "Automated TLS virtual host reverse proxy implementation using Caddy.";
    module = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.reverse-proxy;
    in {
      imports = [self.nixosModules.testing];

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

      # Offline test networks cannot obtain certificates, but the listeners and the
      # automatic HTTP->HTTPS redirect prove every virtual host was loaded.
      testing.checks.reverse-proxy = {
        description = "Caddy serves ${toString (builtins.length (builtins.attrNames cfg.hosts))} virtual host(s)";
        script = ''
          machine.wait_for_unit("caddy.service")
          machine.wait_for_open_port(80)
          machine.wait_for_open_port(443)
          for _host in ${builtins.toJSON (builtins.attrNames cfg.hosts)}:
              _code = machine.succeed(
                  f"${pkgs.curl}/bin/curl -s -o /dev/null -w '%{{http_code}}' --resolve {_host}:80:127.0.0.1 http://{_host}/"
              ).strip()
              assert _code in ("301", "302", "307", "308"), f"{_host}: expected an HTTPS redirect, got HTTP {_code}"
        '';
      };

      persistence.directories = lib.mkIf (config.persistence.enable or false) [
        "/var/lib/caddy"
      ];
    };
  };
}
