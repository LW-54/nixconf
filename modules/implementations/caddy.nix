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

      mkForwardAuthBlock = hostCfg: let
        fa = cfg.forwardAuth;
        stripLines = lib.concatMapStringsSep "\n" (h: "request_header -${h}") fa.copyHeaders;
        copyHeadersDirective = lib.optionalString (fa.copyHeaders != []) "copy_headers ${lib.concatStringsSep " " fa.copyHeaders}";
        hasBypass = hostCfg.bypassPaths != [];
        matcherDef = lib.optionalString hasBypass "@protected not path ${lib.concatStringsSep " " hostCfg.bypassPaths}";
        matcherRef = lib.optionalString hasBypass " @protected";
      in ''
        ${matcherDef}
        route {
          ${stripLines}
          forward_auth${matcherRef} ${fa.upstream} {
            uri ${fa.uri}
            ${copyHeadersDirective}
          }
          reverse_proxy ${hostCfg.upstream}
        }
      '';
    in {
      assertions = [
        {
          assertion = conflicts == [];
          message = "Reverse proxy port conflict(s) detected: ${lib.concatMapStringsSep "; " formatConflict conflicts}.";
        }
        {
          assertion = !cfg.forwardAuth.enable || cfg.forwardAuth.upstream != null;
          message = "Reverse proxy forwardAuth is enabled (`reverse-proxy.forwardAuth.enable = true`), but `reverse-proxy.forwardAuth.upstream` is null.";
        }
      ];

      services.caddy = {
        enable = true;
        virtualHosts =
          lib.mapAttrs (_: hostCfg: let
            useForwardAuth = cfg.forwardAuth.enable && hostCfg.forwardAuth && cfg.forwardAuth.upstream != null;
          in {
            extraConfig = lib.concatStringsSep "\n" (
              lib.filter (s: s != "") [
                (lib.optionalString (hostCfg.basicAuth != null) ''
                  basicauth / {
                    ${lib.concatStringsSep "\n" (lib.mapAttrsToList (user: hash: "${user} ${hash}") hostCfg.basicAuth)}
                  }
                '')
                (
                  if useForwardAuth
                  then mkForwardAuthBlock hostCfg
                  else "reverse_proxy ${hostCfg.upstream}"
                )
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
