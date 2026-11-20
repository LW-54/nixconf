{
  internal.restic.mkDashboard = d:
    d.mkDashboard {
      uid = "nixconf-backups-storage";
      title = "Storage & Backups";
      description = "Restic backup jobs (including telemetry archives on hbox and gdrive), Btrfs host snapshot timers, rclone FUSE mounts, and storage journal logs.";
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
          title = "Rclone Remote Storage";
          rows = [
            [
              (d.mkStorageTable {
                title = "Mounted Rclone Filesystems (Usage & Capacity)";
                w = 24;
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
