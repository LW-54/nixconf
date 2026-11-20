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
      pkgs,
      self,
      ...
    }: let
      cfg = config.reverse-proxy;
      adminPort = 2019;
      conflicts = self.lib.reverse-proxy.findPortConflicts cfg.ports;
      formatConflict = c: "${c.protocol}/${toString c.port} claimed by ${lib.concatStringsSep ", " c.owners}";

      envVarForHost = hostName:
        "NIXCONF_BEARER_"
        + lib.toUpper (builtins.replaceStrings ["." "-" ":" "/"] ["_" "_" "_" "_"] hostName);
      bearerHosts = lib.filterAttrs (_: h: h.bearerAuth.enable) cfg.hosts;
      hasBearerHosts = bearerHosts != {};
      invalidBearerHosts = lib.filterAttrs (_: h: h.bearerAuth.paths == [] || h.bearerAuth.tokenFile == null) bearerHosts;

      bearerEnvLines = lib.concatStrings (lib.mapAttrsToList (
          hostName: hostCfg: let
            varName = envVarForHost hostName;
            tokPath = hostCfg.bearerAuth.tokenFile;
          in ''
            tok="$(${pkgs.coreutils}/bin/tr -d '\r\n' < ${lib.escapeShellArg tokPath})"
            if [ -z "$tok" ]; then
              echo "Missing or empty bearer token at ${tokPath}" >&2
              exit 1
            fi
            printf '%s=%s\n' ${lib.escapeShellArg varName} "$tok" >> "$tmp_env"
          ''
        )
        bearerHosts);

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
        {
          assertion = invalidBearerHosts == {};
          message = "Reverse proxy hosts with `bearerAuth.enable = true` must declare non-empty `paths` and `tokenFile`: ${lib.concatStringsSep ", " (builtins.attrNames invalidBearerHosts)}.";
        }
      ];

      services.caddy = {
        enable = true;
        environmentFile = lib.mkIf hasBearerHosts "/run/caddy-bearer/tokens.env";
        globalConfig = ''
          admin 127.0.0.1:${toString adminPort}
          metrics {
            per_host
          }
        '';
        virtualHosts =
          lib.mapAttrs (hostName: hostCfg: let
            useForwardAuth = cfg.forwardAuth.enable && hostCfg.forwardAuth && cfg.forwardAuth.upstream != null;
            innerBlock = lib.concatStringsSep "\n" (
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
              ]
            );
            stripHeaders = lib.concatMapStringsSep "\n" (h: "request_header -${h}") (
              lib.unique (["Authorization"] ++ cfg.forwardAuth.copyHeaders)
            );
            bearerPlaceholder = "{$" + envVarForHost hostName + "}";
            bearerBlock = ''
              @bearer path ${lib.concatStringsSep " " hostCfg.bearerAuth.paths}
              handle @bearer {
                @bearer_ok header Authorization "Bearer ${bearerPlaceholder}"
                handle @bearer_ok {
                  ${stripHeaders}
                  reverse_proxy ${hostCfg.upstream}
                }
                respond "Unauthorized" 401
              }
              handle {
                ${innerBlock}
              }
            '';
          in {
            extraConfig = lib.concatStringsSep "\n" (
              lib.filter (s: s != "") [
                (
                  if hostCfg.bearerAuth.enable
                  then bearerBlock
                  else innerBlock
                )
                hostCfg.extraConfig
              ]
            );
          })
          cfg.hosts;
      };

      systemd.services = lib.mkIf hasBearerHosts {
        caddy-bearer-env = {
          description = "Render Caddy Bearer authentication environment file from runtime secrets";
          after = ["sops-install-secrets.service"];
          wants = ["sops-install-secrets.service"];
          before = ["caddy.service"];
          partOf = ["caddy.service"];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            RuntimeDirectory = "caddy-bearer";
            RuntimeDirectoryMode = "0700";
          };
          script = ''
            umask 077
            ${pkgs.coreutils}/bin/install -d -m 0700 /run/caddy-bearer
            tmp_env="$(${pkgs.coreutils}/bin/mktemp /run/caddy-bearer/.tokens.XXXXXX)"
            : > "$tmp_env"
            ${bearerEnvLines}
            ${pkgs.coreutils}/bin/chmod 0600 "$tmp_env"
            ${pkgs.coreutils}/bin/mv -f "$tmp_env" /run/caddy-bearer/tokens.env
          '';
        };

        caddy = {
          requires = ["caddy-bearer-env.service"];
          after = ["caddy-bearer-env.service"];
        };
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
        services.caddy.units = ["caddy.service"];
        scrapes.caddy = {
          address = "127.0.0.1";
          port = adminPort;
          metricsPath = "/metrics";
        };
        rules.caddy = {
          backend = "metrics";
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
          title = "Ingress & Edge";
          folder = "02 · Infrastructure";
          json = internalCaddy.mkDashboard self.lib.monitoring.dashboard;
        };
      };

      resources.units = lib.mkIf (config.resources.enable or false) {
        "caddy.service" = {
          tier = lib.mkDefault "critical";
          memory = {
            min = lib.mkDefault "32M";
            low = lib.mkDefault "64M";
          };
        };
      };
    };
  };
}
