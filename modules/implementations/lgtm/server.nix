{
  internal.lgtm.mkServer = {
    config,
    lib,
    pkgs,
    options,
  }: let
    cfg = config.monitoring;
    serverActive = cfg.enable && cfg.server.enable;
    domain = config.reverse-proxy.domain or null;

    connectAddr = addr:
      if addr == "0.0.0.0" || addr == "::" || addr == "*"
      then "127.0.0.1"
      else addr;

    grafanaConnectHost = connectAddr cfg.server.grafana.address;
    promConnectHost = connectAddr cfg.server.prometheus.address;
    lokiConnectHost = connectAddr cfg.server.loki.address;

    grafanaFqdn =
      if domain != null
      then "${cfg.server.grafana.subdomain}.${domain}"
      else null;
    promFqdn =
      if domain != null
      then "${cfg.server.prometheus.subdomain}.${domain}"
      else null;
    lokiFqdn =
      if domain != null
      then "${cfg.server.loki.subdomain}.${domain}"
      else null;

    enabledRuleGroups = lib.filterAttrs (_: g: g.enable && g.rules != []) cfg.rules;
    promRuleGroups = lib.filterAttrs (_: g: g.backend == "prometheus") enabledRuleGroups;
    lokiRuleGroups = lib.filterAttrs (_: g: g.backend == "loki") enabledRuleGroups;

    compileRuleItem = isProm: r:
      (lib.optionalAttrs (r.alert != null) {inherit (r) alert;})
      // (lib.optionalAttrs (r.record != null) {inherit (r) record;})
      // {inherit (r) expr;}
      // (lib.optionalAttrs ((r.alert != null || !isProm) && r.for != null) {inherit (r) for;})
      // (lib.optionalAttrs (r.labels != {}) {inherit (r) labels;})
      // (lib.optionalAttrs (r.alert != null && r.annotations != {}) {inherit (r) annotations;});

    compileRuleGroupFile = isProm: fileName: groups:
      pkgs.writeText fileName (builtins.toJSON {
        groups =
          lib.mapAttrsToList (gName: g: {
            name = gName;
            inherit (g) interval;
            rules = map (compileRuleItem isProm) g.rules;
          })
          groups;
      });

    promRuleFile = compileRuleGroupFile true "prometheus-rules.yml" promRuleGroups;
    lokiRuleFile = compileRuleGroupFile false "loki-rules.yml" lokiRuleGroups;

    lokiRulesDir = pkgs.runCommand "loki-rules" {} ''
      mkdir -p $out/fake
      cp ${lokiRuleFile} $out/fake/rules.yml
    '';

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

    baseLokiConfig =
      {
        auth_enabled = false;
        server = {
          http_listen_address = cfg.server.loki.address;
          http_listen_port = cfg.server.loki.port;
          grpc_listen_port = cfg.server.loki.grpcPort;
        };
        common = {
          instance_addr = "127.0.0.1";
          path_prefix = "/var/lib/loki";
          storage.filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory = "/var/lib/loki/rules";
          };
          replication_factor = 1;
          ring.kvstore.store = "inmemory";
        };
        schema_config.configs = [
          {
            from = "2024-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
        limits_config = {
          retention_period = "${toString (cfg.server.retentionDays * 24)}h";
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
          allow_structured_metadata = true;
        };
        compactor = {
          working_directory = "/var/lib/loki/compactor";
          retention_enabled = true;
          delete_request_store = "filesystem";
        };
      }
      // lib.optionalAttrs (lokiRuleGroups != {}) {
        ruler = {
          storage = {
            type = "local";
            local.directory = "${lokiRulesDir}";
          };
          rule_path = "/var/lib/loki/rules-temp";
          ring.kvstore.store = "inmemory";
          enable_api = true;
        };
      };

    hasHostSnapshot = options ? services && options.services ? hostSnapshot;
    adminSubject = ["group:${config.auth.adminGroup or "lldap_admin"}"];
  in
    lib.mkIf serverActive (lib.mkMerge [
      {
        secrets.files.grafana-secret-key = {
          store = "services/auth";
          key = "autheliaSessionSecret";
          owner = "grafana";
          group = "grafana";
          testValue = "nixconf-test-grafana-secret-key-0123456789abcdef";
        };

        services = {
          prometheus =
            lib.recursiveUpdate {
              enable = true;
              listenAddress = cfg.server.prometheus.address;
              port = cfg.server.prometheus.port;
              retentionTime = "${toString cfg.server.retentionDays}d";
              extraFlags = ["--web.enable-remote-write-receiver"];
              ruleFiles = lib.optional (promRuleGroups != {}) promRuleFile;
            }
            cfg.extraPrometheusConfig;

          loki = {
            enable = true;
            dataDir = "/var/lib/loki";
            configuration = lib.recursiveUpdate baseLokiConfig cfg.extraLokiConfig;
          };

          grafana = {
            enable = true;
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
                    name = "Prometheus";
                    uid = "prometheus";
                    type = "prometheus";
                    access = "proxy";
                    url = "http://${promConnectHost}:${toString cfg.server.prometheus.port}";
                    isDefault = true;
                    jsonData = {
                      httpMethod = "POST";
                      timeInterval = cfg.agent.scrapeInterval;
                    };
                  }
                  {
                    name = "Loki";
                    uid = "loki";
                    type = "loki";
                    access = "proxy";
                    url = "http://${lokiConnectHost}:${toString cfg.server.loki.port}";
                  }
                ];
              };
              dashboards.settings = lib.mkIf (enabledDashboards != {}) {
                apiVersion = 1;
                providers = [
                  {
                    name = "nixconf";
                    type = "file";
                    disableDeletion = true;
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
            "d /var/lib/loki 0750 loki loki -"
            "d /var/lib/loki/chunks 0750 loki loki -"
            "d /var/lib/loki/rules 0750 loki loki -"
            "d /var/lib/loki/rules-temp 0750 loki loki -"
            "d /var/lib/loki/compactor 0750 loki loki -"
          ];
          services = {
            grafana = {
              after = ["sops-install-secrets.service"];
              wants = ["sops-install-secrets.service"];
              serviceConfig = {
                StateDirectory = "grafana";
                StateDirectoryMode = "0750";
              };
            };
            loki.serviceConfig = {
              StateDirectory = "loki";
              StateDirectoryMode = "0750";
            };
          };
        };

        reverse-proxy = {
          ports = [
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
                if promFqdn != null
                then promFqdn
                else "prometheus";
              inherit (cfg.server.prometheus) address port;
              protocol = "tcp";
            }
            {
              owner =
                if lokiFqdn != null
                then lokiFqdn
                else "loki";
              inherit (cfg.server.loki) address port;
              protocol = "tcp";
            }
            {
              owner = "loki-grpc";
              address = cfg.server.loki.address;
              port = cfg.server.loki.grpcPort;
              protocol = "tcp";
            }
          ];

          hosts = lib.mkIf ((config.reverse-proxy.enable or false) && domain != null) {
            ${grafanaFqdn} = {
              upstream = "${grafanaConnectHost}:${toString cfg.server.grafana.port}";
              forwardAuth = true;
            };
            ${promFqdn} = {
              upstream = "${promConnectHost}:${toString cfg.server.prometheus.port}";
              forwardAuth = true;
            };
            ${lokiFqdn} = {
              upstream = "${lokiConnectHost}:${toString cfg.server.loki.port}";
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
          ${promFqdn} = {
            domain = promFqdn;
            policy = "one_factor";
            subject = adminSubject;
          };
          ${lokiFqdn} = {
            domain = lokiFqdn;
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
            directory = "/var/lib/${config.services.prometheus.stateDir}";
            user = "prometheus";
            group = "prometheus";
            mode = "0700";
          }
          {
            directory = "/var/lib/loki";
            user = "loki";
            group = "loki";
            mode = "0750";
          }
        ];

        backup = lib.mkIf (config.backup.enable or false) {
          paths = ["/var/lib/grafana"];
          exclude = [
            "/var/lib/${config.services.prometheus.stateDir}"
            "/var/lib/loki"
          ];
          units.grafana = {
            paths = ["/var/lib/grafana"];
            beforeUnits = ["grafana.service"];
          };
        };
      }
      (lib.optionalAttrs hasHostSnapshot {
        services.hostSnapshot.exclude = lib.mkIf (config.services.hostSnapshot.enable or false) [
          "/persist/.snapshots/staging/system/var/lib/${config.services.prometheus.stateDir}"
          "/persist/.snapshots/staging/system/var/lib/loki"
        ];
      })
    ]);
}
