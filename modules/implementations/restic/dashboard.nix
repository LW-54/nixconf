{
  internal.restic.mkDashboard = d:
    d.mkDashboard {
      uid = "nixconf-backups-storage";
      title = "Backups & Snapshots";
      description = "Restic backup jobs (including telemetry archives on hbox and gdrive), Btrfs host snapshot timers, rclone FUSE mounts, backup operation costs, and storage journal logs.";
      tags = ["restic" "snapshot" "rclone" "storage"];
      refresh = "1m";
      timeFrom = "now-24h";
      variables = [(d.vars.host {})];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Failed Backup / Mount Units";
            w = 5;
            decimals = 0;
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            expr = ''sum(node_systemd_unit_state{host=~"$host",name=~"(restic-.*|host-snapshot-.*|rclone-config|storage-drift-check)\\.service|mnt-storage-.*\\.mount",state="failed"}) or vector(0)'';
            legend = "Failed";
          })
          (d.mkStat {
            title = "Active Timers";
            w = 5;
            decimals = 0;
            expr = ''sum(node_systemd_unit_state{host=~"$host",name=~"(restic-backups-.*|host-snapshot-.*)\\.timer",state="active"}) or vector(0)'';
            legend = "Timers";
          })
          (d.mkStat {
            title = "Active Rclone Mounts";
            w = 5;
            decimals = 0;
            expr = ''count(node_filesystem_size_bytes{host=~"$host",fstype="fuse.rclone"}) or vector(0)'';
            legend = "Mounts";
          })
          (d.mkRatioStat {
            title = "/persist Disk Usage";
            w = 9;
            thresholds = d.thresholds.percentHigh;
            percentLegend = "{{host}} %";
            usedLegend = "{{host}} Used";
            totalLegend = "{{host}} Total";
            percentExpr = ''max by (host) (((node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"} - node_filesystem_avail_bytes{host=~"$host",mountpoint="/persist"}) / clamp_min(node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"}, 1)) * 100)'';
            usedExpr = ''max by (host) (node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"} - node_filesystem_avail_bytes{host=~"$host",mountpoint="/persist"})'';
            totalExpr = ''max by (host) (node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"})'';
          })
        ])
        (d.mkSection {
          title = "Backup & Snapshot Units";
          rows = [
            [
              (d.mkSystemdUnitsTable {
                title = "Failed Backup, Snapshot & Mount Units";
                w = 12;
                h = 7;
                noValue = "No failed units";
                expr = ''node_systemd_unit_state{host=~"$host",name=~"(restic-.*|host-snapshot-.*|rclone-config|storage-drift-check)\\.service|mnt-storage-.*\\.mount",state="failed"} == 1'';
              })
              (d.mkSystemdUnitsTable {
                title = "Active Backup & Snapshot Timers";
                w = 12;
                h = 7;
                expr = ''node_systemd_unit_state{host=~"$host",name=~"(restic-backups-.*|host-snapshot-.*)\\.timer",state="active"} == 1'';
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Rclone Remote Storage & Backup Operation Costs";
          rows = [
            [
              (d.mkStorageTable {
                title = "Mounted Rclone Filesystems (Usage & Capacity)";
                w = 12;
                h = 7;
                selector = ''host=~"$host",fstype="fuse.rclone"'';
                groupBy = ["host" "mountpoint" "device"];
                columns = {
                  host = "Host";
                  mountpoint = "Mountpoint";
                  device = "Remote";
                };
                columnOrder = ["host" "mountpoint" "device"];
              })
              (d.mkTable {
                title = "Remote Storage Budgets by Slice";
                w = 12;
                h = 7;
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
                    };
                    index = {
                      host = 0;
                      slice = 1;
                      "Value #A" = 2;
                      "Value #B" = 3;
                      "Value #C" = 4;
                      "Value #D" = 5;
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
                    expr = ''max by (host, slice) (deriv(nixconf_storage_budget_used_bytes{host=~"$host"}[$__range:])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
            [
              (d.mkTable {
                title = "Backup & Snapshot Operation Costs ($__range)";
                w = 24;
                h = 8;
                logs = true;
                noValue = "No completed backup or snapshot runs in this time range";
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
                      op_unit = "Job";
                      runs = "Runs";
                      total_cpu_s = "Total CPU (s)";
                      avg_wall_s = "Avg Wall (s)";
                      max_mem_bytes = "Max RAM Peak";
                      total_io_read_bytes = "Disk Read";
                      total_io_write_bytes = "Disk Write";
                    };
                    index = {
                      host = 0;
                      op_unit = 1;
                      runs = 2;
                      total_cpu_s = 3;
                      avg_wall_s = 4;
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
                  (d.decimalsOverride "Avg Wall (s)" 1)
                  (d.unitOverride "Max RAM Peak" "bytes")
                  (d.unitOverride "Disk Read" "bytes")
                  (d.unitOverride "Disk Write" "bytes")
                ];
                expr = ''job:="systemd-journal" host:in($host) "Consumed" "CPU time" | ${d.systemdOpsParsePipe} | filter op_unit:~"^(restic-.*|host-snapshot-.*|resources-storage-budgets)\\.service$" | stats by (host, op_unit) count() as runs, sum(cpu_s) as total_cpu_s, avg(wall_s) as avg_wall_s, max(mem_peak_bytes) as max_mem_bytes, sum(io_read_bytes) as total_io_read_bytes, sum(io_write_bytes) as total_io_write_bytes | sort by (total_cpu_s) desc'';
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Backup & Storage Logs";
          rows = [
            [
              (d.mkLogs {
                title = "Restic, Snapshot & Rclone Journal Stream";
                w = 24;
                expr = ''job:="systemd-journal" host:in($host) unit:~"(restic-.*|host-snapshot-.*|rclone-config|storage-drift-check)\\.service"'';
              })
            ]
          ];
        })
      ];
    };
}
