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
        default = "15s";
        description = "Default metrics scrape interval used by the telemetry agent.";
      };

      metricsUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "https://prometheus.adje.app/api/v1/write";
        description = "Remote Prometheus write endpoint URL (`null` defaults to local server when `monitoring.server.enable` is true).";
      };

      logsUrl = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "https://loki.adje.app/loki/api/v1/push";
        description = "Remote Loki push endpoint URL (`null` defaults to local server when `monitoring.server.enable` is true).";
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
  }:
    lib.types.submodule {
      options = {
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
      };
    };

  lokiEndpointSubmodule = lib.types.submodule {
    options = {
      subdomain = lib.mkOption {
        type = lib.types.str;
        default = "loki";
        description = "Subdomain prefix under `reverse-proxy.domain` exposing Loki HTTP ingestion and query endpoints.";
      };

      address = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = "Local bind address for Loki HTTP and gRPC listeners.";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = mkPort "loki";
        description = "Local TCP HTTP port for Loki.";
      };

      grpcPort = lib.mkOption {
        type = lib.types.port;
        default = mkPort "loki-grpc";
        description = "Local TCP gRPC port for Loki internal server listeners.";
      };
    };
  };

  serverSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkEnableOption "central monitoring server stack (Grafana, Prometheus, Loki)";

      retentionDays = lib.mkOption {
        type = lib.types.ints.positive;
        default = 30;
        description = "Retention period in days for metrics and logs time-series storage.";
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

      prometheus = lib.mkOption {
        type = mkEndpointSubmodule {
          defaultSubdomain = "prometheus";
          portSeed = "prometheus";
          serviceDesc = "Prometheus TSDB and remote-write receiver";
        };
        default = {};
        description = "Prometheus metrics storage listener and reverse proxy configuration.";
      };

      loki = lib.mkOption {
        type = lokiEndpointSubmodule;
        default = {};
        description = "Loki log aggregation listener and reverse proxy configuration.";
      };
    };
  };

  scrapeSubmodule = lib.types.submodule {
    options = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this Prometheus scrape job is active.";
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
        enable = lib.mkEnableOption "container resource metrics exporter";

        dockerOnly = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Whether to restrict container metrics collection to Docker containers.";
        };
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
        description = "PromQL or LogQL query expression evaluated for this rule.";
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
        description = "Whether this evaluation rule group is loaded by the metrics or logs backend.";
      };

      backend = lib.mkOption {
        type = lib.types.enum ["prometheus" "loki"];
        default = "prometheus";
        description = "Target rule evaluation engine (`prometheus` for PromQL or `loki` for LogQL).";
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
