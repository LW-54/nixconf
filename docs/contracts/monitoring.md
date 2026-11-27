# Contract: `monitoring`

Declarative metrics, logs, blackbox probing, alerting rules, and dashboard provisioning contract.

[← Back to Contracts Documentation](README.md) | [← Back to Main README](../../README.md)

- **Contract**: `monitoring`
- **Definition File**: [`modules/contracts/monitoring/default.nix`](../../modules/contracts/monitoring/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__agy["nixosModule/agy"]:::defaultNode
    urn__nixconf__ast__module__agy_config["nixosModule/agy-config"]:::defaultNode
    urn__nixconf__ast__module__agy_hub["nixosModule/agy-hub"]:::defaultNode
    urn__nixconf__ast__module__agy_remote_control["nixosModule/agy-remote-control"]:::defaultNode
    urn__nixconf__ast__module__alloy["nixosModule/alloy"]:::defaultNode
    urn__nixconf__ast__module__astrolabe["nixosModule/astrolabe"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_disk["nixosModule/astrolabe-disk"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_hardware["nixosModule/astrolabe-hardware"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_resources["nixosModule/astrolabe-resources"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_services["nixosModule/astrolabe-services"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_system["nixosModule/astrolabe-system"]:::defaultNode
    urn__nixconf__ast__module__attic["nixosModule/attic"]:::defaultNode
    urn__nixconf__ast__module__authelia["nixosModule/authelia"]:::defaultNode
    urn__nixconf__ast__module__caddy["nixosModule/caddy"]:::defaultNode
    urn__nixconf__ast__module__cgroups["nixosModule/cgroups"]:::defaultNode
    urn__nixconf__ast__module__copyparty["nixosModule/copyparty"]:::defaultNode
    urn__nixconf__ast__module__disko["nixosModule/disko"]:::defaultNode
    urn__nixconf__ast__module__docker["nixosModule/docker"]:::defaultNode
    urn__nixconf__ast__module__grafana["nixosModule/grafana"]:::defaultNode
    urn__nixconf__ast__module__impermanence["nixosModule/impermanence"]:::defaultNode
    urn__nixconf__ast__module__nix["nixosModule/nix"]:::defaultNode
    urn__nixconf__ast__module__ntfy["nixosModule/ntfy"]:::defaultNode
    urn__nixconf__ast__module__perf_monitor["nixosModule/perf-monitor"]:::defaultNode
    urn__nixconf__ast__module__rclone["nixosModule/rclone"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__snapshot["nixosModule/snapshot"]:::defaultNode
    urn__nixconf__ast__module__ssh["nixosModule/ssh"]:::defaultNode
    urn__nixconf__ast__module__ttyd["nixosModule/ttyd"]:::defaultNode
    urn__nixconf__ast__module__uchiyomi["nixosModule/uchiyomi"]:::defaultNode
    urn__nixconf__ast__module__vaultwarden["nixosModule/vaultwarden"]:::defaultNode
    urn__nixconf__ast__module__x240["nixosModule/x240"]:::defaultNode
    urn__nixconf__ast__module__x240_desktop["nixosModule/x240-desktop"]:::defaultNode
    urn__nixconf__ast__module__x240_disk["nixosModule/x240-disk"]:::defaultNode
    urn__nixconf__ast__module__x240_hardware["nixosModule/x240-hardware"]:::defaultNode
    urn__nixconf__ast__module__x240_resources["nixosModule/x240-resources"]:::defaultNode
    urn__nixconf__ast__module__x240_system["nixosModule/x240-system"]:::defaultNode
    urn__nixconf__ast__option__monitoring_agent[/"monitoring.agent"/]:::optNode
    urn__nixconf__ast__option__monitoring_dashboards[/"monitoring.dashboards"/]:::optNode
    urn__nixconf__ast__option__monitoring_enable[/"monitoring.enable"/]:::optNode
    urn__nixconf__ast__option__monitoring_exporters[/"monitoring.exporters"/]:::optNode
    urn__nixconf__ast__option__monitoring_extraAlloyConfig[/"monitoring.extraAlloyConfig"/]:::optNode
    urn__nixconf__ast__option__monitoring_extraGrafanaSettings[/"monitoring.extraGrafanaSettings"/]:::optNode
    urn__nixconf__ast__option__monitoring_extraLogsOptions[/"monitoring.extraLogsOptions"/]:::optNode
    urn__nixconf__ast__option__monitoring_extraMetricsOptions[/"monitoring.extraMetricsOptions"/]:::optNode
    urn__nixconf__ast__option__monitoring_logs[/"monitoring.logs"/]:::optNode
    urn__nixconf__ast__option__monitoring_probes[/"monitoring.probes"/]:::optNode
    urn__nixconf__ast__option__monitoring_rules[/"monitoring.rules"/]:::optNode
    urn__nixconf__ast__option__monitoring_scrapes[/"monitoring.scrapes"/]:::optNode
    urn__nixconf__ast__option__monitoring_server[/"monitoring.server"/]:::optNode
    urn__nixconf__ast__option__monitoring_services[/"monitoring.services"/]:::optNode
    urn__nixconf__ast__option__monitoring_watchedUnits[/"monitoring.watchedUnits"/]:::optNode
    urn__nixconf__ast__type__monitoring_agent[["monitoring.agent"]]:::typeNode
    urn__nixconf__ast__type__monitoring_dashboard[["monitoring.dashboard"]]:::typeNode
    urn__nixconf__ast__type__monitoring_exporters[["monitoring.exporters"]]:::typeNode
    urn__nixconf__ast__type__monitoring_fileLog[["monitoring.fileLog"]]:::typeNode
    urn__nixconf__ast__type__monitoring_journalLogs[["monitoring.journalLogs"]]:::typeNode
    urn__nixconf__ast__type__monitoring_logs[["monitoring.logs"]]:::typeNode
    urn__nixconf__ast__type__monitoring_ntfyNotification[["monitoring.ntfyNotification"]]:::typeNode
    urn__nixconf__ast__type__monitoring_probe[["monitoring.probe"]]:::typeNode
    urn__nixconf__ast__type__monitoring_retention[["monitoring.retention"]]:::typeNode
    urn__nixconf__ast__type__monitoring_ruleGroup[["monitoring.ruleGroup"]]:::typeNode
    urn__nixconf__ast__type__monitoring_ruleItem[["monitoring.ruleItem"]]:::typeNode
    urn__nixconf__ast__type__monitoring_scrape[["monitoring.scrape"]]:::typeNode
    urn__nixconf__ast__type__monitoring_server[["monitoring.server"]]:::typeNode
    urn__nixconf__ast__type__monitoring_service[["monitoring.service"]]:::typeNode
    urn__nixconf__drv__devShell__gemini_api["devShell/gemini-api"]:::devShellNode
    urn__nixconf__drv__devShell__master_ssh["devShell/master-ssh"]:::devShellNode
    urn__nixconf__drv__package__agent_git_bootstrap[("package/agent-git-bootstrap")]:::pkgNode
    urn__nixconf__drv__package__agy[("package/agy")]:::pkgNode
    urn__nixconf__drv__package__agy_api[("package/agy-api")]:::pkgNode
    urn__nixconf__drv__package__antigravity[("package/antigravity")]:::pkgNode
    urn__nixconf__drv__package__antigravity_ide[("package/antigravity-ide")]:::pkgNode
    urn__nixconf__drv__package__attic_bootstrap[("package/attic-bootstrap")]:::pkgNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__eval__configuration__x240(["nixosConfiguration/x240"]):::hostNode
    urn__nixconf__onto__contract__auth{{"auth"}}:::contractNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__monitoring{{"monitoring"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__resources{{"resources"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__storage{{"storage"}}:::contractNode
    urn__nixconf__onto__feature__antigravity("antigravity"):::featureNode
    urn__nixconf__onto__feature__attic("attic"):::featureNode
    urn__nixconf__onto__feature__audio("audio"):::featureNode
    urn__nixconf__onto__feature__bitwarden("bitwarden"):::featureNode
    urn__nixconf__onto__feature__copyparty("copyparty"):::featureNode
    urn__nixconf__onto__feature__cursor("cursor"):::featureNode
    urn__nixconf__onto__feature__direnv("direnv"):::featureNode
    urn__nixconf__onto__feature__disko("disko"):::featureNode
    urn__nixconf__onto__feature__docker("docker"):::featureNode
    urn__nixconf__onto__feature__dolphin("dolphin"):::featureNode
    urn__nixconf__onto__feature__fonts("fonts"):::featureNode
    urn__nixconf__onto__feature__foot("foot"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__greetd("greetd"):::featureNode
    urn__nixconf__onto__feature__labwc("labwc"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__feature__micro("micro"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__noctalia("noctalia"):::featureNode
    urn__nixconf__onto__feature__ntfy("ntfy"):::featureNode
    urn__nixconf__onto__feature__perf_monitor("perf-monitor"):::featureNode
    urn__nixconf__onto__feature__snapshot("snapshot"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__tack("tack"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__uchiyomi("uchiyomi"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__feature__vivaldi("vivaldi"):::featureNode
    urn__nixconf__onto__feature__vscode("vscode"):::featureNode
    urn__nixconf__onto__feature__wifi_eduroam("wifi-eduroam"):::featureNode
    urn__nixconf__onto__feature__zed("zed"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__alloy["alloy"]:::implNode
    urn__nixconf__onto__implementation__authelia["authelia"]:::implNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
    urn__nixconf__onto__implementation__grafana["grafana"]:::implNode
    urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__rclone["rclone"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode
    urn__nixconf__onto__implementation__uwsm["uwsm"]:::implNode

    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__agent_git_bootstrap
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__agent_git_bootstrap
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__agent_git_bootstrap
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__agy_hub -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__agy_hub -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__agy_hub -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__agy_hub -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__agy_hub -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__agy_hub -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__agy_hub -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__agy_hub -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__agy_hub -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__agent_git_bootstrap
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__alloy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__alloy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__alloy -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_agent
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_extraGrafanaSettings
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__astrolabe -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__astrolabe -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__astrolabe -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__astrolabe -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__astrolabe -.->|writes| urn__nixconf__ast__option__monitoring_extraGrafanaSettings
    urn__nixconf__ast__module__astrolabe -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__astrolabe -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__astrolabe_resources -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__astrolabe_services -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__attic -->|dependsOn| urn__nixconf__drv__package__attic_bootstrap
    urn__nixconf__ast__module__attic -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__attic -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__attic -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__attic -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__attic -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__attic -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__attic -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__attic -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__attic -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__attic -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__disko -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__disko -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__disko -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__disko -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__docker -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__docker -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__docker -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__docker -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__docker -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__docker -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__docker -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__authelia
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__grafana -.->|reads| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__grafana -.->|reads| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__grafana -.->|reads| urn__nixconf__ast__option__monitoring_extraGrafanaSettings
    urn__nixconf__ast__module__grafana -.->|reads| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__grafana -.->|reads| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__grafana -.->|reads| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__grafana -.->|reads| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__ast__module__grafana -.->|reads| urn__nixconf__ast__option__monitoring_server
    urn__nixconf__ast__module__grafana -.->|reads| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__grafana -.->|reads| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_server
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__impermanence -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__impermanence -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__impermanence -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_server
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__perf_monitor -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__perf_monitor -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__perf_monitor -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__perf_monitor -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__perf_monitor -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__perf_monitor -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__x240 -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__x240 -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__x240 -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__x240 -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__x240 -.->|writes| urn__nixconf__ast__option__monitoring_extraGrafanaSettings
    urn__nixconf__ast__module__x240 -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__x240 -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__x240_resources -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__monitoring_agent
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_agent
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_dashboard
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_exporters
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_fileLog
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_journalLogs
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_logs
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_ntfyNotification
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_probe
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_retention
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleGroup
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleItem
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_scrape
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_server
    urn__nixconf__ast__option__monitoring_agent -.->|typedBy| urn__nixconf__ast__type__monitoring_service
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_agent
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_dashboard
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_exporters
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_fileLog
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_journalLogs
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_logs
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_ntfyNotification
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_probe
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_retention
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleGroup
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleItem
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_scrape
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_server
    urn__nixconf__ast__option__monitoring_dashboards -.->|typedBy| urn__nixconf__ast__type__monitoring_service
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_agent
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_dashboard
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_exporters
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_fileLog
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_journalLogs
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_logs
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_ntfyNotification
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_probe
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_retention
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleGroup
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleItem
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_scrape
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_server
    urn__nixconf__ast__option__monitoring_exporters -.->|typedBy| urn__nixconf__ast__type__monitoring_service
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_agent
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_dashboard
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_exporters
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_fileLog
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_journalLogs
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_logs
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_ntfyNotification
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_probe
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_retention
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleGroup
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleItem
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_scrape
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_server
    urn__nixconf__ast__option__monitoring_logs -.->|typedBy| urn__nixconf__ast__type__monitoring_service
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_agent
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_dashboard
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_exporters
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_fileLog
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_journalLogs
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_logs
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_ntfyNotification
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_probe
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_retention
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleGroup
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleItem
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_scrape
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_server
    urn__nixconf__ast__option__monitoring_probes -.->|typedBy| urn__nixconf__ast__type__monitoring_service
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_agent
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_dashboard
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_exporters
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_fileLog
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_journalLogs
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_logs
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_ntfyNotification
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_probe
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_retention
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleGroup
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleItem
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_scrape
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_server
    urn__nixconf__ast__option__monitoring_rules -.->|typedBy| urn__nixconf__ast__type__monitoring_service
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_agent
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_dashboard
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_exporters
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_fileLog
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_journalLogs
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_logs
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_ntfyNotification
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_probe
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_retention
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleGroup
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleItem
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_scrape
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_server
    urn__nixconf__ast__option__monitoring_scrapes -.->|typedBy| urn__nixconf__ast__type__monitoring_service
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_agent
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_dashboard
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_exporters
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_fileLog
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_journalLogs
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_logs
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_ntfyNotification
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_probe
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_retention
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleGroup
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleItem
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_scrape
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_server
    urn__nixconf__ast__option__monitoring_server -.->|typedBy| urn__nixconf__ast__type__monitoring_service
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_agent
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_dashboard
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_exporters
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_fileLog
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_journalLogs
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_logs
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_ntfyNotification
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_probe
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_retention
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleGroup
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_ruleItem
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_scrape
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_server
    urn__nixconf__ast__option__monitoring_services -.->|typedBy| urn__nixconf__ast__type__monitoring_service
    urn__nixconf__drv__devShell__gemini_api -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__eval__configuration__astrolabe -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__agy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__agy_hub
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_resources
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__attic
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__authelia
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__caddy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__cgroups
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__copyparty
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__disko
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__grafana
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ntfy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__perf_monitor
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__rclone
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__snapshot
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ttyd
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__eval__configuration__x240 -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__agy
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__alloy
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__cgroups
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__disko
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__docker
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__rclone
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_disk
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_resources
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_system
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_agent
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_enable
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_extraAlloyConfig
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_extraGrafanaSettings
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_extraLogsOptions
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_extraMetricsOptions
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_server
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_agent
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_dashboard
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_exporters
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_fileLog
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_journalLogs
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_logs
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_ntfyNotification
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_probe
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_retention
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_ruleGroup
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_ruleItem
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_scrape
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_server
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__type__monitoring_service
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_config
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_hub
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_remote_control
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__devShell__gemini_api
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__agent_git_bootstrap
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__agy
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__agy_api
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__antigravity
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__attic -->|outputs| urn__nixconf__ast__module__attic
    urn__nixconf__onto__feature__attic -->|outputs| urn__nixconf__drv__package__attic_bootstrap
    urn__nixconf__onto__feature__attic -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__attic -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__attic -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__attic -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__attic -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__bitwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__copyparty -->|outputs| urn__nixconf__ast__module__copyparty
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__feature__direnv -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__disko -->|outputs| urn__nixconf__ast__module__disko
    urn__nixconf__onto__feature__disko -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__docker -->|outputs| urn__nixconf__ast__module__docker
    urn__nixconf__onto__feature__docker -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__docker -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__docker -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__dolphin -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__foot -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__foot -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__git -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__locale -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__nix -->|outputs| urn__nixconf__ast__module__nix
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__noctalia -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ntfy -->|outputs| urn__nixconf__ast__module__ntfy
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__perf_monitor -->|outputs| urn__nixconf__ast__module__perf_monitor
    urn__nixconf__onto__feature__perf_monitor -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__perf_monitor -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__snapshot -->|outputs| urn__nixconf__ast__module__snapshot
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__ast__module__ssh
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__drv__devShell__master_ssh
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ttyd -->|outputs| urn__nixconf__ast__module__ttyd
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -->|outputs| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__feature__vaultwarden -->|outputs| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vivaldi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__wifi_eduroam -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__zed -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__zed -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_resources
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__eval__configuration__astrolabe
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__attic
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__copyparty
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__micro
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ntfy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__perf_monitor
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__snapshot
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__tack
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__uchiyomi
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__authelia
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__grafana
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__rclone
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_disk
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_resources
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_system
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__eval__configuration__x240
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__audio
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__cursor
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__docker
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__dolphin
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__fonts
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__foot
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__greetd
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__micro
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__tack
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__wifi_eduroam
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__zed
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__alloy
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__rclone
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__uwsm
    urn__nixconf__onto__implementation__alloy -->|outputs| urn__nixconf__ast__module__alloy
    urn__nixconf__onto__implementation__alloy -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__alloy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__alloy -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__alloy -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__alloy ==>|implements| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__authelia -->|outputs| urn__nixconf__ast__module__authelia
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__auth
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__authelia ==>|implements| urn__nixconf__onto__contract__auth
    urn__nixconf__onto__implementation__caddy -->|outputs| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy ==>|implements| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__cgroups -->|outputs| urn__nixconf__ast__module__cgroups
    urn__nixconf__onto__implementation__cgroups -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__cgroups -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__cgroups -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__cgroups -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__implementation__cgroups ==>|implements| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__grafana -->|outputs| urn__nixconf__ast__module__grafana
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__auth
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__grafana ==>|implements| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__hjem ==>|implements| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__impermanence -->|outputs| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__impermanence ==>|implements| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__rclone -->|outputs| urn__nixconf__ast__module__rclone
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__rclone ==>|implements| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__implementation__restic -->|outputs| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__implementation__restic ==>|implements| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__sops -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops ==>|implements| urn__nixconf__onto__contract__secrets


    click urn__nixconf__ast__module__agy href "../modules/agy.md" "agy"
    click urn__nixconf__ast__module__agy_config href "../modules/agy-config.md" "agy-config"
    click urn__nixconf__ast__module__agy_hub href "../modules/agy-hub.md" "agy-hub"
    click urn__nixconf__ast__module__agy_remote_control href "../modules/agy-remote-control.md" "agy-remote-control"
    click urn__nixconf__ast__module__alloy href "../modules/alloy.md" "alloy"
    click urn__nixconf__ast__module__astrolabe href "../modules/astrolabe.md" "astrolabe"
    click urn__nixconf__ast__module__astrolabe_disk href "../modules/astrolabe-disk.md" "astrolabe-disk"
    click urn__nixconf__ast__module__astrolabe_hardware href "../modules/astrolabe-hardware.md" "astrolabe-hardware"
    click urn__nixconf__ast__module__astrolabe_resources href "../modules/astrolabe-resources.md" "astrolabe-resources"
    click urn__nixconf__ast__module__astrolabe_services href "../modules/astrolabe-services.md" "astrolabe-services"
    click urn__nixconf__ast__module__astrolabe_system href "../modules/astrolabe-system.md" "astrolabe-system"
    click urn__nixconf__ast__module__attic href "../modules/attic.md" "attic"
    click urn__nixconf__ast__module__authelia href "../modules/authelia.md" "authelia"
    click urn__nixconf__ast__module__caddy href "../modules/caddy.md" "caddy"
    click urn__nixconf__ast__module__cgroups href "../modules/cgroups.md" "cgroups"
    click urn__nixconf__ast__module__copyparty href "../modules/copyparty.md" "copyparty"
    click urn__nixconf__ast__module__disko href "../modules/disko.md" "disko"
    click urn__nixconf__ast__module__docker href "../modules/docker.md" "docker"
    click urn__nixconf__ast__module__grafana href "../modules/grafana.md" "grafana"
    click urn__nixconf__ast__module__impermanence href "../modules/impermanence.md" "impermanence"
    click urn__nixconf__ast__module__nix href "../modules/nix.md" "nix"
    click urn__nixconf__ast__module__ntfy href "../modules/ntfy.md" "ntfy"
    click urn__nixconf__ast__module__perf_monitor href "../modules/perf-monitor.md" "perf-monitor"
    click urn__nixconf__ast__module__rclone href "../modules/rclone.md" "rclone"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__snapshot href "../modules/snapshot.md" "snapshot"
    click urn__nixconf__ast__module__ssh href "../modules/ssh.md" "ssh"
    click urn__nixconf__ast__module__ttyd href "../modules/ttyd.md" "ttyd"
    click urn__nixconf__ast__module__uchiyomi href "../modules/uchiyomi.md" "uchiyomi"
    click urn__nixconf__ast__module__vaultwarden href "../modules/vaultwarden.md" "vaultwarden"
    click urn__nixconf__ast__module__x240 href "../modules/x240.md" "x240"
    click urn__nixconf__ast__module__x240_desktop href "../modules/x240-desktop.md" "x240-desktop"
    click urn__nixconf__ast__module__x240_disk href "../modules/x240-disk.md" "x240-disk"
    click urn__nixconf__ast__module__x240_hardware href "../modules/x240-hardware.md" "x240-hardware"
    click urn__nixconf__ast__module__x240_resources href "../modules/x240-resources.md" "x240-resources"
    click urn__nixconf__ast__module__x240_system href "../modules/x240-system.md" "x240-system"
    click urn__nixconf__ast__option__monitoring_agent href "monitoring.md" "monitoring.agent"
    click urn__nixconf__ast__option__monitoring_dashboards href "monitoring.md" "monitoring.dashboards"
    click urn__nixconf__ast__option__monitoring_enable href "monitoring.md" "monitoring.enable"
    click urn__nixconf__ast__option__monitoring_exporters href "monitoring.md" "monitoring.exporters"
    click urn__nixconf__ast__option__monitoring_extraAlloyConfig href "monitoring.md" "monitoring.extraAlloyConfig"
    click urn__nixconf__ast__option__monitoring_extraGrafanaSettings href "monitoring.md" "monitoring.extraGrafanaSettings"
    click urn__nixconf__ast__option__monitoring_extraLogsOptions href "monitoring.md" "monitoring.extraLogsOptions"
    click urn__nixconf__ast__option__monitoring_extraMetricsOptions href "monitoring.md" "monitoring.extraMetricsOptions"
    click urn__nixconf__ast__option__monitoring_logs href "monitoring.md" "monitoring.logs"
    click urn__nixconf__ast__option__monitoring_probes href "monitoring.md" "monitoring.probes"
    click urn__nixconf__ast__option__monitoring_rules href "monitoring.md" "monitoring.rules"
    click urn__nixconf__ast__option__monitoring_scrapes href "monitoring.md" "monitoring.scrapes"
    click urn__nixconf__ast__option__monitoring_server href "monitoring.md" "monitoring.server"
    click urn__nixconf__ast__option__monitoring_services href "monitoring.md" "monitoring.services"
    click urn__nixconf__ast__option__monitoring_watchedUnits href "monitoring.md" "monitoring.watchedUnits"
    click urn__nixconf__ast__type__monitoring_agent href "monitoring.md" "monitoring.agent"
    click urn__nixconf__ast__type__monitoring_dashboard href "monitoring.md" "monitoring.dashboard"
    click urn__nixconf__ast__type__monitoring_exporters href "monitoring.md" "monitoring.exporters"
    click urn__nixconf__ast__type__monitoring_fileLog href "monitoring.md" "monitoring.fileLog"
    click urn__nixconf__ast__type__monitoring_journalLogs href "monitoring.md" "monitoring.journalLogs"
    click urn__nixconf__ast__type__monitoring_logs href "monitoring.md" "monitoring.logs"
    click urn__nixconf__ast__type__monitoring_ntfyNotification href "monitoring.md" "monitoring.ntfyNotification"
    click urn__nixconf__ast__type__monitoring_probe href "monitoring.md" "monitoring.probe"
    click urn__nixconf__ast__type__monitoring_retention href "monitoring.md" "monitoring.retention"
    click urn__nixconf__ast__type__monitoring_ruleGroup href "monitoring.md" "monitoring.ruleGroup"
    click urn__nixconf__ast__type__monitoring_ruleItem href "monitoring.md" "monitoring.ruleItem"
    click urn__nixconf__ast__type__monitoring_scrape href "monitoring.md" "monitoring.scrape"
    click urn__nixconf__ast__type__monitoring_server href "monitoring.md" "monitoring.server"
    click urn__nixconf__ast__type__monitoring_service href "monitoring.md" "monitoring.service"
    click urn__nixconf__drv__devShell__gemini_api href "../devshells.md#gemini-api" "gemini-api"
    click urn__nixconf__drv__devShell__master_ssh href "../devshells.md#master-ssh" "master-ssh"
    click urn__nixconf__drv__package__agent_git_bootstrap href "../packages.md#agent-git-bootstrap" "agent-git-bootstrap"
    click urn__nixconf__drv__package__agy href "../packages.md#agy" "agy"
    click urn__nixconf__drv__package__agy_api href "../packages.md#agy-api" "agy-api"
    click urn__nixconf__drv__package__antigravity href "../packages.md#antigravity" "antigravity"
    click urn__nixconf__drv__package__antigravity_ide href "../packages.md#antigravity-ide" "antigravity-ide"
    click urn__nixconf__drv__package__attic_bootstrap href "../packages.md#attic-bootstrap" "attic-bootstrap"
    click urn__nixconf__eval__configuration__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__eval__configuration__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__contract__auth href "auth.md" "auth"
    click urn__nixconf__onto__contract__backup href "backup.md" "backup"
    click urn__nixconf__onto__contract__home href "home.md" "home"
    click urn__nixconf__onto__contract__monitoring href "monitoring.md" "monitoring"
    click urn__nixconf__onto__contract__persistence href "persistence.md" "persistence"
    click urn__nixconf__onto__contract__resources href "resources.md" "resources"
    click urn__nixconf__onto__contract__reverse_proxy href "reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "secrets.md" "secrets"
    click urn__nixconf__onto__contract__storage href "storage.md" "storage"
    click urn__nixconf__onto__feature__antigravity href "../features/antigravity.md" "antigravity"
    click urn__nixconf__onto__feature__attic href "../features/attic.md" "attic"
    click urn__nixconf__onto__feature__audio href "../features/audio.md" "audio"
    click urn__nixconf__onto__feature__bitwarden href "../features/bitwarden.md" "bitwarden"
    click urn__nixconf__onto__feature__copyparty href "../features/copyparty.md" "copyparty"
    click urn__nixconf__onto__feature__cursor href "../features/cursor.md" "cursor"
    click urn__nixconf__onto__feature__direnv href "../features/direnv.md" "direnv"
    click urn__nixconf__onto__feature__disko href "../features/disko.md" "disko"
    click urn__nixconf__onto__feature__docker href "../features/docker.md" "docker"
    click urn__nixconf__onto__feature__dolphin href "../features/dolphin.md" "dolphin"
    click urn__nixconf__onto__feature__fonts href "../features/fonts.md" "fonts"
    click urn__nixconf__onto__feature__foot href "../features/foot.md" "foot"
    click urn__nixconf__onto__feature__git href "../features/git.md" "git"
    click urn__nixconf__onto__feature__greetd href "../features/greetd.md" "greetd"
    click urn__nixconf__onto__feature__labwc href "../features/labwc.md" "labwc"
    click urn__nixconf__onto__feature__locale href "../features/locale.md" "locale"
    click urn__nixconf__onto__feature__micro href "../features/micro.md" "micro"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__noctalia href "../features/noctalia.md" "noctalia"
    click urn__nixconf__onto__feature__ntfy href "../features/ntfy.md" "ntfy"
    click urn__nixconf__onto__feature__perf_monitor href "../features/perf-monitor.md" "perf-monitor"
    click urn__nixconf__onto__feature__snapshot href "../features/snapshot.md" "snapshot"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__tack href "../features/tack.md" "tack"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__uchiyomi href "../features/uchiyomi.md" "uchiyomi"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__feature__vivaldi href "../features/vivaldi.md" "vivaldi"
    click urn__nixconf__onto__feature__vscode href "../features/vscode.md" "vscode"
    click urn__nixconf__onto__feature__wifi_eduroam href "../features/wifi-eduroam.md" "wifi-eduroam"
    click urn__nixconf__onto__feature__zed href "../features/zed.md" "zed"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__alloy href "../implementations/alloy.md" "alloy"
    click urn__nixconf__onto__implementation__authelia href "../implementations/authelia.md" "authelia"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__cgroups href "../implementations/cgroups.md" "cgroups"
    click urn__nixconf__onto__implementation__grafana href "../implementations/grafana.md" "grafana"
    click urn__nixconf__onto__implementation__hjem href "../implementations/hjem.md" "hjem"
    click urn__nixconf__onto__implementation__impermanence href "../implementations/impermanence.md" "impermanence"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"
    click urn__nixconf__onto__implementation__rclone href "../implementations/rclone.md" "rclone"
    click urn__nixconf__onto__implementation__restic href "../implementations/restic.md" "restic"
    click urn__nixconf__onto__implementation__sops href "../implementations/sops.md" "sops"
    click urn__nixconf__onto__implementation__uwsm href "../implementations/uwsm.md" "uwsm"

  %% Semantic Visual Classes
  classDef hostNode fill:#1e293b,stroke:#38bdf8,stroke-width:2px,color:#f8fafc;
  classDef contractNode fill:#1e1b4b,stroke:#818cf8,stroke-width:2px,color:#f8fafc;
  classDef implNode fill:#0f172a,stroke:#34d399,stroke-width:2px,color:#f8fafc;
  classDef featureNode fill:#134e4a,stroke:#2dd4bf,stroke-width:2px,color:#f8fafc;
  classDef optNode fill:#422006,stroke:#facc15,stroke-width:1px,color:#fefce8;
  classDef typeNode fill:#3b0764,stroke:#c084fc,stroke-width:1px,color:#faf5ff;
  classDef pkgNode fill:#4c0519,stroke:#fb7185,stroke-width:1px,color:#fff1f2;
  classDef devShellNode fill:#451a03,stroke:#fb923c,stroke-width:1px,color:#fff7ed;
  classDef drvNode fill:#18181b,stroke:#a1a1aa,stroke-width:1px,color:#f4f4f5;
  classDef defaultNode fill:#1e293b,stroke:#64748b,stroke-width:1px,color:#f8fafc;
```

</details>

## Outputs

### NixOS Modules

| Module | Description | Docs |
| :--- | :--- | :--- |
| [`monitoring`](../modules/monitoring.md) | Declarative metrics, logs, blackbox probing, alerting rules, and dashboard provisioning contract. | [More →](../modules/monitoring.md) |

### Library Helpers

| Symbol | Type | Description | Docs |
| :--- | :--- | :--- | :--- |
| [`dashboard`](../lib/monitoring.md#dashboard) | `dashboard :: AttrSet  # Values - `ds`: Provisioned metrics and logs datasource descriptor references (`metrics`, `prometheus`, `logs`). - `promTarget`, `logsTarget`: Construct metrics (`PromQL`/`MetricsQL`) or logs (`LogsQL`) target objects (`expr`, `legend`, `queryType`). - `thresholds`, `mappings`: Standard threshold presets and Grafana value mappings. - `links`: Click-to-drilldown Grafana data links (`toTaskManager`, `toTimeMachine`, `toHostHardware`, `toService`, `toUnitLogs`, `toCapacityAnalytics`, `toTrendsExplorer`, `toMetricWorkbench`, `toStorageAtlas`). - `vars`: Template variable constructors (`host`, `promQuery`, `logsField`, `custom`, `textbox`). - `statToggleExpr`, `statBandOverrides`, `systemdOpsParsePipe`: Statistical envelope toggles, overlay styling, and systemd accounting LogsQL parser. - `mkStat`, `mkRatioStat`, `mkBarGauge`, `mkTimeseries`, `mkTable`, `mkStorageTable`, `mkSystemdUnitsTable`, `mkLogs`, `mkText`, `mkEcharts`, `mkStorageTreemap`, `mkMemoryHeatmapTreemap`: Pre-styled Grafana v39 panel and interactive ECharts treemap builders. - `mkRow`, `mkSection`, `mkDashboard`: Responsive 24-column grid layout engine with automatic host event annotations (`Reboots`, `NixOS Deployments`, `OOM Kills`, `Unit Failures`) and top navigation bar. - `mkFleetOverviewDashboard`, `mkTaskManagerDashboard`, `mkTimeMachineDashboard`, `mkTrendsExplorerDashboard`, `mkMetricWorkbenchDashboard`, `mkStorageAtlasDashboard`, `mkLogsExplorerDashboard`, `mkHostHardwareDashboard`, `mkCapacityAnalyticsDashboard`, `mkServicesCatalogDashboard`, `mkServiceInspectorDashboard`, `mkContainersDashboard`: Core infrastructure, statistical capacity, trend exploration, custom metric workbench, storage treemap atlas, and investigation dashboards.` | Opinionated Grafana schema v39 dashboard, layout, panel, variable, annotation, and threshold builders shared across monitoring consumers. | [More →](../lib/monitoring.md#dashboard) |
| [`mkConfig`](../lib/monitoring.md#mkConfig) | `monitoring.mkConfig :: AttrSet -> AttrSet` | Auto-derived configuration binding helper for the 'monitoring' contract. | [More →](../lib/monitoring.md#mkConfig) |
| [`mkOption`](../lib/monitoring.md#mkOption) | `monitoring.mkOption :: AttrSet -> AttrSet` | Auto-derived option constructor for the 'monitoring' contract. | [More →](../lib/monitoring.md#mkOption) |

### Custom Types

- `agent`: submodule
- `dashboard`: submodule
- `exporters`: submodule
- `fileLog`: submodule
- `journalLogs`: submodule
- `logs`: submodule
- `ntfyNotification`: submodule
- `probe`: submodule
- `retention`: submodule
- `ruleGroup`: submodule
- `ruleItem`: submodule
- `scrape`: submodule
- `server`: submodule
- `service`: submodule

## Option Schema Definitions

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `monitoring.agent` | `submodule` | `{ }` | Local telemetry collector agent configuration for metrics scraping, log shipping, and remote-write buffering. |
| `monitoring.dashboards` | `attribute set of (submodule)` | `{ }` | Attribute set of declarative Grafana dashboards provisioned automatically as code. |
| `monitoring.enable` | `boolean` | `false` | Whether to enable declarative system and service monitoring contract. |
| `monitoring.exporters` | `submodule` | `{ }` | Built-in telemetry exporter configurations (host OS, containers, blackbox probing, and custom blocks). |
| `monitoring.extraAlloyConfig` | `strings concatenated with "\n"` | `""` | Raw Grafana Alloy River configuration blocks appended directly to `/etc/alloy/config.alloy`. |
| `monitoring.extraGrafanaSettings` | `attribute set of anything` | `{ }` | Additional backend-specific attributes merged into `services.grafana.settings`. |
| `monitoring.extraLogsOptions` | `list of string` | `[ ]` | Additional backend-specific CLI flags passed to the central logs storage daemon. |
| `monitoring.extraMetricsOptions` | `list of string` | `[ ]` | Additional backend-specific CLI flags passed to the central metrics storage daemon. |
| `monitoring.logs` | `submodule` | `{ }` | Declarative systemd journal and file-based log ingestion sources. |
| `monitoring.probes` | `attribute set of (submodule)` | `{ }` | Attribute set of blackbox health probes checking HTTP, TCP, or ICMP endpoint reachability. |
| `monitoring.rules` | `attribute set of (submodule)` | `{ }` | Attribute set of alerting and recording rule groups evaluated against metrics or logs. |
| `monitoring.scrapes` | `attribute set of (submodule)` | `{ }` | Attribute set of Prometheus scrape targets collected by the local telemetry agent. |
| `monitoring.server` | `submodule` | `{ }` | Central telemetry ingestion, time-series storage, alerting, and visualization server configuration. |
| `monitoring.services` | `attribute set of (submodule)` | `{ }` | Declarative service catalog mapping logical application names to systemd units, virtual hosts, backup jobs, and storage mounts. |
| `monitoring.watchedUnits` | `list of string` | `[ ]` | Critical systemd units (services, timers, or mounts) registered for health monitoring and journal tracking. |

## Fulfilling Implementations

Providers satisfying the `monitoring` contract capability:

| Implementation | Description | Definition | Docs |
| :--- | :--- | :--- | :--- |
| [`alloy`](../implementations/alloy.md) | Telemetry collection agent implementation using Grafana Alloy for metrics scraping, log shipping, and blackbox probing. | [`modules/implementations/grafana/default.nix`](../../modules/implementations/grafana/default.nix) | [More →](../implementations/alloy.md) |
| [`grafana`](../implementations/grafana.md) | Full observability stack implementation using Grafana, VictoriaMetrics, VictoriaLogs, vmalert, Alertmanager, and Grafana Alloy. | [`modules/implementations/grafana/default.nix`](../../modules/implementations/grafana/default.nix) | [More →](../implementations/grafana.md) |

## Contract Consumers

Modules and instances configuring options under the `monitoring` contract capability:

### Hosts

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.exporters`, `monitoring.extraGrafanaSettings`, `monitoring.logs`, `monitoring.rules`

```nix
config = {
  monitoring.dashboards = { auth-security = { enable = true; folder = "02 · Infrastructure"; json = { /* 16 attrs: annotations, description, editable, fiscalYearStartMonth, graphTooltip, ... */ }; title = "Authentication & Security"; }; backups = { enable = true; folder = "02 · Infrastructure"; json = { /* 16 attrs: annotations, description, editable, fiscalYearStartMonth, graphTooltip, ... */ }; title = "Backups & Snapshots"; }; capacity-analytics = { enable = true; folder = "02 · Infrastructure"; json = { /* 16 attrs: annotations, description, editable, fiscalYearStartMonth, graphTooltip, ... */ }; title = "Capacity, Right-Sizing & Operations"; }; containers = { enable = true; folder = "03 · Services"; json = { /* 16 attrs: annotations, description, editable, fiscalYearStartMonth, graphTooltip, ... */ }; title = "Containers & OCI"; }; fleet-overview = { enable = true; folder = "00 · Overview"; json = { /* 16 attrs: annotations, description, editable, fiscalYearStartMonth, graphTooltip, ... */ }; title = "Fleet Command Center"; }; host-hardware = { enable = true; folder = "02 · Infrastructure"; json = { /* 16 attrs: annotations, description, editable, fiscalYearStartMonth, graphTooltip, ... */ }; title = "Host & Hardware"; }; ingress = { enable = true; folder = "02 · Infrastructure"; json = { /* 16 attrs: annotations, description, editable, fiscalYearStartMonth, graphTooltip, ... */ }; title = "Ingress & Edge"; }; logs-explorer = { enable = true; folder = "01 · Investigate"; json = { /* 16 attrs: annotations, description, editable, fiscalYearStartMonth, graphTooltip, ... */ }; title = "Logs Explorer"; }; /* ... +10 more */ };
  monitoring.exporters = { blackbox = { enable = false; }; cadvisor = { dockerOnly = false; enable = true; }; extraBlocks = {}; process = { enable = true; }; unix = { collectors = [ /* 19 items */ ]; enable = true; setCollectors = []; textfileDirectory = "/var/lib/alloy/textfile"; }; };
  monitoring.extraGrafanaSettings = { users = { home_page = "/d/nixconf-fleet-overview"; }; };
  monitoring.logs = { files = {}; journal = { enable = true; labels = {}; maxAge = "12h"; stages = []; units = [ /* 50 items */ ]; }; };
  monitoring.rules = { authelia = { backend = "metrics"; enable = true; interval = "1m"; rules = [ /* 1 items */ ]; }; authelia-logs = { backend = "logs"; enable = true; interval = "1m"; rules = [ /* 1 items */ ]; }; caddy = { backend = "metrics"; enable = true; interval = "1m"; rules = [ /* 2 items */ ]; }; disk = { backend = "metrics"; enable = true; interval = "1m"; rules = [ /* 2 items */ ]; }; host = { backend = "metrics"; enable = true; interval = "1m"; rules = [ /* 3 items */ ]; }; nixconf-perf = { backend = "metrics"; enable = true; interval = "5m"; rules = [ /* 7 items */ ]; }; operations-recording = { backend = "logs"; enable = true; interval = "5m"; rules = [ /* 6 items */ ]; }; persistence = { backend = "metrics"; enable = true; interval = "1m"; rules = [ /* 1 items */ ]; }; /* ... +6 more */ };
};
```

</details>


<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

**Configures options**: `monitoring.agent`, `monitoring.dashboards`, `monitoring.exporters`, `monitoring.extraGrafanaSettings`, `monitoring.logs`, `monitoring.rules`

```nix
# modules/hosts/x240/system.nix
...
50: monitoring.agent = {
51: metricsUrl = "https://vm.adje.app/api/v1/write";
52: logsUrl = "https://vlogs.adje.app/insert/loki/api/v1/push";
53: bearerTokenFile = config.secrets.files.telemetry-ingest-token.path;
...
```

</details>



### Implementations

<details>
<summary><code><a href="../implementations/authelia.md">authelia</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.logs`, `monitoring.rules`, `monitoring.scrapes`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/implementations/authelia/default.nix
...
28: monEnabled = config.monitoring.enable or false;
...
401: monitoring = lib.mkIf monEnabled {
402: watchedUnits =
403: ["authelia-main.service"]
404: ++ lib.optional cfg.directory.enable "lldap.service";
...
465: json = internalAuthelia.mkDashboard self.lib.monitoring.dashboard;
...
```

</details>


<details>
<summary><code><a href="../implementations/caddy.md">caddy</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.logs`, `monitoring.rules`, `monitoring.scrapes`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/implementations/caddy/default.nix
...
192: monitoring = lib.mkIf (config.monitoring.enable or false) {
193: watchedUnits = ["caddy.service"];
194: logs.journal.units = ["caddy.service"];
195: services.caddy.units = ["caddy.service"];
...
230: json = internalCaddy.mkDashboard self.lib.monitoring.dashboard;
...
```

</details>


<details>
<summary><code><a href="../implementations/cgroups.md">cgroups</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.exporters`, `monitoring.rules`, `monitoring.watchedUnits`

```nix
# modules/implementations/cgroups/default.nix
...
125: monEnabled = config.monitoring.enable or false;
...
262: monitoring = lib.mkIf monEnabled {
263: exporters = {
264: cadvisor.enable = true;
265: unix = {
...
396: json = helpers.mkDashboard self.lib.monitoring.dashboard;
...
```

</details>


<details>
<summary><code><a href="../implementations/grafana.md">grafana</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.logs`, `monitoring.scrapes`, `monitoring.server`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/implementations/grafana/default.nix
...
49: monitoring.server.enable = lib.mkDefault true;
...
```

</details>


<details>
<summary><code><a href="../implementations/impermanence.md">impermanence</a></code></summary>

**Configures options**: `monitoring.rules`

```nix
# modules/implementations/impermanence.nix
...
133: monitoring = lib.mkIf (config.monitoring.enable or false) {
134: rules.persistence = {
135: backend = "metrics";
136: interval = "1m";
...
```

</details>


<details>
<summary><code><a href="../implementations/rclone.md">rclone</a></code></summary>

**Configures options**: `monitoring.logs`, `monitoring.watchedUnits`

```nix
# modules/implementations/rclone/default.nix
...
74: monitoring = lib.mkIf (config.monitoring.enable or false) {
75: watchedUnits = rcloneServiceUnits ++ units.nonAutomountUnits;
76: logs.journal.units = rcloneServiceUnits;
77: };
...
```

</details>


<details>
<summary><code><a href="../implementations/restic.md">restic</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.logs`, `monitoring.rules`, `monitoring.watchedUnits`

```nix
# modules/implementations/restic/default.nix
...
66: monitoring = lib.mkIf (config.monitoring.enable or false) {
67: watchedUnits = allBackupUnits;
68: logs.journal.units = backupServiceUnits ++ restoreServiceUnits;
69: rules.restic = {
...
98: json = internalRestic.mkDashboard self.lib.monitoring.dashboard;
...
```

</details>



### Features

<details>
<summary><code><a href="../features/antigravity.md">antigravity</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.exporters`, `monitoring.logs`, `monitoring.probes`, `monitoring.rules`, `monitoring.services`, `monitoring.watchedUnits`

```nix
config = {
  monitoring.dashboards = ...;
  monitoring.exporters = ...;
  monitoring.logs = ...;
  monitoring.probes = ...;
  monitoring.rules = ...;
  monitoring.services = ...;
  monitoring.watchedUnits = ...;
};
```

</details>


<details>
<summary><code><a href="../features/attic.md">attic</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.logs`, `monitoring.probes`, `monitoring.rules`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/features/attic.nix
...
172: (self.lib.monitoring.mkConfig {
173: inherit config cfg;
174: name = "attic";
175: })
...
```

</details>


<details>
<summary><code><a href="../features/copyparty.md">copyparty</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.logs`, `monitoring.probes`, `monitoring.rules`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/features/copyparty.nix
...
323: (self.lib.monitoring.mkConfig {
324: inherit config cfg;
325: name = "copyparty";
326: })
...
328: (lib.mkIf ((config.monitoring.enable or false) && cfg.enableGdrive) {
329: monitoring.services.copyparty.storageMounts = [cfg.gdriveMountPoint];
330: })
331: ]);
...
329: monitoring.services.copyparty.storageMounts = [cfg.gdriveMountPoint];
...
```

</details>


<details>
<summary><code><a href="../features/disko.md">disko</a></code></summary>

**Configures options**: `monitoring.exporters`, `monitoring.rules`

```nix
# modules/features/disko.nix
...
391: (lib.mkIf (config.monitoring.enable or false) {
392: monitoring = {
393: exporters.unix.collectors = ["filesystem" "diskstats"];
394: rules.disk = {
...
392: monitoring = {
393: exporters.unix.collectors = ["filesystem" "diskstats"];
394: rules.disk = {
395: backend = "metrics";
...
```

</details>


<details>
<summary><code><a href="../features/docker.md">docker</a></code></summary>

**Configures options**: `monitoring.exporters`, `monitoring.logs`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/features/docker.nix
...
26: (lib.mkIf (config.monitoring.enable or false) {
27: monitoring = {
28: exporters.cadvisor.enable = true;
29: watchedUnits = ["docker.service"];
...
27: monitoring = {
28: exporters.cadvisor.enable = true;
29: watchedUnits = ["docker.service"];
30: logs.journal.units = ["docker.service"];
...
```

</details>


<details>
<summary><code><a href="../features/nix.md">nix</a></code></summary>

**Configures options**: `monitoring.logs`, `monitoring.watchedUnits`

```nix
# modules/features/nix.nix
...
135: monitoring = lib.mkIf (config.monitoring.enable or false) {
136: watchedUnits =
137: ["nix-daemon.service" "nix-gc.service"]
138: ++ lib.optional config.nix.cachixWatchStore "cachix-watch-store-agent.service";
...
```

</details>


<details>
<summary><code><a href="../features/ntfy.md">ntfy</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.logs`, `monitoring.probes`, `monitoring.rules`, `monitoring.scrapes`, `monitoring.server`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/features/ntfy.nix
...
129: monitoring = lib.mkIf (config.monitoring.enable or false) {
130: scrapes.ntfy = {
131: address = "127.0.0.1";
132: port = cfg.metricsPort;
...
140: server.alerts.ntfy = lib.mkIf (config.monitoring.server.enable or false) {
141: enable = lib.mkDefault true;
142: url = lib.mkDefault "http://${connectAddr cfg.address}:${toString cfg.port}/${cfg.alertTopic}?template=alertmanager";
143: username = lib.mkDefault "admin";
...
177: (self.lib.monitoring.mkConfig {
178: inherit config cfg;
179: name = "ntfy";
180: })
...
```

</details>


<details>
<summary><code><a href="../features/perf-monitor.md">perf-monitor</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.exporters`, `monitoring.rules`, `monitoring.watchedUnits`

```nix
# modules/features/perf-monitor.nix
...
14: textfileDir = config.monitoring.exporters.unix.textfileDirectory or "/var/lib/alloy/textfile";
...
375: monitoring = lib.mkIf (config.monitoring.enable or false) {
376: exporters.unix.textfileDirectory = lib.mkDefault "/var/lib/alloy/textfile";
377: watchedUnits = ["nixconf-ci-metrics.service" "nixconf-eval-metrics.service"];
378: rules.nixconf-perf = {
...
456: json = mkDashboard self.lib.monitoring.dashboard;
...
```

</details>


<details>
<summary><code><a href="../features/snapshot.md">snapshot</a></code></summary>

**Configures options**: `monitoring.logs`, `monitoring.rules`, `monitoring.watchedUnits`

```nix
# modules/features/snapshot.nix
...
370: monitoring = lib.mkIf (config.monitoring.enable or false) (let
...
```

</details>


<details>
<summary><code><a href="../features/ssh.md">ssh</a></code></summary>

**Configures options**: `monitoring.logs`, `monitoring.rules`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/features/ssh.nix
...
209: (lib.mkIf (config.monitoring.enable or false) {
210: monitoring = {
211: watchedUnits = ["sshd.service"];
212: logs.journal.units = ["sshd.service"];
...
210: monitoring = {
211: watchedUnits = ["sshd.service"];
212: logs.journal.units = ["sshd.service"];
213: services.sshd.units = ["sshd.service"];
...
```

</details>


<details>
<summary><code><a href="../features/ttyd.md">ttyd</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.logs`, `monitoring.probes`, `monitoring.rules`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/features/ttyd.nix
...
113: (self.lib.monitoring.mkConfig {
114: inherit config cfg;
115: name = "ttyd";
116: })
...
```

</details>


<details>
<summary><code><a href="../features/uchiyomi.md">uchiyomi</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.exporters`, `monitoring.logs`, `monitoring.probes`, `monitoring.rules`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/features/uchiyomi.nix
...
301: (self.lib.monitoring.mkConfig {
302: inherit config cfg;
303: name = "uchiyomi";
304: })
...
306: (lib.mkIf (config.monitoring.enable or false) {
307: monitoring.exporters.cadvisor.enable = true;
308: })
309: ]);
...
307: monitoring.exporters.cadvisor.enable = true;
...
```

</details>


<details>
<summary><code><a href="../features/vaultwarden.md">vaultwarden</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.logs`, `monitoring.probes`, `monitoring.rules`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/features/vaultwarden.nix
...
58: (self.lib.monitoring.mkConfig {
59: inherit config cfg;
60: name = "vaultwarden";
61: })
...
```

</details>
