{
  internal.lgtm.mkAlloy = {
    config,
    lib,
    pkgs,
    options,
  }: let
    cfg = config.monitoring;
    agentActive = cfg.enable && cfg.agent.enable;
    hostName = config.networking.hostName;

    connectAddr = addr:
      if addr == "0.0.0.0" || addr == "::" || addr == "*"
      then "127.0.0.1"
      else addr;

    sanitizeLabel = name: let
      s = builtins.replaceStrings ["-" "." "/" ":" " "] ["_" "_" "_" "_" "_"] name;
    in
      if builtins.match "[A-Za-z_].*" s == null
      then "c_${s}"
      else s;

    escapeRegex = s:
      builtins.replaceStrings
      ["\\" "." "+" "*" "?" "(" ")" "[" "]" "{" "}" "^" "$" "|"]
      ["\\\\" "\\." "\\+" "\\*" "\\?" "\\(" "\\)" "\\[" "\\]" "\\{" "\\}" "\\^" "\\$" "\\|"]
      s;

    metricsWriteUrl =
      if cfg.agent.metricsUrl != null
      then cfg.agent.metricsUrl
      else if cfg.server.enable
      then "http://${connectAddr cfg.server.prometheus.address}:${toString cfg.server.prometheus.port}/api/v1/write"
      else null;

    logsPushUrl =
      if cfg.agent.logsUrl != null
      then cfg.agent.logsUrl
      else if cfg.server.enable
      then "http://${connectAddr cfg.server.loki.address}:${toString cfg.server.loki.port}/loki/api/v1/push"
      else null;

    externalLabels =
      {
        host = hostName;
      }
      // cfg.agent.extraLabels;

    renderLabels = attrs:
      if attrs == {}
      then "{}"
      else ''
        {
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (k: v: "    ${builtins.toJSON k} = ${builtins.toJSON v},") attrs)}
          }'';

    renderBasicAuth = let
      ba = cfg.agent.basicAuth;
    in
      lib.optionalString (ba.enable && ba.passwordFile != null) ''
        basic_auth {
              username      = ${builtins.toJSON ba.username}
              password_file = ${builtins.toJSON ba.passwordFile}
            }'';

    remoteWriteBlock = lib.optionalString (metricsWriteUrl != null) ''
      prometheus.remote_write "default" {
        external_labels = ${renderLabels externalLabels}
        endpoint {
          url = ${builtins.toJSON metricsWriteUrl}
          ${renderBasicAuth}
        }
      }
    '';

    lokiWriteBlock = lib.optionalString (logsPushUrl != null) ''
      loki.write "default" {
        external_labels = ${renderLabels externalLabels}
        endpoint {
          url = ${builtins.toJSON logsPushUrl}
          ${renderBasicAuth}
        }
      }
    '';

    watchedUnits = lib.unique cfg.watchedUnits;
    watchedUnitRegex = lib.concatStringsSep "|" (map escapeRegex watchedUnits);

    unixExporterBlock = lib.optionalString (cfg.exporters.unix.enable && metricsWriteUrl != null) (let
      unixCfg = cfg.exporters.unix;
      collectorLine =
        if unixCfg.setCollectors != []
        then "set_collectors = ${builtins.toJSON (lib.unique unixCfg.setCollectors)}"
        else if unixCfg.collectors != []
        then "enable_collectors = ${builtins.toJSON (lib.unique unixCfg.collectors)}"
        else "";
      hasWatchedUnits = watchedUnits != [];
      unixForward =
        if hasWatchedUnits
        then "prometheus.relabel.unix_watched.receiver"
        else "prometheus.remote_write.default.receiver";
    in ''
      prometheus.exporter.unix "host" {
        ${collectorLine}
      }
      ${lib.optionalString hasWatchedUnits ''

        prometheus.relabel "unix_watched" {
          rule {
            source_labels = ["__name__", "name"]
            regex         = ${builtins.toJSON "node_systemd_unit_state;(${watchedUnitRegex})"}
            target_label  = "watched"
            replacement   = "true"
          }
          forward_to = [prometheus.remote_write.default.receiver]
        }
      ''}

      prometheus.scrape "unix" {
        targets         = prometheus.exporter.unix.host.targets
        scrape_interval = ${builtins.toJSON cfg.agent.scrapeInterval}
        forward_to      = [${unixForward}]
      }
    '');

    cadvisorBlock = lib.optionalString (cfg.exporters.cadvisor.enable && metricsWriteUrl != null) ''
      prometheus.exporter.cadvisor "containers" {
        docker_only = ${lib.boolToString cfg.exporters.cadvisor.dockerOnly}
      }

      prometheus.scrape "cadvisor" {
        targets         = prometheus.exporter.cadvisor.containers.targets
        scrape_interval = ${builtins.toJSON cfg.agent.scrapeInterval}
        forward_to      = [prometheus.remote_write.default.receiver]
      }
    '';

    enabledScrapes = lib.filterAttrs (_: s: s.enable) cfg.scrapes;
    scrapeBlocks = lib.optionalString (metricsWriteUrl != null) (
      lib.concatStringsSep "\n" (lib.mapAttrsToList (sName: s: let
          sid = sanitizeLabel "scrape_${sName}";
          targetMap =
            {
              "__address__" = "${s.address}:${toString s.port}";
              job = sName;
            }
            // s.labels;
          interval =
            if s.interval != null
            then s.interval
            else cfg.agent.scrapeInterval;
        in ''
          prometheus.scrape ${builtins.toJSON sid} {
            targets         = [${renderLabels targetMap}]
            metrics_path    = ${builtins.toJSON s.metricsPath}
            scheme          = ${builtins.toJSON s.scheme}
            scrape_interval = ${builtins.toJSON interval}
            forward_to      = [prometheus.remote_write.default.receiver]
          }
        '')
        enabledScrapes)
    );

    enabledProbes = lib.filterAttrs (_: p: p.enable) cfg.probes;
    blackboxActive = (cfg.exporters.blackbox.enable || enabledProbes != {}) && metricsWriteUrl != null;

    blackboxConfigText = ''
      modules:
        http_2xx:
          prober: http
          timeout: 5s
          http:
            valid_http_versions: ["HTTP/1.1", "HTTP/2.0"]
            method: GET
            follow_redirects: true
        tcp_connect:
          prober: tcp
          timeout: 5s
        icmp:
          prober: icmp
          timeout: 5s
    '';

    probesByInterval = lib.groupBy (pName: enabledProbes.${pName}.interval) (builtins.attrNames enabledProbes);
    probeBlocks = lib.optionalString (blackboxActive && enabledProbes != {}) (
      lib.concatStringsSep "\n" (lib.mapAttrsToList (interval: pNames: let
          iid = sanitizeLabel "probes_${interval}";
          targetBlocks = lib.concatStringsSep "\n" (map (pName: let
              p = enabledProbes.${pName};
            in ''
              target {
                name    = ${builtins.toJSON pName}
                address = ${builtins.toJSON p.target}
                module  = ${builtins.toJSON p.module}
                ${lib.optionalString (p.labels != {}) "labels  = ${renderLabels p.labels}"}
              }
            '')
            pNames);
        in ''
          prometheus.exporter.blackbox ${builtins.toJSON iid} {
            config_file = "/etc/alloy/blackbox.yml"
          ${targetBlocks}}

          prometheus.scrape ${builtins.toJSON iid} {
            targets         = prometheus.exporter.blackbox.${iid}.targets
            scrape_interval = ${builtins.toJSON interval}
            forward_to      = [prometheus.remote_write.default.receiver]
          }
        '')
        probesByInterval)
    );

    journalCfg = cfg.logs.journal;
    journalBlocks = lib.optionalString (journalCfg.enable && logsPushUrl != null) (let
      journalWatchedUnits = lib.unique (journalCfg.units ++ watchedUnits);
      journalWatchedRegex = lib.concatStringsSep "|" (map escapeRegex journalWatchedUnits);
      hasStages = journalCfg.stages != [];
      journalForward =
        if hasStages
        then "loki.process.journal.receiver"
        else "loki.write.default.receiver";
      journalLabels =
        {
          job = "systemd-journal";
          host = hostName;
        }
        // journalCfg.labels;
    in ''
      loki.relabel "journal" {
        forward_to = []
        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
        rule {
          source_labels = ["__journal__hostname"]
          target_label  = "host"
        }
        rule {
          source_labels = ["__journal__priority_keyword"]
          target_label  = "level"
        }
        rule {
          source_labels = ["__journal_syslog_identifier"]
          target_label  = "syslog_identifier"
        }
        ${lib.optionalString (journalWatchedUnits != []) ''
        rule {
          source_labels = ["unit"]
          regex         = ${builtins.toJSON "^(${journalWatchedRegex})$"}
          target_label  = "watched"
          replacement   = "true"
        }
      ''}
      }

      ${lib.optionalString hasStages ''
        loki.process "journal" {
          ${lib.concatStringsSep "\n" journalCfg.stages}
          forward_to = [loki.write.default.receiver]
        }
      ''}

      loki.source.journal "journal" {
        max_age       = ${builtins.toJSON journalCfg.maxAge}
        relabel_rules = loki.relabel.journal.rules
        labels        = ${renderLabels journalLabels}
        forward_to    = [${journalForward}]
      }
    '');

    enabledFileLogs = lib.filterAttrs (_: f: f.enable && f.paths != []) cfg.logs.files;
    fileLogBlocks = lib.optionalString (logsPushUrl != null) (
      lib.concatStringsSep "\n" (lib.mapAttrsToList (fName: f: let
          sid = sanitizeLabel "file_${fName}";
          pathTargets = map (p:
            {
              __path__ = p;
              job = fName;
              host = hostName;
            }
            // f.labels)
          f.paths;
          hasStages = f.stages != [];
          fileForward =
            if hasStages
            then "loki.process.${sid}.receiver"
            else "loki.write.default.receiver";
        in ''
          local.file_match ${builtins.toJSON sid} {
            path_targets = ${builtins.toJSON pathTargets}
          }
          ${lib.optionalString hasStages ''
            loki.process ${builtins.toJSON sid} {
              ${lib.concatStringsSep "\n" f.stages}
              forward_to = [loki.write.default.receiver]
            }
          ''}
          loki.source.file ${builtins.toJSON sid} {
            targets    = local.file_match.${sid}.targets
            forward_to = [${fileForward}]
          }
        '')
        enabledFileLogs)
    );

    extraBlocksText = lib.concatStringsSep "\n" (builtins.attrValues cfg.exporters.extraBlocks);

    alloySections = lib.filter (s: lib.trim s != "") [
      remoteWriteBlock
      lokiWriteBlock
      unixExporterBlock
      cadvisorBlock
      scrapeBlocks
      probeBlocks
      journalBlocks
      fileLogBlocks
      extraBlocksText
      cfg.extraAlloyConfig
    ];

    alloyConfigText =
      if alloySections == []
      then "// No monitoring pipelines configured.\n"
      else lib.concatStringsSep "\n" alloySections;

    formattedAlloyConfig =
      pkgs.runCommand "config.alloy" {
        nativeBuildInputs = [pkgs.grafana-alloy];
        passAsFile = ["rawConfig"];
        rawConfig = alloyConfigText;
      } ''
        cp "$rawConfigPath" "$out"
        chmod +w "$out"
        alloy fmt -w "$out"
      '';

    alloyConfigSource =
      if pkgs.stdenv.buildPlatform == pkgs.stdenv.hostPlatform
      then formattedAlloyConfig
      else pkgs.writeText "config.alloy" alloyConfigText;

    hasHostSnapshot = options ? services && options.services ? hostSnapshot;
    dockerActive = config.virtualisation.docker.enable or false;
    hasBasicAuthFile = cfg.agent.basicAuth.enable && cfg.agent.basicAuth.passwordFile != null;
  in
    lib.mkIf agentActive (lib.mkMerge [
      {
        users.groups.alloy = {};
        users.users.alloy = {
          isSystemUser = true;
          group = "alloy";
          home = "/var/lib/alloy";
          extraGroups =
            ["systemd-journal"]
            ++ lib.optional dockerActive "docker";
        };

        environment.etc =
          {
            "alloy/config.alloy".source = alloyConfigSource;
          }
          // lib.optionalAttrs blackboxActive {
            "alloy/blackbox.yml".text = blackboxConfigText;
          };

        services.alloy = {
          enable = true;
          extraFlags = [
            "--server.http.listen-addr=${cfg.agent.address}:${toString cfg.agent.port}"
            "--storage.path=/var/lib/alloy"
            "--disable-reporting"
          ];
        };

        systemd.services.alloy = {
          after =
            lib.optional hasBasicAuthFile "sops-install-secrets.service"
            ++ lib.optionals cfg.server.enable ["prometheus.service" "loki.service"];
          wants = lib.optional hasBasicAuthFile "sops-install-secrets.service";
          serviceConfig = {
            DynamicUser = lib.mkForce false;
            User = "alloy";
            Group = "alloy";
          };
        };

        reverse-proxy.ports = [
          {
            owner = "alloy";
            address = cfg.agent.address;
            port = cfg.agent.port;
            protocol = "tcp";
          }
        ];

        persistence.directories = lib.mkIf (config.persistence.enable or false) [
          {
            directory = "/var/lib/alloy";
            user = "alloy";
            group = "alloy";
            mode = "0750";
          }
        ];

        backup.exclude = lib.mkIf (config.backup.enable or false) [
          "/var/lib/alloy"
        ];
      }
      (lib.optionalAttrs hasHostSnapshot {
        services.hostSnapshot.exclude = lib.mkIf (config.services.hostSnapshot.enable or false) [
          "/persist/.snapshots/staging/system/var/lib/alloy"
        ];
      })
    ]);
}
