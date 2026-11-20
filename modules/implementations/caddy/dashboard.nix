{
  internal.caddy.mkDashboard = d:
    d.mkDashboard {
      uid = "nixconf-ingress";
      title = "Ingress & Edge";
      description = "Caddy virtual host HTTP traffic, response status codes, latency percentiles, upstream health, and blackbox probes.";
      tags = ["caddy" "blackbox" "ingress"];
      variables = [
        (d.vars.promQuery {
          name = "probe";
          label = "Probe";
          query = "label_values(probe_success, vhost)";
        })
        (d.vars.promQuery {
          name = "vhost";
          label = "Virtual Host";
          query = "label_values(caddy_http_requests_total, host)";
        })
      ];
      sections = [
        (d.mkRow [
          (d.mkRatioStat {
            title = "Probe Availability";
            w = 7;
            unit = "short";
            usedDecimals = 0;
            totalDecimals = 0;
            thresholds = d.thresholds.percent100Ok;
            colorMode = "background";
            percentLegend = "Availability %";
            usedLegend = "Up";
            totalLegend = "Total";
            percentExpr = ''avg(probe_success{vhost=~"$probe"}) * 100'';
            usedExpr = ''sum(probe_success{vhost=~"$probe"} == 1) or vector(0)'';
            totalExpr = ''count(probe_success{vhost=~"$probe"}) or vector(0)'';
          })
          (d.mkStat {
            title = "Caddy Config Reload";
            w = 3;
            mappings = d.mappings.okFail;
            thresholds = d.thresholds.upDown;
            colorMode = "background";
            expr = "min(caddy_config_last_reload_successful)";
            legend = "Reload";
          })
          (d.mkRatioStat {
            title = "Healthy Upstreams";
            w = 7;
            unit = "short";
            usedDecimals = 0;
            totalDecimals = 0;
            thresholds = d.thresholds.percent100Ok;
            colorMode = "background";
            percentLegend = "Healthy %";
            usedLegend = "Healthy";
            totalLegend = "Total";
            percentExpr = "avg(caddy_reverse_proxy_upstreams_healthy) * 100";
            usedExpr = "sum(caddy_reverse_proxy_upstreams_healthy == 1) or vector(0)";
            totalExpr = "count(caddy_reverse_proxy_upstreams_healthy) or vector(0)";
          })
          (d.mkStat {
            title = "In-Flight Requests";
            w = 3;
            decimals = 0;
            noValue = "0";
            expr = ''sum(caddy_http_requests_in_flight{host=~"$vhost"})'';
            legend = "In-Flight";
          })
          (d.mkStat {
            title = "Request Rate";
            w = 4;
            unit = "reqps";
            decimals = 2;
            graphMode = "area";
            expr = ''sum(rate(caddy_http_requests_total{server="srv0",host=~"$vhost"}[$__rate_interval]))'';
            legend = "RPS";
          })
        ])
        (d.mkSection {
          title = "Endpoint Health Probes";
          rows = [
            [
              (d.mkStat {
                title = "Endpoint Status";
                w = 12;
                h = 6;
                colorMode = "background";
                textMode = "value_and_name";
                mappings = d.mappings.upDown;
                thresholds = d.thresholds.upDown;
                expr = ''max by (vhost, service) (probe_success{vhost=~"$probe"})'';
                legend = "{{vhost}}";
                links = [
                  {
                    title = ''Inspect ''${__field.labels.service}'';
                    url = ''/d/nixconf-service-inspector?var-service=''${__field.labels.service}&''${__url_time_range}'';
                  }
                ];
              })
              (d.mkTable {
                title = "Probe Summary";
                w = 12;
                h = 6;
                transformations = [
                  (d.mergeTransform {})
                  (d.organizeTransform {
                    exclude = ["Time"];
                    rename = {
                      vhost = "Endpoint";
                      host = "Prober";
                      "Value #A" = "Status";
                      "Value #B" = "HTTP";
                      "Value #C" = "Latency";
                    };
                    index = {
                      vhost = 0;
                      "Value #A" = 1;
                      "Value #B" = 2;
                      "Value #C" = 3;
                      host = 4;
                    };
                  })
                ];
                overrides = [
                  (d.cellBadgeOverride "Status" d.mappings.upDown)
                  (d.unitOverride "Latency" "s")
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''max by (host, vhost) (probe_success{vhost=~"$probe"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''max by (host, vhost) (probe_http_status_code{vhost=~"$probe"})'';
                    instant = true;
                    format = "table";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''max by (host, vhost) (probe_duration_seconds{vhost=~"$probe"})'';
                    instant = true;
                    format = "table";
                  })
                ];
              })
            ]
            [
              (d.mkTimeseries {
                title = "Probe Latency";
                w = 12;
                unit = "s";
                thresholds = d.thresholds.latencySec;
                expr = ''max by (vhost) (probe_duration_seconds{vhost=~"$probe"})'';
                legend = "{{vhost}}";
              })
              (d.mkTimeseries {
                title = "HTTP Probe Phase Breakdown";
                w = 12;
                unit = "s";
                stacked = true;
                expr = ''avg by (phase) (probe_http_duration_seconds{vhost=~"$probe"})'';
                legend = "{{phase}}";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Caddy Edge Traffic & Latency";
          rows = [
            [
              (d.mkTimeseries {
                title = "Request Rate by Virtual Host";
                w = 12;
                unit = "reqps";
                expr = ''sum by (host) (rate(caddy_http_requests_total{server="srv0",host=~"$vhost"}[$__rate_interval]))'';
                legend = "{{host}}";
              })
              (d.mkTimeseries {
                title = "HTTP Responses by Status Code";
                w = 12;
                unit = "reqps";
                overrides = d.statusColorOverrides {};
                expr = ''sum by (code) (rate(caddy_http_request_duration_seconds_count{server="srv0",host=~"$vhost"}[$__rate_interval]))'';
                legend = "HTTP {{code}}";
              })
            ]
            [
              (d.mkTimeseries {
                title = "Request Latency Percentiles (p50 / p95 / p99)";
                w = 12;
                unit = "s";
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''histogram_quantile(0.50, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server="srv0",host=~"$vhost"}[$__rate_interval])))'';
                    legend = "p50";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''histogram_quantile(0.95, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server="srv0",host=~"$vhost"}[$__rate_interval])))'';
                    legend = "p95";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''histogram_quantile(0.99, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server="srv0",host=~"$vhost"}[$__rate_interval])))'';
                    legend = "p99";
                  })
                ];
              })
              (d.mkTable {
                title = "Reverse Proxy Upstream Health";
                w = 12;
                expr = "caddy_reverse_proxy_upstreams_healthy";
                transformations = [
                  (d.organizeTransform {
                    exclude = ["Time" "__name__" "instance" "job"];
                    rename = {
                      host = "Host";
                      upstream = "Upstream";
                      Value = "Status";
                    };
                    index = {
                      host = 0;
                      upstream = 1;
                      Value = 2;
                    };
                  })
                ];
                overrides = [(d.cellBadgeOverride "Status" d.mappings.upDown)];
              })
            ]
          ];
        })
      ];
    };
}
