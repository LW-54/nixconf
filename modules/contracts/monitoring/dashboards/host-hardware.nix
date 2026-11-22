{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkHostHardwareDashboard = _:
    d.mkDashboard {
      uid = "nixconf-host-hardware";
      title = "Host & Hardware";
      description = "Single-host CPU, thermals, frequencies, memory breakdown, swap capacity, disk I/O, filesystems, network health, and systemd units.";
      tags = ["host" "hardware" "systemd" "node"];
      graphTooltip = 2;
      variables = [
        (d.vars.host {
          includeAll = false;
          multi = false;
        })
      ];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Uptime";
            w = 4;
            unit = "s";
            decimals = 0;
            expr = ''max(last_over_time(node_time_seconds{host="$host"}[5m]) - last_over_time(node_boot_time_seconds{host="$host"}[5m]))'';
            legend = "Uptime";
          })
          (d.mkStat {
            title = "Failed Units";
            w = 4;
            decimals = 0;
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            noValue = "0";
            expr = ''sum(node_systemd_unit_state{host="$host",state="failed"}) or vector(0)'';
            legend = "Failed";
          })
          (d.mkRatioStat {
            title = "CPU Usage";
            w = 8;
            unit = "short";
            usedDecimals = 2;
            totalDecimals = 0;
            thresholds = d.thresholds.percent;
            percentLegend = "%";
            usedLegend = "Active";
            totalLegend = "Cores";
            percentExpr = ''100 - (avg(rate(node_cpu_seconds_total{host="$host",mode="idle"}[$__rate_interval])) * 100)'';
            usedExpr = ''sum(1 - rate(node_cpu_seconds_total{host="$host",mode="idle"}[$__rate_interval]))'';
            totalExpr = ''count(node_cpu_seconds_total{host="$host",mode="idle"})'';
          })
          (d.mkRatioStat {
            title = "Memory Usage";
            w = 8;
            thresholds = d.thresholds.percent;
            percentLegend = "%";
            usedLegend = "Used";
            totalLegend = "Total";
            percentExpr = ''((node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"}) / clamp_min(node_memory_MemTotal_bytes{host="$host"}, 1)) * 100'';
            usedExpr = ''node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"}'';
            totalExpr = ''node_memory_MemTotal_bytes{host="$host"}'';
          })
        ])
        (d.mkRow [
          (d.mkRatioStat {
            title = "/persist Disk";
            w = 12;
            thresholds = d.thresholds.percentHigh;
            percentLegend = "%";
            usedLegend = "Used";
            totalLegend = "Total";
            percentExpr = ''((last_over_time(node_filesystem_size_bytes{host="$host",mountpoint="/persist"}[5m]) - last_over_time(node_filesystem_avail_bytes{host="$host",mountpoint="/persist"}[5m])) / clamp_min(last_over_time(node_filesystem_size_bytes{host="$host",mountpoint="/persist"}[5m]), 1)) * 100'';
            usedExpr = ''last_over_time(node_filesystem_size_bytes{host="$host",mountpoint="/persist"}[5m]) - last_over_time(node_filesystem_avail_bytes{host="$host",mountpoint="/persist"}[5m])'';
            totalExpr = ''last_over_time(node_filesystem_size_bytes{host="$host",mountpoint="/persist"}[5m])'';
          })
          (d.mkRatioStat {
            title = "/ Root tmpfs";
            w = 12;
            thresholds = d.thresholds.percentHigh;
            percentLegend = "%";
            usedLegend = "Used";
            totalLegend = "Total";
            percentExpr = ''((node_filesystem_size_bytes{host="$host",mountpoint="/",fstype="tmpfs"} - node_filesystem_avail_bytes{host="$host",mountpoint="/",fstype="tmpfs"}) / clamp_min(node_filesystem_size_bytes{host="$host",mountpoint="/",fstype="tmpfs"}, 1)) * 100'';
            usedExpr = ''node_filesystem_size_bytes{host="$host",mountpoint="/",fstype="tmpfs"} - node_filesystem_avail_bytes{host="$host",mountpoint="/",fstype="tmpfs"}'';
            totalExpr = ''node_filesystem_size_bytes{host="$host",mountpoint="/",fstype="tmpfs"}'';
          })
        ])
        (d.mkSection {
          title = "CPU, Load & Hardware Thermals";
          rows = [
            [
              (d.mkTimeseries {
                title = "CPU Utilization by Mode";
                w = 14;
                unit = "percent";
                min = 0;
                max = 100;
                stacked = true;
                overrides = d.cpuModeColorOverrides {};
                expr = ''avg by (mode) (rate(node_cpu_seconds_total{host="$host",mode!="idle"}[$__rate_interval])) * 100'';
                legend = "{{mode}}";
              })
              (d.mkTimeseries {
                title = "Load Average & CPU Cores";
                w = 10;
                min = 0;
                overrides = [(d.dashedLineOverride "/cores/" "red")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''node_load1{host="$host"}'';
                    legend = "1m";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''node_load5{host="$host"}'';
                    legend = "5m";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''node_load15{host="$host"}'';
                    legend = "15m";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''count(node_cpu_seconds_total{host="$host",mode="idle"})'';
                    legend = "cores";
                  })
                ];
              })
            ]
            [
              (d.mkTimeseries {
                title = "Hardware Temperatures";
                w = 12;
                h = 6;
                unit = "celsius";
                noValue = "No hwmon temperature sensors";
                thresholds = d.thresholds.tempC;
                expr = ''max by (chip, sensor) (node_hwmon_temp_celsius{host="$host"})'';
                legend = "{{chip}} {{sensor}}";
              })
              (d.mkTimeseries {
                title = "CPU Core Frequencies";
                w = 12;
                h = 6;
                unit = "hertz";
                noValue = "No cpufreq telemetry";
                expr = ''node_cpu_scaling_frequency_hertz{host="$host"}'';
                legend = "CPU {{cpu}}";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Memory & Swap";
          rows = [
            [
              (d.mkTimeseries {
                title = "Memory Breakdown";
                w = 14;
                unit = "bytes";
                min = 0;
                stacked = true;
                overrides = [(d.dashedLineOverride "/Total/" "red")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''sum(node_memory_MemTotal_bytes{host="$host"} - node_memory_MemFree_bytes{host="$host"} - node_memory_Buffers_bytes{host="$host"} - node_memory_Cached_bytes{host="$host"} - node_memory_SReclaimable_bytes{host="$host"})'';
                    legend = "Used";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''sum(node_memory_Cached_bytes{host="$host"} + node_memory_SReclaimable_bytes{host="$host"})'';
                    legend = "Cached";
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
                    legend = "Total";
                  })
                ];
              })
              (d.mkTimeseries {
                title = "Memory & Swap Pressure (%)";
                w = 10;
                unit = "percent";
                min = 0;
                max = 100;
                thresholds = d.thresholds.percent;
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''((node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"}) / clamp_min(node_memory_MemTotal_bytes{host="$host"}, 1)) * 100'';
                    legend = "RAM %";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''((node_memory_SwapTotal_bytes{host="$host"} - node_memory_SwapFree_bytes{host="$host"}) / clamp_min(node_memory_SwapTotal_bytes{host="$host"}, 1)) * 100'';
                    legend = "Swap %";
                  })
                ];
              })
            ]
            [
              (d.mkTable {
                title = "Memory & Swap Capacity";
                w = 24;
                h = 5;
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      "Value #A" = "RAM Used";
                      "Value #B" = "RAM Total";
                      "Value #C" = "RAM %";
                      "Value #D" = "Swap Used";
                      "Value #E" = "Swap Total";
                      "Value #F" = "Swap %";
                    };
                    index = {
                      host = 0;
                      "Value #A" = 1;
                      "Value #B" = 2;
                      "Value #C" = 3;
                      "Value #D" = 4;
                      "Value #E" = 5;
                      "Value #F" = 6;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "RAM Used" "bytes")
                  (d.unitOverride "RAM Total" "bytes")
                  (d.cellGaugeOverride {
                    colName = "RAM %";
                    thresholds = d.thresholds.percent;
                  })
                  (d.unitOverride "Swap Used" "bytes")
                  (d.unitOverride "Swap Total" "bytes")
                  (d.cellGaugeOverride {
                    colName = "Swap %";
                    thresholds = d.thresholds.percent;
                  })
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host) (node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host) (node_memory_MemTotal_bytes{host="$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host) (((node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"}) / clamp_min(node_memory_MemTotal_bytes{host="$host"}, 1)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host) (node_memory_SwapTotal_bytes{host="$host"} - node_memory_SwapFree_bytes{host="$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''max by (host) (node_memory_SwapTotal_bytes{host="$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''max by (host) (((node_memory_SwapTotal_bytes{host="$host"} - node_memory_SwapFree_bytes{host="$host"}) / clamp_min(node_memory_SwapTotal_bytes{host="$host"}, 1)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Storage & Network";
          rows = [
            [
              (d.mkStorageTable {
                title = "Local Filesystems (Usage & Capacity)";
                w = 13;
                h = 8;
                selector = ''host="$host",fstype!~"ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var|tmp|run|sys|proc|dev).*"'';
              })
              (d.mkTable {
                title = "Top Local Directories & Service Storage";
                w = 11;
                h = 8;
                links = [d.links.toStorageAtlas];
                noValue = "Awaiting first nixconf-storage-scan run";
                sortBy = [
                  {
                    desc = true;
                    displayName = "Size";
                  }
                ];
                transformations = [
                  (d.organizeTransform {
                    exclude = ["Time" "__name__" "host" "instance" "job" "parent" "depth"];
                    rename = {
                      category = "Category";
                      service = "Service";
                      path = "Path";
                      Value = "Size";
                    };
                    index = {
                      category = 0;
                      service = 1;
                      path = 2;
                      Value = 3;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Size" "bytes")
                ];
                expr = ''topk(15, max by (category, service, path) (nixconf_storage_dir_bytes{host="$host",depth="1"}))'';
              })
            ]
            [
              (d.mkTimeseries {
                title = "Disk I/O Throughput (Read / -Write)";
                w = 24;
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
            ]
            [
              (d.mkTimeseries {
                title = "Network Throughput (RX / -TX)";
                w = 14;
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
              (d.mkTimeseries {
                title = "Network Errors & Drops";
                w = 10;
                unit = "pps";
                min = 0;
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''rate(node_network_receive_errs_total{host="$host",device!="lo"}[$__rate_interval]) + rate(node_network_transmit_errs_total{host="$host",device!="lo"}[$__rate_interval])'';
                    legend = "{{device}} errs";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(node_network_receive_drop_total{host="$host",device!="lo"}[$__rate_interval]) + rate(node_network_transmit_drop_total{host="$host",device!="lo"}[$__rate_interval])'';
                    legend = "{{device}} drops";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Long-Term Baselines, Growth & Top Background Operations ($__range)";
          rows = [
            [
              (d.mkStat {
                title = "CPU Avg / P95 / Max ($__range)";
                w = 8;
                unit = "percent";
                decimals = 1;
                textMode = "value_and_name";
                thresholds = d.thresholds.percent;
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''avg(avg_over_time(nixconf:host_cpu_utilization_percent:rate5m{host="$host"}[$__range]))'';
                    legend = "Avg";
                    instant = true;
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''avg(quantile_over_time(0.95, nixconf:host_cpu_utilization_percent:rate5m{host="$host"}[$__range]))'';
                    legend = "P95";
                    instant = true;
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max(max_over_time(nixconf:host_cpu_utilization_percent:rate5m{host="$host"}[$__range]))'';
                    legend = "Max";
                    instant = true;
                  })
                ];
              })
              (d.mkStat {
                title = "RAM Avg / P95 / Max ($__range)";
                w = 8;
                unit = "bytes";
                decimals = 1;
                textMode = "value_and_name";
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''avg(avg_over_time((node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"})[$__range:]))'';
                    legend = "Avg";
                    instant = true;
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max(quantile_over_time(0.95, (node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"})[$__range:]))'';
                    legend = "P95";
                    instant = true;
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max(max_over_time((node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"})[$__range:]))'';
                    legend = "Max";
                    instant = true;
                  })
                ];
              })
              (d.mkStat {
                title = "Daily Growth Rates ($__range)";
                w = 8;
                unit = "bytes";
                decimals = 1;
                textMode = "value_and_name";
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max(deriv((node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"})[$__range:])) * 86400'';
                    legend = "RAM / day";
                    instant = true;
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max(deriv((node_filesystem_size_bytes{host="$host",mountpoint="/persist"} - node_filesystem_avail_bytes{host="$host",mountpoint="/persist"})[$__range:])) * 86400'';
                    legend = "/persist / day";
                    instant = true;
                  })
                ];
              })
            ]
            [
              (d.mkTable {
                title = "Top 12 Background Operations on $host ($__range)";
                w = 24;
                h = 8;
                logs = true;
                noValue = "No completed systemd operation logs in selected range";
                sortBy = [
                  {
                    desc = true;
                    displayName = "Total CPU (s)";
                  }
                ];
                transformations = [
                  (d.organizeTransform {
                    rename = {
                      op_unit = "Operation";
                      runs = "Runs";
                      total_cpu_s = "Total CPU (s)";
                      avg_wall_s = "Avg Wall (s)";
                      p95_wall_s = "P95 Wall (s)";
                      max_mem_bytes = "Max RAM Peak";
                      total_io_read_bytes = "Disk Read";
                      total_io_write_bytes = "Disk Write";
                    };
                    index = {
                      op_unit = 0;
                      runs = 1;
                      total_cpu_s = 2;
                      avg_wall_s = 3;
                      p95_wall_s = 4;
                      max_mem_bytes = 5;
                      total_io_read_bytes = 6;
                      total_io_write_bytes = 7;
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
                  (d.unitOverride "Disk Read" "bytes")
                  (d.unitOverride "Disk Write" "bytes")
                ];
                expr = ''job:="systemd-journal" host:="$host" "Consumed" "CPU time" | ${d.systemdOpsParsePipe} | stats by (op_unit) count() as runs, sum(cpu_s) as total_cpu_s, avg(wall_s) as avg_wall_s, quantile(0.95, wall_s) as p95_wall_s, max(mem_peak_bytes) as max_mem_bytes, sum(io_read_bytes) as total_io_read_bytes, sum(io_write_bytes) as total_io_write_bytes | sort by (total_cpu_s) desc | limit 12'';
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Systemd Services (Click Row for Unit Logs)";
          rows = [
            [
              (d.mkSystemdUnitsTable {
                title = "Watched Units Health";
                w = 12;
                expr = ''node_systemd_unit_state{host="$host",watched="true"} == 1'';
              })
              (d.mkSystemdUnitsTable {
                title = "Failed Systemd Units";
                w = 12;
                noValue = "No failed units";
                expr = ''node_systemd_unit_state{host="$host",state="failed"} == 1'';
              })
            ]
          ];
        })
      ];
    };
}
