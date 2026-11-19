{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkContainersDashboard = _:
    d.mkDashboard {
      uid = "nixconf-containers";
      title = "Containers & Services";
      description = "OCI container and systemd cgroup CPU, memory, and runtime logs across hosts.";
      tags = ["cadvisor" "containers" "services"];
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
            title = "Systemd Services Memory";
            w = 6;
            unit = "bytes";
            decimals = 1;
            expr = ''sum(container_memory_working_set_bytes{host=~"$host",id=~"/system\\.slice/.*\\.service"})'';
            legend = "Services";
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
              (d.mkTimeseries {
                title = "Container Memory Working Set";
                w = 12;
                unit = "bytes";
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
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''label_replace(rate(container_cpu_usage_seconds_total{host=~"$host",id=~".*libpod-.*container"}[5m]), "container", "$1", "id", ".*libpod-([0-9a-f]{12}).*")'';
                    legend = "{{host}} podman:{{container}}";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''rate(container_cpu_usage_seconds_total{host=~"$host",name!=""}[5m])'';
                    legend = "{{host}} {{name}}";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Top Systemd Services by Resource Usage";
          rows = [
            [
              (d.mkBarGauge {
                title = "Top 12 Services — Memory Working Set";
                w = 12;
                unit = "bytes";
                thresholds = d.thresholds.neutral;
                expr = ''topk(12, label_replace(container_memory_working_set_bytes{host=~"$host",id=~"/system\\.slice/.*\\.service"}, "service", "$1", "id", "/system\\.slice/(.*)\\.service"))'';
                legend = "{{host}} {{service}}";
              })
              (d.mkTimeseries {
                title = "Top 12 Services — CPU Usage (cores)";
                w = 12;
                expr = ''topk(12, label_replace(rate(container_cpu_usage_seconds_total{host=~"$host",id=~"/system\\.slice/.*\\.service"}[5m]), "service", "$1", "id", "/system\\.slice/(.*)\\.service"))'';
                legend = "{{host}} {{service}}";
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
                expr = ''{job="systemd-journal", host=~"$host", unit=~"(podman-.*|docker|docker-.*)\\.service"}'';
              })
            ]
          ];
        })
      ];
    };
}
