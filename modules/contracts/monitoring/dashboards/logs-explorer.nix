{config, ...}: let
  d = config.internal.monitoring.dashboard;
in {
  internal.monitoring.dashboard.mkLogsExplorerDashboard = _:
    d.mkDashboard {
      uid = "nixconf-logs-explorer";
      title = "Logs Explorer";
      description = "Interactive journald full-text and LogsQL exploration in VictoriaLogs across hosts, units, severity levels, and watched units.";
      tags = ["victorialogs" "journald" "logs"];
      variables = [
        (d.vars.host {})
        (d.vars.logsField {
          name = "unit";
          label = "Unit";
          field = "unit";
          query = ''job:="systemd-journal" host:in($host)'';
        })
        (d.vars.custom {
          name = "level";
          label = "Level";
          allValue = "*";
          options = ["emerg" "alert" "crit" "err" "error" "warning" "notice" "info" "debug"];
        })
        (d.vars.custom {
          name = "watched";
          label = "Scope";
          includeAll = false;
          multi = false;
          options = [
            {
              text = "All Units";
              value = "*";
            }
            {
              text = "Watched Only";
              value = ''watched:="true"'';
            }
          ];
          current = {
            text = "All Units";
            value = "*";
          };
        })
        (d.vars.textbox {
          name = "search";
          label = "Search (LogsQL / Phrase / ~Regex)";
          default = "*";
        })
      ];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Total Log Lines";
            w = 6;
            logs = true;
            decimals = 0;
            noValue = "0";
            expr = ''job:="systemd-journal" host:in($host) unit:in($unit) level:in($level) ($watched) ($search) | stats count() as total'';
            legend = "Total";
          })
          (d.mkStat {
            title = "Errors & Critical";
            w = 6;
            logs = true;
            decimals = 0;
            noValue = "0";
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            expr = ''job:="systemd-journal" host:in($host) unit:in($unit) level:in("emerg","alert","crit","err","error") ($watched) ($search) | stats count() as total'';
            legend = "Errors";
          })
          (d.mkStat {
            title = "Warnings";
            w = 6;
            logs = true;
            decimals = 0;
            noValue = "0";
            thresholds = d.thresholds.zeroWarn;
            expr = ''job:="systemd-journal" host:in($host) unit:in($unit) level:="warning" ($watched) ($search) | stats count() as total'';
            legend = "Warnings";
          })
          (d.mkStat {
            title = "Watched Unit Errors";
            w = 6;
            logs = true;
            decimals = 0;
            noValue = "0";
            thresholds = d.thresholds.zeroOk;
            colorMode = "background";
            expr = ''job:="systemd-journal" host:in($host) watched:="true" level:in("emerg","alert","crit","err","error") ($search) | stats count() as total'';
            legend = "Watched Errors";
          })
        ])
        (d.mkRow [
          (d.mkTimeseries {
            title = "Log Volume by Severity";
            w = 14;
            h = 7;
            logs = true;
            drawStyle = "bars";
            stacked = true;
            legendMode = "list";
            overrides = d.logLevelColorOverrides {};
            expr = ''job:="systemd-journal" host:in($host) unit:in($unit) level:in($level) ($watched) ($search) | stats by (level) count() as lines'';
            legend = "{{level}}";
          })
          (d.mkBarGauge {
            title = "Top 10 Noisiest Units";
            w = 10;
            h = 7;
            logs = true;
            unit = "short";
            thresholds = d.thresholds.neutral;
            expr = ''job:="systemd-journal" host:in($host) unit:in($unit) level:in($level) ($watched) ($search) | stats by (host, unit) count() as lines | sort by (lines desc) limit 10'';
            legend = "{{host}} / {{unit}}";
          })
        ])
        (d.mkRow [
          (d.mkLogs {
            title = "Journald Log Stream (VictoriaLogs)";
            w = 24;
            h = 16;
            expr = ''job:="systemd-journal" host:in($host) unit:in($unit) level:in($level) ($watched) ($search)'';
          })
        ])
      ];
    };
}
