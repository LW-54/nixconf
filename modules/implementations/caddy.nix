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
      adminPort = self.lib.reverse-proxy.mkPort "caddy-admin";
      conflicts = self.lib.reverse-proxy.findPortConflicts cfg.ports;

      promTarget = refId: expr: legendFormat: {
        inherit expr legendFormat refId;
        datasource = {
          type = "prometheus";
          uid = "prometheus";
        };
      };

      ingressDashboard = {
        uid = "nixconf-ingress";
        title = "Ingress & Service Probes";
        tags = ["nixconf" "caddy" "blackbox"];
        timezone = "browser";
        schemaVersion = 39;
        refresh = "30s";
        time = {
          from = "now-3h";
          to = "now";
        };
        panels = [
          {
            id = 1;
            title = "Endpoint Probe Status (1 = Up)";
            type = "stat";
            gridPos = {
              h = 6;
              w = 12;
              x = 0;
              y = 0;
            };
            targets = [
              (promTarget "A" ''probe_success'' "{{vhost}} ({{instance}})")
            ];
          }
          {
            id = 2;
            title = "Endpoint Probe Duration (s)";
            type = "timeseries";
            gridPos = {
              h = 6;
              w = 12;
              x = 12;
              y = 0;
            };
            fieldConfig.defaults.unit = "s";
            targets = [
              (promTarget "A" ''probe_duration_seconds'' "{{vhost}} ({{instance}})")
            ];
          }
          {
            id = 3;
            title = "Caddy Request Rate by Host";
            type = "timeseries";
            gridPos = {
              h = 8;
              w = 12;
              x = 0;
              y = 6;
            };
            fieldConfig.defaults.unit = "reqps";
            targets = [
              (promTarget "A" ''sum by (host) (rate(caddy_http_requests_total[5m]))'' "{{host}}")
            ];
          }
          {
            id = 4;
            title = "Caddy HTTP Responses by Status Code";
            type = "timeseries";
            gridPos = {
              h = 8;
              w = 12;
              x = 12;
              y = 6;
            };
            fieldConfig.defaults.unit = "reqps";
            targets = [
              (promTarget "A" ''sum by (code) (rate(caddy_http_responses_total[5m]))'' "{{code}}")
            ];
          }
        ];
      };
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
                summary = "Health probe failed for {{ $labels.instance }}";
                description = "Blackbox probe {{ $labels.instance }} has been failing for 3 minutes.";
              };
            }
            {
              alert = "CaddyHttp5xxSpike";
              expr = ''sum by (host) (rate(caddy_http_responses_total{code=~"5.."}[5m])) > 0.1'';
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
          json = ingressDashboard;
        };
      };
    };
  };
}
