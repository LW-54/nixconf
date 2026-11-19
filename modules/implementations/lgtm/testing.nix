{
  internal.lgtm.mkTesting = {
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
    promRuleFiles = config.services.prometheus.ruleFiles or [];
    enabledDashboards = lib.filterAttrs (_: d: d.enable) cfg.dashboards;
    dashboardsPath =
      if cfg.server.enable && enabledDashboards != {}
      then (builtins.head config.services.grafana.provision.dashboards.settings.providers).options.path
      else null;
  in {
    description = "Grafana Alloy, Prometheus, Loki, and Grafana provisioning, validation, and runtime checks";

    evalChecks = {
      agent-has-destination = {
        assertion = !cfg.agent.enable || hasDestination;
        message = "`monitoring.agent.enable` is true, but neither `monitoring.server.enable` nor `monitoring.agent.metricsUrl`/`logsUrl` is configured.";
      };

      server-ports-registered = {
        assertion =
          !cfg.server.enable
          || (
            builtins.elem cfg.server.grafana.port registeredPorts
            && builtins.elem cfg.server.prometheus.port registeredPorts
            && builtins.elem cfg.server.loki.port registeredPorts
            && builtins.elem cfg.server.loki.grpcPort registeredPorts
          );
        message = "When `monitoring.server.enable` is true, Grafana, Prometheus, and Loki ports must be registered in `reverse-proxy.ports`.";
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

      prometheus-rules = {
        enable = cfg.server.enable && promRuleFiles != [];
        description = "Verify generated Prometheus rule files pass promtool check rules";
        priority = 155;
        script =
          lib.concatMapStringsSep "\n" (rf: ''
            ${pkgs.prometheus.cli}/bin/promtool check rules ${lib.escapeShellArg (toString rf)}
          '')
          promRuleFiles;
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
        description = "Prometheus, Loki, and Grafana start cleanly, answer health checks, and accept Authelia proxy headers";
        script = ''
          import datetime

          ${self.lib.testing.mkServiceCheck {unit = "prometheus.service";}}
          ${self.lib.testing.mkServiceCheck {unit = "loki.service";}}
          ${self.lib.testing.mkServiceCheck {unit = "grafana.service";}}

          ${self.lib.testing.mkHttpCheck {
            port = cfg.server.prometheus.port;
            host = connectAddr cfg.server.prometheus.address;
            path = "/-/healthy";
          }}
          ${self.lib.testing.mkHttpCheck {
            port = cfg.server.grafana.port;
            host = connectAddr cfg.server.grafana.address;
            path = "/api/health";
          }}

          machine.wait_for_open_port(${toString cfg.server.loki.port})
          machine.wait_until_succeeds(
              "curl -fsS http://${connectAddr cfg.server.loki.address}:${toString cfg.server.loki.port}/ready",
              timeout=datetime.timedelta(seconds=30),
          )

          _grafana_user = machine.succeed(
              "curl -fsS -H 'Remote-User: admin' -H 'Remote-Groups: lldap_admin' "
              "http://${connectAddr cfg.server.grafana.address}:${toString cfg.server.grafana.port}/api/user"
          )
          assert '"login":"admin"' in _grafana_user, f"Expected Grafana auth.proxy login for admin, got: {_grafana_user}"
        '';
      };
    };
  };
}
