{
  internal.authelia.mkDashboard = d:
    d.mkDashboard {
      uid = "nixconf-auth-security";
      title = "Authentication & Security";
      description = "Authelia SSO authentication attempts, forward-auth authorization decisions, latency percentiles, and SSH/LLDAP security logs.";
      tags = ["authelia" "ssh" "security"];
      variables = [(d.vars.host {})];
      sections = [
        (d.mkRow [
          (d.mkStat {
            title = "Authelia Status";
            w = 4;
            mappings = d.mappings.upDown;
            thresholds = d.thresholds.upDown;
            colorMode = "background";
            expr = ''min(up{job="authelia",host=~"$host"})'';
            legend = "Authelia";
          })
          (d.mkStat {
            title = "Auth Successes";
            w = 5;
            decimals = 0;
            noValue = "0";
            expr = ''sum(increase(authelia_authn{host=~"$host",success="true"}[$__range]))'';
            legend = "Successes";
          })
          (d.mkStat {
            title = "Auth Failures";
            w = 5;
            decimals = 0;
            noValue = "0";
            thresholds = d.thresholds.zeroWarn;
            expr = ''sum(increase(authelia_authn{host=~"$host",success="false"}[$__range]))'';
            legend = "Failures";
          })
          (d.mkStat {
            title = "Forward-Auth Denied (401)";
            w = 5;
            decimals = 0;
            noValue = "0";
            expr = ''sum(increase(authelia_authz{host=~"$host",code="401"}[$__range]))'';
            legend = "Denied";
          })
          (d.mkStat {
            title = "SSH Auth Failures";
            w = 5;
            loki = true;
            decimals = 0;
            noValue = "0";
            thresholds = d.thresholds.zeroWarn;
            expr = ''sum(count_over_time({job="systemd-journal", host=~"$host", unit="sshd.service"} |~ "(?i)(invalid user|failed password|connection closed by authenticating user)" [$__range]))'';
            legend = "SSH Failures";
          })
        ])
        (d.mkSection {
          title = "Authelia SSO & Forward Auth";
          rows = [
            [
              (d.mkTimeseries {
                title = "Forward-Auth Decisions by Code";
                w = 12;
                unit = "reqps";
                overrides = d.statusColorOverrides {};
                expr = ''sum by (code) (rate(authelia_authz{host=~"$host"}[5m]))'';
                legend = "HTTP {{code}}";
              })
              (d.mkTimeseries {
                title = "Authentication Outcomes";
                w = 12;
                unit = "ops";
                overrides = [
                  (d.overrideByName "Success" [(d.colorFixed "green")])
                  (d.overrideByName "Failed" [(d.colorFixed "orange")])
                  (d.overrideByName "Banned" [(d.colorFixed "red")])
                ];
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''sum(rate(authelia_authn{host=~"$host",success="true"}[5m]))'';
                    legend = "Success";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''sum(rate(authelia_authn{host=~"$host",success="false",banned="false"}[5m]))'';
                    legend = "Failed";
                  })
                  (d.promTarget {
                    refId = "C";
                    expr = ''sum(rate(authelia_authn{host=~"$host",banned="true"}[5m]))'';
                    legend = "Banned";
                  })
                ];
              })
            ]
            [
              (d.mkTimeseries {
                title = "Authelia Request Latency (p50 / p95)";
                w = 12;
                h = 7;
                unit = "s";
                targets = [
                  (d.promTarget {
                    refId = "A";
                    expr = ''histogram_quantile(0.50, sum by (le) (rate(authelia_request_duration_bucket{host=~"$host"}[5m])))'';
                    legend = "p50";
                  })
                  (d.promTarget {
                    refId = "B";
                    expr = ''histogram_quantile(0.95, sum by (le) (rate(authelia_request_duration_bucket{host=~"$host"}[5m])))'';
                    legend = "p95";
                  })
                ];
              })
              (d.mkTimeseries {
                title = "Security Failure Events (Logs)";
                w = 12;
                h = 7;
                drawStyle = "bars";
                stacked = true;
                legendMode = "list";
                overrides = [
                  (d.overrideByName "Authelia Failures/Bans" [(d.colorFixed "orange")])
                  (d.overrideByName "SSH Invalid Auth" [(d.colorFixed "red")])
                ];
                targets = [
                  (d.lokiTarget {
                    refId = "A";
                    expr = ''sum(count_over_time({job="systemd-journal", host=~"$host", unit="authelia-main.service"} |~ "(?i)(unsuccessful authentication|banned)" [$__auto]))'';
                    legend = "Authelia Failures/Bans";
                  })
                  (d.lokiTarget {
                    refId = "B";
                    expr = ''sum(count_over_time({job="systemd-journal", host=~"$host", unit="sshd.service"} |~ "(?i)(invalid user|failed password|connection closed by authenticating user)" [$__auto]))'';
                    legend = "SSH Invalid Auth";
                  })
                ];
              })
            ]
          ];
        })
        (d.mkSection {
          title = "Security Audit Logs";
          rows = [
            [
              (d.mkLogs {
                title = "Authelia, LLDAP & SSH Journal Stream";
                w = 24;
                expr = ''{job="systemd-journal", host=~"$host", unit=~"authelia-main\\.service|lldap\\.service|sshd\\.service"}'';
              })
            ]
          ];
        })
      ];
    };
}
