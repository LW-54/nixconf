{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkServicesCatalogDashboard = _:
    d.mkDashboard {
      uid = "nixconf-services-catalog";
      title = "Services Catalog";
      description = "Unified directory across every declared nixconf service: unit state, blackbox probes, HTTP throughput, memory limits, and CPU usage.";
      tags = ["services" "catalog" "apps"];
      variables = [(d.vars.host {})];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Registered Services";
            w = 5;
            decimals = 0;
            expr = ''count(count by (service) (node_systemd_unit_state{host=~"$host",service!=""})) or vector(0)'';
            legend = "Services";
          })
          (d.mkRatioStat {
            title = "Service Probes Healthy";
            w = 7;
            unit = "short";
            usedDecimals = 0;
            totalDecimals = 0;
            thresholds = d.thresholds.percent100Ok;
            colorMode = "background";
            percentLegend = "Up %";
            usedLegend = "Up";
            totalLegend = "Total";
            percentExpr = ''(avg(probe_success{service!=""}) or vector(1)) * 100'';
            usedExpr = ''sum(probe_success{service!=""} == 1) or vector(0)'';
            totalExpr = ''count(probe_success{service!=""}) or vector(0)'';
          })
          (d.mkStat {
            title = "Total HTTP RPS";
            w = 6;
            unit = "reqps";
            decimals = 2;
            graphMode = "area";
            noValue = "0";
            expr = ''sum(rate(caddy_http_requests_total{server="srv0",service!=""}[$__rate_interval])) or vector(0)'';
            legend = "RPS";
          })
          (d.mkStat {
            title = "Total Services RAM";
            w = 6;
            unit = "bytes";
            decimals = 1;
            graphMode = "area";
            expr = ''sum(container_memory_working_set_bytes{host=~"$host",service!=""})'';
            legend = "RAM";
          })
        ])
        (d.mkSection {
          title = "All Monitored Services (Click Any Service Row to Inspect)";
          rows = [
            [
              (d.mkTable {
                title = "Services Overview";
                w = 24;
                h = 12;
                links = [d.links.toService];
                sortBy = [
                  {
                    desc = true;
                    displayName = "RAM Working Set";
                  }
                ];
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      service = "Service";
                      "Value #A" = "Active Units";
                      "Value #B" = "Failed Units";
                      "Value #C" = "Probe";
                      "Value #D" = "HTTP RPS";
                      "Value #E" = "RAM Working Set";
                      "Value #F" = "RAM Limit";
                      "Value #G" = "Limit %";
                      "Value #H" = "CPU (cores)";
                    };
                    index = {
                      service = 0;
                      "Value #A" = 1;
                      "Value #B" = 2;
                      "Value #C" = 3;
                      "Value #D" = 4;
                      "Value #E" = 5;
                      "Value #F" = 6;
                      "Value #G" = 7;
                      "Value #H" = 8;
                    };
                  })
                ];
                overrides = [
                  (d.decimalsOverride "Active Units" 0)
                  (d.decimalsOverride "Failed Units" 0)
                  (d.cellBadgeOverride "Probe" d.mappings.upDown)
                  (d.unitOverride "HTTP RPS" "reqps")
                  (d.decimalsOverride "HTTP RPS" 2)
                  (d.unitOverride "RAM Working Set" "bytes")
                  (d.unitOverride "RAM Limit" "bytes")
                  (d.cellGaugeOverride {
                    colName = "Limit %";
                    thresholds = d.thresholds.percentHigh;
                  })
                  (d.decimalsOverride "CPU (cores)" 3)
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''sum by (service) (node_systemd_unit_state{host=~"$host",service!="",state="active",name!~"restic-.*"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''sum by (service) (node_systemd_unit_state{host=~"$host",service!="",state="failed"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''min by (service) (probe_success{service!=""})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "D";
                    expr = ''sum by (service) (rate(caddy_http_requests_total{server="srv0",service!=""}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "E";
                    expr = ''sum by (service) (container_memory_working_set_bytes{host=~"$host",service!=""})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "F";
                    expr = ''sum by (service) (container_spec_memory_limit_bytes{host=~"$host",service!=""} > 0)'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "G";
                    expr = ''(sum by (service) (container_memory_working_set_bytes{host=~"$host",service!=""}) / (sum by (service) (container_spec_memory_limit_bytes{host=~"$host",service!=""} > 0))) * 100'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "H";
                    expr = ''sum by (service) (rate(container_cpu_usage_seconds_total{host=~"$host",service!=""}[$__rate_interval]))'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
            [
              (d.mkStat {
                title = "Service Endpoints";
                w = 24;
                h = 5;
                colorMode = "background";
                textMode = "value_and_name";
                mappings = d.mappings.upDown;
                thresholds = d.thresholds.upDown;
                noValue = "No service probes configured";
                expr = ''max by (vhost, service) (probe_success{service!=""})'';
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
      ];
    };
}
