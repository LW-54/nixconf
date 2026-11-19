# Host monitoring module: baseline OS metrics, systemd journal streaming, host alert rules, and overview dashboards.
{
  _module.args = {
    hostMonitoringModule = {name}: {
      config,
      lib,
      ...
    }: let
      hostTemplateVar = {
        allValue = ".*";
        current = {
          selected = true;
          text = "All";
          value = "$__all";
        };
        datasource = {
          type = "prometheus";
          uid = "prometheus";
        };
        definition = "label_values(node_uname_info, host)";
        includeAll = true;
        multi = true;
        name = "host";
        query = {
          qryType = 1;
          query = "label_values(node_uname_info, host)";
        };
        refresh = 2;
        sort = 1;
        type = "query";
      };

      promTarget = refId: expr: legendFormat: {
        inherit expr legendFormat refId;
        datasource = {
          type = "prometheus";
          uid = "prometheus";
        };
      };

      lokiTarget = refId: expr: legendFormat: {
        inherit expr legendFormat refId;
        datasource = {
          type = "loki";
          uid = "loki";
        };
      };

      hostOverviewDashboard = {
        uid = "nixconf-host-overview";
        title = "Host & Systemd Overview";
        tags = ["nixconf" "host" "systemd"];
        timezone = "browser";
        schemaVersion = 39;
        refresh = "30s";
        time = {
          from = "now-3h";
          to = "now";
        };
        templating.list = [hostTemplateVar];
        panels = [
          {
            id = 1;
            title = "CPU Usage (%)";
            type = "timeseries";
            gridPos = {
              h = 8;
              w = 8;
              x = 0;
              y = 0;
            };
            fieldConfig.defaults = {
              unit = "percent";
              min = 0;
              max = 100;
            };
            targets = [
              (promTarget "A" ''100 - (avg by (host) (rate(node_cpu_seconds_total{host=~"$host",mode="idle"}[5m])) * 100)'' "{{host}}")
            ];
          }
          {
            id = 2;
            title = "Memory Usage (%)";
            type = "timeseries";
            gridPos = {
              h = 8;
              w = 8;
              x = 8;
              y = 0;
            };
            fieldConfig.defaults = {
              unit = "percent";
              min = 0;
              max = 100;
            };
            targets = [
              (promTarget "A" ''(1 - (node_memory_MemAvailable_bytes{host=~"$host"} / node_memory_MemTotal_bytes{host=~"$host"})) * 100'' "{{host}}")
            ];
          }
          {
            id = 3;
            title = "Load Average (1m / 5m)";
            type = "timeseries";
            gridPos = {
              h = 8;
              w = 8;
              x = 16;
              y = 0;
            };
            targets = [
              (promTarget "A" ''node_load1{host=~"$host"}'' "{{host}} 1m")
              (promTarget "B" ''node_load5{host=~"$host"}'' "{{host}} 5m")
            ];
          }
          {
            id = 4;
            title = "Network Traffic (RX / TX)";
            type = "timeseries";
            gridPos = {
              h = 8;
              w = 12;
              x = 0;
              y = 8;
            };
            fieldConfig.defaults.unit = "Bps";
            targets = [
              (promTarget "A" ''sum by (host) (rate(node_network_receive_bytes_total{host=~"$host",device!="lo"}[5m]))'' "{{host}} rx")
              (promTarget "B" ''sum by (host) (rate(node_network_transmit_bytes_total{host=~"$host",device!="lo"}[5m]))'' "{{host}} tx")
            ];
          }
          {
            id = 5;
            title = "Filesystem Usage (%)";
            type = "bargauge";
            gridPos = {
              h = 8;
              w = 12;
              x = 12;
              y = 8;
            };
            fieldConfig.defaults = {
              unit = "percent";
              min = 0;
              max = 100;
            };
            targets = [
              (promTarget "A" ''(1 - (node_filesystem_avail_bytes{host=~"$host",fstype!~"tmpfs|ramfs|squashfs|overlay"} / node_filesystem_size_bytes{host=~"$host",fstype!~"tmpfs|ramfs|squashfs|overlay"})) * 100'' "{{host}}:{{mountpoint}}")
            ];
          }
          {
            id = 6;
            title = "Failed Systemd Units";
            type = "table";
            gridPos = {
              h = 8;
              w = 24;
              x = 0;
              y = 16;
            };
            targets = [
              (promTarget "A" ''node_systemd_unit_state{host=~"$host",state="failed"} == 1'' "{{host}} - {{name}}")
            ];
          }
        ];
      };

      logsExplorerDashboard = {
        uid = "nixconf-logs-explorer";
        title = "Logs Explorer";
        tags = ["nixconf" "loki" "journald"];
        timezone = "browser";
        schemaVersion = 39;
        refresh = "30s";
        time = {
          from = "now-3h";
          to = "now";
        };
        templating.list = [hostTemplateVar];
        panels = [
          {
            id = 1;
            title = "Journal Log Rate by Level";
            type = "timeseries";
            gridPos = {
              h = 7;
              w = 12;
              x = 0;
              y = 0;
            };
            targets = [
              (lokiTarget "A" ''sum by (level) (count_over_time({job="systemd-journal", host=~"$host"}[$__interval]))'' "{{level}}")
            ];
          }
          {
            id = 2;
            title = "Top Journal Units (Logs / interval)";
            type = "timeseries";
            gridPos = {
              h = 7;
              w = 12;
              x = 12;
              y = 0;
            };
            targets = [
              (lokiTarget "A" ''topk(10, sum by (host, unit) (count_over_time({job="systemd-journal", host=~"$host"}[$__interval])))'' "{{host}} {{unit}}")
            ];
          }
          {
            id = 3;
            title = "Journald Stream";
            type = "logs";
            gridPos = {
              h = 14;
              w = 24;
              x = 0;
              y = 7;
            };
            options = {
              showTime = true;
              showLabels = true;
              enableLogDetails = true;
              wrapLogMessage = true;
            };
            targets = [
              (lokiTarget "A" ''{job="systemd-journal", host=~"$host"}'' "")
            ];
          }
        ];
      };
    in {
      _file = "modules/hosts/${name}.nix, via option host.${name}.configuration";
      key = "primitives-host-monitoring-${name}";

      config = lib.mkIf (config.monitoring.enable or false) {
        monitoring = {
          exporters.unix = {
            enable = true;
            collectors = [
              "cpu"
              "meminfo"
              "loadavg"
              "netdev"
              "systemd"
              "uname"
              "vmstat"
              "time"
              "processes"
            ];
          };

          logs.journal.enable = true;

          rules.host = {
            backend = "prometheus";
            interval = "1m";
            rules = [
              {
                alert = "SystemdUnitFailed";
                expr = ''node_systemd_unit_state{state="failed"} == 1'';
                "for" = "2m";
                labels.severity = "critical";
                annotations = {
                  summary = "Systemd unit {{ $labels.name }} failed on {{ $labels.host }}";
                  description = "Unit {{ $labels.name }} on {{ $labels.host }} has been in failed state for more than 2 minutes.";
                };
              }
              {
                alert = "HostHighMemoryUsage";
                expr = ''(1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100 > 90'';
                "for" = "5m";
                labels.severity = "warning";
                annotations = {
                  summary = "High memory usage on {{ $labels.host }}";
                  description = "Memory utilization on {{ $labels.host }} is above 90%.";
                };
              }
              {
                alert = "HostHighCpuLoad";
                expr = ''node_load5 / count without (cpu, mode) (node_cpu_seconds_total{mode="idle"}) > 2'';
                "for" = "10m";
                labels.severity = "warning";
                annotations = {
                  summary = "High 5m load average on {{ $labels.host }}";
                  description = "5-minute load per CPU core exceeded 2.0 on {{ $labels.host }}.";
                };
              }
            ];
          };

          dashboards = {
            host-overview = {
              title = "Host & Systemd Overview";
              folder = "Infrastructure";
              json = hostOverviewDashboard;
            };
            logs-explorer = {
              title = "Logs Explorer";
              folder = "Infrastructure";
              json = logsExplorerDashboard;
            };
          };
        };
      };
    };
  };
}
