# Host & Systemd Overview dashboard definition for primitive.host monitoring.
{
  _module.args.mkHostOverviewDashboard = d:
    d.mkDashboard {
      uid = "nixconf-host-overview";
      title = "Host & Systemd Overview";
      description = "Fleet-wide host CPU, memory, swap, disk I/O, filesystem capacity, network traffic, and systemd unit health.";
      tags = ["host" "systemd" "node"];
      variables = [(d.vars.host {})];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Uptime";
            w = 4;
            unit = "s";
            decimals = 0;
            expr = ''max by (host) (node_time_seconds{host=~"$host"} - node_boot_time_seconds{host=~"$host"})'';
            legend = "{{host}}";
          })
          (d.mkStat {
            title = "CPU Usage";
            w = 4;
            unit = "percent";
            decimals = 1;
            thresholds = d.thresholds.percent;
            graphMode = "area";
            expr = ''100 - (avg by (host) (rate(node_cpu_seconds_total{host=~"$host",mode="idle"}[5m])) * 100)'';
            legend = "{{host}}";
          })
          (d.mkStat {
            title = "Memory Usage";
            w = 4;
            unit = "percent";
            decimals = 1;
            thresholds = d.thresholds.percent;
            graphMode = "area";
            expr = ''(1 - (node_memory_MemAvailable_bytes{host=~"$host"} / node_memory_MemTotal_bytes{host=~"$host"})) * 100'';
            legend = "{{host}}";
          })
          (d.mkStat {
            title = "/persist Disk";
            w = 4;
            unit = "percent";
            decimals = 1;
            thresholds = d.thresholds.percentHigh;
            expr = ''max by (host) ((1 - (node_filesystem_avail_bytes{host=~"$host",mountpoint="/persist"} / node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"})) * 100)'';
            legend = "{{host}}";
          })
          (d.mkStat {
            title = "/ Root tmpfs";
            w = 4;
            unit = "percent";
            decimals = 1;
            thresholds = d.thresholds.percentHigh;
            expr = ''max by (host) ((1 - (node_filesystem_avail_bytes{host=~"$host",mountpoint="/",fstype="tmpfs"} / node_filesystem_size_bytes{host=~"$host",mountpoint="/",fstype="tmpfs"})) * 100)'';
            legend = "{{host}}";
          })
          (d.mkStat {
            title = "Failed Units";
            w = 4;
            decimals = 0;
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            expr = ''sum(node_systemd_unit_state{host=~"$host",state="failed"}) or vector(0)'';
            legend = "Failed";
          })
        ])
        (d.mkSection {
          title = "CPU & System Load";
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
                expr = ''avg by (mode) (rate(node_cpu_seconds_total{host=~"$host",mode!="idle"}[5m])) * 100'';
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
                    expr = ''node_load1{host=~"$host"}'';
                    legend = "{{host}} 1m";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''node_load5{host=~"$host"}'';
                    legend = "{{host}} 5m";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''node_load15{host=~"$host"}'';
                    legend = "{{host}} 15m";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''count by (host) (node_cpu_seconds_total{host=~"$host",mode="idle"})'';
                    legend = "{{host}} cores";
                  })
                ];
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
                    expr = ''sum(node_memory_MemTotal_bytes{host=~"$host"} - node_memory_MemFree_bytes{host=~"$host"} - node_memory_Buffers_bytes{host=~"$host"} - node_memory_Cached_bytes{host=~"$host"} - node_memory_SReclaimable_bytes{host=~"$host"})'';
                    legend = "Used";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''sum(node_memory_Cached_bytes{host=~"$host"} + node_memory_SReclaimable_bytes{host=~"$host"})'';
                    legend = "Cached";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''sum(node_memory_Buffers_bytes{host=~"$host"})'';
                    legend = "Buffers";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''sum(node_memory_MemFree_bytes{host=~"$host"})'';
                    legend = "Free";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''sum(node_memory_MemTotal_bytes{host=~"$host"})'';
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
                    expr = ''(1 - (node_memory_MemAvailable_bytes{host=~"$host"} / node_memory_MemTotal_bytes{host=~"$host"})) * 100'';
                    legend = "{{host}} RAM";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''(1 - (node_memory_SwapFree_bytes{host=~"$host"} / clamp_min(node_memory_SwapTotal_bytes{host=~"$host"}, 1))) * 100'';
                    legend = "{{host}} Swap";
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
              (d.mkBarGauge {
                title = "Local Filesystem Usage (%)";
                w = 12;
                unit = "percent";
                min = 0;
                max = 100;
                thresholds = d.thresholds.percentHigh;
                expr = ''max by (host, mountpoint, fstype) ((1 - (node_filesystem_avail_bytes{host=~"$host",fstype!~"ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var|tmp|run|sys|proc|dev).*"} / node_filesystem_size_bytes{host=~"$host",fstype!~"ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var|tmp|run|sys|proc|dev).*"})) * 100)'';
                legend = "{{host}} {{mountpoint}} ({{fstype}})";
              })
              (d.mkTimeseries {
                title = "Disk I/O Throughput (Read / -Write)";
                w = 12;
                unit = "Bps";
                overrides = [(d.negativeYOverride "/Write/")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''rate(node_disk_read_bytes_total{host=~"$host",device!~"dm-.*|loop.*"}[5m])'';
                    legend = "{{host}} {{device}} Read";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(node_disk_written_bytes_total{host=~"$host",device!~"dm-.*|loop.*"}[5m])'';
                    legend = "{{host}} {{device}} Write";
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
                    expr = ''rate(node_network_receive_bytes_total{host=~"$host",device!~"lo|veth.*|docker.*|br-.*|podman.*"}[5m])'';
                    legend = "{{host}} {{device}} RX";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(node_network_transmit_bytes_total{host=~"$host",device!~"lo|veth.*|docker.*|br-.*|podman.*"}[5m])'';
                    legend = "{{host}} {{device}} TX";
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
                    expr = ''rate(node_network_receive_errs_total{host=~"$host",device!="lo"}[5m]) + rate(node_network_transmit_errs_total{host=~"$host",device!="lo"}[5m])'';
                    legend = "{{host}} {{device}} errs";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(node_network_receive_drop_total{host=~"$host",device!="lo"}[5m]) + rate(node_network_transmit_drop_total{host=~"$host",device!="lo"}[5m])'';
                    legend = "{{host}} {{device}} drops";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Systemd Services";
          rows = [
            [
              (d.mkSystemdUnitsTable {
                title = "Watched Units Health";
                w = 12;
                expr = ''node_systemd_unit_state{host=~"$host",watched="true"} == 1'';
              })
              (d.mkSystemdUnitsTable {
                title = "Failed Systemd Units";
                w = 12;
                noValue = "No failed units";
                expr = ''node_systemd_unit_state{host=~"$host",state="failed"} == 1'';
              })
            ]
          ];
        })
      ];
    };
}
