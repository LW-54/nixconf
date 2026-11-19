# Logs Explorer dashboard definition for primitive.host monitoring.
{
  _module.args.mkLogsExplorerDashboard = d:
    d.mkDashboard {
      uid = "nixconf-logs-explorer";
      title = "Logs Explorer";
      description = "Interactive journald log exploration filtered by host, systemd unit, syslog severity level, watched status, and regex.";
      tags = ["loki" "journald" "logs"];
      variables = [
        (d.vars.host {})
        (d.vars.lokiLabel {
          name = "unit";
          label = "Unit";
          labelName = "unit";
          stream = ''{job="systemd-journal", host=~"$host"}'';
        })
        (d.vars.custom {
          name = "level";
          label = "Level";
          options = ["emerg" "alert" "crit" "error" "warning" "notice" "info" "debug"];
        })
        (d.vars.custom {
          name = "watched";
          label = "Scope";
          includeAll = false;
          multi = false;
          options = [
            {
              text = "All Units";
              value = ".*";
            }
            {
              text = "Watched Only";
              value = "true";
            }
          ];
          current = {
            text = "All Units";
            value = ".*";
          };
        })
        (d.vars.textbox {
          name = "search";
          label = "Search (Regex)";
          default = "";
        })
      ];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Total Log Lines";
            w = 6;
            loki = true;
            decimals = 0;
            noValue = "0";
            expr = ''sum(count_over_time({job="systemd-journal", host=~"$host", unit=~"$unit", level=~"$level", watched=~"$watched"} |~ "$search" [$__range]))'';
            legend = "Total";
          })
          (d.mkStat {
            title = "Errors & Critical";
            w = 6;
            loki = true;
            decimals = 0;
            noValue = "0";
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            expr = ''sum(count_over_time({job="systemd-journal", host=~"$host", unit=~"$unit", level=~"emerg|alert|crit|err|error", watched=~"$watched"} |~ "$search" [$__range]))'';
            legend = "Errors";
          })
          (d.mkStat {
            title = "Warnings";
            w = 6;
            loki = true;
            decimals = 0;
            noValue = "0";
            thresholds = d.thresholds.zeroWarn;
            expr = ''sum(count_over_time({job="systemd-journal", host=~"$host", unit=~"$unit", level="warning", watched=~"$watched"} |~ "$search" [$__range]))'';
            legend = "Warnings";
          })
          (d.mkStat {
            title = "Watched Unit Errors";
            w = 6;
            loki = true;
            decimals = 0;
            noValue = "0";
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            expr = ''sum(count_over_time({job="systemd-journal", host=~"$host", watched="true", level=~"emerg|alert|crit|err|error"} |~ "$search" [$__range]))'';
            legend = "Watched Errors";
          })
        ])
        (d.mkRow [
          (d.mkTimeseries {
            title = "Log Volume by Severity";
            w = 14;
            h = 7;
            loki = true;
            drawStyle = "bars";
            stacked = true;
            legendMode = "list";
            overrides = d.logLevelColorOverrides {};
            expr = ''sum by (level) (count_over_time({job="systemd-journal", host=~"$host", unit=~"$unit", level=~"$level", watched=~"$watched"} |~ "$search" [$__auto]))'';
            legend = "{{level}}";
          })
          (d.mkBarGauge {
            title = "Top 10 Noisiest Units";
            w = 10;
            h = 7;
            loki = true;
            unit = "short";
            thresholds = d.thresholds.neutral;
            expr = ''topk(10, sum by (host, unit) (count_over_time({job="systemd-journal", host=~"$host", unit=~"$unit", level=~"$level", watched=~"$watched"} |~ "$search" [$__range])))'';
            legend = "{{host}} / {{unit}}";
          })
        ])
        (d.mkRow [
          (d.mkLogs {
            title = "Live Journald Log Stream";
            w = 24;
            h = 16;
            expr = ''{job="systemd-journal", host=~"$host", unit=~"$unit", level=~"$level", watched=~"$watched"} |~ "$search"'';
          })
        ])
      ];
    };
}
