{
  config,
  lib,
  ...
}: let
  d = config.internal.monitoring.dashboard;

  # Deduplicated local filesystems (excludes impermanence btrfs bind-mount duplicates and podman shm mounts while keeping / or /persist and loopback volumes).
  fsSizeSel = extra: ''(node_filesystem_size_bytes{host=~"$host",fstype!~"btrfs|ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var/run|run|sys|proc|dev).*|.*overlay-containers.*"${extra}} or node_filesystem_size_bytes{host=~"$host",fstype="btrfs",mountpoint=~"/|/persist"${extra}})'';
  fsAvailSel = extra: ''(node_filesystem_avail_bytes{host=~"$host",fstype!~"btrfs|ramfs|squashfs|overlay|fuse\\..*",mountpoint!~"/(etc|nix|var/run|run|sys|proc|dev).*|.*overlay-containers.*"${extra}} or node_filesystem_avail_bytes{host=~"$host",fstype="btrfs",mountpoint=~"/|/persist"${extra}})'';

  tag = stype: metric: expr: ''label_set(${expr}, "stype", "${stype}", "metric", "${metric}")'';

  statGuard = statKey: expr: ''(${expr}) and on() label_match(label_set(vector(1), "stat", "${statKey}"), "stat", "$stats")'';

  # Unified subject discovery expression driven dynamically by $host and $subject_type.
  subjectDiscoveryExpr = ''count by (subject) (label_match(label_set(label_copy(node_uname_info{host=~"$host"}, "host", "subject"), "stype", "host") or label_set(label_copy(container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice!=""}, "slice", "subject"), "stype", "slice") or label_set(label_copy(container_memory_working_set_bytes{host=~"$host",unit!=""}, "unit", "subject"), "stype", "unit") or label_set(label_copy(namedprocess_namegroup_num_procs{host=~"$host"}, "groupname", "subject"), "stype", "process") or label_set(label_copy(${fsSizeSel ""}, "mountpoint", "subject"), "stype", "filesystem"), "stype", "$subject_type"))'';

  # Unified multi-subject, multi-metric base expression emitting canonical (host, stype, subject, metric) series.
  baseExpr = ''label_match(label_match(${lib.concatStringsSep " or " [
      # Memory (Bytes)
      (tag "host" "memory" ''label_match(max by (host, subject) (label_copy(node_memory_MemTotal_bytes{host=~"$host"} - node_memory_MemAvailable_bytes{host=~"$host"}, "host", "subject")), "subject", "$subject")'')
      (tag "slice" "memory" ''sum by (host, subject) (label_copy(container_memory_working_set_bytes{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$subject"}, "slice", "subject"))'')
      (tag "unit" "memory" ''sum by (host, subject) (label_copy(container_memory_working_set_bytes{host=~"$host",unit=~"$subject"}, "unit", "subject"))'')
      (tag "process" "memory" ''sum by (host, subject) (label_copy(namedprocess_namegroup_memory_bytes{host=~"$host",memtype="resident",groupname=~"$subject"}, "groupname", "subject"))'')

      # CPU (Cores)
      (tag "host" "cpu" ''label_match(sum by (host, subject) (rate(label_copy(node_cpu_seconds_total{host=~"$host",mode!="idle"}, "host", "subject")[$__rate_interval])), "subject", "$subject")'')
      (tag "slice" "cpu" ''sum by (host, subject) (rate(label_copy(container_cpu_usage_seconds_total{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$subject"}, "slice", "subject")[$__rate_interval]))'')
      (tag "unit" "cpu" ''sum by (host, subject) (rate(label_copy(container_cpu_usage_seconds_total{host=~"$host",unit=~"$subject"}, "unit", "subject")[$__rate_interval]))'')
      (tag "process" "cpu" ''sum by (host, subject) (rate(label_copy(namedprocess_namegroup_cpu_seconds_total{host=~"$host",groupname=~"$subject"}, "groupname", "subject")[$__rate_interval]))'')

      # CPU Utilization (% of host)
      (tag "host" "cpu_pct" ''label_match(100 - (avg by (host, subject) (rate(label_copy(node_cpu_seconds_total{host=~"$host",mode="idle"}, "host", "subject")[$__rate_interval])) * 100), "subject", "$subject")'')
      (tag "slice" "cpu_pct" ''(sum by (host, subject) (rate(label_copy(container_cpu_usage_seconds_total{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$subject"}, "slice", "subject")[$__rate_interval])) / on(host) group_left count by (host) (node_cpu_seconds_total{host=~"$host",mode="idle"})) * 100'')
      (tag "unit" "cpu_pct" ''(sum by (host, subject) (rate(label_copy(container_cpu_usage_seconds_total{host=~"$host",unit=~"$subject"}, "unit", "subject")[$__rate_interval])) / on(host) group_left count by (host) (node_cpu_seconds_total{host=~"$host",mode="idle"})) * 100'')
      (tag "process" "cpu_pct" ''(sum by (host, subject) (rate(label_copy(namedprocess_namegroup_cpu_seconds_total{host=~"$host",groupname=~"$subject"}, "groupname", "subject")[$__rate_interval])) / on(host) group_left count by (host) (node_cpu_seconds_total{host=~"$host",mode="idle"})) * 100'')

      # Disk I/O Read (B/s)
      (tag "host" "io_read" ''label_match(sum by (host, subject) (rate(label_copy(node_disk_read_bytes_total{host=~"$host",device!~"dm-.*|loop.*"}, "host", "subject")[$__rate_interval])), "subject", "$subject")'')
      (tag "slice" "io_read" ''sum by (host, subject) (rate(label_copy(container_fs_reads_bytes_total{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$subject"}, "slice", "subject")[$__rate_interval]))'')
      (tag "unit" "io_read" ''sum by (host, subject) (rate(label_copy(container_fs_reads_bytes_total{host=~"$host",unit=~"$subject"}, "unit", "subject")[$__rate_interval]))'')
      (tag "process" "io_read" ''sum by (host, subject) (rate(label_copy(namedprocess_namegroup_read_bytes_total{host=~"$host",groupname=~"$subject"}, "groupname", "subject")[$__rate_interval]))'')

      # Disk I/O Write (B/s)
      (tag "host" "io_write" ''label_match(sum by (host, subject) (rate(label_copy(node_disk_written_bytes_total{host=~"$host",device!~"dm-.*|loop.*"}, "host", "subject")[$__rate_interval])), "subject", "$subject")'')
      (tag "slice" "io_write" ''sum by (host, subject) (rate(label_copy(container_fs_writes_bytes_total{host=~"$host",id=~"/[^/]+\\.slice",slice=~"$subject"}, "slice", "subject")[$__rate_interval]))'')
      (tag "unit" "io_write" ''sum by (host, subject) (rate(label_copy(container_fs_writes_bytes_total{host=~"$host",unit=~"$subject"}, "unit", "subject")[$__rate_interval]))'')
      (tag "process" "io_write" ''sum by (host, subject) (rate(label_copy(namedprocess_namegroup_write_bytes_total{host=~"$host",groupname=~"$subject"}, "groupname", "subject")[$__rate_interval]))'')

      # Filesystem Storage Used (Bytes) & Usage (%)
      (tag "filesystem" "fs_used" ''max by (host, subject) (label_copy(${fsSizeSel '',mountpoint=~"$subject"''} - ${fsAvailSel '',mountpoint=~"$subject"''}, "mountpoint", "subject"))'')
      (tag "filesystem" "fs_pct" ''max by (host, subject) (label_copy(((${fsSizeSel '',mountpoint=~"$subject"''} - ${fsAvailSel '',mountpoint=~"$subject"''}) / clamp_min(${fsSizeSel '',mountpoint=~"$subject"''}, 1)) * 100, "mountpoint", "subject"))'')

      # Host Contention / PSI (%)
      (tag "host" "psi_cpu" ''label_match(max by (host, subject) (rate(label_copy(node_pressure_cpu_waiting_seconds_total{host=~"$host"}, "host", "subject")[$__rate_interval]) * 100), "subject", "$subject")'')
      (tag "host" "psi_mem" ''label_match(max by (host, subject) (rate(label_copy(node_pressure_memory_stalled_seconds_total{host=~"$host"}, "host", "subject")[$__rate_interval]) * 100), "subject", "$subject")'')
      (tag "host" "psi_io" ''label_match(max by (host, subject) (rate(label_copy(node_pressure_io_stalled_seconds_total{host=~"$host"}, "host", "subject")[$__rate_interval]) * 100), "subject", "$subject")'')

      # Host Network Throughput (B/s)
      (tag "host" "net_rx" ''label_match(sum by (host, subject) (rate(label_copy(node_network_receive_bytes_total{host=~"$host",device!~"lo|veth.*|docker.*|br-.*|podman.*"}, "host", "subject")[$__rate_interval])), "subject", "$subject")'')
      (tag "host" "net_tx" ''label_match(sum by (host, subject) (rate(label_copy(node_network_transmit_bytes_total{host=~"$host",device!~"lo|veth.*|docker.*|br-.*|podman.*"}, "host", "subject")[$__rate_interval])), "subject", "$subject")'')
    ]}, "stype", "$subject_type"), "metric", "$metric")'';

  # Declared soft/hard allocations matching the active (stype, subject, metric) selection.
  allocHighExpr = ''label_match(label_match(${lib.concatStringsSep " or " [
      (tag "slice" "memory" ''max by (host, subject) (label_copy(nixconf:slice_memory_high_bytes{host=~"$host",slice=~"$subject"}, "slice", "subject"))'')
      (tag "unit" "memory" ''max by (host, subject) (label_copy(nixconf:unit_memory_high_bytes{host=~"$host",unit=~"$subject"}, "unit", "subject"))'')
    ]}, "stype", "$subject_type"), "metric", "$metric")'';

  allocMaxExpr = ''label_match(label_match(${lib.concatStringsSep " or " [
      (tag "host" "memory" ''label_match(max by (host, subject) (label_copy(node_memory_MemTotal_bytes{host=~"$host"}, "host", "subject")), "subject", "$subject")'')
      (tag "slice" "memory" ''max by (host, subject) (label_copy(nixconf:slice_memory_max_bytes{host=~"$host",slice=~"$subject"}, "slice", "subject"))'')
      (tag "unit" "memory" ''max by (host, subject) (label_copy(nixconf:unit_memory_max_bytes{host=~"$host",unit=~"$subject"}, "unit", "subject"))'')
      (tag "slice" "cpu" ''max by (host, subject) (label_copy(nixconf_resource_slice_cpu_quota_cores{host=~"$host",slice=~"$subject"}, "slice", "subject"))'')
      (tag "unit" "cpu" ''max by (host, subject) (label_copy(nixconf_resource_unit_cpu_quota_cores{host=~"$host",unit=~"$subject"}, "unit", "subject"))'')
      (tag "filesystem" "fs_used" ''max by (host, subject) (label_copy(${fsSizeSel '',mountpoint=~"$subject"''}, "mountpoint", "subject"))'')
    ]}, "stype", "$subject_type"), "metric", "$metric")'';

  # Multi-unit & line-style overrides so mixed metrics automatically get clean separate Y-axes without colliding colors across subjects.
  workbenchOverrides = [
    (d.overrideByRegexp "/· (memory|fs_used) ·/" [
      {
        id = "unit";
        value = "bytes";
      }
      {
        id = "custom.axisLabel";
        value = "Bytes";
      }
    ])
    (d.overrideByRegexp "/· cpu ·/" [
      {
        id = "unit";
        value = "short";
      }
      {
        id = "custom.axisLabel";
        value = "Cores";
      }
    ])
    (d.overrideByRegexp "/· (cpu_pct|fs_pct|psi_cpu|psi_mem|psi_io) ·/" [
      {
        id = "unit";
        value = "percent";
      }
      {
        id = "custom.axisLabel";
        value = "%";
      }
    ])
    (d.overrideByRegexp "/· (io_read|io_write|net_rx|net_tx) ·/" [
      {
        id = "unit";
        value = "Bps";
      }
      {
        id = "custom.axisLabel";
        value = "Bytes / s";
      }
    ])
    (d.overrideByRegexp "/Rolling (Avg|P50|P95|P99)/" [
      {
        id = "custom.lineStyle";
        value = {
          fill = "dash";
          dash = [4 3];
        };
      }
      {
        id = "custom.fillOpacity";
        value = 0;
      }
    ])
    (d.overrideByRegexp "/Rolling (Min|Max|StdDev|[+-]1σ)/" [
      {
        id = "custom.lineStyle";
        value = {
          fill = "dot";
          dash = [0 4];
        };
      }
      {
        id = "custom.fillOpacity";
        value = 0;
      }
      {
        id = "custom.lineWidth";
        value = 1;
      }
    ])
    (d.overrideByRegexp "/Growth \\/ Day|Prev Cycle/" [
      {
        id = "custom.lineStyle";
        value = {
          fill = "dash";
          dash = [3 4];
        };
      }
      {
        id = "custom.fillOpacity";
        value = 0;
      }
      {
        id = "custom.lineWidth";
        value = 1;
      }
    ])
    (d.overrideByRegexp "/Alloc High/" [
      {
        id = "custom.lineStyle";
        value = {
          fill = "dash";
          dash = [6 4];
        };
      }
      {
        id = "custom.fillOpacity";
        value = 0;
      }
      {
        id = "custom.lineWidth";
        value = 2;
      }
      (d.colorFixed "orange")
    ])
    (d.overrideByRegexp "/Alloc Max/" [
      {
        id = "custom.lineStyle";
        value = {
          fill = "dash";
          dash = [6 4];
        };
      }
      {
        id = "custom.fillOpacity";
        value = 0;
      }
      {
        id = "custom.lineWidth";
        value = 2;
      }
      (d.colorFixed "red")
    ])
  ];

  referenceMarkdown = ''
    ### Unlimited Independent Queries (`+ Query` & Grafana Explore)
    This dashboard is provisioned with **`editable = true`** (unlike the read-only operational dashboards), so you can go beyond the top-bar dropdowns whenever you want completely independent combinations (e.g. *Suwayomi RAM P95* alongside *LLDAP CPU Avg* alongside *Host Load*):

    1. **Stack unlimited queries right here:** Click the main panel title → **Edit** → **`+ Query`** (as many times as you like), switch between Grafana's visual **Builder** and **Code** editors, duplicate/disable queries, or assign custom Y-axes. Reloading the page cleanly resets unsaved experiments back to this starter template.
    2. **Open a blank multi-query canvas:** Click **Open in Explore** in the top navigation bar (or **Panel → Explore** to carry the current graph's queries directly into Explore).

    ### Precomputed & High-Value MetricsQL Building Blocks
    | Family | Metric / Expression | Labels |
    | --- | --- | --- |
    | **Slice Allocations** | `nixconf:slice_memory_high_bytes`, `nixconf:slice_memory_max_bytes`, `nixconf_resource_slice_cpu_quota_cores` | `host`, `slice` |
    | **Unit Allocations** | `nixconf:unit_memory_high_bytes`, `nixconf:unit_memory_max_bytes`, `nixconf_resource_unit_cpu_quota_cores` | `host`, `slice`, `unit` |
    | **Precomputed 5m Rates** | `nixconf:host_cpu_utilization_percent:rate5m`, `nixconf:slice_cpu_cores:rate5m`, `nixconf:unit_cpu_cores:rate5m` | `host`, `slice`, `unit` |
    | **Unit & Container RAM/CPU** | `container_memory_working_set_bytes`, `rate(container_cpu_usage_seconds_total[$__rate_interval])` | `host`, `slice`, `unit`, `service` |
    | **Process Stats** | `namedprocess_namegroup_memory_bytes{memtype="resident"}`, `rate(namedprocess_namegroup_cpu_seconds_total[$__rate_interval])`, `rate(namedprocess_namegroup_read_bytes_total[$__rate_interval])` | `host`, `groupname` |
    | **Systemd Operations (5m)** | `nixconf_operation_cpu_seconds_5m`, `nixconf_operation_memory_peak_bytes_5m`, `nixconf_operation_io_read_bytes_5m`, `nixconf_operation_io_write_bytes_5m` | `host`, `op_unit` |
    | **Rolling Stat Wrappers** | `avg_over_time((EXPR)[$rolling:])`, `quantile_over_time(0.95, (EXPR)[$rolling:])`, `stddev_over_time((EXPR)[$rolling:])`, `deriv((EXPR)[$rolling:]) * 86400`, `(EXPR) offset $compare` | — |
  '';
in {
  internal.monitoring.dashboard.mkMetricWorkbenchDashboard = _:
    d.mkDashboard {
      uid = "nixconf-metric-workbench";
      title = "Metric Workbench";
      description = "Flexible standalone query workbench: combine arbitrary Hosts, Subject Types, Subjects, Metrics, and Stats on one graph with automatic multi-axis units, plus editable=true for unlimited independent '+ Query' rows and one-click Grafana Explore.";
      tags = ["workbench" "custom" "explorer" "statistics" "resources"];
      editable = true;
      refresh = "1m";
      timeFrom = "now-24h";
      graphTooltip = 2;
      extraLinks = [
        {
          icon = "bolt";
          includeVars = false;
          keepTime = true;
          targetBlank = true;
          title = "Open in Explore";
          tooltip = "Open Grafana Explore for completely unconstrained multi-query ad-hoc analysis";
          type = "link";
          url = "/explore";
        }
      ];
      variables = [
        (d.vars.host {})
        (d.vars.custom {
          name = "subject_type";
          label = "Type";
          includeAll = true;
          multi = true;
          allValue = ".*";
          current = {
            text = "Slice";
            value = "slice";
          };
          options = [
            {
              text = "Host";
              value = "host";
            }
            {
              text = "Slice";
              value = "slice";
            }
            {
              text = "Unit / Container";
              value = "unit";
            }
            {
              text = "Process";
              value = "process";
            }
            {
              text = "Filesystem";
              value = "filesystem";
            }
          ];
        })
        (d.vars.promQuery {
          name = "subject";
          label = "Subjects";
          includeAll = true;
          multi = true;
          allValue = ".*";
          qryType = 3;
          query = "query_result(${subjectDiscoveryExpr})";
          regex = ''/subject="([^"]+)"/'';
        })
        (d.vars.custom {
          name = "metric";
          label = "Metrics";
          includeAll = true;
          multi = true;
          allValue = ".*";
          current = {
            text = "Memory (Bytes)";
            value = "memory";
          };
          options = [
            {
              text = "Memory (Bytes)";
              value = "memory";
            }
            {
              text = "CPU (Cores)";
              value = "cpu";
            }
            {
              text = "CPU Utilization (%)";
              value = "cpu_pct";
            }
            {
              text = "Disk I/O Read (B/s)";
              value = "io_read";
            }
            {
              text = "Disk I/O Write (B/s)";
              value = "io_write";
            }
            {
              text = "Storage Used (Bytes)";
              value = "fs_used";
            }
            {
              text = "Storage Usage (%)";
              value = "fs_pct";
            }
            {
              text = "CPU Pressure / PSI (%)";
              value = "psi_cpu";
            }
            {
              text = "Memory Pressure / PSI (%)";
              value = "psi_mem";
            }
            {
              text = "I/O Pressure / PSI (%)";
              value = "psi_io";
            }
            {
              text = "Network RX (B/s)";
              value = "net_rx";
            }
            {
              text = "Network TX (B/s)";
              value = "net_tx";
            }
          ];
        })
        (d.vars.custom {
          name = "stats";
          label = "Stats";
          includeAll = true;
          multi = true;
          allValue = ".*";
          current = {
            text = "Current";
            value = "current";
          };
          options = [
            {
              text = "Current";
              value = "current";
            }
            {
              text = "Rolling Avg";
              value = "avg";
            }
            {
              text = "Rolling P50";
              value = "p50";
            }
            {
              text = "Rolling P95";
              value = "p95";
            }
            {
              text = "Rolling P99";
              value = "p99";
            }
            {
              text = "Rolling Min";
              value = "min";
            }
            {
              text = "Rolling Max";
              value = "max";
            }
            {
              text = "Rolling StdDev (σ)";
              value = "stddev";
            }
            {
              text = "Rolling +1σ";
              value = "upper_1sigma";
            }
            {
              text = "Rolling -1σ";
              value = "lower_1sigma";
            }
            {
              text = "Growth / Day";
              value = "growth_day";
            }
            {
              text = "Prev Cycle (-Offset)";
              value = "prev_cycle";
            }
            {
              text = "Alloc High";
              value = "alloc_high";
            }
            {
              text = "Alloc Max";
              value = "alloc_max";
            }
          ];
        })
        (d.vars.custom {
          name = "rolling";
          label = "Window";
          includeAll = false;
          multi = false;
          current = {
            text = "1h";
            value = "1h";
          };
          options = ["15m" "1h" "6h" "24h" "7d" "30d"];
        })
        (d.vars.custom {
          name = "compare";
          label = "Offset";
          includeAll = false;
          multi = false;
          current = {
            text = "1d";
            value = "1d";
          };
          options = [
            {
              text = "1h";
              value = "1h";
            }
            {
              text = "6h";
              value = "6h";
            }
            {
              text = "1d";
              value = "1d";
            }
            {
              text = "7d";
              value = "7d";
            }
            {
              text = "30d";
              value = "30d";
            }
          ];
        })
      ];
      sections = [
        (d.mkRow [
          (d.mkTimeseries {
            title = "Custom Metric Workbench — Multi-Subject / Multi-Metric / Multi-Stat Graph";
            description = "Pick any Hosts, Types, Subjects, Metrics, and Stats above. Mixing units (e.g. Memory + CPU + Disk I/O) automatically splits Y-axes. Click Panel menu → Edit → '+ Query' to add unlimited completely independent custom queries.";
            w = 24;
            h = 13;
            legendCalcs = ["min" "mean" "max" "lastNotNull"];
            overrides = workbenchOverrides;
            targets = [
              (d.promTarget {
                refId = "A";
                expr = statGuard "current" baseExpr;
                legend = "{{subject}} · {{metric}} · Current";
              })
              (d.promTarget {
                refId = "B";
                expr = statGuard "avg" ''avg_over_time((${baseExpr})[$rolling:])'';
                legend = "{{subject}} · {{metric}} · Rolling Avg ($rolling)";
              })
              (d.promTarget {
                refId = "C";
                expr = statGuard "p50" ''quantile_over_time(0.50, (${baseExpr})[$rolling:])'';
                legend = "{{subject}} · {{metric}} · Rolling P50 ($rolling)";
              })
              (d.promTarget {
                refId = "D";
                expr = statGuard "p95" ''quantile_over_time(0.95, (${baseExpr})[$rolling:])'';
                legend = "{{subject}} · {{metric}} · Rolling P95 ($rolling)";
              })
              (d.promTarget {
                refId = "E";
                expr = statGuard "p99" ''quantile_over_time(0.99, (${baseExpr})[$rolling:])'';
                legend = "{{subject}} · {{metric}} · Rolling P99 ($rolling)";
              })
              (d.promTarget {
                refId = "F";
                expr = statGuard "min" ''min_over_time((${baseExpr})[$rolling:])'';
                legend = "{{subject}} · {{metric}} · Rolling Min ($rolling)";
              })
              (d.promTarget {
                refId = "G";
                expr = statGuard "max" ''max_over_time((${baseExpr})[$rolling:])'';
                legend = "{{subject}} · {{metric}} · Rolling Max ($rolling)";
              })
              (d.promTarget {
                refId = "H";
                expr = statGuard "stddev" ''stddev_over_time((${baseExpr})[$rolling:])'';
                legend = "{{subject}} · {{metric}} · Rolling StdDev ($rolling)";
              })
              (d.promTarget {
                refId = "I";
                expr = ''WITH (b = ${baseExpr}) ${statGuard "upper_1sigma" ''avg_over_time(b[$rolling:]) + stddev_over_time(b[$rolling:])''}'';
                legend = "{{subject}} · {{metric}} · Rolling +1σ ($rolling)";
              })
              (d.promTarget {
                refId = "J";
                expr = ''WITH (b = ${baseExpr}) ${statGuard "lower_1sigma" ''clamp_min(avg_over_time(b[$rolling:]) - stddev_over_time(b[$rolling:]), 0)''}'';
                legend = "{{subject}} · {{metric}} · Rolling -1σ ($rolling)";
              })
              (d.promTarget {
                refId = "K";
                expr = statGuard "growth_day" ''deriv((${baseExpr})[$rolling:]) * 86400'';
                legend = "{{subject}} · {{metric}} · Growth / Day ($rolling)";
              })
              (d.promTarget {
                refId = "L";
                expr = statGuard "prev_cycle" ''(${baseExpr}) offset $compare'';
                legend = "{{subject}} · {{metric}} · Prev Cycle (-$compare)";
              })
              (d.promTarget {
                refId = "M";
                expr = statGuard "alloc_high" allocHighExpr;
                legend = "{{subject}} · {{metric}} · Alloc High";
              })
              (d.promTarget {
                refId = "N";
                expr = statGuard "alloc_max" allocMaxExpr;
                legend = "{{subject}} · {{metric}} · Alloc Max";
              })
            ];
          })
        ])
        (d.mkSection {
          title = "Selected Series Statistical Summary (over $rolling)";
          rows = [
            [
              (d.mkTable {
                title = "Statistical Breakdown for Active Workbench Selection ($rolling)";
                description = "Instant statistical summary for every selected (Host, Type, Subject, Metric) over $rolling alongside declared allocations.";
                w = 24;
                h = 8;
                sortBy = [
                  {
                    desc = true;
                    displayName = "P95";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      stype = "Type";
                      subject = "Subject";
                      metric = "Metric";
                      "Value #A" = "Current";
                      "Value #B" = "Min";
                      "Value #C" = "Avg";
                      "Value #D" = "P50";
                      "Value #E" = "P95";
                      "Value #F" = "P99";
                      "Value #G" = "Max";
                      "Value #H" = "StdDev";
                      "Value #I" = "Growth / Day";
                      "Value #J" = "Alloc High";
                      "Value #K" = "Alloc Max";
                    };
                    index = {
                      host = 0;
                      stype = 1;
                      subject = 2;
                      metric = 3;
                      "Value #A" = 4;
                      "Value #B" = 5;
                      "Value #C" = 6;
                      "Value #D" = 7;
                      "Value #E" = 8;
                      "Value #F" = 9;
                      "Value #G" = 10;
                      "Value #H" = 11;
                      "Value #I" = 12;
                      "Value #J" = 13;
                      "Value #K" = 14;
                    };
                  })
                ];
                overrides = [
                  (d.decimalsOverride "Current" 3)
                  (d.decimalsOverride "Min" 3)
                  (d.decimalsOverride "Avg" 3)
                  (d.decimalsOverride "P50" 3)
                  (d.decimalsOverride "P95" 3)
                  (d.decimalsOverride "P99" 3)
                  (d.decimalsOverride "Max" 3)
                  (d.decimalsOverride "StdDev" 3)
                  (d.decimalsOverride "Growth / Day" 3)
                  (d.decimalsOverride "Alloc High" 3)
                  (d.decimalsOverride "Alloc Max" 3)
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = baseExpr;
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''min_over_time((${baseExpr})[$rolling:])'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''avg_over_time((${baseExpr})[$rolling:])'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''quantile_over_time(0.50, (${baseExpr})[$rolling:])'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''quantile_over_time(0.95, (${baseExpr})[$rolling:])'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''quantile_over_time(0.99, (${baseExpr})[$rolling:])'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "G";
                    expr = ''max_over_time((${baseExpr})[$rolling:])'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "H";
                    expr = ''stddev_over_time((${baseExpr})[$rolling:])'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "I";
                    expr = ''deriv((${baseExpr})[$rolling:]) * 86400'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "J";
                    expr = allocHighExpr;
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "K";
                    expr = allocMaxExpr;
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Query Builder Cheat Sheet (Unlimited '+ Query' & Explore Reference)";
          collapsed = true;
          rows = [
            [
              (d.mkText {
                title = "Building Unlimited Independent Queries";
                w = 24;
                h = 10;
                content = referenceMarkdown;
              })
            ]
          ];
        })
      ];
    };
}
