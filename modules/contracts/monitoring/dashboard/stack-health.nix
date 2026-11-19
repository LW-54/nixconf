{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkStackHealthDashboard = _:
    d.mkDashboard {
      uid = "nixconf-lgtm-health";
      title = "Monitoring Stack Health";
      description = "Prometheus TSDB ingestion, Loki distributor streams, Grafana HTTP traffic, active alerts, and scrape target health.";
      tags = ["lgtm" "prometheus" "loki" "grafana"];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Scrape Targets Healthy";
            w = 5;
            unit = "percent";
            decimals = 1;
            thresholds = d.thresholds.percent100Ok;
            colorMode = "background";
            expr = ''avg(up) * 100'';
            legend = "Healthy";
          })
          (d.mkStat {
            title = "Firing Alerts";
            w = 5;
            decimals = 0;
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            expr = ''count(ALERTS{alertstate="firing"}) or vector(0)'';
            legend = "Alerts";
          })
          (d.mkStat {
            title = "Prometheus Active Series";
            w = 5;
            decimals = 0;
            graphMode = "area";
            expr = ''sum(prometheus_tsdb_head_series)'';
            legend = "Series";
          })
          (d.mkStat {
            title = "Loki Active Streams";
            w = 4;
            decimals = 0;
            graphMode = "area";
            expr = ''sum(loki_ingester_memory_streams)'';
            legend = "Streams";
          })
          (d.mkStat {
            title = "Loki Ingestion Rate";
            w = 5;
            unit = "Bps";
            decimals = 1;
            graphMode = "area";
            expr = ''sum(rate(loki_distributor_bytes_received_total[5m]))'';
            legend = "Ingestion";
          })
        ])
        (d.mkSection {
          title = "Alerts & Scrape Targets";
          rows = [
            [
              (d.mkTable {
                title = "Active Alerts (Firing / Pending)";
                w = 12;
                h = 7;
                noValue = "No active alerts";
                expr = ''ALERTS{alertstate=~"firing|pending"}'';
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
              (d.mkTable {
                title = "Scrape Targets Status";
                w = 12;
                h = 7;
                expr = "up";
                transformations = [
                  (d.organizeTransform {
                    exclude = ["Time" "__name__" "vhost"];
                    rename = {
                      host = "Host";
                      job = "Job";
                      instance = "Instance";
                      Value = "Status";
                    };
                    index = {
                      host = 0;
                      job = 1;
                      instance = 2;
                      Value = 3;
                    };
                  })
                ];
                overrides = [(d.cellBadgeOverride "Status" d.mappings.upDown)];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Ingestion & Storage";
          rows = [
            [
              (d.mkTimeseries {
                title = "Prometheus TSDB Append Rate";
                w = 12;
                unit = "ops";
                expr = ''rate(prometheus_tsdb_head_samples_appended_total[5m])'';
                legend = "{{host}} samples/s";
              })
              (d.mkTimeseries {
                title = "Loki Log Ingestion Rate";
                w = 12;
                unit = "Bps";
                expr = ''sum by (tenant) (rate(loki_distributor_bytes_received_total[5m]))'';
                legend = "{{tenant}}";
              })
            ]
          ];
        })
        (d.mkSection {
          title = "LGTM Resource Footprint";
          rows = [
            [
              (d.mkTimeseries {
                title = "Monitoring Services Memory Working Set";
                w = 12;
                unit = "bytes";
                expr = ''label_replace(container_memory_working_set_bytes{id=~"/system\\.slice/(prometheus|loki|grafana|alloy)\\.service"}, "service", "$1", "id", "/system\\.slice/(.*)\\.service")'';
                legend = "{{host}} {{service}}";
              })
              (d.mkTimeseries {
                title = "Grafana HTTP Request Rate by Status";
                w = 12;
                unit = "reqps";
                overrides = d.statusColorOverrides {};
                expr = ''sum by (status_code) (rate(grafana_http_request_duration_seconds_count{status_code!=""}[5m]))'';
                legend = "HTTP {{status_code}}";
              })
            ]
          ];
        })
      ];
    };
}
