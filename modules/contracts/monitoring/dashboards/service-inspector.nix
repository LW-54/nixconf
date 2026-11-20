{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkServiceInspectorDashboard = _:
    d.mkDashboard {
      uid = "nixconf-service-inspector";
      title = "Service Inspector";
      description = "Vertical per-service drilldown correlating HTTP traffic, blackbox probes, systemd units, cgroup compute, storage mounts, and VictoriaLogs.";
      tags = ["service" "app" "inspector"];
      graphTooltip = 2;
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
          allValue = "*";
          options = ["emerg" "alert" "crit" "err" "error" "warning" "notice" "info" "debug"];
        })
        (d.vars.textbox {
          name = "search";
          label = "Log Search (LogsQL)";
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
            expr = ''sum(rate(caddy_http_requests_total{server="srv0",service="$service"}[$__rate_interval]))'';
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
            logs = true;
            decimals = 0;
            noValue = "0";
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            expr = ''job:="systemd-journal" host:in($host) service:="$service" level:in("emerg","alert","crit","err","error") $search | stats count() as total'';
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
                expr = ''sum by (code) (rate(caddy_http_request_duration_seconds_count{server="srv0",service="$service"}[$__rate_interval]))'';
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
                    expr = ''histogram_quantile(0.50, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server="srv0",service="$service"}[$__rate_interval])))'';
                    legend = "p50";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''histogram_quantile(0.95, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server="srv0",service="$service"}[$__rate_interval])))'';
                    legend = "p95";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''histogram_quantile(0.99, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server="srv0",service="$service"}[$__rate_interval])))'';
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
                    expr = ''rate(container_cpu_usage_seconds_total{host=~"$host",service="$service"}[$__rate_interval])'';
                    legend = "{{host}} {{unit}} ({{slice}})";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(container_cpu_cfs_throttled_seconds_total{host=~"$host",service="$service"}[$__rate_interval]) > 0'';
                    legend = "{{host}} {{unit}} throttled";
                  })
                ];
              })
            ]
            [
              (d.mkSystemdUnitsTable {
                title = "Service & Backup Units Health";
                w = 10;
                h = 6;
                expr = ''node_systemd_unit_state{host=~"$host",service="$service"} == 1'';
              })
              (d.mkStorageTable {
                title = "Service Storage Mounts";
                w = 14;
                h = 6;
                selector = ''host=~"$host",service="$service"'';
                groupBy = ["host" "mountpoint"];
                columns = {
                  host = "Host";
                  mountpoint = "Mountpoint";
                };
                columnOrder = ["host" "mountpoint"];
                noValue = "No dedicated storage mounts";
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
                logs = true;
                drawStyle = "bars";
                stacked = true;
                legendMode = "list";
                overrides = d.logLevelColorOverrides {};
                expr = ''job:="systemd-journal" host:in($host) service:="$service" level:in($level) $search | stats by (level) count() as lines'';
                legend = "{{level}}";
              })
            ]
            [
              (d.mkLogs {
                title = "Live Service Journal Stream";
                w = 24;
                h = 14;
                expr = ''job:="systemd-journal" host:in($host) service:="$service" level:in($level) $search'';
              })
            ]
          ];
        })
      ];
    };
}
