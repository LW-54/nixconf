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
                title = "Memory Working Set vs Declared Allocations";
                w = 12;
                h = 7;
                unit = "bytes";
                noValue = "No systemd cgroup metrics";
                overrides = [
                  (d.dashedLineOverride "/Alloc High/" "orange")
                  (d.dashedLineOverride "/Alloc Max|limit/" "red")
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''container_memory_working_set_bytes{host=~"$host",service="$service"}'';
                    legend = "{{host}} {{unit}} ({{slice}})";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''nixconf:unit_memory_high_bytes{host=~"$host"} * on (host, unit) group_left (service) (container_memory_working_set_bytes{host=~"$host",service="$service"} * 0 + 1)'';
                    legend = "{{host}} {{unit}} Alloc High";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''nixconf:unit_memory_max_bytes{host=~"$host"} * on (host, unit) group_left (service) (container_memory_working_set_bytes{host=~"$host",service="$service"} * 0 + 1)'';
                    legend = "{{host}} {{unit}} Alloc Max";
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
              (d.mkTable {
                title = "Long-Term Allocation & Statistical Profile ($__range)";
                w = 24;
                h = 6;
                links = [d.links.toTrendsExplorer d.links.toCapacityAnalytics];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      slice = "Slice";
                      unit = "Unit";
                      "Value #A" = "Current";
                      "Value #B" = "Min";
                      "Value #C" = "Avg";
                      "Value #D" = "P95";
                      "Value #E" = "Max";
                      "Value #F" = "StdDev";
                      "Value #G" = "Growth / Day";
                      "Value #H" = "Alloc High";
                      "Value #I" = "Alloc Max";
                      "Value #J" = "P95 / High %";
                    };
                    index = {
                      host = 0;
                      slice = 1;
                      unit = 2;
                      "Value #A" = 3;
                      "Value #B" = 4;
                      "Value #C" = 5;
                      "Value #D" = 6;
                      "Value #E" = 7;
                      "Value #F" = 8;
                      "Value #G" = 9;
                      "Value #H" = 10;
                      "Value #I" = 11;
                      "Value #J" = 12;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Current" "bytes")
                  (d.unitOverride "Min" "bytes")
                  (d.unitOverride "Avg" "bytes")
                  (d.unitOverride "P95" "bytes")
                  (d.unitOverride "Max" "bytes")
                  (d.unitOverride "StdDev" "bytes")
                  (d.unitOverride "Growth / Day" "bytes")
                  (d.unitOverride "Alloc High" "bytes")
                  (d.unitOverride "Alloc Max" "bytes")
                  (d.cellGaugeOverride {
                    colName = "P95 / High %";
                    thresholds = d.thresholds.percentHigh;
                  })
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host, slice, unit) (container_memory_working_set_bytes{host=~"$host",service="$service"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''min by (host, slice, unit) (min_over_time(container_memory_working_set_bytes{host=~"$host",service="$service"}[$__range]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''avg by (host, slice, unit) (avg_over_time(container_memory_working_set_bytes{host=~"$host",service="$service"}[$__range]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host, slice, unit) (quantile_over_time(0.95, container_memory_working_set_bytes{host=~"$host",service="$service"}[$__range]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''max by (host, slice, unit) (max_over_time(container_memory_working_set_bytes{host=~"$host",service="$service"}[$__range]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''max by (host, slice, unit) (stddev_over_time(container_memory_working_set_bytes{host=~"$host",service="$service"}[$__range]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "G";
                    expr = ''max by (host, slice, unit) (deriv(container_memory_working_set_bytes{host=~"$host",service="$service"}[$__range])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "H";
                    expr = ''max by (host, slice, unit) (nixconf:unit_memory_high_bytes{host=~"$host"} * on (host, slice, unit) group_left () (container_memory_working_set_bytes{host=~"$host",service="$service"} * 0 + 1))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "I";
                    expr = ''max by (host, slice, unit) (nixconf:unit_memory_max_bytes{host=~"$host"} * on (host, slice, unit) group_left () (container_memory_working_set_bytes{host=~"$host",service="$service"} * 0 + 1))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "J";
                    expr = ''(max by (host, slice, unit) (quantile_over_time(0.95, container_memory_working_set_bytes{host=~"$host",service="$service"}[$__range])) / clamp_min(max by (host, slice, unit) (nixconf:unit_memory_high_bytes{host=~"$host"} * on (host, slice, unit) group_left () (container_memory_working_set_bytes{host=~"$host",service="$service"} * 0 + 1)), 1)) * 100'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
            [
              (d.mkSystemdUnitsTable {
                title = "Service & Backup Units Health";
                w = 8;
                h = 6;
                expr = ''node_systemd_unit_state{host=~"$host",service="$service"} == 1'';
              })
              (d.mkStorageTable {
                title = "Service Storage Mounts";
                w = 8;
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
              (d.mkTable {
                title = "Service Local Directories & Cache";
                w = 8;
                h = 6;
                links = [d.links.toStorageAtlas];
                noValue = "No scanned directories (>= 1 MiB) matched";
                sortBy = [
                  {
                    desc = true;
                    displayName = "Size";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      category = "Category";
                      path = "Path";
                      "Value #A" = "Size";
                      "Value #B" = "Growth / Day";
                    };
                    index = {
                      host = 0;
                      category = 1;
                      path = 2;
                      "Value #A" = 3;
                      "Value #B" = 4;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Size" "bytes")
                  (d.unitOverride "Growth / Day" "bytes")
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''topk(20, max by (host, category, path) (nixconf_storage_dir_bytes{host=~"$host",service=~"$service|$service-.*"}))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host, category, path) (deriv(nixconf_storage_dir_bytes{host=~"$host",service=~"$service|$service-.*"}[$__range:])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                ];
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
