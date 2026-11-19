{
  config,
  lib,
  ...
}: let
  types = config.contract.monitoring.types;
in {
  contract.monitoring = {
    description = "Declarative metrics, logs, blackbox probing, alerting rules, and dashboard provisioning contract.";

    options = {
      enable = lib.mkEnableOption "declarative system and service monitoring contract";

      agent = lib.mkOption {
        type = types.agent;
        default = {};
        example = {
          enable = true;
          metricsUrl = "https://prometheus.adje.app/api/v1/write";
          logsUrl = "https://loki.adje.app/loki/api/v1/push";
        };
        description = "Local telemetry collector agent configuration for metrics scraping, log shipping, and remote-write buffering.";
      };

      server = lib.mkOption {
        type = types.server;
        default = {};
        example = {
          enable = true;
          retentionDays = 30;
        };
        description = "Central telemetry ingestion, time-series storage, and visualization server configuration.";
      };

      scrapes = lib.mkOption {
        type = lib.types.attrsOf types.scrape;
        default = {};
        example = {
          caddy = {
            port = 2019;
            metricsPath = "/metrics";
          };
        };
        description = "Attribute set of Prometheus scrape targets collected by the local telemetry agent.";
      };

      exporters = lib.mkOption {
        type = types.exporters;
        default = {};
        example = {
          unix = {
            enable = true;
            collectors = ["cpu" "meminfo" "filesystem"];
          };
        };
        description = "Built-in telemetry exporter configurations (host OS, containers, blackbox probing, and custom blocks).";
      };

      logs = lib.mkOption {
        type = types.logs;
        default = {};
        example = {
          journal.enable = true;
        };
        description = "Declarative systemd journal and file-based log ingestion sources.";
      };

      probes = lib.mkOption {
        type = lib.types.attrsOf types.probe;
        default = {};
        example = {
          "vaultwarden.adje.app" = {
            target = "http://127.0.0.1:23469";
            module = "http_2xx";
          };
        };
        description = "Attribute set of blackbox health probes checking HTTP, TCP, or ICMP endpoint reachability.";
      };

      watchedUnits = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["caddy.service" "vaultwarden.service"];
        description = "Critical systemd units (services, timers, or mounts) registered for health monitoring and journal tracking.";
      };

      rules = lib.mkOption {
        type = lib.types.attrsOf types.ruleGroup;
        default = {};
        example = {
          host = {
            backend = "prometheus";
            rules = [
              {
                alert = "SystemdUnitFailed";
                expr = ''node_systemd_unit_state{state="failed"} == 1'';
              }
            ];
          };
        };
        description = "Attribute set of alerting and recording rule groups evaluated by Prometheus or Loki.";
      };

      dashboards = lib.mkOption {
        type = lib.types.attrsOf types.dashboard;
        default = {};
        example = {
          host-overview = {
            title = "Host Overview";
            folder = "Infrastructure";
            json = {
              title = "Host Overview";
              schemaVersion = 39;
              panels = [];
            };
          };
        };
        description = "Attribute set of declarative Grafana dashboards provisioned automatically as code.";
      };

      extraAlloyConfig = lib.mkOption {
        type = lib.types.lines;
        default = "";
        example = ''
          logging {
            level = "info"
          }
        '';
        description = "Raw Grafana Alloy River configuration blocks appended directly to `/etc/alloy/config.alloy`.";
      };

      extraPrometheusConfig = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        example = {
          globalConfig.evaluation_interval = "30s";
        };
        description = "Additional backend-specific attributes merged into the Prometheus server configuration.";
      };

      extraLokiConfig = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        example = {
          limits_config.ingestion_rate_mb = 8;
        };
        description = "Additional backend-specific attributes merged into `services.loki.configuration`.";
      };

      extraGrafanaSettings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        example = {
          users.default_theme = "dark";
        };
        description = "Additional backend-specific attributes merged into `services.grafana.settings`.";
      };
    };

    mkOption = {
      enable ? true,
      units ? [],
      metrics ? null,
      probe ? null,
      logFiles ? {},
      rules ? {},
      dashboards ? {},
    }: let
      m =
        if metrics == null
        then {}
        else metrics;
      p =
        if probe == null
        then {}
        else probe;
    in {
      monitoring = {
        enable =
          lib.mkEnableOption "telemetry collection and health registration for this service"
          // {default = enable;};

        units = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = units;
          description = "Systemd units belonging to this service registered in `monitoring.watchedUnits` and journal tracking.";
        };

        metrics = {
          enable =
            lib.mkEnableOption "Prometheus metrics scraping for this service"
            // {default = metrics != null && (m.enable or true);};

          address = lib.mkOption {
            type = lib.types.str;
            default = m.address or "127.0.0.1";
            description = "Bind address where this service exposes its Prometheus metrics endpoint.";
          };

          port = lib.mkOption {
            type = lib.types.nullOr lib.types.port;
            default = m.port or null;
            description = "TCP port where this service exposes its Prometheus metrics endpoint.";
          };

          path = lib.mkOption {
            type = lib.types.str;
            default = m.path or "/metrics";
            description = "HTTP path serving Prometheus metrics for this service.";
          };
        };

        probe = {
          enable =
            lib.mkEnableOption "blackbox health probing for this service"
            // {default = probe != null && (p.enable or true);};

          target = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = p.target or null;
            description = "Target URL or `host:port` endpoint checked by the blackbox prober.";
          };

          module = lib.mkOption {
            type = lib.types.enum ["http_2xx" "tcp_connect" "icmp"];
            default = p.module or "http_2xx";
            description = "Blackbox probe profile applied to this service endpoint.";
          };
        };

        logFiles = lib.mkOption {
          type = lib.types.attrsOf types.fileLog;
          default = logFiles;
          description = "File-based log sources associated with this service.";
        };

        rules = lib.mkOption {
          type = lib.types.attrsOf types.ruleGroup;
          default = rules;
          description = "Alerting and recording rule groups associated with this service.";
        };

        dashboards = lib.mkOption {
          type = lib.types.attrsOf types.dashboard;
          default = dashboards;
          description = "Grafana dashboards associated with this service.";
        };
      };
    };

    mkConfig = {
      config,
      cfg,
      name ? null,
    }: let
      mon = cfg.monitoring or {};
      enabled = (config.monitoring.enable or false) && (cfg.enable or true) && (mon.enable or false);
      serviceName =
        if name != null
        then name
        else if (cfg.subdomain or null) != null && cfg.subdomain != ""
        then cfg.subdomain
        else "service";
      metricsCfg = mon.metrics or {};
      probeCfg = mon.probe or {};
      units = mon.units or [];
    in
      lib.mkIf enabled {
        monitoring = {
          watchedUnits = units;
          logs = {
            journal.units = units;
            files = mon.logFiles or {};
          };
          scrapes = lib.mkIf ((metricsCfg.enable or false) && (metricsCfg.port or null) != null) {
            ${serviceName} = {
              inherit (metricsCfg) address port;
              metricsPath = metricsCfg.path or "/metrics";
            };
          };
          probes = lib.mkIf ((probeCfg.enable or false) && (probeCfg.target or null) != null) {
            ${serviceName} = {
              inherit (probeCfg) target module;
            };
          };
          rules = mon.rules or {};
          dashboards = mon.dashboards or {};
        };
      };
  };
}
