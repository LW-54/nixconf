{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkTimeMachineDashboard = _:
    d.mkDashboard {
      uid = "nixconf-time-machine";
      title = "Incident Time Machine";
      description = "Point-in-time forensic reconstruction: scrub or zoom the Master Timeline Strip to inspect exact process, service, pressure, filesystem, and log states at any moment.";
      tags = ["forensics" "time-machine" "incident" "logs"];
      refresh = "off";
      timeFrom = "now-6h";
      graphTooltip = 2;
      variables = [
        (d.vars.host {
          includeAll = false;
          multi = false;
        })
        (d.vars.textbox {
          name = "search";
          label = "Log Filter (LogsQL)";
          default = "";
        })
      ];
      sections = [
        (d.mkSection {
          title = "Master Timeline Strip (Drag-Zoom Any Spike or Use Time Step Arrows)";
          rows = [
            [
              (d.mkTimeseries {
                title = "System Pulse & Contention (%)";
                w = 24;
                h = 6;
                unit = "percent";
                min = 0;
                thresholds = d.thresholds.percent;
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''100 - (avg(rate(node_cpu_seconds_total{host="$host",mode="idle"}[$__rate_interval])) * 100)'';
                    legend = "CPU %";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''((node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"}) / clamp_min(node_memory_MemTotal_bytes{host="$host"}, 1)) * 100'';
                    legend = "Memory %";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''rate(node_pressure_cpu_waiting_seconds_total{host="$host"}[$__rate_interval]) * 100'';
                    legend = "CPU PSI %";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''rate(node_pressure_memory_stalled_seconds_total{host="$host"}[$__rate_interval]) * 100'';
                    legend = "Memory PSI %";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''rate(node_pressure_io_stalled_seconds_total{host="$host"}[$__rate_interval]) * 100'';
                    legend = "I/O PSI %";
                  })
                ];
              })
            ]
            [
              (d.mkTimeseries {
                title = "Error & Warning Log Bursts";
                w = 24;
                h = 4;
                logs = true;
                drawStyle = "bars";
                stacked = true;
                legendMode = "list";
                overrides = d.logLevelColorOverrides {};
                expr = ''job:="systemd-journal" host:="$host" level:in("emerg","alert","crit","err","error","warning") | stats by (level) count() as lines'';
                legend = "{{level}}";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Snapshot State at Selected Window End ($__to)";
          rows = [
            [
              (d.mkRatioStat {
                title = "CPU at Snapshot";
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
                title = "Memory at Snapshot";
                w = 6;
                thresholds = d.thresholds.percent;
                percentLegend = "%";
                usedLegend = "Used";
                totalLegend = "Total";
                percentExpr = ''((node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"}) / clamp_min(node_memory_MemTotal_bytes{host="$host"}, 1)) * 100'';
                usedExpr = ''node_memory_MemTotal_bytes{host="$host"} - node_memory_MemAvailable_bytes{host="$host"}'';
                totalExpr = ''node_memory_MemTotal_bytes{host="$host"}'';
              })
              (d.mkStat {
                title = "PSI at Snapshot (%)";
                w = 4;
                unit = "percent";
                decimals = 1;
                textMode = "value_and_name";
                thresholds = d.thresholds.percent;
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''rate(node_pressure_cpu_waiting_seconds_total{host="$host"}[$__rate_interval]) * 100'';
                    legend = "CPU";
                    instant = true;
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(node_pressure_memory_stalled_seconds_total{host="$host"}[$__rate_interval]) * 100'';
                    legend = "Mem";
                    instant = true;
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''rate(node_pressure_io_stalled_seconds_total{host="$host"}[$__rate_interval]) * 100'';
                    legend = "I/O";
                    instant = true;
                  })
                ];
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
              (d.mkStat {
                title = "Active Alerts";
                w = 4;
                decimals = 0;
                thresholds = d.thresholds.zeroOk;
                colorMode = "background";
                noValue = "0";
                expr = ''count(ALERTS{host="$host",alertstate="firing"}) or vector(0)'';
                legend = "Firing";
              })
            ]
            [
              (d.mkTable {
                title = "Top Processes at Snapshot";
                w = 14;
                h = 8;
                sortBy = [
                  {
                    desc = true;
                    displayName = "RAM (RSS)";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      groupname = "Process";
                      "Value #A" = "Procs";
                      "Value #B" = "CPU (cores)";
                      "Value #C" = "RAM (RSS)";
                      "Value #D" = "Disk Read/s";
                      "Value #E" = "Disk Write/s";
                      "Value #F" = "Open FDs";
                    };
                    index = {
                      groupname = 0;
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
                  (d.decimalsOverride "Procs" 0)
                  (d.decimalsOverride "CPU (cores)" 3)
                  (d.unitOverride "RAM (RSS)" "bytes")
                  (d.unitOverride "Disk Read/s" "Bps")
                  (d.unitOverride "Disk Write/s" "Bps")
                  (d.decimalsOverride "Open FDs" 0)
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (groupname) (namedprocess_namegroup_num_procs{host="$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''sum by (groupname) (rate(namedprocess_namegroup_cpu_seconds_total{host="$host"}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''topk(25, sum by (groupname) (namedprocess_namegroup_memory_bytes{host="$host",memtype="resident"}))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''sum by (groupname) (rate(namedprocess_namegroup_read_bytes_total{host="$host"}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''sum by (groupname) (rate(namedprocess_namegroup_write_bytes_total{host="$host"}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''max by (groupname) (namedprocess_namegroup_open_filedesc{host="$host"})'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
              (d.mkSystemdUnitsTable {
                title = "Failed Units at Snapshot";
                w = 10;
                h = 8;
                noValue = "No failed systemd units";
                expr = ''node_systemd_unit_state{host="$host",state="failed"} == 1'';
              })
            ]
            [
              (d.mkTable {
                title = "Services & Cgroup Limits at Snapshot";
                w = 12;
                h = 7;
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
                    };
                    index = {
                      host = 0;
                      slice = 1;
                      unit = 2;
                      "Value #A" = 3;
                      "Value #B" = 4;
                      "Value #C" = 5;
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
                ];
              })
              (d.mkStorageTable {
                title = "Filesystems at Snapshot";
                w = 12;
                h = 7;
                selector = ''host="$host",fstype!~"ramfs|squashfs|overlay",mountpoint!~"/(etc|nix|var/run|run|sys|proc|dev).*"'';
                groupBy = ["host" "mountpoint"];
                columns = {
                  host = "Host";
                  mountpoint = "Mountpoint";
                };
                columnOrder = ["host" "mountpoint"];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Correlated Subsystem Curves";
          rows = [
            [
              (d.mkTimeseries {
                title = "CPU Utilization by Mode";
                w = 12;
                h = 7;
                unit = "percent";
                min = 0;
                max = 100;
                stacked = true;
                overrides = d.cpuModeColorOverrides {};
                expr = ''avg by (mode) (rate(node_cpu_seconds_total{host="$host",mode!="idle"}[$__rate_interval])) * 100'';
                legend = "{{mode}}";
              })
              (d.mkTimeseries {
                title = "Memory Breakdown";
                w = 12;
                h = 7;
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
          title = "Synchronized Journald Logs";
          rows = [
            [
              (d.mkLogs {
                title = "Journald Stream Locked to Window ($host)";
                w = 24;
                h = 12;
                expr = ''job:="systemd-journal" host:="$host" $search'';
              })
            ]
          ];
        })
      ];
    };
}
