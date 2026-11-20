{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkServiceInspectorDashboard = _:
    d.mkDashboard {
      uid = "nixconf-service-inspector";
      title = "Service Inspector";
      description = "Vertical per-service drilldown correlating HTTP traffic, blackbox probes, systemd units, cgroup compute, storage mounts, and logs.";
      tags = ["service" "app" "inspector"];
      variables = [
        (d.vars.promQuery {
          name = "service";
          label = "Service";
          query = ''label_values(node_systemd_unit_state{service=~".+"}, service)'';
          includeAll = false;
          multi = false;
        })
        (d.vars.host {})
        (d.vars.custom {
          name = "level";
          label = "Log Level";
          options = ["emerg" "alert" "crit" "error" "warning" "notice" "info" "debug"];
        })
        (d.vars.textbox {
          name = "search";
          label = "Log Search (Regex)";
          default = "";
        })
      ];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Units Active";
            w = 4;
            decimals = 0;
            thresholds = d.thresholds.upDown;
            colorMode = "background";
            expr = ''sum(node_systemd_unit_state{host=~"$host",service="$service",state="active",name!~"restic-.*"}) or vector(0)'';
            legend = "Active";
          })
          (d.mkStat {
            title = "Failed Units";
            w = 4;
            decimals = 0;
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            expr = ''sum(node_systemd_unit_state{host=~"$host",service="$service",state="failed"}) or vector(0)'';
            legend = "Failed";
          })
          (d.mkStat {
            title = "Endpoint Probe";
            w = 4;
            mappings = d.mappings.upDown;
            thresholds = d.thresholds.upDown;
            colorMode = "background";
            noValue = "N/A";
            expr = ''min(probe_success{service="$service"})'';
            legend = "Probe";
          })
          (d.mkStat {
            title = "HTTP Request Rate";
            w = 4;
            unit = "reqps";
            decimals = 2;
            graphMode = "area";
            noValue = "—";
            expr = ''sum(rate(caddy_http_requests_total{server="srv0",service="$service"}[5m]))'';
            legend = "RPS";
          })
          (d.mkStat {
            title = "Memory Working Set";
            w = 4;
            unit = "bytes";
            decimals = 1;
            graphMode = "area";
            noValue = "—";
            expr = ''sum(container_memory_working_set_bytes{host=~"$host",service="$service"})'';
            legend = "Memory";
          })
          (d.mkStat {
            title = "Error Logs";
            w = 4;
            loki = true;
            decimals = 0;
            noValue = "0";
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            expr = ''sum(count_over_time({job="systemd-journal", host=~"$host", service="$service", level=~"emerg|alert|crit|err|error"} |~ "$search" [$__range]))'';
            legend = "Errors";
          })
        ])
        (d.mkSection {
          title = "HTTP Traffic & Endpoint Health";
          rows = [
            [
              (d.mkTimeseries {
                title = "HTTP Responses by Status Code";
                w = 12;
                h = 7;
                unit = "reqps";
                noValue = "No HTTP traffic";
                overrides = d.statusColorOverrides {};
                expr = ''sum by (code) (rate(caddy_http_request_duration_seconds_count{server="srv0",service="$service"}[5m]))'';
                legend = "HTTP {{code}}";
              })
              (d.mkTimeseries {
                title = "HTTP Latency Percentiles (p50 / p95 / p99)";
                w = 12;
                h = 7;
                unit = "s";
                noValue = "No HTTP traffic";
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''histogram_quantile(0.50, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server="srv0",service="$service"}[5m])))'';
                    legend = "p50";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''histogram_quantile(0.95, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server="srv0",service="$service"}[5m])))'';
                    legend = "p95";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''histogram_quantile(0.99, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server="srv0",service="$service"}[5m])))'';
                    legend = "p99";
                  })
                ];
              })
            ]
            [
              (d.mkTimeseries {
                title = "Blackbox Probe Latency";
                w = 12;
                h = 6;
                unit = "s";
                thresholds = d.thresholds.latencySec;
                noValue = "No blackbox probe configured";
                expr = ''max by (vhost) (probe_duration_seconds{service="$service"})'';
                legend = "{{vhost}}";
              })
              (d.mkTimeseries {
                title = "HTTP Probe Phase Breakdown";
                w = 12;
                h = 6;
                unit = "s";
                stacked = true;
                noValue = "No blackbox probe configured";
                expr = ''avg by (phase) (probe_http_duration_seconds{service="$service"})'';
                legend = "{{phase}}";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Compute, Units & Storage";
          rows = [
            [
              (d.mkTimeseries {
                title = "Memory Working Set";
                w = 12;
                h = 7;
                unit = "bytes";
                noValue = "No systemd cgroup metrics";
                overrides = [(d.dashedLineOverride "/limit/" "red")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''container_memory_working_set_bytes{host=~"$host",service="$service"}'';
                    legend = "{{host}} {{unit}} ({{slice}})";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''container_spec_memory_limit_bytes{host=~"$host",service="$service"} > 0'';
                    legend = "{{host}} {{unit}} limit";
                  })
                ];
              })
              (d.mkTimeseries {
                title = "CPU Usage (cores)";
                w = 12;
                h = 7;
                noValue = "No systemd cgroup metrics";
                overrides = [(d.dashedLineOverride "/throttled/" "orange")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''rate(container_cpu_usage_seconds_total{host=~"$host",service="$service"}[5m])'';
                    legend = "{{host}} {{unit}} ({{slice}})";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(container_cpu_cfs_throttled_seconds_total{host=~"$host",service="$service"}[5m]) > 0'';
                    legend = "{{host}} {{unit}} throttled";
                  })
                ];
              })
            ]
            [
              (d.mkSystemdUnitsTable {
                title = "Service & Backup Units Health";
                w = 14;
                h = 6;
                expr = ''node_systemd_unit_state{host=~"$host",service="$service"} == 1'';
              })
              (d.mkBarGauge {
                title = "Service Storage Usage (%)";
                w = 10;
                h = 6;
                unit = "percent";
                min = 0;
                max = 100;
                thresholds = d.thresholds.percentHigh;
                noValue = "No dedicated storage mounts";
                expr = ''max by (host, mountpoint, device) ((1 - (node_filesystem_avail_bytes{host=~"$host",service="$service"} / clamp_min(node_filesystem_size_bytes{host=~"$host",service="$service"}, 1))) * 100)'';
                legend = "{{mountpoint}} ({{device}})";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Service Logs";
          rows = [
            [
              (d.mkTimeseries {
                title = "Log Volume by Severity";
                w = 24;
                h = 6;
                loki = true;
                drawStyle = "bars";
                stacked = true;
                legendMode = "list";
                overrides = d.logLevelColorOverrides {};
                expr = ''sum by (level) (count_over_time({job="systemd-journal", host=~"$host", service="$service", level=~"$level"} |~ "$search" [$__auto]))'';
                legend = "{{level}}";
              })
            ]
            [
              (d.mkLogs {
                title = "Live Service Journal Stream";
                w = 24;
                h = 14;
                expr = ''{job="systemd-journal", host=~"$host", service="$service", level=~"$level"} |~ "$search"'';
              })
            ]
          ];
        })
      ];
    };
}
