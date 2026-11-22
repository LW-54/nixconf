{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkContainersDashboard = _:
    d.mkDashboard {
      uid = "nixconf-containers";
      title = "Containers & OCI";
      description = "OCI container (Podman / Docker) memory, CPU, and runtime logs across hosts.";
      tags = ["cadvisor" "containers" "podman" "docker"];
      variables = [(d.vars.host {})];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Active OCI Containers";
            w = 6;
            decimals = 0;
            noValue = "0";
            expr = ''(count(container_memory_working_set_bytes{host=~"$host",id=~".*libpod-.*container"}) or vector(0)) + (count(container_memory_working_set_bytes{host=~"$host",name!=""}) or vector(0))'';
            legend = "Containers";
          })
          (d.mkStat {
            title = "Container Memory Total";
            w = 6;
            unit = "bytes";
            decimals = 1;
            noValue = "0";
            expr = ''(sum(container_memory_working_set_bytes{host=~"$host",id=~".*libpod-.*container"}) or vector(0)) + (sum(container_memory_working_set_bytes{host=~"$host",name!=""}) or vector(0))'';
            legend = "Memory";
          })
          (d.mkStat {
            title = "Container CPU Total (cores)";
            w = 6;
            decimals = 2;
            noValue = "0";
            expr = ''(sum(rate(container_cpu_usage_seconds_total{host=~"$host",id=~".*libpod-.*container"}[$__rate_interval])) or vector(0)) + (sum(rate(container_cpu_usage_seconds_total{host=~"$host",name!=""}[$__rate_interval])) or vector(0))'';
            legend = "Cores";
          })
          (d.mkStat {
            title = "Host Memory Available";
            w = 6;
            unit = "bytes";
            decimals = 1;
            expr = ''sum(node_memory_MemAvailable_bytes{host=~"$host"})'';
            legend = "Available";
          })
        ])
        (d.mkSection {
          title = "OCI Containers (Podman / Docker)";
          rows = [
            [
              (d.mkTable {
                title = "Container Memory vs Caps, CPU & Disk I/O";
                w = 24;
                h = 7;
                links = [d.links.toTrendsExplorer];
                noValue = "No active OCI containers";
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
                      unit = "Container Scope";
                      "Value #A" = "Memory";
                      "Value #B" = "Mem Cap";
                      "Value #C" = "Cap %";
                      "Value #D" = "CPU (cores)";
                      "Value #E" = "Disk Read/s";
                      "Value #F" = "Disk Write/s";
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
                    };
                  })
                ];
                overrides = [
                  (d.unitOverride "Memory" "bytes")
                  (d.unitOverride "Mem Cap" "bytes")
                  (d.cellGaugeOverride {
                    colName = "Cap %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.decimalsOverride "CPU (cores)" 3)
                  (d.unitOverride "Disk Read/s" "Bps")
                  (d.unitOverride "Disk Write/s" "Bps")
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host, slice, unit) (container_memory_working_set_bytes{host=~"$host",unit=~"podman-.*\\.scope"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host, slice, unit) (container_spec_memory_limit_bytes{host=~"$host",unit=~"podman-.*\\.scope"} > 0)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host, slice, unit) ((container_memory_working_set_bytes{host=~"$host",unit=~"podman-.*\\.scope"} / clamp_min(container_spec_memory_limit_bytes{host=~"$host",unit=~"podman-.*\\.scope"} > 0, 1)) * 100)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''max by (host, slice, unit) (rate(container_cpu_usage_seconds_total{host=~"$host",unit=~"podman-.*\\.scope"}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''max by (host, slice, unit) (rate(container_fs_reads_bytes_total{host=~"$host",unit=~"podman-.*\\.scope"}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''max by (host, slice, unit) (rate(container_fs_writes_bytes_total{host=~"$host",unit=~"podman-.*\\.scope"}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
            [
              (d.mkTimeseries {
                title = "Container Memory Working Set";
                w = 12;
                unit = "bytes";
                noValue = "No active OCI containers";
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''label_replace(container_memory_working_set_bytes{host=~"$host",id=~".*libpod-.*container"}, "container", "$1", "id", ".*libpod-([0-9a-f]{12}).*")'';
                    legend = "{{host}} podman:{{container}}";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''container_memory_working_set_bytes{host=~"$host",name!=""}'';
                    legend = "{{host}} {{name}}";
                  })
                ];
              })
              (d.mkTimeseries {
                title = "Container CPU Usage (cores)";
                w = 12;
                noValue = "No active OCI containers";
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''label_replace(rate(container_cpu_usage_seconds_total{host=~"$host",id=~".*libpod-.*container"}[$__rate_interval]), "container", "$1", "id", ".*libpod-([0-9a-f]{12}).*")'';
                    legend = "{{host}} podman:{{container}}";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(container_cpu_usage_seconds_total{host=~"$host",name!=""}[$__rate_interval])'';
                    legend = "{{host}} {{name}}";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Container Runtime Logs";
          rows = [
            [
              (d.mkLogs {
                title = "Podman & Docker Service Logs";
                w = 24;
                h = 10;
                expr = ''job:="systemd-journal" host:in($host) unit:~"(podman-.*|docker|docker-.*)\\.service"'';
              })
            ]
          ];
        })
      ];
    };
}
