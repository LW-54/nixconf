{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkStorageAtlasDashboard = _:
    d.mkDashboard {
      uid = "nixconf-storage-atlas";
      title = "Storage Atlas (Treemap)";
      description = "Interactive WizTree & stock-market heatmap visualization of storage across hosts, storage providers (local, hbox, gdrive, b2), services, and local directory trees. Click any rectangle to zoom in and use breadcrumbs to navigate back.";
      tags = ["storage" "treemap" "wiztree" "disk" "providers" "capacity"];
      refresh = "1m";
      timeFrom = "now-7d";
      graphTooltip = 0;
      variables = [
        (d.vars.host {})
        (d.vars.custom {
          name = "view";
          label = "Hierarchy";
          includeAll = false;
          multi = false;
          current = {
            text = "All (Host → Provider → Slice/FS)";
            value = "fleet";
          };
          options = [
            {
              text = "All (Host → Provider → Slice/FS)";
              value = "fleet";
            }
            {
              text = "By Storage Provider (local / hbox / gdrive / b2)";
              value = "provider";
            }
            {
              text = "By Service (Local State + Cache + Remote)";
              value = "service";
            }
            {
              text = "By Directory (WizTree Local Tree)";
              value = "directory";
            }
          ];
        })
        (d.vars.custom {
          name = "color_mode";
          label = "Color Mode";
          includeAll = false;
          multi = false;
          current = {
            text = "Stock Market Heatmap (Growth / Day)";
            value = "growth";
          };
          options = [
            {
              text = "Stock Market Heatmap (Growth / Day)";
              value = "growth";
            }
            {
              text = "Capacity Pressure (Usage %)";
              value = "usage";
            }
            {
              text = "WizTree Category Palette";
              value = "category";
            }
          ];
        })
        (d.vars.custom {
          name = "window";
          label = "Growth Window";
          includeAll = false;
          multi = false;
          current = {
            text = "7d";
            value = "7d";
          };
          options = ["24h" "7d" "30d"];
        })
      ];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Local /persist & Root Used";
            w = 5;
            unit = "bytes";
            decimals = 1;
            expr = ''sum(max by (host, mountpoint) (node_filesystem_size_bytes{host=~"$host",mountpoint=~"/|/persist"} - node_filesystem_avail_bytes{host=~"$host",mountpoint=~"/|/persist"}))'';
            legend = "Local Used";
          })
          (d.mkStat {
            title = "Remote Storage Used";
            w = 5;
            unit = "bytes";
            decimals = 1;
            noValue = "0 B";
            expr = ''sum(max by (slice) (nixconf_storage_budget_used_bytes{host=~"$host"}))'';
            legend = "Remote Used";
          })
          (d.mkStat {
            title = "Remote Budget Headroom";
            w = 5;
            unit = "bytes";
            decimals = 1;
            noValue = "—";
            expr = ''sum(max by (slice) (clamp_min(nixconf_storage_budget_limit_bytes{host=~"$host"} - nixconf_storage_budget_used_bytes{host=~"$host"}, 0)))'';
            legend = "Free Budget";
          })
          (d.mkStat {
            title = "Largest Local Directory";
            w = 5;
            unit = "bytes";
            decimals = 1;
            noValue = "Scanning…";
            expr = ''max(nixconf_storage_dir_bytes{host=~"$host",depth="1"})'';
            legend = "Top Dir";
          })
          (d.mkStat {
            title = "Net Local Growth ($window)";
            w = 4;
            unit = "bytes";
            decimals = 1;
            description = "Combined daily local disk growth (bytes/day) over $window.";
            expr = ''sum(max by (host, mountpoint) (deriv((node_filesystem_size_bytes{host=~"$host",mountpoint="/persist"} - node_filesystem_avail_bytes{host=~"$host",mountpoint="/persist"})[$window:])) * 86400)'';
            legend = "B / day";
          })
        ])
        (d.mkRow [
          (d.mkStorageTreemap {
            title = "Interactive Storage Treemap — $view ($color_mode)";
            description = "Click any rectangle to zoom into nested providers, services, or subdirectories. Use the breadcrumb bar at the bottom to step back up. Switch Hierarchy and Color Mode in the top bar.";
            w = 24;
            h = 16;
          })
        ])
        (d.mkSection {
          title = "Dedicated Quick Views — WizTree Directory Map & Storage by Provider";
          rows = [
            [
              (d.mkStorageTreemap {
                title = "WizTree Local Directory Map ($host)";
                description = "Always-visible interactive local directory treemap (Category → Directory → Subdirectories).";
                w = 12;
                h = 12;
                view = "directory";
              })
              (d.mkStorageTreemap {
                title = "Storage by Provider (Local vs Cloud)";
                description = "Side-by-side comparison of local disks/volumes against every remote storage provider (hbox, gdrive, b2).";
                w = 12;
                h = 12;
                view = "provider";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Exact Directory & Remote Breakdown Tables";
          collapsed = true;
          rows = [
            [
              (d.mkTable {
                title = "Local Directories & Services (Depth 1–2, >= 1 MiB)";
                w = 14;
                h = 10;
                noValue = "Awaiting first nixconf-storage-scan run";
                sortBy = [
                  {
                    desc = true;
                    displayName = "Size";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      category = "Category";
                      service = "Service";
                      path = "Path";
                      depth = "Depth";
                      "Value #A" = "Size";
                      "Value #B" = "Growth / Day";
                    };
                    index = {
                      host = 0;
                      category = 1;
                      service = 2;
                      path = 3;
                      depth = 4;
                      "Value #A" = 5;
                      "Value #B" = 6;
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Size" "bytes")
                  (d.unitOverride "Growth / Day" "bytes")
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host, category, service, path, depth) (nixconf_storage_dir_bytes{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host, category, service, path, depth) (deriv(nixconf_storage_dir_bytes{host=~"$host"}[$window:])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
              (d.mkTable {
                title = "Remote Storage Providers & Slices";
                w = 10;
                h = 10;
                noValue = "No remote storage budgets configured";
                sortBy = [
                  {
                    desc = true;
                    displayName = "Used";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      host = "Host";
                      provider = "Provider";
                      slice = "Slice";
                      scope = "Scope";
                      "Value #A" = "Used";
                      "Value #B" = "Limit";
                      "Value #C" = "Usage %";
                      "Value #D" = "Growth / Day";
                    };
                    index = {
                      host = 0;
                      provider = 1;
                      slice = 2;
                      scope = 3;
                      "Value #A" = 4;
                      "Value #B" = 5;
                      "Value #C" = 6;
                      "Value #D" = 7;
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
                    expr = ''max by (host, provider, slice, scope) (nixconf_storage_budget_used_bytes{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host, provider, slice, scope) (nixconf_storage_budget_limit_bytes{host=~"$host"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host, provider, slice, scope) ((nixconf_storage_budget_used_bytes{host=~"$host"} / clamp_min(nixconf_storage_budget_limit_bytes{host=~"$host"}, 1)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host, provider, slice, scope) (deriv(nixconf_storage_budget_used_bytes{host=~"$host"}[$window:])) * 86400'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
          ];
        })
      ];
    };
}
