{
  internal.victoria.mkDashboard = d:
    d.mkDashboard {
      uid = "nixconf-observability-health";
      title = "Observability Health";
      description = "VictoriaMetrics TSDB storage & ingestion, VictoriaLogs compression & disk budget, vmalert rule evaluation, Alertmanager delivery, Alloy agents, and Grafana traffic.";
      tags = ["victoria" "victoriametrics" "victorialogs" "vmalert" "alertmanager" "grafana"];
      sections = [
        (d.mkRow [
          (d.mkRatioStat {
            title = "Scrape Targets Healthy";
            w = 6;
            unit = "short";
            usedDecimals = 0;
            totalDecimals = 0;
            thresholds = d.thresholds.percent100Ok;
            colorMode = "background";
            percentLegend = "Healthy %";
            usedLegend = "Up";
            totalLegend = "Total";
            percentExpr = ''avg(up) * 100'';
            usedExpr = ''sum(up == 1) or vector(0)'';
            totalExpr = ''count(up) or vector(0)'';
          })
          (d.mkStat {
            title = "Firing Alerts";
            w = 4;
            decimals = 0;
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            noValue = "0";
            expr = ''count(ALERTS{alertstate="firing"}) or vector(0)'';
            legend = "Alerts";
          })
          (d.mkStat {
            title = "VictoriaMetrics Stored Rows";
            w = 4;
            decimals = 0;
            graphMode = "area";
            expr = ''sum(vm_rows{type="storage/big"}) or sum(vm_rows)'';
            legend = "Rows";
          })
          (d.mkStat {
            title = "VictoriaMetrics Data Size";
            w = 5;
            unit = "bytes";
            decimals = 1;
            graphMode = "area";
            expr = ''sum(vm_data_size_bytes)'';
            legend = "Disk Used";
          })
          (d.mkStat {
            title = "VictoriaLogs Compressed Size";
            w = 5;
            unit = "bytes";
            decimals = 1;
            graphMode = "area";
            expr = ''sum(vl_compressed_data_size_bytes)'';
            legend = "Compressed";
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
                links = [d.links.toTimeMachine];
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
          title = "VictoriaMetrics & VictoriaLogs Ingestion & Compression";
          rows = [
            [
              (d.mkTimeseries {
                title = "VictoriaMetrics Row Ingestion Rate";
                w = 12;
                unit = "ops";
                expr = ''sum by (type) (rate(vm_rows_inserted_total[$__rate_interval]))'';
                legend = "{{type}} rows/s";
              })
              (d.mkTimeseries {
                title = "VictoriaLogs Ingestion Rate (Lines & Bytes/s)";
                w = 12;
                unit = "Bps";
                expr = ''sum(rate(vl_bytes_ingested_total[$__rate_interval]))'';
                legend = "Ingested bytes/s";
              })
            ]
            [
              (d.mkTimeseries {
                title = "VictoriaLogs Compression Footprint";
                w = 12;
                unit = "bytes";
                overrides = [(d.dashedLineOverride "/Uncompressed/" "orange")];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''sum(vl_compressed_data_size_bytes)'';
                    legend = "Compressed on disk";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''sum(vl_uncompressed_data_size_bytes)'';
                    legend = "Uncompressed logical";
                  })
                ];
              })
              (d.mkTimeseries {
                title = "VictoriaMetrics & VictoriaLogs Free Disk Headroom";
                w = 12;
                unit = "bytes";
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''min(vm_free_disk_space_bytes)'';
                    legend = "VM free";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''min(vl_free_disk_space_bytes)'';
                    legend = "VL free";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Stack Services & Grafana Traffic";
          rows = [
            [
              (d.mkTimeseries {
                title = "Observability Services Memory Working Set";
                w = 12;
                unit = "bytes";
                expr = ''container_memory_working_set_bytes{unit=~"(victoriametrics|victorialogs|vmalert-metrics|vmalert-logs|alertmanager|grafana|alloy)\\.service"}'';
                legend = "{{host}} {{unit}}";
              })
              (d.mkTimeseries {
                title = "Grafana HTTP Request Rate by Status";
                w = 12;
                unit = "reqps";
                overrides = d.statusColorOverrides {};
                expr = ''sum by (status_code) (rate(grafana_http_request_duration_seconds_count{status_code!=""}[$__rate_interval]))'';
                legend = "HTTP {{status_code}}";
              })
            ]
          ];
        })
      ];
    };
}
