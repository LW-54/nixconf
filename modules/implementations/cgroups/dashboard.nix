{
  internal.cgroups.mkDashboard = d:
    d.mkDashboard {
      uid = "nixconf-resources";
      title = "Resources & Allocation";
      description = "Cgroups v2 workload tiers, Linux PSI pressure stalls, CPU throttling, memory headroom, local volumes, and remote storage budgets.";
      tags = ["resources" "cgroups" "psi" "oom" "storage"];
      variables = [
        (d.vars.host {})
        (d.vars.promQuery {
          name = "slice";
          label = "Slice";
          query = ''label_values(container_memory_working_set_bytes{slice!=""}, slice)'';
        })
      ];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "CPU PSI (some %)";
            w = 4;
            unit = "percent";
            decimals = 1;
            thresholds = d.thresholds.percent;
            graphMode = "area";
            instant = false;
            noValue = "0%";
            expr = ''avg(rate(node_pressure_cpu_waiting_seconds_total{host=~"$host"}[5m])) * 100'';
            legend = "CPU PSI";
          })
          (d.mkStat {
            title = "Memory PSI (full %)";
            w = 4;
            unit = "percent";
            decimals = 1;
            thresholds = d.thresholds.percent;
            graphMode = "area";
            instant = false;
            noValue = "0%";
            expr = ''avg(rate(node_pressure_memory_stalled_seconds_total{host=~"$host"}[5m])) * 100'';
            legend = "Mem PSI";
          })
          (d.mkStat {
            title = "I/O PSI (full %)";
            w = 4;
            unit = "percent";
            decimals = 1;
            thresholds = d.thresholds.percent;
            graphMode = "area";
            instant = false;
            noValue = "0%";
            expr = ''avg(rate(node_pressure_io_stalled_seconds_total{host=~"$host"}[5m])) * 100'';
            legend = "I/O PSI";
          })
          (d.mkStat {
            title = "Throttled Units";
            w = 4;
            decimals = 0;
            thresholds = d.thresholds.zeroWarn;
            colorMode = "background";
            noValue = "0";
            expr = ''count(rate(container_cpu_cfs_throttled_periods_total{host=~"$host",unit!=""}[5m]) > 0) or vector(0)'';
            legend = "Throttled";
          })
          (d.mkStat {
            title = "OOM Kills (range)";
            w = 4;
            decimals = 0;
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            instant = false;
            noValue = "0";
            expr = ''sum(increase(container_oom_events_total{host=~"$host"}[$__range])) or vector(0)'';
            legend = "OOM Kills";
          })
          (d.mkStat {
            title = "AC Power Status";
            w = 4;
            mappings = [
              {
                type = "value";
                options = {
                  "0" = {
                    index = 0;
                    color = "orange";
                    text = "Battery";
                  };
                  "1" = {
                    index = 1;
                    color = "green";
                    text = "AC";
                  };
                };
              }
            ];
            thresholds = d.thresholds.upDown;
            colorMode = "background";
            noValue = "AC / N/A";
            expr = ''max(node_power_supply_online{host=~"$host"})'';
            legend = "Power";
          })
        ])
        (d.mkSection {
          title = "Tier & Slice Resource Allocation";
          rows = [
            [
              (d.mkTimeseries {
                title = "Memory Working Set by Slice";
                w = 12;
                unit = "bytes";
                stacked = true;
                expr = ''sum by (host, slice) (container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"})'';
                legend = "{{host}} {{slice}}.slice";
              })
              (d.mkTimeseries {
                title = "CPU Usage by Slice (cores)";
                w = 12;
                stacked = true;
                expr = ''sum by (host, slice) (rate(container_cpu_usage_seconds_total{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[5m]))'';
                legend = "{{host}} {{slice}}.slice";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Contention & Pressure (Linux PSI)";
          rows = [
            [
              (d.mkTimeseries {
                title = "Host Pressure Stall Rates (CPU / Memory / I/O)";
                w = 12;
                unit = "percent";
                min = 0;
                thresholds = d.thresholds.percent;
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''rate(node_pressure_cpu_waiting_seconds_total{host=~"$host"}[5m]) * 100'';
                    legend = "{{host}} CPU waiting";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(node_pressure_memory_stalled_seconds_total{host=~"$host"}[5m]) * 100'';
                    legend = "{{host}} Memory stalled";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''rate(node_pressure_io_stalled_seconds_total{host=~"$host"}[5m]) * 100'';
                    legend = "{{host}} I/O stalled";
                  })
                ];
              })
              (d.mkTimeseries {
                title = "Cgroup CPU Throttling (cores throttled)";
                w = 12;
                min = 0;
                noValue = "No CPU quota throttling";
                expr = ''topk(12, rate(container_cpu_cfs_throttled_seconds_total{host=~"$host",slice=~"$slice",unit!=""}[5m]) > 0)'';
                legend = "{{host}} {{unit}} ({{slice}})";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Service Right-Sizing & Headroom";
          rows = [
            [
              (d.mkBarGauge {
                title = "Memory Limit Utilization (%)";
                w = 10;
                unit = "percent";
                min = 0;
                max = 100;
                thresholds = d.thresholds.percentHigh;
                noValue = "No bounded service memory limits";
                expr = ''max by (host, slice, unit) ((container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""} / (container_spec_memory_limit_bytes{host=~"$host",slice=~"$slice",unit!=""} > 0)) * 100)'';
                legend = "{{host}} {{unit}} ({{slice}})";
              })
              (d.mkTable {
                title = "Managed Services Resource Summary";
                w = 14;
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
                      "Value #C" = "CPU (cores)";
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
                    expr = ''max by (host, slice, unit) (container_spec_memory_limit_bytes{host=~"$host",slice=~"$slice",unit!=""} > 0)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host, slice, unit) (rate(container_cpu_usage_seconds_total{host=~"$host",slice=~"$slice",unit!=""}[5m]))'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Local Volumes & Remote Storage Budgets";
          rows = [
            [
              (d.mkBarGauge {
                title = "Local Filesystem & Dedicated Volumes (%)";
                w = 12;
                unit = "percent";
                min = 0;
                max = 100;
                thresholds = d.thresholds.percentHigh;
                expr = ''max by (host, mountpoint, fstype) ((1 - (node_filesystem_avail_bytes{host=~"$host",fstype!~"ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var/run|run|sys|proc|dev).*"} / clamp_min(node_filesystem_size_bytes{host=~"$host",fstype!~"ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var/run|run|sys|proc|dev).*"}, 1))) * 100)'';
                legend = "{{host}} {{mountpoint}} ({{fstype}})";
              })
              (d.mkBarGauge {
                title = "Remote Storage Budgets Utilization (%)";
                w = 12;
                unit = "percent";
                min = 0;
                max = 100;
                thresholds = d.thresholds.percentHigh;
                noValue = "No remote storage budgets configured";
                expr = ''max by (host, slice) ((nixconf_storage_budget_used_bytes{host=~"$host"} / clamp_min(nixconf_storage_budget_limit_bytes{host=~"$host"}, 1)) * 100)'';
                legend = "{{host}} {{slice}}";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "OOM & Power Policy Events";
          rows = [
            [
              (d.mkLogs {
                title = "OOM Killer & Power Policy Journal Stream";
                w = 24;
                h = 10;
                expr = ''{job="systemd-journal", host=~"$host"} |~ "(?i)(systemd-oomd|Out of memory|Killed process|resources-power-policy|oom-kill)"'';
              })
            ]
          ];
        })
      ];
    };
}
