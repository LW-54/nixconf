{config, ...}: let
  d = config.internal.monitoring.dashboard;
  toggle = d.statToggleExpr;

  mkEnvelopeTargets = {
    expr,
    labelPrefix ? "",
    allocHighExpr ? null,
    allocMaxExpr ? null,
  }: let
    pfx =
      if labelPrefix == ""
      then ""
      else "${labelPrefix} ";
  in
    [
      (d.promTarget {
        refId = "A";
        expr = toggle "current" expr;
        legend = "${pfx}Current";
      })
      (d.promTarget {
        refId = "B";
        expr = toggle "avg" ''avg_over_time((${expr})[$rolling:])'';
        legend = "${pfx}Rolling Avg ($rolling)";
      })
      (d.promTarget {
        refId = "C";
        expr = toggle "p95" ''quantile_over_time(0.95, (${expr})[$rolling:])'';
        legend = "${pfx}Rolling P95 ($rolling)";
      })
      (d.promTarget {
        refId = "D";
        expr = toggle "min" ''min_over_time((${expr})[$rolling:])'';
        legend = "${pfx}Rolling Min ($rolling)";
      })
      (d.promTarget {
        refId = "E";
        expr = toggle "max" ''max_over_time((${expr})[$rolling:])'';
        legend = "${pfx}Rolling Max ($rolling)";
      })
      (d.promTarget {
        refId = "F";
        expr = toggle "upper_1sigma" ''avg_over_time((${expr})[$rolling:]) + stddev_over_time((${expr})[$rolling:])'';
        legend = "${pfx}Rolling +1σ ($rolling)";
      })
      (d.promTarget {
        refId = "G";
        expr = toggle "lower_1sigma" ''clamp_min(avg_over_time((${expr})[$rolling:]) - stddev_over_time((${expr})[$rolling:]), 0)'';
        legend = "${pfx}Rolling -1σ ($rolling)";
      })
      (d.promTarget {
        refId = "H";
        expr = toggle "prev_cycle" ''(${expr}) offset $compare'';
        legend = "${pfx}Prev Cycle (-$compare)";
      })
    ]
    ++ (
      if allocHighExpr != null
      then [
        (d.promTarget {
          refId = "I";
          expr = toggle "alloc_high" allocHighExpr;
          legend = "${pfx}Alloc High";
        })
      ]
      else []
    )
    ++ (
      if allocMaxExpr != null
      then [
        (d.promTarget {
          refId = "J";
          expr = toggle "alloc_max" allocMaxExpr;
          legend = "${pfx}Alloc Max";
        })
      ]
      else []
    );
