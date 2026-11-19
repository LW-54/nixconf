{
  config,
  lib,
  ...
}: let
  internalCaddy = config.internal.caddy;
in {
  options.internal.caddy = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Internal helper builders for the Caddy reverse proxy implementation.";
  };

  /**
  Automated TLS virtual host reverse proxy implementation using Caddy.
  */
  config.implementation.caddy = {
    contract = "reverse-proxy";
    description = "Automated TLS virtual host reverse proxy implementation using Caddy.";
    module = {
      config,
      lib,
      self,
      ...
    }: let
      cfg = config.reverse-proxy;
      adminPort = 2019;
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
        globalConfig = ''
          admin 127.0.0.1:${toString adminPort}
          metrics {
            per_host
          }
        '';
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

      reverse-proxy.ports = [
        {
          owner = "caddy-admin";
          address = "127.0.0.1";
          port = adminPort;
          protocol = "tcp";
        }
      ];

      networking.firewall.allowedTCPPorts = [80 443];

      persistence.directories = lib.mkIf (config.persistence.enable or false) [
        "/var/lib/caddy"
      ];

      monitoring = lib.mkIf (config.monitoring.enable or false) {
        watchedUnits = ["caddy.service"];
        logs.journal.units = ["caddy.service"];
        scrapes.caddy = {
          address = "127.0.0.1";
          port = adminPort;
          metricsPath = "/metrics";
        };
        rules.caddy = {
          backend = "prometheus";
          interval = "1m";
          rules = [
            {
              alert = "EndpointProbeFailed";
              expr = "probe_success == 0";
              "for" = "3m";
              labels.severity = "critical";
              annotations = {
                summary = "Health probe failed for {{ $labels.vhost }} ({{ $labels.host }})";
                description = "Blackbox probe {{ $labels.vhost }} from {{ $labels.host }} has been failing for 3 minutes.";
              };
            }
            {
              alert = "CaddyHttp5xxSpike";
              expr = ''sum by (host) (rate(caddy_http_request_duration_seconds_count{code=~"5.."}[5m])) > 0.1'';
              "for" = "5m";
              labels.severity = "warning";
              annotations = {
                summary = "Elevated 5xx responses on {{ $labels.host }}";
                description = "Caddy is returning more than 0.1 5xx responses/sec for {{ $labels.host }}.";
              };
            }
          ];
        };
        dashboards.ingress = {
          title = "Ingress & Service Probes";
          folder = "Services";
          json = internalCaddy.mkDashboard self.lib.monitoring.dashboard;
        };
      };
    };
  };
}
