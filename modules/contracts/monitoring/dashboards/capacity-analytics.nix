{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkCapacityAnalyticsDashboard = _:
    d.mkDashboard {
      uid = "nixconf-capacity-analytics";
      title = "Capacity, Right-Sizing & Operations";
      description = "Long-running statistical baselines (min, avg, p50, p95, p99, max, variance, growth rate) compared directly against declared allocations, plus systemd operation and cumulative process cost rankings.";
      tags = ["capacity" "right-sizing" "statistics" "operations" "resources"];
      refresh = "1m";
      timeFrom = "now-7d";
      graphTooltip = 2;
      variables = [
        (d.vars.host {})
        (d.vars.promQuery {
          name = "slice";
          label = "Slice";
          query = ''label_values(container_memory_working_set_bytes{host=~"$host",slice!=""}, slice)'';
        })
        (d.vars.custom {
          name = "window";
          label = "Stats Window";
          includeAll = false;
          multi = false;
          current = {
            text = "7d";
            value = "7d";
          };
          options = ["6h" "24h" "7d" "30d" "90d"];
        })
      ];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Host RAM P95 ($window)";
            w = 4;
            unit = "bytes";
            decimals = 1;
            expr = ''sum(quantile_over_time(0.95, (node_memory_MemTotal_bytes{host=~"$host"} - node_memory_MemAvailable_bytes{host=~"$host"})[$window:]))'';
            legend = "RAM P95";
          })
          (d.mkStat {
            title = "Host RAM Growth ($window)";
            w = 4;
            unit = "bytes";
            decimals = 1;
            description = "Estimated daily RAM usage slope (bytes/day) over $window via linear derivative.";
            expr = ''sum(deriv((node_memory_MemTotal_bytes{host=~"$host"} - node_memory_MemAvailable_bytes{host=~"$host"})[$window:])) * 86400'';
            legend = "B / day";
          })
          (d.mkStat {
            title = "Host CPU P95 ($window)";
            w = 4;
            unit = "percent";
            decimals = 1;
            thresholds = d.thresholds.percent;
            expr = ''avg(quantile_over_time(0.95, nixconf:host_cpu_utilization_percent:rate5m{host=~"$host"}[$window:]))'';
            legend = "CPU P95";
          })
          (d.mkStat {
            title = "/persist Growth ($window)";
            w = 4;
            unit = "bytes";
            decimals = 1;
            description = "Estimated daily /persist disk growth (bytes/day) over $window.";
            expr = ''sum(deriv((node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"} - node_filesystem_avail_bytes{host=~"$host",mountpoint="/persist"})[$window:])) * 86400'';
            legend = "B / day";
          })
          (d.mkStat {
            title = "Top Op CPU ($__range)";
            w = 4;
            unit = "s";
            decimals = 1;
            noValue = "—";
            expr = ''max(sum by (host, op_unit) (sum_over_time(nixconf_operation_cpu_seconds_5m{host=~"$host"}[$__range])))'';
            legend = "Top Op CPU";
          })
          (d.mkStat {
            title = "Top Op Disk I/O ($__range)";
            w = 4;
            unit = "bytes";
            decimals = 1;
            noValue = "—";
            expr = ''max((sum by (host, op_unit) (sum_over_time(nixconf_operation_io_read_bytes_5m{host=~"$host"}[$__range])) + sum by (host, op_unit) (sum_over_time(nixconf_operation_io_write_bytes_5m{host=~"$host"}[$__range]))) or sum by (host, op_unit) (sum_over_time(nixconf_operation_io_read_bytes_5m{host=~"$host"}[$__range])) or sum by (host, op_unit) (sum_over_time(nixconf_operation_io_write_bytes_5m{host=~"$host"}[$__range])))'';
            legend = "Top Op I/O";
          })
        ])
        (d.mkSection {
          title = "Slice Baselines vs Declared Allocations ($window)";
          rows = [
            [
              (d.mkTable {
                title = "Workload Slices — Statistical Profile vs Declared Limits ($window)";
                w = 24;
                h = 9;
                links = [d.links.toTrendsExplorer];
                sortBy = [
                  {
                    desc = true;
                    displayName = "RAM P95";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      slice = "Slice";
                      "Value #A" = "Current";
                      "Value #B" = "RAM Min";
                      "Value #C" = "RAM Avg";
                      "Value #D" = "RAM P95";
                      "Value #E" = "RAM Max";
                      "Value #F" = "StdDev";
                      "Value #G" = "Burst (Max/Avg)";
                      "Value #H" = "Growth / Day";
                      "Value #I" = "Alloc High";
                      "Value #J" = "P95 / High %";
                      "Value #K" = "Alloc Max";
                      "Value #L" = "Max / Max %";
                      "Value #M" = "CPU Avg";
                      "Value #N" = "CPU P95";
                    };
                    index = {
                      host = 0;
                      slice = 1;
                      "Value #A" = 2;
                      "Value #B" = 3;
                      "Value #C" = 4;
                      "Value #D" = 5;
                      "Value #E" = 6;
                      "Value #F" = 7;
                      "Value #G" = 8;
                      "Value #H" = 9;
                      "Value #I" = 10;
                      "Value #J" = 11;
                      "Value #K" = 12;
                      "Value #L" = 13;
                      "Value #M" = 14;
                      "Value #N" = 15;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Current" "bytes")
                  (d.unitOverride "RAM Min" "bytes")
                  (d.unitOverride "RAM Avg" "bytes")
                  (d.unitOverride "RAM P95" "bytes")
                  (d.unitOverride "RAM Max" "bytes")
                  (d.unitOverride "StdDev" "bytes")
                  (d.decimalsOverride "Burst (Max/Avg)" 2)
                  (d.unitOverride "Growth / Day" "bytes")
                  (d.unitOverride "Alloc High" "bytes")
                  (d.cellGaugeOverride {
                    colName = "P95 / High %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.unitOverride "Alloc Max" "bytes")
                  (d.cellGaugeOverride {
                    colName = "Max / Max %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.decimalsOverride "CPU Avg" 3)
                  (d.decimalsOverride "CPU P95" 3)
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''sum by (host, slice) (container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''min by (host, slice) (min_over_time(container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''avg by (host, slice) (avg_over_time(container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host, slice) (quantile_over_time(0.95, container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''max by (host, slice) (max_over_time(container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''max by (host, slice) (stddev_over_time(container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "G";
                    expr = ''max by (host, slice) (max_over_time(container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[$window])) / clamp_min(avg by (host, slice) (avg_over_time(container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[$window])), 1)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "H";
                    expr = ''sum by (host, slice) (deriv(container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[$window])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "I";
                    expr = ''max by (host, slice) (nixconf:slice_memory_high_bytes{host=~"$host",slice=~"$slice"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "J";
                    expr = ''(max by (host, slice) (quantile_over_time(0.95, container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[$window])) / clamp_min(max by (host, slice) (nixconf:slice_memory_high_bytes{host=~"$host",slice=~"$slice"}), 1)) * 100'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "K";
                    expr = ''max by (host, slice) (nixconf:slice_memory_max_bytes{host=~"$host",slice=~"$slice"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "L";
                    expr = ''(max by (host, slice) (max_over_time(container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[$window])) / clamp_min(max by (host, slice) (nixconf:slice_memory_max_bytes{host=~"$host",slice=~"$slice"}), 1)) * 100'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "M";
                    expr = ''avg by (host, slice) (avg_over_time(nixconf:slice_cpu_cores:rate5m{host=~"$host",slice=~"$slice"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "N";
                    expr = ''max by (host, slice) (quantile_over_time(0.95, nixconf:slice_cpu_cores:rate5m{host=~"$host",slice=~"$slice"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Service, Mount & Container Right-Sizing ($window vs Declared Allocations)";
          rows = [
            [
              (d.mkTable {
                title = "All Managed Units & Containers — Statistical Distribution vs Limits ($window)";
                w = 24;
                h = 13;
                links = [
                  d.links.toUnitLogs
                  d.links.toTrendsExplorer
                ];
                sortBy = [
                  {
                    desc = true;
                    displayName = "RAM P95";
                  }
                ];
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
                      "Value #D" = "P50";
                      "Value #E" = "RAM P95";
                      "Value #F" = "P99";
                      "Value #G" = "Max";
                      "Value #H" = "StdDev";
                      "Value #I" = "Growth / Day";
                      "Value #J" = "Alloc High";
                      "Value #K" = "Alloc Max";
                      "Value #L" = "P95 / High %";
                      "Value #M" = "Max / Max %";
                      "Value #N" = "CPU Avg";
                      "Value #O" = "CPU P95";
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
                      "Value #K" = 13;
                      "Value #L" = 14;
                      "Value #M" = 15;
                      "Value #N" = 16;
                      "Value #O" = 17;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Current" "bytes")
                  (d.unitOverride "Min" "bytes")
                  (d.unitOverride "Avg" "bytes")
                  (d.unitOverride "P50" "bytes")
                  (d.unitOverride "RAM P95" "bytes")
                  (d.unitOverride "P99" "bytes")
                  (d.unitOverride "Max" "bytes")
                  (d.unitOverride "StdDev" "bytes")
                  (d.unitOverride "Growth / Day" "bytes")
                  (d.unitOverride "Alloc High" "bytes")
                  (d.unitOverride "Alloc Max" "bytes")
                  (d.cellGaugeOverride {
                    colName = "P95 / High %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.cellGaugeOverride {
                    colName = "Max / Max %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.decimalsOverride "CPU Avg" 3)
                  (d.decimalsOverride "CPU P95" 3)
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host, slice, unit) (container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''min by (host, slice, unit) (min_over_time(container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''avg by (host, slice, unit) (avg_over_time(container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host, slice, unit) (quantile_over_time(0.50, container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''max by (host, slice, unit) (quantile_over_time(0.95, container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''max by (host, slice, unit) (quantile_over_time(0.99, container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "G";
                    expr = ''max by (host, slice, unit) (max_over_time(container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "H";
                    expr = ''max by (host, slice, unit) (stddev_over_time(container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "I";
                    expr = ''max by (host, slice, unit) (deriv(container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}[$window])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "J";
                    expr = ''max by (host, slice, unit) (nixconf:unit_memory_high_bytes{host=~"$host",slice=~"$slice"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "K";
                    expr = ''max by (host, slice, unit) (nixconf:unit_memory_max_bytes{host=~"$host",slice=~"$slice"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "L";
                    expr = ''(max by (host, slice, unit) (quantile_over_time(0.95, container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}[$window])) / clamp_min(max by (host, slice, unit) (nixconf:unit_memory_high_bytes{host=~"$host",slice=~"$slice"}), 1)) * 100'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "M";
                    expr = ''(max by (host, slice, unit) (max_over_time(container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}[$window])) / clamp_min(max by (host, slice, unit) (nixconf:unit_memory_max_bytes{host=~"$host",slice=~"$slice"}), 1)) * 100'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "N";
                    expr = ''avg by (host, slice, unit) (avg_over_time(nixconf:unit_cpu_cores:rate5m{host=~"$host",slice=~"$slice",unit!=""}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "O";
                    expr = ''max by (host, slice, unit) (quantile_over_time(0.95, nixconf:unit_cpu_cores:rate5m{host=~"$host",slice=~"$slice",unit!=""}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Operations & Background Jobs Profiler (Optimization Targets)";
          rows = [
            [
              (d.mkTable {
                title = "Systemd Operations, Timers & Jobs — Cumulative Cost & Latency ($__range)";
                w = 24;
                h = 11;
                logs = true;
                noValue = "No completed systemd operation accounting logs in selected range";
                description = "Parsed directly from systemd cgroups v2 accounting logs (Consumed CPU/wall/peak-RAM/disk-I/O) over the selected time range. Sort by Total CPU, Disk Read, Disk Write, or Runs to surface background optimization targets.";
                sortBy = [
                  {
                    desc = true;
                    displayName = "Total CPU (s)";
                  }
                ];
                transformations = [
                  (d.organizeTransform {
                    rename = {
                      host = "Host";
                      op_unit = "Operation";
                      runs = "Runs";
                      total_cpu_s = "Total CPU (s)";
                      avg_wall_s = "Avg Wall (s)";
                      p95_wall_s = "P95 Wall (s)";
                      max_mem_bytes = "Max RAM Peak";
                      total_io_read_bytes = "Total Disk Read";
                      total_io_write_bytes = "Total Disk Write";
                    };
                    index = {
                      host = 0;
                      op_unit = 1;
                      runs = 2;
                      total_cpu_s = 3;
                      avg_wall_s = 4;
                      p95_wall_s = 5;
                      max_mem_bytes = 6;
                      total_io_read_bytes = 7;
                      total_io_write_bytes = 8;
                    };
                  })
                ];
                overrides = [
                  (d.decimalsOverride "Runs" 0)
                  (d.unitOverride "Total CPU (s)" "s")
                  (d.decimalsOverride "Total CPU (s)" 2)
                  (d.unitOverride "Avg Wall (s)" "s")
                  (d.decimalsOverride "Avg Wall (s)" 2)
                  (d.unitOverride "P95 Wall (s)" "s")
                  (d.decimalsOverride "P95 Wall (s)" 2)
                  (d.unitOverride "Max RAM Peak" "bytes")
                  (d.unitOverride "Total Disk Read" "bytes")
                  (d.unitOverride "Total Disk Write" "bytes")
                ];
                expr = ''job:="systemd-journal" host:in($host) "Consumed" "CPU time" | ${d.systemdOpsParsePipe} | stats by (host, op_unit) count() as runs, sum(cpu_s) as total_cpu_s, avg(wall_s) as avg_wall_s, quantile(0.95, wall_s) as p95_wall_s, max(mem_peak_bytes) as max_mem_bytes, sum(io_read_bytes) as total_io_read_bytes, sum(io_write_bytes) as total_io_write_bytes | sort by (total_cpu_s) desc | limit 50'';
              })
            ]
            [
              (d.mkTimeseries {
                title = "Top Operations — CPU Time Trend (5m buckets)";
                w = 12;
                h = 7;
                unit = "s";
                drawStyle = "bars";
                stacked = true;
                noValue = "Waiting for recorded systemd operation metrics";
                expr = ''topk(12, sum by (host, op_unit) (nixconf_operation_cpu_seconds_5m{host=~"$host"} > 0))'';
                legend = "{{host}} {{op_unit}}";
              })
              (d.mkTimeseries {
                title = "Top Operations — Disk I/O Trend (5m buckets)";
                w = 12;
                h = 7;
                unit = "bytes";
                drawStyle = "bars";
                stacked = true;
                noValue = "Waiting for recorded systemd operation metrics";
                expr = ''topk(12, ((sum by (host, op_unit) (nixconf_operation_io_read_bytes_5m{host=~"$host"}) + sum by (host, op_unit) (nixconf_operation_io_write_bytes_5m{host=~"$host"})) or sum by (host, op_unit) (nixconf_operation_io_read_bytes_5m{host=~"$host"}) or sum by (host, op_unit) (nixconf_operation_io_write_bytes_5m{host=~"$host"})) > 0)'';
                legend = "{{host}} {{op_unit}}";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Cumulative Process Executable Cost Rankings ($window)";
          rows = [
            [
              (d.mkTable {
                title = "Executables Ranked by Cumulative CPU, RAM & Disk I/O ($window)";
                w = 24;
                h = 11;
                links = [d.links.toTaskManager];
                sortBy = [
                  {
                    desc = true;
                    displayName = "Total CPU (s)";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      groupname = "Process";
                      "Value #A" = "Total CPU (s)";
                      "Value #B" = "CPU Avg";
                      "Value #C" = "CPU P95";
                      "Value #D" = "RAM Avg";
                      "Value #E" = "RAM P95";
                      "Value #F" = "RAM Max";
                      "Value #G" = "RAM StdDev";
                      "Value #H" = "RAM Growth / Day";
                      "Value #I" = "Total Disk Read";
                      "Value #J" = "Total Disk Write";
                    };
                    index = {
                      host = 0;
                      groupname = 1;
                      "Value #A" = 2;
                      "Value #B" = 3;
                      "Value #C" = 4;
                      "Value #D" = 5;
                      "Value #E" = 6;
                      "Value #F" = 7;
                      "Value #G" = 8;
                      "Value #H" = 9;
                      "Value #I" = 10;
                      "Value #J" = 11;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Total CPU (s)" "s")
                  (d.decimalsOverride "Total CPU (s)" 1)
                  (d.decimalsOverride "CPU Avg" 3)
                  (d.decimalsOverride "CPU P95" 3)
                  (d.unitOverride "RAM Avg" "bytes")
                  (d.unitOverride "RAM P95" "bytes")
                  (d.unitOverride "RAM Max" "bytes")
                  (d.unitOverride "RAM StdDev" "bytes")
                  (d.unitOverride "RAM Growth / Day" "bytes")
                  (d.unitOverride "Total Disk Read" "bytes")
                  (d.unitOverride "Total Disk Write" "bytes")
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''topk(35, sum by (host, groupname) (increase(namedprocess_namegroup_cpu_seconds_total{host=~"$host"}[$window])))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''avg by (host, groupname) (avg_over_time(nixconf:process_cpu_cores:rate5m{host=~"$host"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host, groupname) (quantile_over_time(0.95, nixconf:process_cpu_cores:rate5m{host=~"$host"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''avg by (host, groupname) (avg_over_time(namedprocess_namegroup_memory_bytes{host=~"$host",memtype="resident"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''max by (host, groupname) (quantile_over_time(0.95, namedprocess_namegroup_memory_bytes{host=~"$host",memtype="resident"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''max by (host, groupname) (max_over_time(namedprocess_namegroup_memory_bytes{host=~"$host",memtype="resident"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "G";
                    expr = ''max by (host, groupname) (stddev_over_time(namedprocess_namegroup_memory_bytes{host=~"$host",memtype="resident"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "H";
                    expr = ''sum by (host, groupname) (deriv(namedprocess_namegroup_memory_bytes{host=~"$host",memtype="resident"}[$window])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "I";
                    expr = ''sum by (host, groupname) (increase(namedprocess_namegroup_read_bytes_total{host=~"$host"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "J";
                    expr = ''sum by (host, groupname) (increase(namedprocess_namegroup_write_bytes_total{host=~"$host"}[$window]))'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Disk, Local Volumes & Remote Storage Growth Forecasts ($window)";
          rows = [
            [
              (d.mkTable {
                title = "Local Filesystems & Dedicated Volumes — Growth Rate & Days to 90% ($window)";
                w = 13;
                h = 8;
                links = [d.links.toStorageAtlas];
                sortBy = [
                  {
                    desc = true;
                    displayName = "Usage %";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      mountpoint = "Mountpoint";
                      "Value #A" = "Used";
                      "Value #B" = "Total";
                      "Value #C" = "Usage %";
                      "Value #D" = "Growth / Day";
                      "Value #E" = "Days to 90%";
                    };
                    index = {
                      host = 0;
                      mountpoint = 1;
                      "Value #A" = 2;
                      "Value #B" = 3;
                      "Value #C" = 4;
                      "Value #D" = 5;
                      "Value #E" = 6;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Used" "bytes")
                  (d.unitOverride "Total" "bytes")
                  (d.cellGaugeOverride {
                    colName = "Usage %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.unitOverride "Growth / Day" "bytes")
                  (d.decimalsOverride "Days to 90%" 1)
                ];
                targets = let
                  fsSize = ''(node_filesystem_size_bytes{host=~"$host",fstype!~"btrfs|ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var/run|run|sys|proc|dev).*|.*overlay-containers.*"} or node_filesystem_size_bytes{host=~"$host",fstype="btrfs",mountpoint=~"/|/persist"})'';
                  fsAvail = ''(node_filesystem_avail_bytes{host=~"$host",fstype!~"btrfs|ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var/run|run|sys|proc|dev).*|.*overlay-containers.*"} or node_filesystem_avail_bytes{host=~"$host",fstype="btrfs",mountpoint=~"/|/persist"})'';
                  fsUsed = ''(${fsSize} - ${fsAvail})'';
                in [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host, mountpoint) (${fsUsed})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host, mountpoint) (${fsSize})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host, mountpoint) ((${fsUsed} / clamp_min(${fsSize}, 1)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host, mountpoint) (deriv(${fsUsed}[$window:])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''max by (host, mountpoint) (clamp_min((0.90 * ${fsSize}) - ${fsUsed}, 0)) / (max by (host, mountpoint) (deriv(${fsUsed}[$window:]) * 86400) > 1048576)'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
              (d.mkTable {
                title = "Remote Storage Budgets — Growth Rate & Days to Limit ($window)";
                w = 11;
                h = 8;
                links = [d.links.toStorageAtlas];
                noValue = "No remote storage budgets configured";
                sortBy = [
                  {
                    desc = true;
                    displayName = "Usage %";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      slice = "Slice";
                      "Value #A" = "Used";
                      "Value #B" = "Limit";
                      "Value #C" = "Usage %";
                      "Value #D" = "Growth / Day";
                      "Value #E" = "Days to Limit";
                    };
                    index = {
                      host = 0;
                      slice = 1;
                      "Value #A" = 2;
                      "Value #B" = 3;
                      "Value #C" = 4;
                      "Value #D" = 5;
                      "Value #E" = 6;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Used" "bytes")
                  (d.unitOverride "Limit" "bytes")
                  (d.cellGaugeOverride {
                    colName = "Usage %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.unitOverride "Growth / Day" "bytes")
                  (d.decimalsOverride "Days to Limit" 1)
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host, slice) (nixconf_storage_budget_used_bytes{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host, slice) (nixconf_storage_budget_limit_bytes{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host, slice) ((nixconf_storage_budget_used_bytes{host=~"$host"} / clamp_min(nixconf_storage_budget_limit_bytes{host=~"$host"}, 1)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host, slice) (deriv(nixconf_storage_budget_used_bytes{host=~"$host"}[$window])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''max by (host, slice) (clamp_min(nixconf_storage_budget_limit_bytes{host=~"$host"} - nixconf_storage_budget_used_bytes{host=~"$host"}, 0)) / (max by (host, slice) (deriv(nixconf_storage_budget_used_bytes{host=~"$host"}[$window]) * 86400) > 1048576)'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
          ];
        })
      ];
    };
}
