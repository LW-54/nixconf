{
  internal.grafana.mkServer = {
    config,
    lib,
    pkgs,
    options,
    self,
    mkDashboard,
  }: let
    cfg = config.monitoring;
    serverActive = cfg.enable && cfg.server.enable;
    domain = config.reverse-proxy.domain or null;

    connectAddr = addr:
      if addr == "0.0.0.0" || addr == "::" || addr == "*"
      then "127.0.0.1"
      else addr;

    grafanaConnectHost = connectAddr cfg.server.grafana.address;
    vmConnectHost = connectAddr cfg.server.metrics.address;
    vlConnectHost = connectAddr cfg.server.logs.address;
    alertsConnectHost = connectAddr cfg.server.alerts.address;

    vmUrl = "http://${vmConnectHost}:${toString cfg.server.metrics.port}";
    vlUrl = "http://${vlConnectHost}:${toString cfg.server.logs.port}";
    amUrl = "http://${alertsConnectHost}:${toString cfg.server.alerts.port}";

    vmalertMetricsPort = self.lib.reverse-proxy.mkPort "vmalert-metrics";
    vmalertLogsPort = self.lib.reverse-proxy.mkPort "vmalert-logs";

    grafanaFqdn =
      if domain != null
      then "${cfg.server.grafana.subdomain}.${domain}"
      else null;
    vmFqdn =
      if domain != null
      then "${cfg.server.metrics.subdomain}.${domain}"
      else null;
    vlFqdn =
      if domain != null
      then "${cfg.server.logs.subdomain}.${domain}"
      else null;
    alertsFqdn =
      if domain != null
      then "${cfg.server.alerts.subdomain}.${domain}"
      else null;

    enabledRuleGroups = lib.filterAttrs (_: g: g.enable && g.rules != []) cfg.rules;
    metricsRuleGroups = lib.filterAttrs (_: g: g.backend == "metrics") enabledRuleGroups;
    logsRuleGroups = lib.filterAttrs (_: g: g.backend == "logs") enabledRuleGroups;

    compileRuleItem = isMetrics: r:
      (lib.optionalAttrs (r.alert != null) {inherit (r) alert;})
      // (lib.optionalAttrs (r.record != null) {inherit (r) record;})
      // {inherit (r) expr;}
      // (lib.optionalAttrs ((r.alert != null || !isMetrics) && r.for != null) {inherit (r) for;})
      // (lib.optionalAttrs (r.labels != {}) {inherit (r) labels;})
      // (lib.optionalAttrs (r.alert != null && r.annotations != {}) {inherit (r) annotations;});

    compileGroups = isMetrics: groupType: groups:
      lib.mapAttrsToList (gName: g: {
        name = gName;
        type = groupType;
        inherit (g) interval;
        rules = map (compileRuleItem isMetrics) g.rules;
      })
      groups;

    hasMetricsRules = metricsRuleGroups != {};
    hasLogsRules = logsRuleGroups != {};

    enabledDashboards = lib.filterAttrs (_: d: d.enable) cfg.dashboards;

    dashboardsDir =
      pkgs.runCommand "grafana-dashboards" {}
      (''
          mkdir -p $out
        ''
        + lib.concatStrings (lib.mapAttrsToList (dName: dCfg: let
            safeName = builtins.replaceStrings ["/"] ["-"] dName;
            srcFile =
              if builtins.isPath dCfg.json || lib.isDerivation dCfg.json
              then dCfg.json
              else if builtins.isString dCfg.json
              then pkgs.writeText "${safeName}.json" dCfg.json
              else pkgs.writeText "${safeName}.json" (builtins.toJSON dCfg.json);
            subDir =
              if dCfg.folder == "" || dCfg.folder == "General"
              then ""
              else "/${dCfg.folder}";
          in ''
            mkdir -p "$out${subDir}"
            cp ${srcFile} "$out${subDir}/${safeName}.json"
          '')
          enabledDashboards));

    ntfyCfg = cfg.server.alerts.ntfy;
    ntfyActive = ntfyCfg.enable && ntfyCfg.url != null;
    hasNtfyServer = options ? services && options.services ? ntfy-server && (config.services.ntfy-server.enable or false);

    hasHostSnapshot = options ? services && options.services ? hostSnapshot;
    adminSubject = ["group:${config.auth.adminGroup or "lldap_admin"}"];
  in
    lib.mkIf serverActive (lib.mkMerge [
      {
        users.groups = {
          victoriametrics = {};
          victorialogs = {};
        };
        users.users = {
          victoriametrics = {
            isSystemUser = true;
            group = "victoriametrics";
            home = "/var/lib/victoriametrics";
          };
          victorialogs = {
            isSystemUser = true;
            group = "victorialogs";
            home = "/var/lib/victorialogs";
          };
        };

        secrets.files.grafana-secret-key = {
          store = "services/auth";
          key = "autheliaSessionSecret";
          owner = "grafana";
          group = "grafana";
          testValue = "nixconf-test-grafana-secret-key-0123456789abcdef";
        };
        secrets.files.telemetry-ingest-token = {
          store = "services/monitoring";
          key = "telemetryIngestToken";
          owner = "root";
          group = "root";
          testValue = "nixconf-test-telemetry-ingest-token-0123456789abcdef";
        };

        services = {
          victoriametrics = {
            enable = true;
            listenAddress = "${cfg.server.metrics.address}:${toString cfg.server.metrics.port}";
            retentionPeriod = cfg.server.retention.metrics;
            stateDir = "victoriametrics";
            extraOptions = cfg.extraMetricsOptions;
          };

          victorialogs = {
            enable = true;
            listenAddress = "${cfg.server.logs.address}:${toString cfg.server.logs.port}";
            stateDir = "victorialogs";
            extraOptions =
              [
                "-retentionPeriod=${cfg.server.retention.logs}"
                "-retention.maxDiskUsagePercent=${toString cfg.server.retention.logsMaxDiskPercent}"
                "-snapshotsMaxAge=6h"
              ]
              ++ cfg.extraLogsOptions;
          };

          prometheus.alertmanager = {
            enable = true;
            listenAddress = cfg.server.alerts.address;
            port = cfg.server.alerts.port;
            checkConfig = false;
            extraFlags = ["--cluster.listen-address="];
            configuration = {
              route = {
                group_by = ["alertname" "host"];
                group_wait = "30s";
                group_interval = "5m";
                repeat_interval = "4h";
                receiver =
                  if ntfyActive
                  then "ntfy"
                  else "blackhole";
              };
              inhibit_rules = [
                {
                  source_matchers = ["severity=\"critical\""];
                  target_matchers = ["severity=\"warning\""];
                  equal = ["alertname" "host"];
                }
              ];
              receivers =
                [{name = "blackhole";}]
                ++ lib.optional ntfyActive {
                  name = "ntfy";
                  webhook_configs = [
                    ({
                        inherit (ntfyCfg) url;
                        send_resolved = true;
                      }
                      // lib.optionalAttrs (ntfyCfg.passwordFile != null) {
                        http_config.basic_auth = {
                          inherit (ntfyCfg) username;
                          password_file = "/run/credentials/alertmanager.service/ntfy-password";
                        };
                      })
                  ];
                };
            };
          };

          vmalert.instances = {
            metrics = {
              enable = hasMetricsRules;
              settings = {
                "datasource.url" = vmUrl;
                "remoteWrite.url" = vmUrl;
                "remoteRead.url" = vmUrl;
                "notifier.url" = [amUrl];
                "httpListenAddr" = ["127.0.0.1:${toString vmalertMetricsPort}"];
              };
              rules.groups = compileGroups true "prometheus" metricsRuleGroups;
            };

            logs = {
              enable = hasLogsRules;
              settings = {
                "datasource.url" = vlUrl;
                "remoteWrite.url" = vmUrl;
                "remoteRead.url" = vmUrl;
                "notifier.url" = [amUrl];
                "httpListenAddr" = ["127.0.0.1:${toString vmalertLogsPort}"];
              };
              rules.groups = compileGroups false "vlogs" logsRuleGroups;
            };
          };

          grafana = {
            enable = true;
            declarativePlugins = with pkgs.grafanaPlugins; [
              prometheus
              victoriametrics-logs-datasource
            ];
            settings =
              lib.recursiveUpdate {
                server = {
                  http_addr = cfg.server.grafana.address;
                  http_port = cfg.server.grafana.port;
                  domain =
                    if grafanaFqdn != null
                    then grafanaFqdn
                    else "localhost";
                  root_url =
                    if grafanaFqdn != null
                    then "https://${grafanaFqdn}/"
                    else "http://${grafanaConnectHost}:${toString cfg.server.grafana.port}/";
                  enforce_domain = false;
                };
                security = {
                  secret_key = "$__file{${config.secrets.files.grafana-secret-key.path}}";
                  disable_initial_admin_creation = true;
                  cookie_secure = grafanaFqdn != null;
                };
                users = {
                  allow_sign_up = false;
                  auto_assign_org = true;
                  auto_assign_org_role = "Admin";
                };
                "auth.proxy" = {
                  enabled = true;
                  header_name = "Remote-User";
                  header_property = "username";
                  auto_sign_up = true;
                  headers = "Name:Remote-Name Email:Remote-Email Groups:Remote-Groups";
                  whitelist = "127.0.0.1, ::1";
                };
                "auth.basic".enabled = false;
                auth.disable_login_form = true;
                analytics = {
                  reporting_enabled = false;
                  check_for_updates = false;
                };
              }
              cfg.extraGrafanaSettings;

            provision = {
              enable = true;
              datasources.settings = {
                apiVersion = 1;
                prune = true;
                datasources = [
                  {
                    name = "VictoriaMetrics";
                    uid = "prometheus";
                    type = "prometheus";
                    access = "proxy";
                    url = vmUrl;
                    isDefault = true;
                    jsonData = {
                      httpMethod = "POST";
                      timeInterval = cfg.agent.scrapeInterval;
                    };
                  }
                  {
                    name = "VictoriaLogs";
                    uid = "victorialogs";
                    type = "victoriametrics-logs-datasource";
                    access = "proxy";
                    url = vlUrl;
                    jsonData = {
                      maxLines = 1000;
                    };
                  }
                ];
              };
              dashboards.settings = lib.mkIf (enabledDashboards != {}) {
                apiVersion = 1;
                providers = [
                  {
                    name = "nixconf";
                    type = "file";
                    disableDeletion = false;
                    allowUiUpdates = true;
                    updateIntervalSeconds = 30;
                    options = {
                      path = dashboardsDir;
                      foldersFromFilesStructure = true;
                    };
                  }
                ];
              };
            };
          };
        };

        systemd = {
          tmpfiles.rules = [
            "d /var/lib/grafana 0750 grafana grafana -"
            "d /var/lib/victoriametrics 0700 victoriametrics victoriametrics -"
            "d /var/lib/victoriametrics/snapshots 0700 victoriametrics victoriametrics -"
            "d /var/lib/victorialogs 0700 victorialogs victorialogs -"
          ];
          services =
            {
              grafana = {
                after = ["sops-install-secrets.service"];
                wants = ["sops-install-secrets.service"];
                serviceConfig = {
                  StateDirectory = "grafana";
                  StateDirectoryMode = "0750";
                };
              };
              victoriametrics.serviceConfig = {
                DynamicUser = lib.mkForce false;
                PrivateUsers = lib.mkForce false;
                User = "victoriametrics";
                Group = "victoriametrics";
              };
              victorialogs.serviceConfig = {
                DynamicUser = lib.mkForce false;
                PrivateUsers = lib.mkForce false;
                User = "victorialogs";
                Group = "victorialogs";
              };
              alertmanager = lib.optionalAttrs (ntfyActive && ntfyCfg.passwordFile != null) {
                after =
                  ["sops-install-secrets.service"]
                  ++ lib.optional hasNtfyServer "ntfy-sh.service";
                wants = ["sops-install-secrets.service"];
                serviceConfig.LoadCredential = ["ntfy-password:${ntfyCfg.passwordFile}"];
              };
            }
            // lib.optionalAttrs hasMetricsRules {
              vmalert-metrics = {
                after = ["victoriametrics.service" "alertmanager.service"];
                wants = ["victoriametrics.service" "alertmanager.service"];
              };
            }
            // lib.optionalAttrs hasLogsRules {
              vmalert-logs = {
                after = ["victorialogs.service" "victoriametrics.service" "alertmanager.service"];
                wants = ["victorialogs.service" "victoriametrics.service" "alertmanager.service"];
              };
            };
        };

        reverse-proxy = {
          ports =
            [
              {
                owner =
                  if grafanaFqdn != null
                  then grafanaFqdn
                  else "grafana";
                inherit (cfg.server.grafana) address port;
                protocol = "tcp";
              }
              {
                owner =
                  if vmFqdn != null
                  then vmFqdn
                  else "victoriametrics";
                inherit (cfg.server.metrics) address port;
                protocol = "tcp";
              }
              {
                owner =
                  if vlFqdn != null
                  then vlFqdn
                  else "victorialogs";
                inherit (cfg.server.logs) address port;
                protocol = "tcp";
              }
              {
                owner =
                  if alertsFqdn != null
                  then alertsFqdn
                  else "alertmanager";
                inherit (cfg.server.alerts) address port;
                protocol = "tcp";
              }
            ]
            ++ lib.optional hasMetricsRules {
              owner = "vmalert-metrics";
              address = "127.0.0.1";
              port = vmalertMetricsPort;
              protocol = "tcp";
            }
            ++ lib.optional hasLogsRules {
              owner = "vmalert-logs";
              address = "127.0.0.1";
              port = vmalertLogsPort;
              protocol = "tcp";
            };

          hosts = lib.mkIf ((config.reverse-proxy.enable or false) && domain != null) {
            ${grafanaFqdn} = {
              upstream = "${grafanaConnectHost}:${toString cfg.server.grafana.port}";
              forwardAuth = true;
            };
            ${vmFqdn} = {
              upstream = "${vmConnectHost}:${toString cfg.server.metrics.port}";
              forwardAuth = true;
              bearerAuth = {
                enable = true;
                paths = ["/api/v1/write"];
                tokenFile = config.secrets.files.telemetry-ingest-token.path;
              };
            };
            ${vlFqdn} = {
              upstream = "${vlConnectHost}:${toString cfg.server.logs.port}";
              forwardAuth = true;
              bearerAuth = {
                enable = true;
                paths = ["/insert/loki/api/v1/push"];
                tokenFile = config.secrets.files.telemetry-ingest-token.path;
              };
            };
            ${alertsFqdn} = {
              upstream = "${alertsConnectHost}:${toString cfg.server.alerts.port}";
              forwardAuth = true;
            };
          };
        };

        auth.rules = lib.mkIf ((config.auth.enable or false) && domain != null) {
          ${grafanaFqdn} = {
            domain = grafanaFqdn;
            policy = "one_factor";
            subject = adminSubject;
          };
          ${vmFqdn} = {
            domain = vmFqdn;
            policy = "one_factor";
            subject = adminSubject;
          };
          ${vlFqdn} = {
            domain = vlFqdn;
            policy = "one_factor";
            subject = adminSubject;
          };
          ${alertsFqdn} = {
            domain = alertsFqdn;
            policy = "one_factor";
            subject = adminSubject;
          };
        };

        persistence.directories = lib.mkIf (config.persistence.enable or false) [
          {
            directory = "/var/lib/grafana";
            user = "grafana";
            group = "grafana";
            mode = "0750";
          }
          {
            directory = "/var/lib/victoriametrics";
            user = "victoriametrics";
            group = "victoriametrics";
            mode = "0700";
          }
          {
            directory = "/var/lib/victorialogs";
            user = "victorialogs";
            group = "victorialogs";
            mode = "0700";
          }
        ];

        backup = lib.mkIf (config.backup.enable or false) {
          paths = ["/var/lib/grafana"];
          exclude = [
            "/var/lib/victoriametrics/data"
            "/var/lib/victoriametrics/indexdb"
            "/var/lib/victoriametrics/cache"
            "/var/lib/victoriametrics/metadata"
            "/var/lib/victoriametrics/snapshots"
            "/var/lib/victoriametrics/tmp"
            "/var/lib/victorialogs/partitions"
            "/var/lib/victorialogs/indexdb"
            "/var/lib/victorialogs/cache"
          ];
          units = {
            grafana = {
              paths = ["/var/lib/grafana"];
              beforeUnits = ["grafana.service"];
            };
            telemetry = {
              scope = "host";
              paths = [
                "/var/lib/victoriametrics/.backup-stage"
                "/var/lib/victorialogs/.backup-stage"
              ];
              autoRestore = false;
              beforeUnits = [];
              destinationOverrides = {
                hbox-host = {
                  enable = true;
                  schedule = {
                    onCalendar = "*-*-* 02:30:00";
                    randomizedDelaySec = "15m";
                  };
                };
                gdrive-host = {
                  enable = true;
                  schedule = {
                    onCalendar = "*-*-* 04:00:00";
                    randomizedDelaySec = "15m";
                  };
                };
              };
              prepareCommand = ''
                rm -rf /var/lib/victoriametrics/.backup-stage /var/lib/victorialogs/.backup-stage
                vm_snap="$(${pkgs.curl}/bin/curl -fsS -X POST "${vmUrl}/snapshot/create" | ${pkgs.jq}/bin/jq -r '.snapshot')"
                if [ -n "$vm_snap" ] && [ "$vm_snap" != "null" ]; then
                  ${pkgs.coreutils}/bin/cp -alL "/var/lib/victoriametrics/snapshots/$vm_snap" /var/lib/victoriametrics/.backup-stage
                else
                  mkdir -p /var/lib/victoriametrics/.backup-stage
                fi
                mkdir -p /var/lib/victorialogs/.backup-stage/partitions
                vl_snaps="$(${pkgs.curl}/bin/curl -fsS -X POST "${vlUrl}/internal/partition/snapshot/create")"
                for snap in $(printf '%s' "$vl_snaps" | ${pkgs.jq}/bin/jq -r '.[]?'); do
                  part="$(${pkgs.coreutils}/bin/basename "$(${pkgs.coreutils}/bin/dirname "$(${pkgs.coreutils}/bin/dirname "$snap")")")"
                  ${pkgs.coreutils}/bin/cp -alL "$snap" "/var/lib/victorialogs/.backup-stage/partitions/$part"
                done
              '';
              cleanupCommand = ''
                rm -rf /var/lib/victoriametrics/.backup-stage /var/lib/victorialogs/.backup-stage
                ${pkgs.curl}/bin/curl -fsS -X POST "${vmUrl}/snapshot/delete_all" >/dev/null || true
                for snap in $(${pkgs.curl}/bin/curl -fsS -X POST "${vlUrl}/internal/partition/snapshot/list" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.[]?' 2>/dev/null || true); do
                  ${pkgs.curl}/bin/curl -fsS -X POST --url-query "path=$snap" "${vlUrl}/internal/partition/snapshot/delete" >/dev/null || true
                done
              '';
            };
          };
        };

        monitoring = {
          watchedUnits =
            ["victoriametrics.service" "victorialogs.service" "alertmanager.service" "grafana.service"]
            ++ lib.optional hasMetricsRules "vmalert-metrics.service"
            ++ lib.optional hasLogsRules "vmalert-logs.service";
          logs.journal.units =
            ["victoriametrics.service" "victorialogs.service" "alertmanager.service" "grafana.service"]
            ++ lib.optional hasMetricsRules "vmalert-metrics.service"
            ++ lib.optional hasLogsRules "vmalert-logs.service";
          scrapes =
            {
              victoriametrics.port = lib.mkDefault cfg.server.metrics.port;
              victorialogs.port = lib.mkDefault cfg.server.logs.port;
              alertmanager.port = lib.mkDefault cfg.server.alerts.port;
              grafana.port = lib.mkDefault cfg.server.grafana.port;
            }
            // lib.optionalAttrs hasMetricsRules {
              vmalert-metrics = {
                address = "127.0.0.1";
                port = vmalertMetricsPort;
              };
            }
            // lib.optionalAttrs hasLogsRules {
              vmalert-logs = {
                address = "127.0.0.1";
                port = vmalertLogsPort;
              };
            };
          services = {
            grafana = {
              units = lib.mkDefault ["grafana.service"];
              vhost = lib.mkDefault grafanaFqdn;
              backupUnit = lib.mkDefault (
                if (config.backup.enable or false)
                then "grafana"
                else null
              );
            };
            victoriametrics = {
              units = lib.mkDefault ["victoriametrics.service"];
              vhost = lib.mkDefault vmFqdn;
            };
            victorialogs = {
              units = lib.mkDefault ["victorialogs.service"];
              vhost = lib.mkDefault vlFqdn;
            };
            alertmanager = {
              units = lib.mkDefault (["alertmanager.service"]
                ++ lib.optional hasMetricsRules "vmalert-metrics.service"
                ++ lib.optional hasLogsRules "vmalert-logs.service");
              vhost = lib.mkDefault alertsFqdn;
            };
          };
          dashboards.observability-health = lib.mkDefault {
            title = "Observability Health";
            folder = "02 · Infrastructure";
            json = mkDashboard self.lib.monitoring.dashboard;
          };
        };

        resources.units = lib.mkIf (config.resources.enable or false) (
          {
            "victoriametrics.service" = {
              tier = lib.mkDefault "standard";
              memory = {
                high = lib.mkDefault "25%";
                max = lib.mkDefault "40%";
              };
            };
            "victorialogs.service" = {
              tier = lib.mkDefault "standard";
              memory = {
                high = lib.mkDefault "20%";
                max = lib.mkDefault "35%";
              };
            };
            "alertmanager.service" = {
              tier = lib.mkDefault "standard";
              memory = {
                high = lib.mkDefault "128M";
                max = lib.mkDefault "256M";
              };
            };
            "grafana.service" = {
              tier = lib.mkDefault "standard";
              memory = {
                high = lib.mkDefault "15%";
                max = lib.mkDefault "25%";
              };
            };
          }
          // lib.optionalAttrs hasMetricsRules {
            "vmalert-metrics.service".tier = lib.mkDefault "standard";
          }
          // lib.optionalAttrs hasLogsRules {
            "vmalert-logs.service".tier = lib.mkDefault "standard";
          }
        );
      }
      (lib.optionalAttrs hasHostSnapshot {
        services.hostSnapshot.exclude = lib.mkIf (config.services.hostSnapshot.enable or false) [
          "/persist/.snapshots/staging/system/var/lib/victoriametrics"
          "/persist/.snapshots/staging/system/var/lib/victorialogs"
        ];
      })
    ]);
}
