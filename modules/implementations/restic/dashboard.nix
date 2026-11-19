{
  internal.restic.mkDashboard = d:
    d.mkDashboard {
      uid = "nixconf-backups-storage";
      title = "Backup, Snapshots & Storage";
      description = "Restic backup jobs, Btrfs host snapshot timers, rclone FUSE mounts, and storage journal logs.";
      tags = ["restic" "snapshot" "rclone" "storage"];
      refresh = "1m";
      timeFrom = "now-24h";
      variables = [(d.vars.host {})];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Failed Backup / Mount Units";
            w = 6;
            decimals = 0;
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            expr = ''sum(node_systemd_unit_state{host=~"$host",name=~"(restic-.*|host-snapshot-.*|rclone-config|storage-drift-check)\\.service|mnt-storage-.*\\.mount",state="failed"}) or vector(0)'';
            legend = "Failed";
          })
          (d.mkStat {
            title = "Active Timers";
            w = 6;
            decimals = 0;
            expr = ''sum(node_systemd_unit_state{host=~"$host",name=~"(restic-backups-.*|host-snapshot-.*)\\.timer",state="active"}) or vector(0)'';
            legend = "Timers";
          })
          (d.mkStat {
            title = "Active Rclone Mounts";
            w = 6;
            decimals = 0;
            expr = ''sum(node_systemd_unit_state{host=~"$host",name=~"mnt-storage-.*\\.mount",state="active"}) or vector(0)'';
            legend = "Mounts";
          })
          (d.mkStat {
            title = "/persist Disk Usage";
            w = 6;
            unit = "percent";
            decimals = 1;
            thresholds = d.thresholds.percentHigh;
            expr = ''max by (host) ((1 - (node_filesystem_avail_bytes{host=~"$host",mountpoint="/persist"} / node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"})) * 100)'';
            legend = "{{host}}";
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
              (d.mkSystemdUnitsTable {
                title = "Rclone Mount & Config Units";
                w = 12;
                h = 7;
                expr = ''node_systemd_unit_state{host=~"$host",name=~"mnt-storage-.*\\.mount|rclone-config\\.service"} == 1'';
              })
              (d.mkBarGauge {
                title = "Remote Storage Usage (%)";
                w = 12;
                h = 7;
                unit = "percent";
                min = 0;
                max = 100;
                thresholds = d.thresholds.percentHigh;
                expr = ''max by (host, mountpoint, device) ((1 - (node_filesystem_avail_bytes{host=~"$host",fstype="fuse.rclone"} / clamp_min(node_filesystem_size_bytes{host=~"$host",fstype="fuse.rclone"}, 1))) * 100)'';
                legend = "{{host}} {{mountpoint}} ({{device}})";
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
                expr = ''{job="systemd-journal", host=~"$host", unit=~"(restic-.*|host-snapshot-.*|rclone-config|storage-drift-check)\\.service"}'';
              })
            ]
          ];
        })
      ];
    };
}
