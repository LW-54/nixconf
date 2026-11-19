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
          ${lib.optionalString (enabledDashboards != {}) ''
            test -d "$prov_dir/dashboards" && test -s "$prov_dir/dashboards/dashboard.yaml" || {
              echo "Missing Grafana dashboards provisioning config" >&2
              exit 1
            }
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
