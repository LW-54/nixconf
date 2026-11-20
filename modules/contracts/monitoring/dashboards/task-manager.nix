{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkTaskManagerDashboard = _:
    d.mkDashboard {
      uid = "nixconf-task-manager";
      title = "Task Manager";
      description = "Historical and live htop/btop/Task Manager equivalent: per-process CPU, memory, swap, disk I/O, open FDs, per-core CPU, thermals, sockets, and systemd cgroups.";
      tags = ["task-manager" "processes" "htop" "btop" "performance"];
      refresh = "10s";
      timeFrom = "now-1h";
      graphTooltip = 2;
      variables = [
        (d.vars.host {
          includeAll = false;
          multi = false;
        })
        (d.vars.textbox {
          name = "proc";
          label = "Process Filter (Regex)";
          default = ".*";
        })
      ];
      sections = [
        (d.mkRow [
          (d.mkRatioStat {
            title = "CPU Utilization";
            w = 6;
            unit = "short";
            usedDecimals = 2;
            totalDecimals = 0;
            thresholds = d.thresholds.percent;
            percentLegend = "%";
            usedLegend = "Active Cores";
            totalLegend = "Total Cores";
            percentExpr = ''100 - (avg(rate(node_cpu_seconds_total{host="$host",mode="idle"}[$__rate_interval])) * 100)'';
            usedExpr = ''sum(1 - rate(node_cpu_seconds_total{host="$host",mode="idle"}[$__rate_interval]))'';
            totalExpr = ''count(node_cpu_seconds_total{host="$host",mode="idle"})'';
          })
          (d.mkRatioStat {
            title = "Memory";
            w = 6;
            thresholds = d.thresholds.percent;
            percentLegend = "%";
            usedLegend = "Used";
            totalLegend = "Total";
            percentExpr = ''((node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"}) / clamp_min(node_memory_MemTotal_bytes{host="$host"}, 1)) * 100'';
            usedExpr = ''node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"}'';
            totalExpr = ''node_memory_MemTotal_bytes{host="$host"}'';
          })
          (d.mkRatioStat {
            title = "Swap";
            w = 5;
            thresholds = d.thresholds.percent;
            percentLegend = "%";
            usedLegend = "Used";
            totalLegend = "Total";
            percentExpr = ''((node_memory_SwapTotal_bytes{host="$host"} - node_memory_SwapFree_bytes{host="$host"}) / clamp_min(node_memory_SwapTotal_bytes{host="$host"}, 1)) * 100'';
            usedExpr = ''node_memory_SwapTotal_bytes{host="$host"} - node_memory_SwapFree_bytes{host="$host"}'';
            totalExpr = ''node_memory_SwapTotal_bytes{host="$host"}'';
          })
          (d.mkStat {
            title = "Temp & Clock";
            w = 4;
            textMode = "value_and_name";
            noValue = "N/A";
            targets = [
              (d.promTarget {
                refId = "A";
                expr = ''max(node_hwmon_temp_celsius{host="$host"})'';
                legend = "Max Temp";
                instant = true;
              })
              (d.promTarget {
                refId = "B";
                expr = ''avg(node_cpu_scaling_frequency_hertz{host="$host"})'';
                legend = "Avg Clock";
                instant = true;
              })
            ];
            overrides = [
              (d.overrideByRefId "A" [
                {
                  id = "unit";
                  value = "celsius";
                }
                {
                  id = "decimals";
                  value = 1;
                }
                {
                  id = "thresholds";
                  value = d.thresholds.tempC;
                }
              ])
              (d.overrideByRefId "B" [
                {
                  id = "unit";
                  value = "hertz";
                }
                {
                  id = "decimals";
                  value = 2;
                }
                {
                  id = "thresholds";
                  value = d.thresholds.neutral;
                }
              ])
            ];
          })
          (d.mkStat {
            title = "Processes & Threads";
            w = 3;
            decimals = 0;
            textMode = "value_and_name";
            targets = [
              (d.promTarget {
                refId = "A";
                expr = ''sum(namedprocess_namegroup_num_procs{host="$host"})'';
                legend = "Procs";
                instant = true;
              })
              (d.promTarget {
                refId = "B";
                expr = ''sum(namedprocess_namegroup_num_threads{host="$host"})'';
                legend = "Threads";
                instant = true;
              })
              (d.promTarget {
                refId = "C";
                expr = ''max(node_procs_running{host="$host"})'';
                legend = "Running";
                instant = true;
              })
            ];
          })
        ])
        (d.mkSection {
          title = "Processes (Grouped by Executable)";
          rows = [
            [
              (d.mkTable {
                title = "All Tracked Processes on $host";
                w = 24;
                h = 12;
                sortBy = [
                  {
                    desc = true;
                    displayName = "CPU %";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      groupname = "Process";
                      "Value #A" = "Procs";
                      "Value #B" = "Threads";
                      "Value #C" = "CPU (cores)";
                      "Value #D" = "CPU %";
                      "Value #E" = "RAM (RSS)";
                      "Value #F" = "Swapped";
                      "Value #G" = "Disk Read/s";
                      "Value #H" = "Disk Write/s";
                      "Value #I" = "Open FDs";
                    };
                    index = {
                      groupname = 0;
                      "Value #A" = 1;
                      "Value #B" = 2;
                      "Value #C" = 3;
                      "Value #D" = 4;
                      "Value #E" = 5;
                      "Value #F" = 6;
                      "Value #G" = 7;
                      "Value #H" = 8;
                      "Value #I" = 9;
                    };
                  })
                ];
                overrides = [
                  (d.decimalsOverride "Procs" 0)
                  (d.decimalsOverride "Threads" 0)
                  (d.decimalsOverride "CPU (cores)" 3)
                  (d.cellGaugeOverride {
                    colName = "CPU %";
                    thresholds = d.thresholds.percent;
                  })
                  (d.unitOverride "RAM (RSS)" "bytes")
                  (d.unitOverride "Swapped" "bytes")
                  (d.unitOverride "Disk Read/s" "Bps")
                  (d.unitOverride "Disk Write/s" "Bps")
                  (d.decimalsOverride "Open FDs" 0)
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (groupname) (namedprocess_namegroup_num_procs{host="$host",groupname=~"$proc"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (groupname) (namedprocess_namegroup_num_threads{host="$host",groupname=~"$proc"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''sum by (groupname) (rate(namedprocess_namegroup_cpu_seconds_total{host="$host",groupname=~"$proc"}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''(sum by (groupname) (rate(namedprocess_namegroup_cpu_seconds_total{host="$host",groupname=~"$proc"}[$__rate_interval])) / on() group_left() clamp_min(count(node_cpu_seconds_total{host="$host",mode="idle"}), 1)) * 100'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''sum by (groupname) (namedprocess_namegroup_memory_bytes{host="$host",groupname=~"$proc",memtype="resident"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''sum by (groupname) (namedprocess_namegroup_memory_bytes{host="$host",groupname=~"$proc",memtype="swapped"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "G";
                    expr = ''sum by (groupname) (rate(namedprocess_namegroup_read_bytes_total{host="$host",groupname=~"$proc"}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "H";
                    expr = ''sum by (groupname) (rate(namedprocess_namegroup_write_bytes_total{host="$host",groupname=~"$proc"}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "I";
                    expr = ''max by (groupname) (namedprocess_namegroup_open_filedesc{host="$host",groupname=~"$proc"})'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
            [
              (d.mkTimeseries {
                title = "Top 10 Processes — CPU (cores)";
                w = 8;
                h = 8;
                min = 0;
                expr = ''topk(10, sum by (groupname) (rate(namedprocess_namegroup_cpu_seconds_total{host="$host",groupname=~"$proc"}[$__rate_interval])))'';
                legend = "{{groupname}}";
              })
              (d.mkTimeseries {
                title = "Top 10 Processes — RAM (RSS)";
                w = 8;
                h = 8;
                unit = "bytes";
                min = 0;
                expr = ''topk(10, sum by (groupname) (namedprocess_namegroup_memory_bytes{host="$host",groupname=~"$proc",memtype="resident"}))'';
                legend = "{{groupname}}";
              })
              (d.mkTimeseries {
                title = "Top 10 Processes — Disk I/O (Read / -Write)";
                w = 8;
                h = 8;
                unit = "Bps";
                overrides = [(d.negativeYOverride "/Write/")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''topk(10, sum by (groupname) (rate(namedprocess_namegroup_read_bytes_total{host="$host",groupname=~"$proc"}[$__rate_interval])))'';
                    legend = "{{groupname}} Read";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''topk(10, sum by (groupname) (rate(namedprocess_namegroup_write_bytes_total{host="$host",groupname=~"$proc"}[$__rate_interval])))'';
                    legend = "{{groupname}} Write";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Hardware Performance (CPU Cores, Memory, Disk, Network)";
          rows = [
            [
              (d.mkBarGauge {
                title = "Per-Core CPU Utilization (%)";
                w = 10;
                h = 8;
                unit = "percent";
                min = 0;
                max = 100;
                thresholds = d.thresholds.percent;
                expr = ''100 - (avg by (cpu) (rate(node_cpu_seconds_total{host="$host",mode="idle"}[$__rate_interval])) * 100)'';
                legend = "CPU {{cpu}}";
              })
              (d.mkTimeseries {
                title = "Memory Breakdown";
                w = 14;
                h = 8;
                unit = "bytes";
                min = 0;
                stacked = true;
                overrides = [(d.dashedLineOverride "/Total/" "red")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''sum(node_memory_MemTotal_bytes{host="$host"} - node_memory_MemFree_bytes{host="$host"} - node_memory_Buffers_bytes{host="$host"} - node_memory_Cached_bytes{host="$host"} - node_memory_SReclaimable_bytes{host="$host"})'';
                    legend = "Active / Used";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''sum(node_memory_Cached_bytes{host="$host"} + node_memory_SReclaimable_bytes{host="$host"})'';
                    legend = "Page Cache";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''sum(node_memory_Buffers_bytes{host="$host"})'';
                    legend = "Buffers";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''sum(node_memory_MemFree_bytes{host="$host"})'';
                    legend = "Free";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''sum(node_memory_MemTotal_bytes{host="$host"})'';
                    legend = "Total RAM";
                  })
                ];
              })
            ]
            [
              (d.mkTimeseries {
                title = "Disk I/O Throughput (Read / -Write)";
                w = 12;
                h = 7;
                unit = "Bps";
                overrides = [(d.negativeYOverride "/Write/")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''rate(node_disk_read_bytes_total{host="$host",device!~"dm-.*|loop.*"}[$__rate_interval])'';
                    legend = "{{device}} Read";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(node_disk_written_bytes_total{host="$host",device!~"dm-.*|loop.*"}[$__rate_interval])'';
                    legend = "{{device}} Write";
                  })
                ];
              })
              (d.mkTimeseries {
                title = "Network Throughput (RX / -TX)";
                w = 12;
                h = 7;
                unit = "Bps";
                overrides = [(d.negativeYOverride "/TX/")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''rate(node_network_receive_bytes_total{host="$host",device!~"lo|veth.*|docker.*|br-.*|podman.*"}[$__rate_interval])'';
                    legend = "{{device}} RX";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(node_network_transmit_bytes_total{host="$host",device!~"lo|veth.*|docker.*|br-.*|podman.*"}[$__rate_interval])'';
                    legend = "{{device}} TX";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Systemd Units & Network Sockets";
          rows = [
            [
              (d.mkTable {
                title = "Systemd Units by Memory & CPU (Click Row for Logs)";
                w = 16;
                h = 8;
                links = [d.links.toUnitLogs];
                sortBy = [
                  {
                    desc = true;
                    displayName = "Memory";
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
                      "Value #A" = "Memory";
                      "Value #B" = "Mem Limit";
                      "Value #C" = "Limit %";
                      "Value #D" = "CPU (cores)";
                    };
                    index = {
                      host = 0;
                      slice = 1;
                      unit = 2;
                      "Value #A" = 3;
                      "Value #B" = 4;
                      "Value #C" = 5;
                      "Value #D" = 6;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Memory" "bytes")
                  (d.unitOverride "Mem Limit" "bytes")
                  (d.cellGaugeOverride {
                    colName = "Limit %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.decimalsOverride "CPU (cores)" 3)
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host, slice, unit) (container_memory_working_set_bytes{host="$host",unit!=""})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host, slice, unit) (container_spec_memory_limit_bytes{host="$host",unit!=""} > 0)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host, slice, unit) ((container_memory_working_set_bytes{host="$host",unit!=""} / (container_spec_memory_limit_bytes{host="$host",unit!=""} > 0)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host, slice, unit) (rate(container_cpu_usage_seconds_total{host="$host",unit!=""}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
              (d.mkTimeseries {
                title = "TCP Socket States";
                w = 8;
                h = 8;
                decimals = 0;
                min = 0;
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''node_sockstat_TCP_inuse{host="$host"}'';
                    legend = "In Use";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''node_sockstat_TCP_tw{host="$host"}'';
                    legend = "TIME_WAIT";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''node_sockstat_TCP_alloc{host="$host"}'';
                    legend = "Allocated";
                  })
                ];
              })
            ]
          ];
        })
      ];
    };
}