in {
  internal.monitoring.dashboard.mkTrendsExplorerDashboard = _:
    d.mkDashboard {
      uid = "nixconf-trends-explorer";
      title = "Trends, Cycles & Metric Explorer";
      description = "Time-based trend and cycle explorer with toggleable statistical overlays (Current, Rolling Avg/Min/P95/Max, ±1σ variance bands, previous-cycle offset, and declared allocations) across arbitrary time frames.";
      tags = ["trends" "cycles" "statistics" "explorer" "resources"];
      refresh = "1m";
      timeFrom = "now-24h";
      graphTooltip = 2;
      variables = [
        (d.vars.host {
          includeAll = false;
          multi = false;
        })
        (d.vars.custom {
          name = "rolling";
          label = "Rolling Window";
          includeAll = false;
          multi = false;
          current = {
            text = "1h";
            value = "1h";
          };
          options = ["15m" "1h" "6h" "24h" "7d"];
        })
        (d.vars.custom {
          name = "compare";
          label = "Cycle Offset";
          includeAll = false;
          multi = false;
          current = {
            text = "1d";
            value = "1d";
          };
          options = [
            {
              text = "1d (Yesterday)";
              value = "1d";
            }
            {
              text = "7d (Last Week)";
              value = "7d";
            }
            {
              text = "30d (Last Month)";
              value = "30d";
            }
          ];
        })
        (d.vars.custom {
          name = "stats";
          label = "Stat Overlays";
          includeAll = true;
          multi = true;
          allValue = ".*";
          options = [
            {
              text = "Current";
              value = "current";
            }
            {
              text = "Rolling Avg";
              value = "avg";
            }
            {
              text = "Rolling P95";
              value = "p95";
            }
            {
              text = "Rolling Min";
              value = "min";
            }
            {
              text = "Rolling Max";
              value = "max";
            }
            {
              text = "Rolling +1σ";
              value = "upper_1sigma";
            }
            {
              text = "Rolling -1σ";
              value = "lower_1sigma";
            }
            {
              text = "Prev Cycle";
              value = "prev_cycle";
            }
            {
              text = "Alloc High";
              value = "alloc_high";
            }
            {
              text = "Alloc Max";
              value = "alloc_max";
            }
          ];
        })
        (d.vars.promQuery {
          name = "slice";
          label = "Slice";
          includeAll = false;
          multi = false;
          query = ''label_values(container_memory_working_set_bytes{host="$host",id=~"/[^/]+\\.slice",slice!=""}, slice)'';
        })
        (d.vars.promQuery {
          name = "unit";
          label = "Unit";
          includeAll = false;
          multi = false;
          query = ''label_values(container_memory_working_set_bytes{host="$host",unit!=""}, unit)'';
        })
        (d.vars.promQuery {
          name = "proc";
          label = "Process";
          includeAll = false;
          multi = false;
          query = ''label_values(namedprocess_namegroup_num_procs{host="$host"}, groupname)'';
        })
      ];
      sections = [
        (d.mkSection {
          title = "Host Global Cycles & Statistical Envelopes ($host)";
          rows = [
            [
              (d.mkTimeseries {
                title = "Host CPU Utilization (%) — Current, Rolling Stats & Cycle Comparison";
                w = 12;
                h = 9;
                unit = "percent";
                min = 0;
                max = 100;
                legendCalcs = ["min" "mean" "max" "lastNotNull"];
                overrides = d.statBandOverrides {};
                targets = mkEnvelopeTargets {
                  expr = ''100 - (avg(rate(node_cpu_seconds_total{host="$host",mode="idle"}[$__rate_interval])) * 100)'';
                };
              })
              (d.mkTimeseries {
                title = "Host Memory Used — Current, Rolling Stats & Cycle Comparison";
                w = 12;
                h = 9;
                unit = "bytes";
                min = 0;
                legendCalcs = ["min" "mean" "max" "lastNotNull"];
                overrides = d.statBandOverrides {};
                targets = mkEnvelopeTargets {
                  expr = ''max(node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"})'';
                  allocMaxExpr = ''max(node_memory_MemTotal_bytes{host="$host"})'';
                };
              })
            ]
            [
              (d.mkTimeseries {
                title = "Host Contention Cycles (CPU / Memory / I/O PSI %)";
                w = 12;
                h = 7;
                unit = "percent";
                min = 0;
                legendCalcs = ["mean" "max" "lastNotNull"];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''rate(node_pressure_cpu_waiting_seconds_total{host="$host"}[$__rate_interval]) * 100'';
                    legend = "CPU PSI %";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(node_pressure_memory_stalled_seconds_total{host="$host"}[$__rate_interval]) * 100'';
                    legend = "Mem PSI %";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''rate(node_pressure_io_stalled_seconds_total{host="$host"}[$__rate_interval]) * 100'';
                    legend = "I/O PSI %";
                  })
                ];
              })
              (d.mkTimeseries {
                title = "Host Disk & Network Activity Cycles (Quiet-Window Finder)";
                w = 12;
                h = 7;
                unit = "Bps";
                overrides = [(d.negativeYOverride "/Write|TX/")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''sum(rate(node_disk_read_bytes_total{host="$host",device!~"dm-.*|loop.*"}[$__rate_interval]))'';
                    legend = "Disk Read";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''sum(rate(node_disk_written_bytes_total{host="$host",device!~"dm-.*|loop.*"}[$__rate_interval]))'';
                    legend = "Disk Write";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''sum(rate(node_network_receive_bytes_total{host="$host",device!~"lo|veth.*|docker.*|br-.*|podman.*"}[$__rate_interval]))'';
                    legend = "Net RX";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''sum(rate(node_network_transmit_bytes_total{host="$host",device!~"lo|veth.*|docker.*|br-.*|podman.*"}[$__rate_interval]))'';
                    legend = "Net TX";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Slice Trends vs Declared Allocations ($slice.slice)";
          rows = [
            [
              (d.mkTimeseries {
                title = "$slice.slice Memory Working Set vs Allocations";
                w = 12;
                h = 9;
                unit = "bytes";
                min = 0;
                legendCalcs = ["min" "mean" "max" "lastNotNull"];
                overrides = d.statBandOverrides {};
                targets = mkEnvelopeTargets {
                  expr = ''sum(container_memory_working_set_bytes{host="$host",id=~"/[^/]+\\.slice",slice="$slice"})'';
                  allocHighExpr = ''max(nixconf:slice_memory_high_bytes{host="$host",slice="$slice"})'';
                  allocMaxExpr = ''max(nixconf:slice_memory_max_bytes{host="$host",slice="$slice"})'';
                };
              })
              (d.mkTimeseries {
                title = "$slice.slice CPU Usage (cores) — Trends & Cycles";
                w = 12;
                h = 9;
                min = 0;
                legendCalcs = ["min" "mean" "max" "lastNotNull"];
                overrides = d.statBandOverrides {};
                targets = mkEnvelopeTargets {
                  expr = ''sum(rate(container_cpu_usage_seconds_total{host="$host",id=~"/[^/]+\\.slice",slice="$slice"}[$__rate_interval]))'';
                  allocMaxExpr = ''max(nixconf_resource_slice_cpu_quota_cores{host="$host",slice="$slice"})'';
                };
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Unit / Service / Container Trends vs Allocations ($unit)";
          rows = [
            [
              (d.mkTimeseries {
                title = "$unit Memory Working Set vs Allocations";
                w = 12;
                h = 9;
                unit = "bytes";
                min = 0;
                legendCalcs = ["min" "mean" "max" "lastNotNull"];
                overrides = d.statBandOverrides {};
                targets = mkEnvelopeTargets {
                  expr = ''max(container_memory_working_set_bytes{host="$host",unit="$unit"})'';
                  allocHighExpr = ''max(nixconf:unit_memory_high_bytes{host="$host",unit="$unit"})'';
                  allocMaxExpr = ''max(nixconf:unit_memory_max_bytes{host="$host",unit="$unit"})'';
                };
              })
              (d.mkTimeseries {
                title = "$unit CPU Usage (cores) — Trends & Cycles";
                w = 12;
                h = 9;
                min = 0;
                legendCalcs = ["min" "mean" "max" "lastNotNull"];
                overrides = d.statBandOverrides {};
                targets = mkEnvelopeTargets {
                  expr = ''max(rate(container_cpu_usage_seconds_total{host="$host",unit="$unit"}[$__rate_interval]))'';
                  allocMaxExpr = ''max(nixconf_resource_unit_cpu_quota_cores{host="$host",unit="$unit"})'';
                };
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Process Executable Trends ($proc)";
          rows = [
            [
              (d.mkTimeseries {
                title = "$proc Resident Memory (RSS) — Trends & Cycles";
                w = 12;
                h = 8;
                unit = "bytes";
                min = 0;
                legendCalcs = ["min" "mean" "max" "lastNotNull"];
                overrides = d.statBandOverrides {};
                targets = mkEnvelopeTargets {
                  expr = ''sum(namedprocess_namegroup_memory_bytes{host="$host",groupname="$proc",memtype="resident"})'';
                };
              })
              (d.mkTimeseries {
                title = "$proc CPU Usage (cores) — Trends & Cycles";
                w = 12;
                h = 8;
                min = 0;
                legendCalcs = ["min" "mean" "max" "lastNotNull"];
                overrides = d.statBandOverrides {};
                targets = mkEnvelopeTargets {
                  expr = ''sum(rate(namedprocess_namegroup_cpu_seconds_total{host="$host",groupname="$proc"}[$__rate_interval]))'';
                };
              })
            ]
            [
              (d.mkTimeseries {
                title = "$proc Disk I/O (Read / -Write)";
                w = 24;
                h = 6;
                unit = "Bps";
                overrides = [(d.negativeYOverride "/Write/")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''sum(rate(namedprocess_namegroup_read_bytes_total{host="$host",groupname="$proc"}[$__rate_interval]))'';
                    legend = "Read";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''sum(rate(namedprocess_namegroup_write_bytes_total{host="$host",groupname="$proc"}[$__rate_interval]))'';
                    legend = "Write";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Background Operation Schedule & Overlap Distribution ($host)";
          rows = [
            [
              (d.mkTimeseries {
                title = "Background Operations — CPU Time per 5m Window (Schedule Overlap View)";
                w = 12;
                h = 8;
                unit = "s";
                drawStyle = "bars";
                stacked = true;
                noValue = "Waiting for recorded systemd operation accounting samples";
                expr = ''topk(15, sum by (op_unit) (nixconf_operation_cpu_seconds_5m{host="$host"} > 0))'';
                legend = "{{op_unit}}";
              })
              (d.mkTimeseries {
                title = "Background Operations — Disk Read + Write per 5m Window";
                w = 12;
                h = 8;
                unit = "bytes";
                drawStyle = "bars";
                stacked = true;
                noValue = "Waiting for recorded systemd operation accounting samples";
                expr = ''topk(15, ((sum by (op_unit) (nixconf_operation_io_read_bytes_5m{host="$host"}) + sum by (op_unit) (nixconf_operation_io_write_bytes_5m{host="$host"})) or sum by (op_unit) (nixconf_operation_io_read_bytes_5m{host="$host"}) or sum by (op_unit) (nixconf_operation_io_write_bytes_5m{host="$host"})) > 0)'';
                legend = "{{op_unit}}";
              })
            ]
          ];
        })
      ];
    };
}
