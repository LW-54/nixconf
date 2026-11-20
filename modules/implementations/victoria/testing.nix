{
  internal.victoria.mkTesting = {
    self,
    config,
    lib,
    pkgs,
  }: let
    cfg = config.monitoring;
    connectAddr = addr:
      if addr == "0.0.0.0" || addr == "::" || addr == "*"
      then "127.0.0.1"
      else addr;

    hasDestination =
      cfg.server.enable
      || cfg.agent.metricsUrl != null
      || cfg.agent.logsUrl != null;

    registeredPorts = map (p: p.port) (config.reverse-proxy.ports or []);
    vmalertInstances = lib.filterAttrs (_: inst: inst.enable) (config.services.vmalert.instances or {});
    enabledDashboards = lib.filterAttrs (_: d: d.enable) cfg.dashboards;
    dashboardsPath =
      if cfg.server.enable && enabledDashboards != {}
      then (builtins.head config.services.grafana.provision.dashboards.settings.providers).options.path
      else null;
    domain = config.reverse-proxy.domain or null;
    bearerAuthActive = cfg.server.enable && (config.reverse-proxy.enable or false) && domain != null;
    bearerVar = hostName:
      "NIXCONF_BEARER_"
      + lib.toUpper (builtins.replaceStrings ["." "-" ":" "/"] ["_" "_" "_" "_"] hostName);
    vmFqdn = "${cfg.server.metrics.subdomain}.${domain}";
    vlFqdn = "${cfg.server.logs.subdomain}.${domain}";
    yamlFormat = pkgs.formats.yaml {};
  in {
    description = "Grafana Alloy, VictoriaMetrics, VictoriaLogs, vmalert, Alertmanager, and Grafana provisioning, validation, and runtime checks";

    evalChecks = {
      agent-has-destination = {
        assertion = !cfg.agent.enable || hasDestination;
        message = "`monitoring.agent.enable` is true, but neither `monitoring.server.enable` nor `monitoring.agent.metricsUrl`/`logsUrl` is configured.";
      };

      agent-single-auth-method = {
        assertion = !(cfg.agent.bearerTokenFile != null && cfg.agent.basicAuth.enable);
        message = "`monitoring.agent.bearerTokenFile` and `monitoring.agent.basicAuth.enable` are mutually exclusive; pick one telemetry push authentication mechanism.";
      };

      server-ports-registered = {
        assertion =
          !cfg.server.enable
          || (
            builtins.elem cfg.server.grafana.port registeredPorts
            && builtins.elem cfg.server.metrics.port registeredPorts
            && builtins.elem cfg.server.logs.port registeredPorts
            && builtins.elem cfg.server.alerts.port registeredPorts
          );
        message = "When `monitoring.server.enable` is true, Grafana, VictoriaMetrics, VictoriaLogs, and Alertmanager ports must be registered in `reverse-proxy.ports`.";
      };
    };

    inspectChecks = {
      alloy-config = {
        enable = cfg.agent.enable;
        description = "Verify /etc/alloy/config.alloy exists and validates with alloy validate";
        priority = 150;
        script = ''
          cfg_link="$etc/alloy/config.alloy"
          if [ ! -e "$cfg_link" ]; then
            echo "Error: $cfg_link does not exist!" >&2
            exit 1
          fi
          cfg_target="$(readlink -f "$cfg_link")"
          ${pkgs.grafana-alloy}/bin/alloy fmt "$cfg_target" >/dev/null
          ${pkgs.grafana-alloy}/bin/alloy validate "$cfg_target"
        '';
      };

      vmalert-rules = {
        enable = cfg.server.enable && vmalertInstances != {};
        description = "Verify generated vmalert metrics and LogsQL rule files pass vmalert -dryRun";
        priority = 155;
        script = lib.concatStrings (
          lib.mapAttrsToList (name: inst: let
            ruleFile = yamlFormat.generate "vmalert-${name}-rules.yml" inst.rules;
            dsUrl = builtins.head (lib.toList inst.settings."datasource.url");
          in ''
            ${pkgs.victoriametrics}/bin/vmalert -rule=${lib.escapeShellArg (toString ruleFile)} -dryRun -datasource.url=${lib.escapeShellArg dsUrl} -notifier.blackhole >/dev/null
          '')
          vmalertInstances
        );
      };

      grafana-provisioning = {
        enable = cfg.server.enable;
        description = "Verify Grafana provisioning datasources and dashboards exist in provisioning tree";
        priority = 160;
        script = ''
          prov_dir="${config.services.grafana.settings.paths.provisioning}"
          test -d "$prov_dir/datasources" || {
            echo "Missing Grafana datasources provisioning dir: $prov_dir/datasources" >&2
            exit 1
          }
          test -s "$prov_dir/datasources/datasource.yaml" || {
            echo "Missing Grafana datasource.yaml" >&2
            exit 1
          }
          ${lib.optionalString (enabledDashboards != {} && dashboardsPath != null) ''
            test -d "$prov_dir/dashboards" && test -s "$prov_dir/dashboards/dashboard.yaml" || {
              echo "Missing Grafana dashboards provisioning config" >&2
              exit 1
            }
            dash_files="$(find ${lib.escapeShellArg (toString dashboardsPath)} -type f -name '*.json' | sort)"
            test -n "$dash_files" || {
              echo "No dashboard JSON files found under ${toString dashboardsPath}" >&2
              exit 1
            }
            uids_file="$(mktemp)"
            trap 'rm -f "$uids_file"' EXIT
            count=0
            while IFS= read -r df; do
              ${pkgs.jq}/bin/jq -e '
                def is_int: (type == "number") and (floor == .) and (. >= 0);
                def all_panels: [.panels[] | ., (.panels[]? // empty)];
                (.uid | type == "string" and length > 0)
                and (.title | type == "string" and length > 0)
                and (.schemaVersion == 39)
                and (.panels | type == "array" and length > 0)
                and (all_panels | all(
                  (.id | is_int and . >= 1)
                  and (.gridPos | type == "object")
                  and (.gridPos.h | is_int and . >= 1)
                  and (.gridPos.w | is_int and . >= 1 and . <= 24)
                  and (.gridPos.x | is_int and . >= 0)
                  and (.gridPos.y | is_int and . >= 0)
                  and ((.gridPos.x + .gridPos.w) <= 24)
                ))
                and ((all_panels | map(.id)) as $ids | ($ids | length) == ($ids | unique | length))
                and (((.templating.list // []) | all((.current | type) == "object")))
              ' "$df" >/dev/null || {
                echo "Dashboard JSON schema check failed for: $df" >&2
                exit 1
              }
              ${pkgs.jq}/bin/jq -r '.uid' "$df" >> "$uids_file"
              count=$((count + 1))
            done <<< "$dash_files"
            total_uids="$(wc -l < "$uids_file")"
            unique_uids="$(sort -u "$uids_file" | wc -l)"
            if [ "$total_uids" -ne "$unique_uids" ]; then
              echo "Duplicate dashboard UIDs detected across provisioned dashboards!" >&2
              sort "$uids_file" | uniq -d >&2
              exit 1
            fi
            echo "Validated $count provisioned Grafana dashboard(s) with unique UIDs."
          ''}
        '';
      };

      caddy-bearer-config = {
        enable = bearerAuthActive;
        description = "Verify Caddyfile configures @bearer routes with NIXCONF_BEARER_ env vars for telemetry ingest endpoints";
        priority = 165;
        script = ''
          ${self.lib.testing.mkInspectFile {
            path = "$etc/caddy/caddy_config";
            pattern = "@bearer";
          }}
          ${self.lib.testing.mkInspectFile {
            path = "$etc/caddy/caddy_config";
            pattern = "NIXCONF_BEARER_";
          }}
        '';
      };
    };

    vmChecks = {
      agent = {
        enable = cfg.agent.enable;
        description = "alloy.service is active and serves healthy status on its HTTP endpoint";
        script = ''
          ${self.lib.testing.mkServiceCheck {unit = "alloy.service";}}
          ${self.lib.testing.mkHttpCheck {
            port = cfg.agent.port;
            host = connectAddr cfg.agent.address;
            path = "/-/healthy";
          }}
        '';
      };

      server = {
        enable = cfg.server.enable;
        description = "VictoriaMetrics, VictoriaLogs, vmalert, Alertmanager, and Grafana start cleanly, answer health checks, and accept Authelia proxy headers";
        script = ''
          ${self.lib.testing.mkServiceCheck {unit = "victoriametrics.service";}}
          ${self.lib.testing.mkServiceCheck {unit = "victorialogs.service";}}
          ${self.lib.testing.mkServiceCheck {unit = "alertmanager.service";}}
          ${self.lib.testing.mkServiceCheck {unit = "grafana.service";}}
          ${lib.concatStrings (map (n: self.lib.testing.mkServiceCheck {unit = "vmalert-${n}.service";}) (builtins.attrNames vmalertInstances))}

          ${self.lib.testing.mkHttpCheck {
            port = cfg.server.metrics.port;
            host = connectAddr cfg.server.metrics.address;
            path = "/health";
          }}
          ${self.lib.testing.mkHttpCheck {
            port = cfg.server.logs.port;
            host = connectAddr cfg.server.logs.address;
            path = "/health";
          }}
          ${self.lib.testing.mkHttpCheck {
            port = cfg.server.alerts.port;
            host = connectAddr cfg.server.alerts.address;
            path = "/-/healthy";
          }}
          ${self.lib.testing.mkHttpCheck {
            port = cfg.server.grafana.port;
            host = connectAddr cfg.server.grafana.address;
            path = "/api/health";
          }}

          _grafana_user = machine.succeed(
              "curl -fsS -H 'Remote-User: admin' -H 'Remote-Groups: lldap_admin' "
              "http://${connectAddr cfg.server.grafana.address}:${toString cfg.server.grafana.port}/api/user"
          )
          assert '"login":"admin"' in _grafana_user, f"Expected Grafana auth.proxy login for admin, got: {_grafana_user}"

          _grafana_prom = machine.succeed(
              "curl -fsS -H 'Remote-User: admin' -H 'Remote-Groups: lldap_admin' "
              "-H 'Content-Type: application/json' "
              "-d '{\"queries\":[{\"refId\":\"A\",\"datasource\":{\"type\":\"prometheus\",\"uid\":\"prometheus\"},\"expr\":\"vector(1)\",\"instant\":true}],\"from\":\"now-5m\",\"to\":\"now\"}' "
              "http://${connectAddr cfg.server.grafana.address}:${toString cfg.server.grafana.port}/api/ds/query"
          )
          assert '"status":200' in _grafana_prom, f"Expected Grafana VictoriaMetrics datasource query to succeed, got: {_grafana_prom}"

          _grafana_vlogs = machine.succeed(
              "curl -fsS -H 'Remote-User: admin' -H 'Remote-Groups: lldap_admin' "
              "-H 'Content-Type: application/json' "
              "-d '{\"queries\":[{\"refId\":\"A\",\"datasource\":{\"type\":\"victoriametrics-logs-datasource\",\"uid\":\"victorialogs\"},\"expr\":\"* | stats count() as n\",\"queryType\":\"stats\"}],\"from\":\"now-5m\",\"to\":\"now\"}' "
              "http://${connectAddr cfg.server.grafana.address}:${toString cfg.server.grafana.port}/api/ds/query"
          )
          assert '"status":200' in _grafana_vlogs, f"Expected Grafana VictoriaLogs datasource query to succeed, got: {_grafana_vlogs}"
          ${lib.optionalString bearerAuthActive ''
            ${self.lib.testing.mkServiceCheck {unit = "caddy-bearer-env.service";}}
            _bearer_mode = machine.succeed("stat -c '%a' /run/caddy-bearer/tokens.env").strip()
            assert _bearer_mode == "600", f"Expected /run/caddy-bearer/tokens.env mode 600, got {_bearer_mode}"
            machine.succeed("grep -q '^${bearerVar vmFqdn}=' /run/caddy-bearer/tokens.env")
            machine.succeed("grep -q '^${bearerVar vlFqdn}=' /run/caddy-bearer/tokens.env")
          ''}
        '';
      };
    };
  };
}
