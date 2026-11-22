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
            expr = ''avg(rate(node_pressure_cpu_waiting_seconds_total{host=~"$host"}[$__rate_interval])) * 100'';
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
            expr = ''avg(rate(node_pressure_memory_stalled_seconds_total{host=~"$host"}[$__rate_interval])) * 100'';
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
            expr = ''avg(rate(node_pressure_io_stalled_seconds_total{host=~"$host"}[$__rate_interval])) * 100'';
            legend = "I/O PSI";
          })
          (d.mkStat {
            title = "Throttled Units";
            w = 4;
            decimals = 0;
            thresholds = d.thresholds.zeroWarn;
            colorMode = "background";
            noValue = "0";
            expr = ''count(rate(container_cpu_cfs_throttled_periods_total{host=~"$host",unit!=""}[$__rate_interval]) > 0) or vector(0)'';
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
            noValue = "N/A (Mains Only)";
            expr = ''max(last_over_time(node_power_supply_online{host=~"$host"}[5m]))'';
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
                overrides = [(d.dashedLineOverride "/Host Total/" "red")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''sum by (host, slice) (container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"})'';
                    legend = "{{host}} {{slice}}.slice";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''sum(node_memory_MemTotal_bytes{host=~"$host"})'';
                    legend = "Host Total RAM";
                  })
                ];
              })
              (d.mkTimeseries {
                title = "CPU Usage by Slice (cores)";
                w = 12;
                stacked = true;
                overrides = [(d.dashedLineOverride "/Host Total/" "red")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''sum by (host, slice) (rate(container_cpu_usage_seconds_total{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$slice"}[$__rate_interval]))'';
                    legend = "{{host}} {{slice}}.slice";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''count(node_cpu_seconds_total{host=~"$host",mode="idle"})'';
                    legend = "Host Total Cores";
                  })
                ];
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
                    expr = ''rate(node_pressure_cpu_waiting_seconds_total{host=~"$host"}[$__rate_interval]) * 100'';
                    legend = "{{host}} CPU waiting";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(node_pressure_memory_stalled_seconds_total{host=~"$host"}[$__rate_interval]) * 100'';
                    legend = "{{host}} Memory stalled";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''rate(node_pressure_io_stalled_seconds_total{host=~"$host"}[$__rate_interval]) * 100'';
                    legend = "{{host}} I/O stalled";
                  })
                ];
              })
              (d.mkTimeseries {
                title = "Cgroup CPU Throttling (cores throttled)";
                w = 12;
                min = 0;
                noValue = "No CPU quota throttling";
                expr = ''topk(12, rate(container_cpu_cfs_throttled_seconds_total{host=~"$host",slice=~"$slice",unit!=""}[$__rate_interval]) > 0)'';
                legend = "{{host}} {{unit}} ({{slice}})";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Service Right-Sizing & Headroom";
          rows = [
            [
              (d.mkTable {
                title = "Managed Services, Mounts & Containers — Memory, P95, Limits & CPU";
                w = 24;
                h = 10;
                links = [
                  d.links.toUnitLogs
                  d.links.toTrendsExplorer
                  d.links.toCapacityAnalytics
                ];
                sortBy = [
                  {
                    desc = true;
                    displayName = "Limit %";
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
                      "Value #B" = "P95 ($__range)";
                      "Value #C" = "Alloc High";
                      "Value #D" = "Alloc Max";
                      "Value #E" = "Headroom";
                      "Value #F" = "Limit %";
                      "Value #G" = "CPU (cores)";
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
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Memory" "bytes")
                  (d.unitOverride "P95 ($__range)" "bytes")
                  (d.unitOverride "Alloc High" "bytes")
                  (d.unitOverride "Alloc Max" "bytes")
                  (d.unitOverride "Headroom" "bytes")
                  (d.cellGaugeOverride {
                    colName = "Limit %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.decimalsOverride "CPU (cores)" 2)
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
                    expr = ''max by (host, slice, unit) (quantile_over_time(0.95, container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}[$__range]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host, slice, unit) (nixconf:unit_memory_high_bytes{host=~"$host",slice=~"$slice"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host, slice, unit) (nixconf:unit_memory_max_bytes{host=~"$host",slice=~"$slice"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''max by (host, slice, unit) (clamp_min(nixconf:unit_memory_max_bytes{host=~"$host",slice=~"$slice"} - container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""}, 0))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''max by (host, slice, unit) ((container_memory_working_set_bytes{host=~"$host",slice=~"$slice",unit!=""} / clamp_min(nixconf:unit_memory_max_bytes{host=~"$host",slice=~"$slice"}, 1)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "G";
                    expr = ''max by (host, slice, unit) (rate(container_cpu_usage_seconds_total{host=~"$host",slice=~"$slice",unit!=""}[$__rate_interval]))'';
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
              (d.mkStorageTable {
                title = "Local Filesystems & Dedicated Volumes";
                w = 24;
                h = 8;
                selector = ''host=~"$host",fstype!~"ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var/run|run|sys|proc|dev).*"'';
              })
            ]
            [
              (d.mkTable {
                title = "Remote Storage Budgets";
                w = 24;
                h = 6;
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
                      "Value #B" = "Available";
                      "Value #C" = "Limit";
                      "Value #D" = "Objects";
                      "Value #E" = "Usage %";
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
                  (d.unitOverride "Available" "bytes")
                  (d.unitOverride "Limit" "bytes")
                  (d.decimalsOverride "Objects" 0)
                  (d.cellGaugeOverride {
                    colName = "Usage %";
                    thresholds = d.thresholds.percentHigh;
                  })
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
                    expr = ''max by (host, slice) (clamp_min(nixconf_storage_budget_limit_bytes{host=~"$host"} - nixconf_storage_budget_used_bytes{host=~"$host"}, 0))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host, slice) (nixconf_storage_budget_limit_bytes{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host, slice) (nixconf_storage_budget_objects{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''max by (host, slice) ((nixconf_storage_budget_used_bytes{host=~"$host"} / clamp_min(nixconf_storage_budget_limit_bytes{host=~"$host"}, 1)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                ];
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
                expr = ''job:="systemd-journal" host:in($host) _msg:~"(?i)(systemd-oomd|Out of memory|Killed process|resources-power-policy|oom-kill)"'';
              })
            ]
          ];
        })
      ];
    };
}
