{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkFleetOverviewDashboard = _:
    d.mkDashboard {
      uid = "nixconf-fleet-overview";
      title = "Fleet Command Center";
      description = "Fleet-wide operational pulse: online hosts, alerts, endpoint probes, backups, compute capacity, and storage budgets.";
      tags = ["fleet" "overview" "command"];
      variables = [(d.vars.host {})];
      sections = [
        (d.mkRow [
          (d.mkRatioStat {
            title = "Hosts Online";
            w = 4;
            unit = "short";
            usedDecimals = 0;
            totalDecimals = 0;
            thresholds = d.thresholds.percent100Ok;
            colorMode = "background";
            percentLegend = "Online %";
            usedLegend = "Online";
            totalLegend = "Known";
            percentExpr = ''(count((time() - max by (host) (timestamp(node_uname_info{host=~"$host"}))) < bool 120) / clamp_min(count(max by (host) (last_over_time(node_uname_info{host=~"$host"}[7d]))), 1)) * 100'';
            usedExpr = ''count(((time() - max by (host) (timestamp(node_uname_info{host=~"$host"}))) < bool 120) == 1) or vector(0)'';
            totalExpr = ''count(max by (host) (last_over_time(node_uname_info{host=~"$host"}[7d]))) or vector(0)'';
          })
          (d.mkStat {
            title = "Firing Alerts";
            w = 3;
            decimals = 0;
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            noValue = "0";
            expr = ''count(ALERTS{alertstate="firing",host=~"$host"}) or vector(0)'';
            legend = "Firing";
          })
          (d.mkRatioStat {
            title = "Endpoint Probes";
            w = 5;
            unit = "short";
            usedDecimals = 0;
            totalDecimals = 0;
            thresholds = d.thresholds.percent100Ok;
            colorMode = "background";
            percentLegend = "Up %";
            usedLegend = "Up";
            totalLegend = "Total";
            percentExpr = ''(avg(probe_success) or vector(1)) * 100'';
            usedExpr = ''sum(probe_success == 1) or vector(0)'';
            totalExpr = ''count(probe_success) or vector(0)'';
          })
          (d.mkStat {
            title = "Failed Units";
            w = 3;
            decimals = 0;
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            noValue = "0";
            expr = ''sum(node_systemd_unit_state{host=~"$host",state="failed"}) or vector(0)'';
            legend = "Failed";
          })
          (d.mkRatioStat {
            title = "Fleet RAM";
            w = 4;
            thresholds = d.thresholds.percent;
            percentLegend = "%";
            usedLegend = "Used";
            totalLegend = "Total";
            percentExpr = ''((sum(node_memory_MemTotal_bytes{host=~"$host"}) - sum(node_memory_MemAvailable_bytes{host=~"$host"})) / clamp_min(sum(node_memory_MemTotal_bytes{host=~"$host"}), 1)) * 100'';
            usedExpr = ''sum(node_memory_MemTotal_bytes{host=~"$host"} - node_memory_MemAvailable_bytes{host=~"$host"})'';
            totalExpr = ''sum(node_memory_MemTotal_bytes{host=~"$host"})'';
          })
          (d.mkRatioStat {
            title = "Fleet /persist";
            w = 5;
            thresholds = d.thresholds.percentHigh;
            percentLegend = "%";
            usedLegend = "Used";
            totalLegend = "Total";
            percentExpr = ''((sum(last_over_time(node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"}[5m])) - sum(last_over_time(node_filesystem_avail_bytes{host=~"$host",mountpoint="/persist"}[5m]))) / clamp_min(sum(last_over_time(node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"}[5m])), 1)) * 100'';
            usedExpr = ''sum(last_over_time(node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"}[5m]) - last_over_time(node_filesystem_avail_bytes{host=~"$host",mountpoint="/persist"}[5m]))'';
            totalExpr = ''sum(last_over_time(node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"}[5m]))'';
          })
        ])
        (d.mkSection {
          title = "Host Matrix (Click Any Row to Drill Down)";
          rows = [
            [
              (d.mkTable {
                title = "Hosts Capacity & Health";
                w = 24;
                h = 6;
                links = [
                  d.links.toTaskManager
                  d.links.toTimeMachine
                  d.links.toHostHardware
                  d.links.toCapacityAnalytics
                  d.links.toStorageAtlas
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      "Value #A" = "Status";
                      "Value #B" = "Uptime";
                      "Value #C" = "CPU (cores)";
                      "Value #D" = "CPU %";
                      "Value #E" = "RAM Used";
                      "Value #F" = "RAM Total";
                      "Value #G" = "RAM %";
                      "Value #H" = "/persist Used";
                      "Value #I" = "/persist Total";
                      "Value #J" = "/persist %";
                      "Value #K" = "Failed";
                    };
                    index = {
                      host = 0;
                      "Value #A" = 1;
                      "Value #B" = 2;
                      "Value #C" = 3;
                      "Value #D" = 4;
                      "Value #E" = 5;
                      "Value #F" = 6;
                      "Value #G" = 7;
                      "Value #H" = 8;
                      "Value #I" = 9;
                      "Value #J" = 10;
                      "Value #K" = 11;
                    };
                  })
                ];
                overrides = [
                  (d.cellBadgeOverride "Status" d.mappings.upDown)
                  (d.unitOverride "Uptime" "s")
                  (d.decimalsOverride "Uptime" 0)
                  (d.decimalsOverride "CPU (cores)" 2)
                  (d.cellGaugeOverride {
                    colName = "CPU %";
                    thresholds = d.thresholds.percent;
                  })
                  (d.unitOverride "RAM Used" "bytes")
                  (d.unitOverride "RAM Total" "bytes")
                  (d.cellGaugeOverride {
                    colName = "RAM %";
                    thresholds = d.thresholds.percent;
                  })
                  (d.unitOverride "/persist Used" "bytes")
                  (d.unitOverride "/persist Total" "bytes")
                  (d.cellGaugeOverride {
                    colName = "/persist %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.decimalsOverride "Failed" 0)
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host) ((time() - timestamp(node_uname_info{host=~"$host"})) < bool 120)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host) (last_over_time(node_time_seconds{host=~"$host"}[5m]) - last_over_time(node_boot_time_seconds{host=~"$host"}[5m]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''sum by (host) (1 - rate(node_cpu_seconds_total{host=~"$host",mode="idle"}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''100 - (avg by (host) (rate(node_cpu_seconds_total{host=~"$host",mode="idle"}[$__rate_interval])) * 100)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''max by (host) (node_memory_MemTotal_bytes{host=~"$host"} - node_memory_MemAvailable_bytes{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''max by (host) (node_memory_MemTotal_bytes{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "G";
                    expr = ''max by (host) (((node_memory_MemTotal_bytes{host=~"$host"} - node_memory_MemAvailable_bytes{host=~"$host"}) / clamp_min(node_memory_MemTotal_bytes{host=~"$host"}, 1)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "H";
                    expr = ''max by (host) (last_over_time(node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"}[5m]) - last_over_time(node_filesystem_avail_bytes{host=~"$host",mountpoint="/persist"}[5m]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "I";
                    expr = ''max by (host) (last_over_time(node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"}[5m]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "J";
                    expr = ''max by (host) (((last_over_time(node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"}[5m]) - last_over_time(node_filesystem_avail_bytes{host=~"$host",mountpoint="/persist"}[5m])) / clamp_min(last_over_time(node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"}[5m]), 1)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "K";
                    expr = ''sum by (host) (node_systemd_unit_state{host=~"$host",state="failed"})'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Alerts & Public Endpoints";
          rows = [
            [
              (d.mkTable {
                title = "Active Alerts (Firing / Pending)";
                w = 12;
                h = 7;
                noValue = "All clear — no active alerts";
                links = [d.links.toTimeMachine];
                expr = ''ALERTS{alertstate=~"firing|pending",host=~"$host"}'';
                transformations = [
                  (d.organizeTransform {
                    exclude = ["Time" "__name__" "Value"];
                    rename = {
                      alertname = "Alert";
                      alertstate = "State";
                      severity = "Severity";
                      host = "Host";
                    };
                    index = {
                      alertname = 0;
                      alertstate = 1;
                      severity = 2;
                      host = 3;
                    };
                  })
                ];
                overrides = [(d.cellBadgeOverride "State" d.mappings.alertState)];
              })
              (d.mkStat {
                title = "Endpoint Probes";
                w = 12;
                h = 7;
                colorMode = "background";
                textMode = "value_and_name";
                mappings = d.mappings.upDown;
                thresholds = d.thresholds.upDown;
                noValue = "No blackbox probes configured";
                expr = ''max by (vhost, service) (probe_success)'';
                legend = "{{vhost}}";
                links = [
                  {
                    title = ''Inspect ''${__field.labels.service}'';
                    url = ''/d/nixconf-service-inspector?var-service=''${__field.labels.service}&''${__url_time_range}'';
                  }
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Remote Storage Budgets & Failed Backup Units";
          rows = [
            [
              (d.mkTable {
                title = "Remote Storage Budgets";
                w = 14;
                h = 6;
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
              (d.mkSystemdUnitsTable {
                title = "Failed Systemd Units (Fleet)";
                w = 10;
                h = 6;
                noValue = "No failed units across fleet";
                expr = ''node_systemd_unit_state{host=~"$host",state="failed"} == 1'';
              })
            ]
          ];
        })
      ];
    };
}
