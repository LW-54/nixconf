{
  config,
  lib,
  ...
}: let
  mkPort = config.contract.reverse-proxy.lib.mkPort.value;

  basicAuthSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "HTTP Basic Authentication for remote telemetry push endpoints";

      username = lib.mkOption {
        type = lib.types.str;
        default = "admin";
        description = "Username sent in HTTP Basic Authentication headers.";
      };

      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "/run/secrets/lldap-admin-password";
        description = "Filesystem path containing the password sent in HTTP Basic Authentication headers.";
      };
    };
  };

  agentSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "local telemetry collection agent on this host" // {default = true;};

      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Local bind address for the telemetry agent HTTP server.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = mkPort "alloy";
        description = "Local TCP port for the telemetry agent HTTP server.";
      };

      scrapeInterval = lib.mkOption {
        type = lib.types.str;
        default = "10s";
        description = "Default metrics scrape interval used by the telemetry agent.";
      };

      metricsUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "https://vm.adje.app/api/v1/write";
        description = "Remote metrics write endpoint URL (`null` defaults to local server when `monitoring.server.enable` is true).";
      };

      logsUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "https://vlogs.adje.app/insert/loki/api/v1/push";
        description = "Remote log push endpoint URL (`null` defaults to local server when `monitoring.server.enable` is true).";
      };

      basicAuth = lib.mkOption {
        type = basicAuthSubmodule;
        default = {};
        description = "HTTP Basic Authentication configuration used when pushing telemetry to remote endpoints.";
      };

      extraLabels = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        example = {role = "workstation";};
        description = "Additional static labels attached to all metrics and logs emitted by this host.";
      };
    };
  };

  mkEndpointSubmodule = {
    defaultSubdomain,
    portSeed,
    serviceDesc,
    extraOptions ? {},
  }:
    lib.types.submodule {
      options =
        {
          subdomain = lib.mkOption {
            type = lib.types.str;
            default = defaultSubdomain;
            description = "Subdomain prefix under `reverse-proxy.domain` exposing ${serviceDesc}.";
          };

          address = lib.mkOption {
            type = lib.types.str;
            default = "127.0.0.1";
            description = "Local bind address for ${serviceDesc}.";
          };

          port = lib.mkOption {
            type = lib.types.port;
            default = mkPort portSeed;
            description = "Local TCP HTTP port for ${serviceDesc}.";
          };
        }
        // extraOptions;
    };

  ntfyNotificationSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "Alertmanager webhook notifications to ntfy";

      url = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "http://127.0.0.1:2586/alerts?template=alertmanager";
        description = "Webhook endpoint URL on the target ntfy server (`?template=alertmanager`).";
      };

      username = lib.mkOption {
        type = lib.types.str;
        default = "admin";
        description = "Username sent via HTTP Basic Authentication to ntfy.";
      };

      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "/run/secrets/ntfy-admin-password";
        description = "Filesystem path containing the password for Alertmanager webhook authentication to ntfy.";
      };
    };
  };

  retentionSubmodule = lib.types.submodule {
    options = {
      metrics = lib.mkOption {
        type = lib.types.str;
        default = "100y";
        description = "Retention period duration for metrics time-series storage (e.g., `100y` for effectively unlimited historical metrics).";
      };

      logs = lib.mkOption {
        type = lib.types.str;
        default = "100y";
        description = "Retention period duration for logs storage (paired with `logsMaxDiskPercent` for capacity-bounded cleanup).";
      };

      logsMaxDiskPercent = lib.mkOption {
        type = lib.types.ints.between 1 99;
        default = 85;
        description = "Maximum allowed filesystem usage percentage (`1..99`) before the logs store automatically drops oldest daily partitions.";
      };
    };
  };

  serverSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "central monitoring server stack (metrics store, log store, rule evaluator, Alertmanager, and Grafana)";

      retention = lib.mkOption {
        type = retentionSubmodule;
        default = {};
        description = "Time- and capacity-based retention policies for metrics and log storage.";
      };

      metrics = lib.mkOption {
        type = mkEndpointSubmodule {
          defaultSubdomain = "vm";
          portSeed = "victoriametrics";
          serviceDesc = "metrics time-series store and remote-write receiver";
        };
        default = {};
        description = "Metrics time-series storage listener and reverse proxy configuration.";
      };

      logs = lib.mkOption {
        type = mkEndpointSubmodule {
          defaultSubdomain = "vlogs";
          portSeed = "victorialogs";
          serviceDesc = "log storage and query server";
        };
        default = {};
        description = "Log storage listener and reverse proxy configuration.";
      };

      alerts = lib.mkOption {
        type = mkEndpointSubmodule {
          defaultSubdomain = "alerts";
          portSeed = "alertmanager";
          serviceDesc = "Alertmanager routing and silencing UI";
          extraOptions = {
            ntfy = lib.mkOption {
              type = ntfyNotificationSubmodule;
              default = {};
              description = "Self-hosted or external ntfy webhook notification target for firing alerts.";
            };
          };
        };
        default = {};
        description = "Alertmanager HTTP listener, reverse proxy, and notification routing configuration.";
      };

      grafana = lib.mkOption {
        type = mkEndpointSubmodule {
          defaultSubdomain = "grafana";
          portSeed = "grafana";
          serviceDesc = "Grafana web UI";
        };
        default = {};
        description = "Grafana web visualization listener and reverse proxy configuration.";
      };
    };
  };

  scrapeSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this metrics scrape job is active.";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Target host or IP address exposing the metrics endpoint.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        example = 9090;
        description = "Target TCP port exposing the metrics endpoint.";
      };

      metricsPath = lib.mkOption {
        type = lib.types.str;
        default = "/metrics";
        description = "HTTP URI path serving Prometheus-formatted metrics.";
      };

      scheme = lib.mkOption {
        type = lib.types.enum ["http" "https"];
        default = "http";
        description = "URL scheme used when scraping this metrics target.";
      };

      interval = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "30s";
        description = "Optional per-target scrape interval overriding the agent default.";
      };

      labels = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Static labels attached to every metric scraped from this target.";
      };
    };
  };

  exportersSubmodule = lib.types.submodule {
    options = {
      unix = {
        enable = lib.mkEnableOption "host OS metrics exporter";

        collectors = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "List of additional collectors enabled on the host OS exporter.";
        };

        setCollectors = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Explicit replacement list of collectors enabled on the host OS exporter.";
        };

        textfileDirectory = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "/var/lib/alloy/textfile";
          description = "Optional directory of Prometheus `.prom` textfiles scraped by the host OS exporter `textfile` collector.";
        };
      };

      cadvisor = {
        enable = lib.mkEnableOption "container and cgroup resource metrics exporter";

        dockerOnly = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to restrict container metrics collection to Docker containers.";
        };
      };

      process = {
        enable = lib.mkEnableOption "process-level resource metrics exporter (Task Manager)";
      };

      blackbox = {
        enable = lib.mkEnableOption "blackbox endpoint probing exporter";
      };

      extraBlocks = lib.mkOption {
        type = lib.types.attrsOf lib.types.lines;
        default = {};
        description = "Named raw exporter configuration blocks passed through to the telemetry collector.";
      };
    };
  };

  journalLogsSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "systemd journal log shipping";

      maxAge = lib.mkOption {
        type = lib.types.str;
        default = "12h";
        description = "Maximum age of historical journal entries read on agent startup.";
      };

      units = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Systemd unit names tracked and tagged by the journal log collector.";
      };

      labels = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Additional static labels attached to shipped journal log entries.";
      };

      stages = lib.mkOption {
        type = lib.types.listOf lib.types.lines;
        default = [];
        description = "Additional `loki.process` stage blocks applied to journal log streams.";
      };
    };
  };

  fileLogSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether tailing is enabled for this log file group.";
      };

      paths = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "Glob patterns of filesystem log paths to tail and ship.";
      };

      labels = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Static labels attached to entries read from these log files.";
      };

      stages = lib.mkOption {
        type = lib.types.listOf lib.types.lines;
        default = [];
        description = "Additional `loki.process` stage blocks applied to these file logs.";
      };
    };
  };

  logsSubmodule = lib.types.submodule {
    options = {
      journal = lib.mkOption {
        type = journalLogsSubmodule;
        default = {};
        description = "Systemd journal collection and label processing configuration.";
      };

      files = lib.mkOption {
        type = lib.types.attrsOf fileLogSubmodule;
        default = {};
        description = "Named file-based log sources tailed and forwarded by the telemetry agent.";
      };
    };
  };

  probeSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this blackbox health probe is active.";
      };

      target = lib.mkOption {
        type = lib.types.str;
        example = "http://127.0.0.1:8080";
        description = "Target URL or `host:port` endpoint checked by the blackbox prober.";
      };

      module = lib.mkOption {
        type = lib.types.enum ["http_2xx" "tcp_connect" "icmp"];
        default = "http_2xx";
        description = "Blackbox prober module profile used to evaluate endpoint health.";
      };

      interval = lib.mkOption {
        type = lib.types.str;
        default = "60s";
        description = "Evaluation interval for executing this blackbox health probe.";
      };

      labels = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Additional static labels attached to probe metrics.";
      };
    };
  };

  ruleItemSubmodule = lib.types.submodule {
    options = {
      alert = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "ServiceDown";
        description = "Alert rule name triggered when `expr` evaluates true (mutually exclusive with `record`).";
      };

      record = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "job:http_requests:rate5m";
        description = "Recording rule output metric name (mutually exclusive with `alert`).";
      };

      expr = lib.mkOption {
        type = lib.types.str;
        example = "up == 0";
        description = "MetricsQL/PromQL or LogsQL query expression evaluated for this rule.";
      };

      for = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "5m";
        description = "Duration the alert expression must remain active before firing.";
      };

      labels = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Labels attached to generated alert instances or recorded metrics.";
      };

      annotations = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Human-readable templating annotations attached to firing alerts.";
      };
    };
  };

  ruleGroupSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this evaluation rule group is loaded by the rule engine.";
      };

      backend = lib.mkOption {
        type = lib.types.enum ["metrics" "logs"];
        default = "metrics";
        description = "Target rule evaluation engine (`metrics` for PromQL/MetricsQL or `logs` for LogsQL).";
      };

      interval = lib.mkOption {
        type = lib.types.str;
        default = "1m";
        description = "Evaluation cadence for rules inside this group.";
      };

      rules = lib.mkOption {
        type = lib.types.listOf ruleItemSubmodule;
        default = [];
        description = "Ordered list of alerting or recording rules evaluated in this group.";
      };
    };
  };

  dashboardSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this dashboard is provisioned into Grafana.";
      };

      title = lib.mkOption {
        type = lib.types.str;
        default = name;
        description = "Human-readable dashboard title.";
      };

      folder = lib.mkOption {
        type = lib.types.str;
        default = "General";
        description = "Grafana folder name organizing this dashboard.";
      };

      json = lib.mkOption {
        type = lib.types.either lib.types.path (lib.types.either lib.types.str (lib.types.attrsOf lib.types.anything));
        example = {
          title = "Overview";
          schemaVersion = 39;
          panels = [];
        };
        description = "Dashboard definition as a JSON file path, raw JSON string, or Nix attribute set.";
      };
    };
  });

  serviceSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this service registration participates in unified telemetry labeling and service views.";
      };

      units = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["vaultwarden.service"];
        description = "Systemd unit names belonging to this service for unit state, cgroup, and journal labeling.";
      };

      vhost = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "vaultwarden.adje.app";
        description = "Primary reverse-proxy virtual host FQDN served by this service for Caddy and blackbox correlation.";
      };

      backupUnit = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "vaultwarden";
        description = "Optional backup unit name prefix correlating restic backup and restore units with this service.";
      };

      storageMounts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        example = ["/mnt/storage/copyparty"];
        description = "Mountpoint paths associated with this service for per-service storage telemetry.";
      };
    };
  };
in {
  contract.monitoring.types = {
    agent = agentSubmodule;
    server = serverSubmodule;
    retention = retentionSubmodule;
    ntfyNotification = ntfyNotificationSubmodule;
    scrape = scrapeSubmodule;
    exporters = exportersSubmodule;
    journalLogs = journalLogsSubmodule;
    fileLog = fileLogSubmodule;
    logs = logsSubmodule;
    probe = probeSubmodule;
    ruleItem = ruleItemSubmodule;
    ruleGroup = ruleGroupSubmodule;
    dashboard = dashboardSubmodule;
    service = serviceSubmodule;
  };
}
