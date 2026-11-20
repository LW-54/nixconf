# Implementation: `authelia`

Centralized SSO, forward authentication, 2FA, and LDAP directory implementation using Authelia and LLDAP.

[← Back to Implementations Documentation](README.md) | [← Back to Main README](../../README.md)

- **Implementation**: `authelia`
- **Fulfills Contract**: [`auth`](../contracts/auth.md)
- **Definition File**: [`modules/implementations/authelia/default.nix`](../../modules/implementations/authelia/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__astrolabe["nixosModule/astrolabe"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_disk["nixosModule/astrolabe-disk"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_hardware["nixosModule/astrolabe-hardware"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_resources["nixosModule/astrolabe-resources"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_services["nixosModule/astrolabe-services"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_system["nixosModule/astrolabe-system"]:::defaultNode
    urn__nixconf__ast__module__authelia["nixosModule/authelia"]:::defaultNode
    urn__nixconf__ast__module__caddy["nixosModule/caddy"]:::defaultNode
    urn__nixconf__ast__module__cgroups["nixosModule/cgroups"]:::defaultNode
    urn__nixconf__ast__module__impermanence["nixosModule/impermanence"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__sops["nixosModule/sops"]:::defaultNode
    urn__nixconf__ast__module__victoria["nixosModule/victoria"]:::defaultNode
    urn__nixconf__ast__option__auth_address[/"auth.address"/]:::optNode
    urn__nixconf__ast__option__auth_adminGroup[/"auth.adminGroup"/]:::optNode
    urn__nixconf__ast__option__auth_defaultPolicy[/"auth.defaultPolicy"/]:::optNode
    urn__nixconf__ast__option__auth_directory[/"auth.directory"/]:::optNode
    urn__nixconf__ast__option__auth_enable[/"auth.enable"/]:::optNode
    urn__nixconf__ast__option__auth_port[/"auth.port"/]:::optNode
    urn__nixconf__ast__option__auth_rules[/"auth.rules"/]:::optNode
    urn__nixconf__ast__option__auth_subdomain[/"auth.subdomain"/]:::optNode
    urn__nixconf__ast__option__backup_destinations[/"backup.destinations"/]:::optNode
    urn__nixconf__ast__option__backup_enable[/"backup.enable"/]:::optNode
    urn__nixconf__ast__option__backup_exclude[/"backup.exclude"/]:::optNode
    urn__nixconf__ast__option__backup_paths[/"backup.paths"/]:::optNode
    urn__nixconf__ast__option__backup_units[/"backup.units"/]:::optNode
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
    urn__nixconf__ast__option__persistence_directories[/"persistence.directories"/]:::optNode
    urn__nixconf__ast__option__persistence_enable[/"persistence.enable"/]:::optNode
    urn__nixconf__ast__option__persistence_files[/"persistence.files"/]:::optNode
    urn__nixconf__ast__option__persistence_users[/"persistence.users"/]:::optNode
    urn__nixconf__ast__option__resources_disk[/"resources.disk"/]:::optNode
    urn__nixconf__ast__option__resources_enable[/"resources.enable"/]:::optNode
    urn__nixconf__ast__option__resources_oom[/"resources.oom"/]:::optNode
    urn__nixconf__ast__option__resources_power[/"resources.power"/]:::optNode
    urn__nixconf__ast__option__resources_profile[/"resources.profile"/]:::optNode
    urn__nixconf__ast__option__resources_storageBudgets[/"resources.storageBudgets"/]:::optNode
    urn__nixconf__ast__option__resources_tiers[/"resources.tiers"/]:::optNode
    urn__nixconf__ast__option__resources_units[/"resources.units"/]:::optNode
    urn__nixconf__ast__option__resources_volumes[/"resources.volumes"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_domain[/"reverse-proxy.domain"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_enable[/"reverse-proxy.enable"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_forwardAuth[/"reverse-proxy.forwardAuth"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_hosts[/"reverse-proxy.hosts"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_ports[/"reverse-proxy.ports"/]:::optNode
    urn__nixconf__ast__option__secrets_defaultFile[/"secrets.defaultFile"/]:::optNode
    urn__nixconf__ast__option__secrets_enable[/"secrets.enable"/]:::optNode
    urn__nixconf__ast__option__secrets_files[/"secrets.files"/]:::optNode
    urn__nixconf__ast__option__secrets_placeholder[/"secrets.placeholder"/]:::optNode
    urn__nixconf__ast__option__secrets_templates[/"secrets.templates"/]:::optNode
    urn__nixconf__ast__type__auth_directory[["auth.directory"]]:::typeNode
    urn__nixconf__ast__type__auth_policy[["auth.policy"]]:::typeNode
    urn__nixconf__ast__type__auth_rule[["auth.rule"]]:::typeNode
    urn__nixconf__ast__type__backup_destination[["backup.destination"]]:::typeNode
    urn__nixconf__ast__type__backup_destinationOverride[["backup.destinationOverride"]]:::typeNode
    urn__nixconf__ast__type__backup_retention[["backup.retention"]]:::typeNode
    urn__nixconf__ast__type__backup_schedule[["backup.schedule"]]:::typeNode
    urn__nixconf__ast__type__backup_unit[["backup.unit"]]:::typeNode
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
    urn__nixconf__ast__type__persistence_entries[["persistence.entries"]]:::typeNode
    urn__nixconf__ast__type__persistence_user[["persistence.user"]]:::typeNode
    urn__nixconf__ast__type__resources_byteSize[["resources.byteSize"]]:::typeNode
    urn__nixconf__ast__type__resources_cgroupWeight[["resources.cgroupWeight"]]:::typeNode
    urn__nixconf__ast__type__resources_cpuQuota[["resources.cpuQuota"]]:::typeNode
    urn__nixconf__ast__type__resources_disk[["resources.disk"]]:::typeNode
    urn__nixconf__ast__type__resources_onBattery[["resources.onBattery"]]:::typeNode
    urn__nixconf__ast__type__resources_oom[["resources.oom"]]:::typeNode
    urn__nixconf__ast__type__resources_oomPreference[["resources.oomPreference"]]:::typeNode
    urn__nixconf__ast__type__resources_oomScore[["resources.oomScore"]]:::typeNode
    urn__nixconf__ast__type__resources_percentage[["resources.percentage"]]:::typeNode
    urn__nixconf__ast__type__resources_power[["resources.power"]]:::typeNode
    urn__nixconf__ast__type__resources_profile[["resources.profile"]]:::typeNode
    urn__nixconf__ast__type__resources_resourceSize[["resources.resourceSize"]]:::typeNode
    urn__nixconf__ast__type__resources_storageBudget[["resources.storageBudget"]]:::typeNode
    urn__nixconf__ast__type__resources_tier[["resources.tier"]]:::typeNode
    urn__nixconf__ast__type__resources_unit[["resources.unit"]]:::typeNode
    urn__nixconf__ast__type__resources_volume[["resources.volume"]]:::typeNode
    urn__nixconf__ast__type__reverse_proxy_forwardAuth[["reverse-proxy.forwardAuth"]]:::typeNode
    urn__nixconf__ast__type__reverse_proxy_fqdn[["reverse-proxy.fqdn"]]:::typeNode
    urn__nixconf__ast__type__reverse_proxy_host[["reverse-proxy.host"]]:::typeNode
    urn__nixconf__ast__type__reverse_proxy_portAllocation[["reverse-proxy.portAllocation"]]:::typeNode
    urn__nixconf__ast__type__secrets_secret[["secrets.secret"]]:::typeNode
    urn__nixconf__ast__type__secrets_template[["secrets.template"]]:::typeNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__onto__contract__auth{{"auth"}}:::contractNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__monitoring{{"monitoring"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__resources{{"resources"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__feature__antigravity("antigravity"):::featureNode
    urn__nixconf__onto__feature__bitwarden("bitwarden"):::featureNode
    urn__nixconf__onto__feature__copyparty("copyparty"):::featureNode
    urn__nixconf__onto__feature__direnv("direnv"):::featureNode
    urn__nixconf__onto__feature__disko("disko"):::featureNode
    urn__nixconf__onto__feature__docker("docker"):::featureNode
    urn__nixconf__onto__feature__dolphin("dolphin"):::featureNode
    urn__nixconf__onto__feature__foot("foot"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__labwc("labwc"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__noctalia("noctalia"):::featureNode
    urn__nixconf__onto__feature__ntfy("ntfy"):::featureNode
    urn__nixconf__onto__feature__snapshot("snapshot"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__uchiyomi("uchiyomi"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__feature__vivaldi("vivaldi"):::featureNode
    urn__nixconf__onto__feature__vscode("vscode"):::featureNode
    urn__nixconf__onto__feature__wifi_eduroam("wifi-eduroam"):::featureNode
    urn__nixconf__onto__feature__zed("zed"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__authelia["authelia"]:::implNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__rclone["rclone"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode
    urn__nixconf__onto__implementation__victoria["victoria"]:::implNode

    urn__nixconf__ast__module__astrolabe -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__astrolabe -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__astrolabe -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__astrolabe -.->|writes| urn__nixconf__ast__option__monitoring_extraGrafanaSettings
    urn__nixconf__ast__module__astrolabe -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__astrolabe -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__astrolabe_resources -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__astrolabe_resources -.->|writes| urn__nixconf__ast__option__resources_oom
    urn__nixconf__ast__module__astrolabe_resources -.->|writes| urn__nixconf__ast__option__resources_profile
    urn__nixconf__ast__module__astrolabe_resources -.->|writes| urn__nixconf__ast__option__resources_storageBudgets
    urn__nixconf__ast__module__astrolabe_resources -.->|writes| urn__nixconf__ast__option__resources_tiers
    urn__nixconf__ast__module__astrolabe_resources -.->|writes| urn__nixconf__ast__option__resources_volumes
    urn__nixconf__ast__module__astrolabe_services -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__astrolabe_services -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__astrolabe_services -.->|writes| urn__nixconf__ast__option__monitoring_server
    urn__nixconf__ast__module__astrolabe_services -.->|writes| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__authelia -.->|reads| urn__nixconf__ast__option__auth_directory
    urn__nixconf__ast__module__authelia -.->|reads| urn__nixconf__ast__option__auth_rules
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__auth_directory
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__reverse_proxy_forwardAuth
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_forwardAuth
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__cgroups -.->|reads| urn__nixconf__ast__option__resources_disk
    urn__nixconf__ast__module__cgroups -.->|reads| urn__nixconf__ast__option__resources_oom
    urn__nixconf__ast__module__cgroups -.->|reads| urn__nixconf__ast__option__resources_power
    urn__nixconf__ast__module__cgroups -.->|reads| urn__nixconf__ast__option__resources_profile
    urn__nixconf__ast__module__cgroups -.->|reads| urn__nixconf__ast__option__resources_storageBudgets
    urn__nixconf__ast__module__cgroups -.->|reads| urn__nixconf__ast__option__resources_tiers
    urn__nixconf__ast__module__cgroups -.->|reads| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__cgroups -.->|reads| urn__nixconf__ast__option__resources_volumes
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__resources_disk
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__resources_power
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__resources_tiers
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__impermanence -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__impermanence -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__sops -.->|writes| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__ast__module__victoria -.->|flowsTo| urn__nixconf__ast__module__authelia
    urn__nixconf__ast__module__victoria -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__victoria -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__victoria -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__victoria -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__victoria -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__victoria -.->|reads| urn__nixconf__ast__option__monitoring_agent
    urn__nixconf__ast__module__victoria -.->|reads| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__victoria -.->|reads| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__victoria -.->|reads| urn__nixconf__ast__option__monitoring_extraGrafanaSettings
    urn__nixconf__ast__module__victoria -.->|reads| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__victoria -.->|reads| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__victoria -.->|reads| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__victoria -.->|reads| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__ast__module__victoria -.->|reads| urn__nixconf__ast__option__monitoring_server
    urn__nixconf__ast__module__victoria -.->|reads| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__victoria -.->|reads| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__auth_rules
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__victoria -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__option__auth_defaultPolicy -.->|typedBy| urn__nixconf__ast__type__auth_policy
    urn__nixconf__ast__option__auth_directory -.->|typedBy| urn__nixconf__ast__type__auth_directory
    urn__nixconf__ast__option__auth_directory -.->|typedBy| urn__nixconf__ast__type__auth_rule
    urn__nixconf__ast__option__auth_rules -.->|typedBy| urn__nixconf__ast__type__auth_directory
    urn__nixconf__ast__option__auth_rules -.->|typedBy| urn__nixconf__ast__type__auth_rule
    urn__nixconf__ast__option__backup_destinations -.->|typedBy| urn__nixconf__ast__type__backup_destination
    urn__nixconf__ast__option__backup_destinations -.->|typedBy| urn__nixconf__ast__type__backup_destinationOverride
    urn__nixconf__ast__option__backup_destinations -.->|typedBy| urn__nixconf__ast__type__backup_retention
    urn__nixconf__ast__option__backup_destinations -.->|typedBy| urn__nixconf__ast__type__backup_schedule
    urn__nixconf__ast__option__backup_destinations -.->|typedBy| urn__nixconf__ast__type__backup_unit
    urn__nixconf__ast__option__backup_units -.->|typedBy| urn__nixconf__ast__type__backup_destination
    urn__nixconf__ast__option__backup_units -.->|typedBy| urn__nixconf__ast__type__backup_destinationOverride
    urn__nixconf__ast__option__backup_units -.->|typedBy| urn__nixconf__ast__type__backup_retention
    urn__nixconf__ast__option__backup_units -.->|typedBy| urn__nixconf__ast__type__backup_schedule
    urn__nixconf__ast__option__backup_units -.->|typedBy| urn__nixconf__ast__type__backup_unit
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
    urn__nixconf__ast__option__persistence_directories -.->|typedBy| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_files -.->|typedBy| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_users -.->|typedBy| urn__nixconf__ast__type__persistence_user
    urn__nixconf__ast__option__resources_disk -.->|typedBy| urn__nixconf__ast__type__resources_disk
    urn__nixconf__ast__option__resources_oom -.->|typedBy| urn__nixconf__ast__type__resources_oom
    urn__nixconf__ast__option__resources_power -.->|typedBy| urn__nixconf__ast__type__resources_power
    urn__nixconf__ast__option__resources_profile -.->|typedBy| urn__nixconf__ast__type__resources_profile
    urn__nixconf__ast__option__resources_storageBudgets -.->|typedBy| urn__nixconf__ast__type__resources_storageBudget
    urn__nixconf__ast__option__resources_tiers -.->|typedBy| urn__nixconf__ast__type__resources_tier
    urn__nixconf__ast__option__resources_units -.->|typedBy| urn__nixconf__ast__type__resources_unit
    urn__nixconf__ast__option__resources_volumes -.->|typedBy| urn__nixconf__ast__type__resources_volume
    urn__nixconf__ast__option__reverse_proxy_domain -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_fqdn
    urn__nixconf__ast__option__reverse_proxy_forwardAuth -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_forwardAuth
    urn__nixconf__ast__option__reverse_proxy_forwardAuth -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__ast__option__reverse_proxy_forwardAuth -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_portAllocation
    urn__nixconf__ast__option__reverse_proxy_hosts -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_forwardAuth
    urn__nixconf__ast__option__reverse_proxy_hosts -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__ast__option__reverse_proxy_hosts -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_portAllocation
    urn__nixconf__ast__option__reverse_proxy_ports -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_forwardAuth
    urn__nixconf__ast__option__reverse_proxy_ports -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__ast__option__reverse_proxy_ports -.->|typedBy| urn__nixconf__ast__type__reverse_proxy_portAllocation
    urn__nixconf__ast__option__secrets_files -.->|typedBy| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__ast__option__secrets_files -.->|typedBy| urn__nixconf__ast__type__secrets_template
    urn__nixconf__ast__option__secrets_templates -.->|typedBy| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__ast__option__secrets_templates -.->|typedBy| urn__nixconf__ast__type__secrets_template
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_resources
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__authelia
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__caddy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__cgroups
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__victoria
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_address
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_adminGroup
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_defaultPolicy
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_directory
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_enable
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_port
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_rules
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_subdomain
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__type__auth_directory
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__type__auth_policy
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__type__auth_rule
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__option__backup_destinations
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__option__backup_enable
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__option__backup_paths
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__option__backup_units
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__type__backup_destination
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__type__backup_destinationOverride
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__type__backup_retention
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__type__backup_schedule
    urn__nixconf__onto__contract__backup -->|declares| urn__nixconf__ast__type__backup_unit
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
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_enable
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_files
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_users
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__type__persistence_user
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_disk
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_enable
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_oom
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_power
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_profile
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_storageBudgets
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_tiers
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_units
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_volumes
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_byteSize
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_cgroupWeight
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_cpuQuota
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_disk
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_onBattery
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_oom
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_oomPreference
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_oomScore
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_percentage
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_power
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_profile
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_resourceSize
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_storageBudget
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_tier
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_unit
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_volume
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_enable
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_forwardAuth
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__type__reverse_proxy_forwardAuth
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__type__reverse_proxy_fqdn
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__type__reverse_proxy_portAllocation
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_defaultFile
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_enable
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_files
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__type__secrets_template
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__bitwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__direnv -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__disko -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__docker -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__docker -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__docker -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__dolphin -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__foot -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__noctalia -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vivaldi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__wifi_eduroam -.->|consumes| urn__nixconf__onto__contract__secrets
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
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__copyparty
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ntfy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__snapshot
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__uchiyomi
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__authelia
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__rclone
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__victoria
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__docker
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__dolphin
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__foot
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__wifi_eduroam
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__zed
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__rclone
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__victoria
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
    urn__nixconf__onto__implementation__cgroups ==>|implements| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__impermanence -->|outputs| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__impermanence ==>|implements| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic -->|outputs| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic ==>|implements| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__ast__module__sops
    urn__nixconf__onto__implementation__sops -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops ==>|implements| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__victoria -->|outputs| urn__nixconf__ast__module__victoria
    urn__nixconf__onto__implementation__victoria -.->|consumes| urn__nixconf__onto__contract__auth
    urn__nixconf__onto__implementation__victoria -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__victoria -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__victoria -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__victoria -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__victoria -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__victoria -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__victoria ==>|implements| urn__nixconf__onto__contract__monitoring


    click urn__nixconf__ast__module__astrolabe href "../modules/astrolabe.md" "astrolabe"
    click urn__nixconf__ast__module__astrolabe_disk href "../modules/astrolabe-disk.md" "astrolabe-disk"
    click urn__nixconf__ast__module__astrolabe_hardware href "../modules/astrolabe-hardware.md" "astrolabe-hardware"
    click urn__nixconf__ast__module__astrolabe_resources href "../modules/astrolabe-resources.md" "astrolabe-resources"
    click urn__nixconf__ast__module__astrolabe_services href "../modules/astrolabe-services.md" "astrolabe-services"
    click urn__nixconf__ast__module__astrolabe_system href "../modules/astrolabe-system.md" "astrolabe-system"
    click urn__nixconf__ast__module__authelia href "../modules/authelia.md" "authelia"
    click urn__nixconf__ast__module__caddy href "../modules/caddy.md" "caddy"
    click urn__nixconf__ast__module__cgroups href "../modules/cgroups.md" "cgroups"
    click urn__nixconf__ast__module__impermanence href "../modules/impermanence.md" "impermanence"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__sops href "../modules/sops.md" "sops"
    click urn__nixconf__ast__module__victoria href "../modules/victoria.md" "victoria"
    click urn__nixconf__ast__option__auth_address href "../contracts/auth.md" "auth.address"
    click urn__nixconf__ast__option__auth_adminGroup href "../contracts/auth.md" "auth.adminGroup"
    click urn__nixconf__ast__option__auth_defaultPolicy href "../contracts/auth.md" "auth.defaultPolicy"
    click urn__nixconf__ast__option__auth_directory href "../contracts/auth.md" "auth.directory"
    click urn__nixconf__ast__option__auth_enable href "../contracts/auth.md" "auth.enable"
    click urn__nixconf__ast__option__auth_port href "../contracts/auth.md" "auth.port"
    click urn__nixconf__ast__option__auth_rules href "../contracts/auth.md" "auth.rules"
    click urn__nixconf__ast__option__auth_subdomain href "../contracts/auth.md" "auth.subdomain"
    click urn__nixconf__ast__option__backup_destinations href "../contracts/backup.md" "backup.destinations"
    click urn__nixconf__ast__option__backup_enable href "../contracts/backup.md" "backup.enable"
    click urn__nixconf__ast__option__backup_exclude href "../contracts/backup.md" "backup.exclude"
    click urn__nixconf__ast__option__backup_paths href "../contracts/backup.md" "backup.paths"
    click urn__nixconf__ast__option__backup_units href "../contracts/backup.md" "backup.units"
    click urn__nixconf__ast__option__monitoring_agent href "../contracts/monitoring.md" "monitoring.agent"
    click urn__nixconf__ast__option__monitoring_dashboards href "../contracts/monitoring.md" "monitoring.dashboards"
    click urn__nixconf__ast__option__monitoring_enable href "../contracts/monitoring.md" "monitoring.enable"
    click urn__nixconf__ast__option__monitoring_exporters href "../contracts/monitoring.md" "monitoring.exporters"
    click urn__nixconf__ast__option__monitoring_extraAlloyConfig href "../contracts/monitoring.md" "monitoring.extraAlloyConfig"
    click urn__nixconf__ast__option__monitoring_extraGrafanaSettings href "../contracts/monitoring.md" "monitoring.extraGrafanaSettings"
    click urn__nixconf__ast__option__monitoring_extraLogsOptions href "../contracts/monitoring.md" "monitoring.extraLogsOptions"
    click urn__nixconf__ast__option__monitoring_extraMetricsOptions href "../contracts/monitoring.md" "monitoring.extraMetricsOptions"
    click urn__nixconf__ast__option__monitoring_logs href "../contracts/monitoring.md" "monitoring.logs"
    click urn__nixconf__ast__option__monitoring_probes href "../contracts/monitoring.md" "monitoring.probes"
    click urn__nixconf__ast__option__monitoring_rules href "../contracts/monitoring.md" "monitoring.rules"
    click urn__nixconf__ast__option__monitoring_scrapes href "../contracts/monitoring.md" "monitoring.scrapes"
    click urn__nixconf__ast__option__monitoring_server href "../contracts/monitoring.md" "monitoring.server"
    click urn__nixconf__ast__option__monitoring_services href "../contracts/monitoring.md" "monitoring.services"
    click urn__nixconf__ast__option__monitoring_watchedUnits href "../contracts/monitoring.md" "monitoring.watchedUnits"
    click urn__nixconf__ast__option__persistence_directories href "../contracts/persistence.md" "persistence.directories"
    click urn__nixconf__ast__option__persistence_enable href "../contracts/persistence.md" "persistence.enable"
    click urn__nixconf__ast__option__persistence_files href "../contracts/persistence.md" "persistence.files"
    click urn__nixconf__ast__option__persistence_users href "../contracts/persistence.md" "persistence.users"
    click urn__nixconf__ast__option__resources_disk href "../contracts/resources.md" "resources.disk"
    click urn__nixconf__ast__option__resources_enable href "../contracts/resources.md" "resources.enable"
    click urn__nixconf__ast__option__resources_oom href "../contracts/resources.md" "resources.oom"
    click urn__nixconf__ast__option__resources_power href "../contracts/resources.md" "resources.power"
    click urn__nixconf__ast__option__resources_profile href "../contracts/resources.md" "resources.profile"
    click urn__nixconf__ast__option__resources_storageBudgets href "../contracts/resources.md" "resources.storageBudgets"
    click urn__nixconf__ast__option__resources_tiers href "../contracts/resources.md" "resources.tiers"
    click urn__nixconf__ast__option__resources_units href "../contracts/resources.md" "resources.units"
    click urn__nixconf__ast__option__resources_volumes href "../contracts/resources.md" "resources.volumes"
    click urn__nixconf__ast__option__reverse_proxy_domain href "../contracts/reverse-proxy.md" "reverse-proxy.domain"
    click urn__nixconf__ast__option__reverse_proxy_enable href "../contracts/reverse-proxy.md" "reverse-proxy.enable"
    click urn__nixconf__ast__option__reverse_proxy_forwardAuth href "../contracts/reverse-proxy.md" "reverse-proxy.forwardAuth"
    click urn__nixconf__ast__option__reverse_proxy_hosts href "../contracts/reverse-proxy.md" "reverse-proxy.hosts"
    click urn__nixconf__ast__option__reverse_proxy_ports href "../contracts/reverse-proxy.md" "reverse-proxy.ports"
    click urn__nixconf__ast__option__secrets_defaultFile href "../contracts/secrets.md" "secrets.defaultFile"
    click urn__nixconf__ast__option__secrets_enable href "../contracts/secrets.md" "secrets.enable"
    click urn__nixconf__ast__option__secrets_files href "../contracts/secrets.md" "secrets.files"
    click urn__nixconf__ast__option__secrets_placeholder href "../contracts/secrets.md" "secrets.placeholder"
    click urn__nixconf__ast__option__secrets_templates href "../contracts/secrets.md" "secrets.templates"
    click urn__nixconf__ast__type__auth_directory href "../contracts/auth.md" "auth.directory"
    click urn__nixconf__ast__type__auth_policy href "../contracts/auth.md" "auth.policy"
    click urn__nixconf__ast__type__auth_rule href "../contracts/auth.md" "auth.rule"
    click urn__nixconf__ast__type__backup_destination href "../contracts/backup.md" "backup.destination"
    click urn__nixconf__ast__type__backup_destinationOverride href "../contracts/backup.md" "backup.destinationOverride"
    click urn__nixconf__ast__type__backup_retention href "../contracts/backup.md" "backup.retention"
    click urn__nixconf__ast__type__backup_schedule href "../contracts/backup.md" "backup.schedule"
    click urn__nixconf__ast__type__backup_unit href "../contracts/backup.md" "backup.unit"
    click urn__nixconf__ast__type__monitoring_agent href "../contracts/monitoring.md" "monitoring.agent"
    click urn__nixconf__ast__type__monitoring_dashboard href "../contracts/monitoring.md" "monitoring.dashboard"
    click urn__nixconf__ast__type__monitoring_exporters href "../contracts/monitoring.md" "monitoring.exporters"
    click urn__nixconf__ast__type__monitoring_fileLog href "../contracts/monitoring.md" "monitoring.fileLog"
    click urn__nixconf__ast__type__monitoring_journalLogs href "../contracts/monitoring.md" "monitoring.journalLogs"
    click urn__nixconf__ast__type__monitoring_logs href "../contracts/monitoring.md" "monitoring.logs"
    click urn__nixconf__ast__type__monitoring_ntfyNotification href "../contracts/monitoring.md" "monitoring.ntfyNotification"
    click urn__nixconf__ast__type__monitoring_probe href "../contracts/monitoring.md" "monitoring.probe"
    click urn__nixconf__ast__type__monitoring_retention href "../contracts/monitoring.md" "monitoring.retention"
    click urn__nixconf__ast__type__monitoring_ruleGroup href "../contracts/monitoring.md" "monitoring.ruleGroup"
    click urn__nixconf__ast__type__monitoring_ruleItem href "../contracts/monitoring.md" "monitoring.ruleItem"
    click urn__nixconf__ast__type__monitoring_scrape href "../contracts/monitoring.md" "monitoring.scrape"
    click urn__nixconf__ast__type__monitoring_server href "../contracts/monitoring.md" "monitoring.server"
    click urn__nixconf__ast__type__monitoring_service href "../contracts/monitoring.md" "monitoring.service"
    click urn__nixconf__ast__type__persistence_entries href "../contracts/persistence.md" "persistence.entries"
    click urn__nixconf__ast__type__persistence_user href "../contracts/persistence.md" "persistence.user"
    click urn__nixconf__ast__type__resources_byteSize href "../contracts/resources.md" "resources.byteSize"
    click urn__nixconf__ast__type__resources_cgroupWeight href "../contracts/resources.md" "resources.cgroupWeight"
    click urn__nixconf__ast__type__resources_cpuQuota href "../contracts/resources.md" "resources.cpuQuota"
    click urn__nixconf__ast__type__resources_disk href "../contracts/resources.md" "resources.disk"
    click urn__nixconf__ast__type__resources_onBattery href "../contracts/resources.md" "resources.onBattery"
    click urn__nixconf__ast__type__resources_oom href "../contracts/resources.md" "resources.oom"
    click urn__nixconf__ast__type__resources_oomPreference href "../contracts/resources.md" "resources.oomPreference"
    click urn__nixconf__ast__type__resources_oomScore href "../contracts/resources.md" "resources.oomScore"
    click urn__nixconf__ast__type__resources_percentage href "../contracts/resources.md" "resources.percentage"
    click urn__nixconf__ast__type__resources_power href "../contracts/resources.md" "resources.power"
    click urn__nixconf__ast__type__resources_profile href "../contracts/resources.md" "resources.profile"
    click urn__nixconf__ast__type__resources_resourceSize href "../contracts/resources.md" "resources.resourceSize"
    click urn__nixconf__ast__type__resources_storageBudget href "../contracts/resources.md" "resources.storageBudget"
    click urn__nixconf__ast__type__resources_tier href "../contracts/resources.md" "resources.tier"
    click urn__nixconf__ast__type__resources_unit href "../contracts/resources.md" "resources.unit"
    click urn__nixconf__ast__type__resources_volume href "../contracts/resources.md" "resources.volume"
    click urn__nixconf__ast__type__reverse_proxy_forwardAuth href "../contracts/reverse-proxy.md" "reverse-proxy.forwardAuth"
    click urn__nixconf__ast__type__reverse_proxy_fqdn href "../contracts/reverse-proxy.md" "reverse-proxy.fqdn"
    click urn__nixconf__ast__type__reverse_proxy_host href "../contracts/reverse-proxy.md" "reverse-proxy.host"
    click urn__nixconf__ast__type__reverse_proxy_portAllocation href "../contracts/reverse-proxy.md" "reverse-proxy.portAllocation"
    click urn__nixconf__ast__type__secrets_secret href "../contracts/secrets.md" "secrets.secret"
    click urn__nixconf__ast__type__secrets_template href "../contracts/secrets.md" "secrets.template"
    click urn__nixconf__eval__configuration__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__contract__auth href "../contracts/auth.md" "auth"
    click urn__nixconf__onto__contract__backup href "../contracts/backup.md" "backup"
    click urn__nixconf__onto__contract__monitoring href "../contracts/monitoring.md" "monitoring"
    click urn__nixconf__onto__contract__persistence href "../contracts/persistence.md" "persistence"
    click urn__nixconf__onto__contract__resources href "../contracts/resources.md" "resources"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "../contracts/secrets.md" "secrets"
    click urn__nixconf__onto__feature__antigravity href "../features/antigravity.md" "antigravity"
    click urn__nixconf__onto__feature__bitwarden href "../features/bitwarden.md" "bitwarden"
    click urn__nixconf__onto__feature__copyparty href "../features/copyparty.md" "copyparty"
    click urn__nixconf__onto__feature__direnv href "../features/direnv.md" "direnv"
    click urn__nixconf__onto__feature__disko href "../features/disko.md" "disko"
    click urn__nixconf__onto__feature__docker href "../features/docker.md" "docker"
    click urn__nixconf__onto__feature__dolphin href "../features/dolphin.md" "dolphin"
    click urn__nixconf__onto__feature__foot href "../features/foot.md" "foot"
    click urn__nixconf__onto__feature__git href "../features/git.md" "git"
    click urn__nixconf__onto__feature__labwc href "../features/labwc.md" "labwc"
    click urn__nixconf__onto__feature__locale href "../features/locale.md" "locale"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__noctalia href "../features/noctalia.md" "noctalia"
    click urn__nixconf__onto__feature__ntfy href "../features/ntfy.md" "ntfy"
    click urn__nixconf__onto__feature__snapshot href "../features/snapshot.md" "snapshot"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__uchiyomi href "../features/uchiyomi.md" "uchiyomi"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__feature__vivaldi href "../features/vivaldi.md" "vivaldi"
    click urn__nixconf__onto__feature__vscode href "../features/vscode.md" "vscode"
    click urn__nixconf__onto__feature__wifi_eduroam href "../features/wifi-eduroam.md" "wifi-eduroam"
    click urn__nixconf__onto__feature__zed href "../features/zed.md" "zed"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__authelia href "authelia.md" "authelia"
    click urn__nixconf__onto__implementation__caddy href "caddy.md" "caddy"
    click urn__nixconf__onto__implementation__cgroups href "cgroups.md" "cgroups"
    click urn__nixconf__onto__implementation__impermanence href "impermanence.md" "impermanence"
    click urn__nixconf__onto__implementation__lw href "lw.md" "lw"
    click urn__nixconf__onto__implementation__rclone href "rclone.md" "rclone"
    click urn__nixconf__onto__implementation__restic href "restic.md" "restic"
    click urn__nixconf__onto__implementation__sops href "sops.md" "sops"
    click urn__nixconf__onto__implementation__victoria href "victoria.md" "victoria"

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
| [`authelia`](../modules/authelia.md) | Centralized SSO, forward authentication, 2FA, and LDAP directory implementation using Authelia and LLDAP. | [More →](../modules/authelia.md) |

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).

## Consumed Contracts

Capability contracts configured by this implementation:

<details>
<summary><code><a href="../contracts/auth.md">auth</a></code></summary>

**Configures options**: `auth.directory`

```nix
# modules/implementations/authelia/default.nix
...
130: message = "implementation.authelia currently requires `auth.directory.enable = true` (LLDAP backend).";
...
134: message = "auth.subdomain and auth.directory.subdomain must be distinct virtual host prefixes.";
...
138: auth.directory.adminEmail = lib.mkDefault (
...
231: endpoints.authz.forward-auth.implementation = "ForwardAuth";
...
532: caddy-forward-auth = {
533: description = "Verify Caddyfile enforces forward_auth on protected services";
534: script = lib.optionalString (config.reverse-proxy.enable or false) (
535: self.lib.testing.mkInspectFile {
...
561: _unauth = machine.succeed(
...
```

</details>


<details>
<summary><code><a href="../contracts/backup.md">backup</a></code></summary>

**Configures options**: `backup.paths`, `backup.units`

```nix
# modules/implementations/authelia/default.nix
...
376: backup = lib.mkIf (config.backup.enable or false) {
377: paths =
378: ["/var/lib/authelia-main"]
379: ++ lib.optional cfg.directory.enable "/var/lib/lldap";
...
```

</details>


<details>
<summary><code><a href="../contracts/monitoring.md">monitoring</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.logs`, `monitoring.rules`, `monitoring.scrapes`, `monitoring.services`, `monitoring.watchedUnits`

```nix
# modules/implementations/authelia/default.nix
...
28: monEnabled = config.monitoring.enable or false;
...
395: monitoring = lib.mkIf monEnabled {
396: watchedUnits =
397: ["authelia-main.service"]
398: ++ lib.optional cfg.directory.enable "lldap.service";
...
459: json = internalAuthelia.mkDashboard self.lib.monitoring.dashboard;
...
```

</details>


<details>
<summary><code><a href="../contracts/persistence.md">persistence</a></code></summary>

**Configures options**: `persistence.directories`

```nix
# modules/implementations/authelia/default.nix
...
371: persistence.directories = lib.mkIf (config.persistence.enable or false) (
...
```

</details>


<details>
<summary><code><a href="../contracts/resources.md">resources</a></code></summary>

**Configures options**: `resources.units`

```nix
# modules/implementations/authelia/default.nix
...
84: resources = map globToRegex hostCfg.bypassPaths;
...
463: resources.units = lib.mkIf (config.resources.enable or false) (
...
```

</details>


<details>
<summary><code><a href="../contracts/reverse-proxy.md">reverse-proxy</a></code></summary>

**Configures options**: `reverse-proxy.forwardAuth`, `reverse-proxy.hosts`, `reverse-proxy.ports`

```nix
# modules/implementations/authelia/default.nix
...
29: metricsPort = self.lib.reverse-proxy.mkPort "authelia-metrics";
...
30: domain = config.reverse-proxy.domain or null;
...
78: (config.reverse-proxy.hosts or {});
...
315: reverse-proxy = {
316: forwardAuth = {
317: enable = true;
318: upstream = "${authConnectHost}:${toString cfg.port}";
...
355: hosts = lib.mkIf ((config.reverse-proxy.enable or false) && domain != null) (
...
490: (config.reverse-proxy.forwardAuth.enable or false)
...
491: && (config.reverse-proxy.forwardAuth.upstream or null) == "${authConnectHost}:${toString cfg.port}";
...
492: message = "`reverse-proxy.forwardAuth` must be enabled and point to Authelia's listener.";
...
497: (authFqdn == null || !(config.reverse-proxy.hosts.${authFqdn}.forwardAuth or false))
...
498: && (lldapFqdn == null || !(config.reverse-proxy.hosts.${lldapFqdn}.forwardAuth or false));
...
534: script = lib.optionalString (config.reverse-proxy.enable or false) (
...
```

</details>


<details>
<summary><code><a href="../contracts/secrets.md">secrets</a></code></summary>

**Configures options**: `secrets.files`

```nix
# modules/implementations/authelia/default.nix
...
151: secrets.files =
152: {
153: authelia-jwt-secret = {
154: store = "services/auth";
...
196: LLDAP_JWT_SECRET_FILE = config.secrets.files.lldap-jwt-secret.path;
...
210: ldap_user_pass_file = config.secrets.files.lldap-admin-password.path;
...
212: jwt_secret_file = config.secrets.files.lldap-jwt-secret.path;
...
218: secrets = {
219: jwtSecretFile = config.secrets.files.authelia-jwt-secret.path;
220: sessionSecretFile = config.secrets.files.authelia-session-secret.path;
221: storageEncryptionKeyFile = config.secrets.files.authelia-storage-encryption-key.path;
...
219: jwtSecretFile = config.secrets.files.authelia-jwt-secret.path;
...
220: sessionSecretFile = config.secrets.files.authelia-session-secret.path;
...
221: storageEncryptionKeyFile = config.secrets.files.authelia-storage-encryption-key.path;
...
296: after = ["sops-install-secrets.service"];
...
297: wants = ["sops-install-secrets.service"];
...
306: after = ["sops-install-secrets.service"] ++ lib.optional cfg.directory.enable "lldap.service";
...
307: wants = ["sops-install-secrets.service"];
...
310: LoadCredential = ["ldapPasswordFile:${config.secrets.files.lldap-admin-password.path}"];
...
```

</details>
