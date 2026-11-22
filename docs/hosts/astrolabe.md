# Host: `astrolabe`

Headless VPS Server (adje.app public edge and core services).

[← Back to Hosts Documentation](README.md) | [← Back to Main README](../../README.md)

- **Host**: `astrolabe`
- **System**: `x86_64-linux`
- **State Version**: `25.11`
- **Definition File**: [`modules/hosts/astrolabe/default.nix`](../../modules/hosts/astrolabe/default.nix)

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
    urn__nixconf__ast__module__authelia["nixosModule/authelia"]:::defaultNode
    urn__nixconf__ast__module__bitwarden_desktop["nixosModule/bitwarden-desktop"]:::defaultNode
    urn__nixconf__ast__module__bw["nixosModule/bw"]:::defaultNode
    urn__nixconf__ast__module__caddy["nixosModule/caddy"]:::defaultNode
    urn__nixconf__ast__module__cgroups["nixosModule/cgroups"]:::defaultNode
    urn__nixconf__ast__module__copyparty["nixosModule/copyparty"]:::defaultNode
    urn__nixconf__ast__module__direnv["nixosModule/direnv"]:::defaultNode
    urn__nixconf__ast__module__disko["nixosModule/disko"]:::defaultNode
    urn__nixconf__ast__module__docker["nixosModule/docker"]:::defaultNode
    urn__nixconf__ast__module__dolphin["nixosModule/dolphin"]:::defaultNode
    urn__nixconf__ast__module__foot["nixosModule/foot"]:::defaultNode
    urn__nixconf__ast__module__git["nixosModule/git"]:::defaultNode
    urn__nixconf__ast__module__grafana["nixosModule/grafana"]:::defaultNode
    urn__nixconf__ast__module__hjem["nixosModule/hjem"]:::defaultNode
    urn__nixconf__ast__module__impermanence["nixosModule/impermanence"]:::defaultNode
    urn__nixconf__ast__module__labwc["nixosModule/labwc"]:::defaultNode
    urn__nixconf__ast__module__locale["nixosModule/locale"]:::defaultNode
    urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__module__micro["nixosModule/micro"]:::defaultNode
    urn__nixconf__ast__module__nix["nixosModule/nix"]:::defaultNode
    urn__nixconf__ast__module__noctalia["nixosModule/noctalia"]:::defaultNode
    urn__nixconf__ast__module__ntfy["nixosModule/ntfy"]:::defaultNode
    urn__nixconf__ast__module__rclone["nixosModule/rclone"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__snapshot["nixosModule/snapshot"]:::defaultNode
    urn__nixconf__ast__module__sops["nixosModule/sops"]:::defaultNode
    urn__nixconf__ast__module__ssh["nixosModule/ssh"]:::defaultNode
    urn__nixconf__ast__module__tack["nixosModule/tack"]:::defaultNode
    urn__nixconf__ast__module__ttyd["nixosModule/ttyd"]:::defaultNode
    urn__nixconf__ast__module__uchiyomi["nixosModule/uchiyomi"]:::defaultNode
    urn__nixconf__ast__module__vaultwarden["nixosModule/vaultwarden"]:::defaultNode
    urn__nixconf__ast__module__vivaldi["nixosModule/vivaldi"]:::defaultNode
    urn__nixconf__ast__module__vscode["nixosModule/vscode"]:::defaultNode
    urn__nixconf__ast__module__wifi_eduroam["nixosModule/wifi-eduroam"]:::defaultNode
    urn__nixconf__ast__module__x240_resources["nixosModule/x240-resources"]:::defaultNode
    urn__nixconf__ast__module__x240_system["nixosModule/x240-system"]:::defaultNode
    urn__nixconf__ast__module__zed["nixosModule/zed"]:::defaultNode
    urn__nixconf__ast__option__auth_directory[/"auth.directory"/]:::optNode
    urn__nixconf__ast__option__auth_rules[/"auth.rules"/]:::optNode
    urn__nixconf__ast__option__backup_enable[/"backup.enable"/]:::optNode
    urn__nixconf__ast__option__backup_exclude[/"backup.exclude"/]:::optNode
    urn__nixconf__ast__option__backup_paths[/"backup.paths"/]:::optNode
    urn__nixconf__ast__option__backup_units[/"backup.units"/]:::optNode
    urn__nixconf__ast__option__default_user_email[/"default-user.email"/]:::optNode
    urn__nixconf__ast__option__default_user_githubUsername[/"default-user.githubUsername"/]:::optNode
    urn__nixconf__ast__option__default_user_username[/"default-user.username"/]:::optNode
    urn__nixconf__ast__option__home_shared[/"home.shared"/]:::optNode
    urn__nixconf__ast__option__home_users[/"home.users"/]:::optNode
    urn__nixconf__ast__option__monitoring_dashboards[/"monitoring.dashboards"/]:::optNode
    urn__nixconf__ast__option__monitoring_exporters[/"monitoring.exporters"/]:::optNode
    urn__nixconf__ast__option__monitoring_extraGrafanaSettings[/"monitoring.extraGrafanaSettings"/]:::optNode
    urn__nixconf__ast__option__monitoring_logs[/"monitoring.logs"/]:::optNode
    urn__nixconf__ast__option__monitoring_probes[/"monitoring.probes"/]:::optNode
    urn__nixconf__ast__option__monitoring_rules[/"monitoring.rules"/]:::optNode
    urn__nixconf__ast__option__monitoring_scrapes[/"monitoring.scrapes"/]:::optNode
    urn__nixconf__ast__option__monitoring_server[/"monitoring.server"/]:::optNode
    urn__nixconf__ast__option__monitoring_services[/"monitoring.services"/]:::optNode
    urn__nixconf__ast__option__monitoring_watchedUnits[/"monitoring.watchedUnits"/]:::optNode
    urn__nixconf__ast__option__persistence_directories[/"persistence.directories"/]:::optNode
    urn__nixconf__ast__option__persistence_files[/"persistence.files"/]:::optNode
    urn__nixconf__ast__option__persistence_users[/"persistence.users"/]:::optNode
    urn__nixconf__ast__option__resources_disk[/"resources.disk"/]:::optNode
    urn__nixconf__ast__option__resources_oom[/"resources.oom"/]:::optNode
    urn__nixconf__ast__option__resources_power[/"resources.power"/]:::optNode
    urn__nixconf__ast__option__resources_profile[/"resources.profile"/]:::optNode
    urn__nixconf__ast__option__resources_storageBudgets[/"resources.storageBudgets"/]:::optNode
    urn__nixconf__ast__option__resources_tiers[/"resources.tiers"/]:::optNode
    urn__nixconf__ast__option__resources_units[/"resources.units"/]:::optNode
    urn__nixconf__ast__option__resources_volumes[/"resources.volumes"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_domain[/"reverse-proxy.domain"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_forwardAuth[/"reverse-proxy.forwardAuth"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_hosts[/"reverse-proxy.hosts"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_ports[/"reverse-proxy.ports"/]:::optNode
    urn__nixconf__ast__option__secrets_files[/"secrets.files"/]:::optNode
    urn__nixconf__ast__option__secrets_placeholder[/"secrets.placeholder"/]:::optNode
    urn__nixconf__ast__option__secrets_templates[/"secrets.templates"/]:::optNode
    urn__nixconf__ast__option__storage_activeSlices[/"storage.activeSlices"/]:::optNode
    urn__nixconf__ast__option__storage_enable[/"storage.enable"/]:::optNode
    urn__nixconf__ast__option__storage_mounts[/"storage.mounts"/]:::optNode
    urn__nixconf__drv__devShell__default["devShell/default"]:::devShellNode
    urn__nixconf__drv__devShell__gemini_api["devShell/gemini-api"]:::devShellNode
    urn__nixconf__drv__devShell__github_cli["devShell/github-cli"]:::devShellNode
    urn__nixconf__drv__devShell__github_ssh["devShell/github-ssh"]:::devShellNode
    urn__nixconf__drv__devShell__master_ssh["devShell/master-ssh"]:::devShellNode
    urn__nixconf__drv__devShell__sops_admin["devShell/sops-admin"]:::devShellNode
    urn__nixconf__drv__devShell__storage_admin["devShell/storage-admin"]:::devShellNode
    urn__nixconf__drv__package__agy[("package/agy")]:::pkgNode
    urn__nixconf__drv__package__agy_api[("package/agy-api")]:::pkgNode
    urn__nixconf__drv__package__antigravity[("package/antigravity")]:::pkgNode
    urn__nixconf__drv__package__antigravity_ide[("package/antigravity-ide")]:::pkgNode
    urn__nixconf__drv__package__bw[("package/bw")]:::pkgNode
    urn__nixconf__drv__package__git[("package/git")]:::pkgNode
    urn__nixconf__drv__package__micro[("package/micro")]:::pkgNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__eval__configuration__x240(["nixosConfiguration/x240"]):::hostNode
    urn__nixconf__onto__contract__monitoring{{"monitoring"}}:::contractNode
    urn__nixconf__onto__contract__resources{{"resources"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__feature__antigravity("antigravity"):::featureNode
    urn__nixconf__onto__feature__bitwarden("bitwarden"):::featureNode
    urn__nixconf__onto__feature__copyparty("copyparty"):::featureNode
    urn__nixconf__onto__feature__direnv("direnv"):::featureNode
    urn__nixconf__onto__feature__disko("disko"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__feature__micro("micro"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__ntfy("ntfy"):::featureNode
    urn__nixconf__onto__feature__snapshot("snapshot"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__tack("tack"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__uchiyomi("uchiyomi"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
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

    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
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
    urn__nixconf__ast__module__agy_hub -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__agy_hub -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__agy_hub -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__alloy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__alloy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__alloy -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_extraGrafanaSettings
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__alloy -.->|reads| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__alloy -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__alloy -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__alloy -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__alloy -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__astrolabe -.->|flowsTo| urn__nixconf__ast__module__grafana
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
    urn__nixconf__ast__module__astrolabe_services -.->|writes| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__sops
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
    urn__nixconf__ast__module__bitwarden_desktop -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__ast__module__bw -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__ast__module__bw -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__bw -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__impermanence
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
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__restic
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
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__storage_enable
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__storage_mounts
    urn__nixconf__ast__module__direnv -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__direnv -.->|writes| urn__nixconf__ast__option__persistence_users
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
    urn__nixconf__ast__module__docker -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__docker -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__dolphin -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__dolphin -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__foot -.->|flowsTo| urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__foot -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__foot -.->|writes| urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__foot -.->|writes| urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__foot -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__git -->|dependsOn| urn__nixconf__drv__package__git
    urn__nixconf__ast__module__git -.->|flowsTo| urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__git -.->|writes| urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__git -.->|writes| urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__authelia
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__sops
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
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__auth_rules
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_server
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__hjem -.->|reads| urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__hjem -.->|reads| urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__impermanence -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__impermanence -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__impermanence -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__labwc -.->|flowsTo| urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__labwc -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__labwc -.->|writes| urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__labwc -.->|writes| urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__labwc -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__locale -.->|flowsTo| urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__locale -.->|writes| urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__lw -.->|flowsTo| urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__lw -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__lw -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__lw -.->|reads| urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -.->|reads| urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -.->|reads| urn__nixconf__ast__option__default_user_username
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__default_user_username
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__micro -->|dependsOn| urn__nixconf__drv__package__micro
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__noctalia -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__noctalia -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_server
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__rclone -.->|reads| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__ast__module__rclone -.->|reads| urn__nixconf__ast__option__storage_enable
    urn__nixconf__ast__module__rclone -.->|reads| urn__nixconf__ast__option__storage_mounts
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__sops
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
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__sops -.->|writes| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__storage_enable
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__storage_mounts
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__ast__module__vivaldi -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vivaldi -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__vscode -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vscode -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__wifi_eduroam -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__wifi_eduroam -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__wifi_eduroam -.->|writes| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__x240_resources -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__x240_resources -.->|writes| urn__nixconf__ast__option__resources_disk
    urn__nixconf__ast__module__x240_resources -.->|writes| urn__nixconf__ast__option__resources_profile
    urn__nixconf__ast__module__x240_resources -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__x240_resources -.->|writes| urn__nixconf__ast__option__resources_volumes
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__zed -.->|flowsTo| urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__zed -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__zed -.->|writes| urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__zed -.->|writes| urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__zed -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__drv__devShell__default -->|dependsOn| urn__nixconf__drv__package__git
    urn__nixconf__drv__devShell__gemini_api -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__drv__devShell__gemini_api -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__drv__devShell__github_cli -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__drv__devShell__github_cli -->|dependsOn| urn__nixconf__drv__package__git
    urn__nixconf__drv__devShell__github_ssh -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__drv__devShell__master_ssh -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__drv__devShell__sops_admin -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__drv__devShell__storage_admin -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__eval__configuration__astrolabe -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__eval__configuration__astrolabe -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__eval__configuration__astrolabe -->|dependsOn| urn__nixconf__drv__package__git
    urn__nixconf__eval__configuration__astrolabe -->|dependsOn| urn__nixconf__drv__package__micro
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__agy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__agy_hub
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_resources
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__authelia
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__bw
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__caddy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__cgroups
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__copyparty
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__direnv
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__disko
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__git
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__grafana
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__hjem
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__locale
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__micro
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ntfy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__rclone
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__snapshot
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__tack
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ttyd
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__eval__configuration__x240 -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__eval__configuration__x240 -->|dependsOn| urn__nixconf__drv__package__bw
    urn__nixconf__eval__configuration__x240 -->|dependsOn| urn__nixconf__drv__package__git
    urn__nixconf__eval__configuration__x240 -->|dependsOn| urn__nixconf__drv__package__micro
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__agy
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__alloy
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__bw
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__cgroups
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__direnv
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__disko
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__docker
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__dolphin
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__foot
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__git
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__hjem
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__labwc
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__locale
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__micro
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__noctalia
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__rclone
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__tack
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__vivaldi
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__vscode
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__wifi_eduroam
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_resources
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_system
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__zed
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_extraGrafanaSettings
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_probes
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_scrapes
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_server
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_disk
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_oom
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_power
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_profile
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_storageBudgets
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_tiers
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_units
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_volumes
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_forwardAuth
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_ports
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_config
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_hub
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_remote_control
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__devShell__gemini_api
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__agy
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__agy_api
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__antigravity
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__bitwarden -->|outputs| urn__nixconf__ast__module__bitwarden_desktop
    urn__nixconf__onto__feature__bitwarden -->|outputs| urn__nixconf__ast__module__bw
    urn__nixconf__onto__feature__bitwarden -->|outputs| urn__nixconf__drv__package__bw
    urn__nixconf__onto__feature__copyparty -->|outputs| urn__nixconf__ast__module__copyparty
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__direnv -->|outputs| urn__nixconf__ast__module__direnv
    urn__nixconf__onto__feature__disko -->|outputs| urn__nixconf__ast__module__disko
    urn__nixconf__onto__feature__disko -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__git -->|outputs| urn__nixconf__ast__module__git
    urn__nixconf__onto__feature__git -->|outputs| urn__nixconf__drv__devShell__github_cli
    urn__nixconf__onto__feature__git -->|outputs| urn__nixconf__drv__devShell__github_ssh
    urn__nixconf__onto__feature__git -->|outputs| urn__nixconf__drv__package__git
    urn__nixconf__onto__feature__locale -->|outputs| urn__nixconf__ast__module__locale
    urn__nixconf__onto__feature__micro -->|outputs| urn__nixconf__ast__module__micro
    urn__nixconf__onto__feature__micro -->|outputs| urn__nixconf__drv__package__micro
    urn__nixconf__onto__feature__nix -->|outputs| urn__nixconf__ast__module__nix
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ntfy -->|outputs| urn__nixconf__ast__module__ntfy
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ntfy -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__snapshot -->|outputs| urn__nixconf__ast__module__snapshot
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__ast__module__ssh
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__drv__devShell__master_ssh
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__tack -->|outputs| urn__nixconf__ast__module__tack
    urn__nixconf__onto__feature__ttyd -->|outputs| urn__nixconf__ast__module__ttyd
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -->|outputs| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -->|outputs| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
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
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__copyparty
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__micro
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ntfy
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
    urn__nixconf__onto__implementation__authelia -->|outputs| urn__nixconf__ast__module__authelia
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy -->|outputs| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy ==>|implements| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__cgroups -->|outputs| urn__nixconf__ast__module__cgroups
    urn__nixconf__onto__implementation__cgroups -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__cgroups -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__cgroups ==>|implements| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__grafana -->|outputs| urn__nixconf__ast__module__grafana
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__grafana -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__grafana ==>|implements| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__hjem -->|outputs| urn__nixconf__ast__module__hjem
    urn__nixconf__onto__implementation__impermanence -->|outputs| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__lw -->|outputs| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__rclone -->|outputs| urn__nixconf__ast__module__rclone
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__restic -->|outputs| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__ast__module__sops
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__drv__devShell__sops_admin


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
    click urn__nixconf__ast__module__authelia href "../modules/authelia.md" "authelia"
    click urn__nixconf__ast__module__bitwarden_desktop href "../modules/bitwarden-desktop.md" "bitwarden-desktop"
    click urn__nixconf__ast__module__bw href "../modules/bw.md" "bw"
    click urn__nixconf__ast__module__caddy href "../modules/caddy.md" "caddy"
    click urn__nixconf__ast__module__cgroups href "../modules/cgroups.md" "cgroups"
    click urn__nixconf__ast__module__copyparty href "../modules/copyparty.md" "copyparty"
    click urn__nixconf__ast__module__direnv href "../modules/direnv.md" "direnv"
    click urn__nixconf__ast__module__disko href "../modules/disko.md" "disko"
    click urn__nixconf__ast__module__docker href "../modules/docker.md" "docker"
    click urn__nixconf__ast__module__dolphin href "../modules/dolphin.md" "dolphin"
    click urn__nixconf__ast__module__foot href "../modules/foot.md" "foot"
    click urn__nixconf__ast__module__git href "../modules/git.md" "git"
    click urn__nixconf__ast__module__grafana href "../modules/grafana.md" "grafana"
    click urn__nixconf__ast__module__hjem href "../modules/hjem.md" "hjem"
    click urn__nixconf__ast__module__impermanence href "../modules/impermanence.md" "impermanence"
    click urn__nixconf__ast__module__labwc href "../modules/labwc.md" "labwc"
    click urn__nixconf__ast__module__locale href "../modules/locale.md" "locale"
    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__ast__module__micro href "../modules/micro.md" "micro"
    click urn__nixconf__ast__module__nix href "../modules/nix.md" "nix"
    click urn__nixconf__ast__module__noctalia href "../modules/noctalia.md" "noctalia"
    click urn__nixconf__ast__module__ntfy href "../modules/ntfy.md" "ntfy"
    click urn__nixconf__ast__module__rclone href "../modules/rclone.md" "rclone"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__snapshot href "../modules/snapshot.md" "snapshot"
    click urn__nixconf__ast__module__sops href "../modules/sops.md" "sops"
    click urn__nixconf__ast__module__ssh href "../modules/ssh.md" "ssh"
    click urn__nixconf__ast__module__tack href "../modules/tack.md" "tack"
    click urn__nixconf__ast__module__ttyd href "../modules/ttyd.md" "ttyd"
    click urn__nixconf__ast__module__uchiyomi href "../modules/uchiyomi.md" "uchiyomi"
    click urn__nixconf__ast__module__vaultwarden href "../modules/vaultwarden.md" "vaultwarden"
    click urn__nixconf__ast__module__vivaldi href "../modules/vivaldi.md" "vivaldi"
    click urn__nixconf__ast__module__vscode href "../modules/vscode.md" "vscode"
    click urn__nixconf__ast__module__wifi_eduroam href "../modules/wifi-eduroam.md" "wifi-eduroam"
    click urn__nixconf__ast__module__x240_resources href "../modules/x240-resources.md" "x240-resources"
    click urn__nixconf__ast__module__x240_system href "../modules/x240-system.md" "x240-system"
    click urn__nixconf__ast__module__zed href "../modules/zed.md" "zed"
    click urn__nixconf__ast__option__auth_directory href "../contracts/auth.md" "auth.directory"
    click urn__nixconf__ast__option__auth_rules href "../contracts/auth.md" "auth.rules"
    click urn__nixconf__ast__option__backup_enable href "../contracts/backup.md" "backup.enable"
    click urn__nixconf__ast__option__backup_exclude href "../contracts/backup.md" "backup.exclude"
    click urn__nixconf__ast__option__backup_paths href "../contracts/backup.md" "backup.paths"
    click urn__nixconf__ast__option__backup_units href "../contracts/backup.md" "backup.units"
    click urn__nixconf__ast__option__default_user_email href "../contracts/default-user.md" "default-user.email"
    click urn__nixconf__ast__option__default_user_githubUsername href "../contracts/default-user.md" "default-user.githubUsername"
    click urn__nixconf__ast__option__default_user_username href "../contracts/default-user.md" "default-user.username"
    click urn__nixconf__ast__option__home_shared href "../contracts/home.md" "home.shared"
    click urn__nixconf__ast__option__home_users href "../contracts/home.md" "home.users"
    click urn__nixconf__ast__option__monitoring_dashboards href "../contracts/monitoring.md" "monitoring.dashboards"
    click urn__nixconf__ast__option__monitoring_exporters href "../contracts/monitoring.md" "monitoring.exporters"
    click urn__nixconf__ast__option__monitoring_extraGrafanaSettings href "../contracts/monitoring.md" "monitoring.extraGrafanaSettings"
    click urn__nixconf__ast__option__monitoring_logs href "../contracts/monitoring.md" "monitoring.logs"
    click urn__nixconf__ast__option__monitoring_probes href "../contracts/monitoring.md" "monitoring.probes"
    click urn__nixconf__ast__option__monitoring_rules href "../contracts/monitoring.md" "monitoring.rules"
    click urn__nixconf__ast__option__monitoring_scrapes href "../contracts/monitoring.md" "monitoring.scrapes"
    click urn__nixconf__ast__option__monitoring_server href "../contracts/monitoring.md" "monitoring.server"
    click urn__nixconf__ast__option__monitoring_services href "../contracts/monitoring.md" "monitoring.services"
    click urn__nixconf__ast__option__monitoring_watchedUnits href "../contracts/monitoring.md" "monitoring.watchedUnits"
    click urn__nixconf__ast__option__persistence_directories href "../contracts/persistence.md" "persistence.directories"
    click urn__nixconf__ast__option__persistence_files href "../contracts/persistence.md" "persistence.files"
    click urn__nixconf__ast__option__persistence_users href "../contracts/persistence.md" "persistence.users"
    click urn__nixconf__ast__option__resources_disk href "../contracts/resources.md" "resources.disk"
    click urn__nixconf__ast__option__resources_oom href "../contracts/resources.md" "resources.oom"
    click urn__nixconf__ast__option__resources_power href "../contracts/resources.md" "resources.power"
    click urn__nixconf__ast__option__resources_profile href "../contracts/resources.md" "resources.profile"
    click urn__nixconf__ast__option__resources_storageBudgets href "../contracts/resources.md" "resources.storageBudgets"
    click urn__nixconf__ast__option__resources_tiers href "../contracts/resources.md" "resources.tiers"
    click urn__nixconf__ast__option__resources_units href "../contracts/resources.md" "resources.units"
    click urn__nixconf__ast__option__resources_volumes href "../contracts/resources.md" "resources.volumes"
    click urn__nixconf__ast__option__reverse_proxy_domain href "../contracts/reverse-proxy.md" "reverse-proxy.domain"
    click urn__nixconf__ast__option__reverse_proxy_forwardAuth href "../contracts/reverse-proxy.md" "reverse-proxy.forwardAuth"
    click urn__nixconf__ast__option__reverse_proxy_hosts href "../contracts/reverse-proxy.md" "reverse-proxy.hosts"
    click urn__nixconf__ast__option__reverse_proxy_ports href "../contracts/reverse-proxy.md" "reverse-proxy.ports"
    click urn__nixconf__ast__option__secrets_files href "../contracts/secrets.md" "secrets.files"
    click urn__nixconf__ast__option__secrets_placeholder href "../contracts/secrets.md" "secrets.placeholder"
    click urn__nixconf__ast__option__secrets_templates href "../contracts/secrets.md" "secrets.templates"
    click urn__nixconf__ast__option__storage_activeSlices href "../contracts/storage.md" "storage.activeSlices"
    click urn__nixconf__ast__option__storage_enable href "../contracts/storage.md" "storage.enable"
    click urn__nixconf__ast__option__storage_mounts href "../contracts/storage.md" "storage.mounts"
    click urn__nixconf__drv__devShell__default href "../devshells.md#default" "default"
    click urn__nixconf__drv__devShell__gemini_api href "../devshells.md#gemini-api" "gemini-api"
    click urn__nixconf__drv__devShell__github_cli href "../devshells.md#github-cli" "github-cli"
    click urn__nixconf__drv__devShell__github_ssh href "../devshells.md#github-ssh" "github-ssh"
    click urn__nixconf__drv__devShell__master_ssh href "../devshells.md#master-ssh" "master-ssh"
    click urn__nixconf__drv__devShell__sops_admin href "../devshells.md#sops-admin" "sops-admin"
    click urn__nixconf__drv__devShell__storage_admin href "../devshells.md#storage-admin" "storage-admin"
    click urn__nixconf__drv__package__agy href "../packages.md#agy" "agy"
    click urn__nixconf__drv__package__agy_api href "../packages.md#agy-api" "agy-api"
    click urn__nixconf__drv__package__antigravity href "../packages.md#antigravity" "antigravity"
    click urn__nixconf__drv__package__antigravity_ide href "../packages.md#antigravity-ide" "antigravity-ide"
    click urn__nixconf__drv__package__bw href "../packages.md#bw" "bw"
    click urn__nixconf__drv__package__git href "../packages.md#git" "git"
    click urn__nixconf__drv__package__micro href "../packages.md#micro" "micro"
    click urn__nixconf__eval__configuration__astrolabe href "astrolabe.md" "astrolabe"
    click urn__nixconf__eval__configuration__x240 href "x240.md" "x240"
    click urn__nixconf__onto__contract__monitoring href "../contracts/monitoring.md" "monitoring"
    click urn__nixconf__onto__contract__resources href "../contracts/resources.md" "resources"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__feature__antigravity href "../features/antigravity.md" "antigravity"
    click urn__nixconf__onto__feature__bitwarden href "../features/bitwarden.md" "bitwarden"
    click urn__nixconf__onto__feature__copyparty href "../features/copyparty.md" "copyparty"
    click urn__nixconf__onto__feature__direnv href "../features/direnv.md" "direnv"
    click urn__nixconf__onto__feature__disko href "../features/disko.md" "disko"
    click urn__nixconf__onto__feature__git href "../features/git.md" "git"
    click urn__nixconf__onto__feature__locale href "../features/locale.md" "locale"
    click urn__nixconf__onto__feature__micro href "../features/micro.md" "micro"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__ntfy href "../features/ntfy.md" "ntfy"
    click urn__nixconf__onto__feature__snapshot href "../features/snapshot.md" "snapshot"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__tack href "../features/tack.md" "tack"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__uchiyomi href "../features/uchiyomi.md" "uchiyomi"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__host__astrolabe href "astrolabe.md" "astrolabe"
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

## Active Contracts

The following contracts are materialized on `astrolabe` through its active implementation providers:

| Contract | Contract Description | Implementation | Implementation Description | Docs |
| :--- | :--- | :--- | :--- | :--- |
| [`auth`](../contracts/auth.md) | Declarative single sign-on (SSO), forward authentication, access control policy, and LDAP directory contract. | [`authelia`](../implementations/authelia.md) | Centralized SSO, forward authentication, 2FA, and LDAP directory implementation using Authelia and LLDAP. | [More →](../contracts/auth.md) |
| [`reverse-proxy`](../contracts/reverse-proxy.md) | Declarative HTTP/TLS reverse proxy virtual host ingress and routing management. | [`caddy`](../implementations/caddy.md) | Automated TLS virtual host reverse proxy implementation using Caddy. | [More →](../contracts/reverse-proxy.md) |
| [`resources`](../contracts/resources.md) | Declarative compute tiering, cgroups v2 limits, OOM ordering, power-aware throttling, local disk volumes, and remote storage budgets. | [`cgroups`](../implementations/cgroups.md) | Systemd control groups v2 tiering, OOM ordering, power policy, local disk volumes, and remote storage budget implementation. | [More →](../contracts/resources.md) |
| [`monitoring`](../contracts/monitoring.md) | Declarative metrics, logs, blackbox probing, alerting rules, and dashboard provisioning contract. | [`grafana`](../implementations/grafana.md) | Full observability stack implementation using Grafana, VictoriaMetrics, VictoriaLogs, vmalert, Alertmanager, and Grafana Alloy. | [More →](../contracts/monitoring.md) |
| [`home`](../contracts/home.md) | Declarative user home dotfile tree, XDG directory specifications, and session environment. | [`hjem`](../implementations/hjem.md) | Lightweight declarative home directory files and XDG environment manager. | [More →](../contracts/home.md) |
| [`persistence`](../contracts/persistence.md) | Declarative state preservation across ephemeral reboots for system and user directories. | [`impermanence`](../implementations/impermanence.md) | Ephemeral root filesystem with persistent state bind-mounts via Impermanence. | [More →](../contracts/persistence.md) |
| [`default-user`](../contracts/default-user.md) | Default primary user account identification, credentials, and configuration injection. | [`lw`](../implementations/lw.md) | Primary human user account orchestration and identity provisioning. | [More →](../contracts/default-user.md) |
| [`storage`](../contracts/storage.md) | Declarative multi-provider storage contract separating open driver definitions, logical providers, host/shared slices, and mount requests. | [`rclone`](../implementations/rclone.md) | Declarative multi-provider storage mounts, crypt/union tiering, and rclone configuration provisioning. | [More →](../contracts/storage.md) |
| [`backup`](../contracts/backup.md) | Declarative multi-provider backup contract separating per-provider schedules/retention, host vs shared repository scopes, per-service units, and boot-time most-recent auto-restore. | [`restic`](../implementations/restic.md) | Multi-provider restic backup implementation backed by rclone storage slices, per-provider schedules/retention, and boot-time most-recent auto-restore. | [More →](../contracts/backup.md) |
| [`secrets`](../contracts/secrets.md) | Declarative encrypted secrets provisioning, filesystem mounting, and permission management. | [`sops`](../implementations/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [More →](../contracts/secrets.md) |

## Enabled Features

The following system and desktop features are imported by `astrolabe`:

| Feature | Description | Outputs Used | Docs |
| :--- | :--- | :--- | :--- |
| [`antigravity`](../features/antigravity.md) | Modular Google Antigravity CLI (agy), declarative config/rules, remote-control daemon, Rust hub, desktop/IDE packages, and Gemini API shell. | [`agy`](../modules/agy.md) (module), [`agy-config`](../modules/agy-config.md) (module), [`agy-hub`](../modules/agy-hub.md) (module), [`agy-remote-control`](../modules/agy-remote-control.md) (module), [`agy`](../packages.md#agy) (package), [`agy-api`](../packages.md#agy-api) (package), [`antigravity`](../packages.md#antigravity) (package), [`antigravity-ide`](../packages.md#antigravity-ide) (package) | [More →](../features/antigravity.md) |
| [`bitwarden`](../features/bitwarden.md) | Bitwarden password manager CLI wrapper, desktop application, and vault retrieval helpers. | [`bitwarden-desktop`](../modules/bitwarden-desktop.md) (module), [`bw`](../modules/bw.md) (module), [`bw`](../packages.md#bw) (package) | [More →](../features/bitwarden.md) |
| [`copyparty`](../features/copyparty.md) | Self-hosted multi-protocol file server, resumable upload hub, and cloud storage browser via Copyparty. | [`copyparty`](../modules/copyparty.md) (module) | [More →](../features/copyparty.md) |
| [`direnv`](../features/direnv.md) | Per-directory declarative shell environment integration via nix-direnv. | [`direnv`](../modules/direnv.md) (module) | [More →](../features/direnv.md) |
| [`disko`](../features/disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | [`disko`](../modules/disko.md) (module) | [More →](../features/disko.md) |
| [`git`](../features/git.md) | Git version control system, global/per-user configuration, and Bitwarden GitHub SSH/CLI shells. | [`git`](../modules/git.md) (module), [`git`](../packages.md#git) (package) | [More →](../features/git.md) |
| [`locale`](../features/locale.md) | System internationalization, time zone, and language locale configuration. | [`locale`](../modules/locale.md) (module) | [More →](../features/locale.md) |
| [`micro`](../features/micro.md) | Modern and intuitive terminal-based text editor with wrapped declarative configuration. | [`micro`](../modules/micro.md) (module), [`micro`](../packages.md#micro) (package) | [More →](../features/micro.md) |
| [`nix`](../features/nix.md) | Nix package manager daemon settings, binary caches, garbage collection, and nix-ld. | [`nix`](../modules/nix.md) (module) | [More →](../features/nix.md) |
| [`ntfy`](../features/ntfy.md) | Self-hosted push notification server (ntfy) with declarative admin credentials, metrics, probes, and Alertmanager wiring. | [`ntfy`](../modules/ntfy.md) (module) | [More →](../features/ntfy.md) |
| [`snapshot`](../features/snapshot.md) | Atomic local Btrfs read-only snapshots paired with deduplicated restic off-site host snapshots and manual CLI triggers. | [`snapshot`](../modules/snapshot.md) (module) | [More →](../features/snapshot.md) |
| [`ssh`](../features/ssh.md) | OpenSSH server daemon hardening, authorized key distribution, and master SSH key agent shell. | [`ssh`](../modules/ssh.md) (module) | [More →](../features/ssh.md) |
| [`tack`](../features/tack.md) | Flake input pinning and lockfile orchestration tool. | [`tack`](../modules/tack.md) (module) | [More →](../features/tack.md) |
| [`ttyd`](../features/ttyd.md) | Web terminal server bridging browser sessions to persistent tmux-backed system shells via ttyd. | [`ttyd`](../modules/ttyd.md) (module) | [More →](../features/ttyd.md) |
| [`uchiyomi`](../features/uchiyomi.md) | Self-hosted manga, manhwa, and webtoon server, reader, and downloader stack. | [`uchiyomi`](../modules/uchiyomi.md) (module) | [More →](../features/uchiyomi.md) |
| [`vaultwarden`](../features/vaultwarden.md) | Self-hosted Bitwarden compatible password manager server. | [`vaultwarden`](../modules/vaultwarden.md) (module) | [More →](../features/vaultwarden.md) |

## Host Submodules

Host-specific configuration submodules partitioning hardware, disks, and local system services:

<details>
<summary><code><a href="../modules/astrolabe-disk.md">astrolabe-disk</a></code></summary>

```nix
astrolabe-disk = {...}: {
  imports = [
    self.nixosModules.disko
    self.nixosModules.impermanence
  ];

  config =
    self.lib.disko.mkLayout {
      device = "/dev/sda";
      espSize = "512M";
      biosBootSize = "1M";
    }
    // {
      zramSwap.enable = true;
    };
};
```

</details>

<details>
<summary><code><a href="../modules/astrolabe-hardware.md">astrolabe-hardware</a></code></summary>

```nix
astrolabe-hardware = {
  modulesPath,
  lib,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  config = {
    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    boot.loader.grub = {
      enable = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "/dev/sda";
    };
  };
};
```

</details>

<details>
<summary><code><a href="../modules/astrolabe-resources.md">astrolabe-resources</a></code></summary>

```nix
astrolabe-resources = {config, ...}: let
```

</details>

<details>
<summary><code><a href="../modules/astrolabe-services.md">astrolabe-services</a></code></summary>

```nix
astrolabe-services = {...}: {
  imports = [
    self.nixosModules.caddy
    self.nixosModules.authelia
    self.nixosModules.grafana
    self.nixosModules.ntfy
    self.nixosModules.restic
    self.nixosModules.snapshot
    self.nixosModules.vaultwarden
    self.nixosModules.ttyd
    self.nixosModules.agy
    self.nixosModules.agy-hub
    self.nixosModules.uchiyomi
    self.nixosModules.copyparty
  ];

  config = {
    reverse-proxy.domain = "adje.app";
  };
};
```

</details>

<details>
<summary><code><a href="../modules/astrolabe-system.md">astrolabe-system</a></code></summary>

```nix
astrolabe-system = {pkgs, ...}: {
  imports = [
    self.nixosModules.sops
    self.nixosModules.cgroups
    self.nixosModules.rclone
    self.nixosModules.lw
    self.nixosModules.hjem
    self.nixosModules.nix
    self.nixosModules.locale
    self.nixosModules.direnv
    self.nixosModules.ssh
    self.nixosModules.git
    self.nixosModules.tack
    self.nixosModules.bw
    self.nixosModules.micro
  ];

  config = {
    networking.hostName = "astrolabe";
    environment.systemPackages = with pkgs; [
      rsync
      btop
    ];
    system.configurationRevision = self.rev or self.dirtyRev or "unknown";
    system.stateVersion = "25.11";
  };
};
```

</details>

## Storage Layout

Evaluated Disko layout in canonical `lsblk(8)` format (see [`disko`](../features/disko.md)):

```text
NAME                     TYPE       FSTYPE  SIZE      MOUNTPOINT
/dev/sda                 disk       gpt
├─bios                   part               1M
├─esp                    part       vfat    512M      /boot
└─root                   part       lvm_pv  100%
  └─system               lvm_vg
    └─root               lvm_lv     btrfs   100%FREE
      ├─subvol:/nix      subvolume  btrfs             /nix
      ├─subvol:/persist  subvolume  btrfs             /persist
      └─subvol:/root     subvolume  btrfs             (snapshot)
[nodev]
└─tmpfs                  nodev      tmpfs   25%       /
```

## Persisted State

State preserved across reboots by fulfilling the [`persistence`](../contracts/persistence.md) contract:

```text
/persist/system
├── [dir]  /etc/NetworkManager/system-connections/
├── [dir]  /etc/nixos/
├── [dir]  /tmp/
├── [dir]  /var/cache/copyparty/
├── [dir]  /var/cache/host-snapshot-gdrive/
├── [dir]  /var/cache/host-snapshot-hbox/
├── [dir]  /var/cache/restic-backups-agy-gdrive-host/
├── [dir]  /var/cache/restic-backups-agy-hbox-host/
├── [dir]  /var/cache/restic-backups-authelia-gdrive-host/
├── [dir]  /var/cache/restic-backups-authelia-hbox-host/
├── [dir]  /var/cache/restic-backups-copyparty-gdrive-host/
├── [dir]  /var/cache/restic-backups-copyparty-hbox-host/
├── [dir]  /var/cache/restic-backups-grafana-gdrive-host/
├── [dir]  /var/cache/restic-backups-grafana-hbox-host/
├── [dir]  /var/cache/restic-backups-lldap-gdrive-host/
├── [dir]  /var/cache/restic-backups-lldap-hbox-host/
├── [dir]  /var/cache/restic-backups-telemetry-gdrive-host/
├── [dir]  /var/cache/restic-backups-telemetry-hbox-host/
├── [dir]  /var/cache/restic-backups-uchiyomi-gdrive-host/
├── [dir]  /var/cache/restic-backups-uchiyomi-hbox-host/
├── [dir]  /var/cache/restic-backups-vaultwarden-b2-shared/
├── [dir]  /var/cache/restic-backups-vaultwarden-gdrive-shared/
├── [dir]  /var/cache/restic-backups-vaultwarden-hbox-shared/
├── [dir]  /var/cache/uchiyomi/
├── [dir]  /var/lib/alloy/
├── [dir]  /var/lib/containers/
├── [dir]  /var/lib/copyparty/
├── [dir]  /var/lib/grafana/
├── [dir]  /var/lib/nixconf-backup/
├── [dir]  /var/lib/nixos/
├── [dir]  /var/lib/systemd/coredump/
├── [dir]  /var/lib/uchiyomi/
├── [dir]  /var/log/
├── [file] /etc/machine-id
├── [file] /etc/ssh/ssh_host_ed25519_key
├── [file] /etc/ssh/ssh_host_ed25519_key.pub
├── [file] /etc/ssh/ssh_host_rsa_key
└── [file] /etc/ssh/ssh_host_rsa_key.pub

/persist/users/lw/cache
├── [dir]  ~lw/.cache/direnv/
├── [dir]  ~lw/.cache/nix-index/
└── [dir]  ~lw/.cache/nix/

/persist/users/lw/data
├── [dir]  ~lw/.config/Bitwarden CLI/
├── [dir]  ~lw/.gemini/
├── [dir]  ~lw/.local/share/direnv/
├── [dir]  ~lw/.ssh/
├── [dir]  ~lw/Documents/
├── [dir]  ~lw/Downloads/
├── [dir]  ~lw/Projects/
└── [dir]  ~lw/nixconf/
```

## Resource Allocation

Workload tiering, OOM protection, and capacity policies enforced via [`resources`](../contracts/resources.md):

- **Profile**: `server`
- **Power-Aware Throttling**: `false`
- **systemd-oomd**: `true` (swap kill: `false`)

### Workload Tiers

| Tier (`Slice`) | Policy | On Battery | Assigned Units |
| :--- | :--- | :--- | :--- |
| `critical.slice` | CPU:500, IO:500, MemMin:5%, MemLow:15%, OOM:avoid, Score:-500 | — | `authelia-main.service`, `caddy.service`, `lldap.service`, `sshd.service`, `vaultwarden.service` |
| `system.slice` | CPU:300, IO:300, MemLow:5%, OOM:avoid | — | — |
| `machine.slice` | CPU:100, IO:100, OOMKill:80% | — | — |
| `standard.slice` | CPU:100, IO:100, MemHigh:75%, OOMKill:80%, Score:0 | — | `agy-hub.service`, `alertmanager.service`, `alloy.service`, `copyparty.service`, `grafana.service`, `mnt-storage-copyparty.mount`, `mnt-storage-gdrive.mount`, `mnt-storage-uchiyomi.mount`, `ntfy-sh.service`, `ttyd-web.service`, `victorialogs.service`, `victoriametrics.service`, `vmalert-logs.service`, `vmalert-metrics.service` |
| `user.slice` | CPU:100, IO:100 | — | — |
| `media.slice` | CPU:60, IO:60, MemHigh:50%, MemMax:65%, OOMKill:70%, Score:200 | — | `podman-uchiyomi-flaresolverr.service`, `podman-uchiyomi-suwayomi.service`, `podman-uchiyomi.service` |
| `background.slice` | CPU:20, IO:20, MemHigh:80%, OOMKill:60%, Score:500 | — | `agy-remote-control.service`, `cachix-watch-store-agent.service`, `host-snapshot-gdrive.service`, `host-snapshot-hbox.service`, `nix-daemon.service`, `nix-gc.service`, `nix-optimise.service`, `resources-storage-budgets.service`, `restic-backups-agy-gdrive-host.service`, `restic-backups-agy-hbox-host.service`, `restic-backups-authelia-gdrive-host.service`, `restic-backups-authelia-hbox-host.service`, `restic-backups-copyparty-gdrive-host.service`, `restic-backups-copyparty-hbox-host.service`, `restic-backups-grafana-gdrive-host.service`, `restic-backups-grafana-hbox-host.service`, `restic-backups-lldap-gdrive-host.service`, `restic-backups-lldap-hbox-host.service`, `restic-backups-telemetry-gdrive-host.service`, `restic-backups-telemetry-hbox-host.service`, `restic-backups-uchiyomi-gdrive-host.service`, `restic-backups-uchiyomi-hbox-host.service`, `restic-backups-vaultwarden-b2-shared.service`, `restic-backups-vaultwarden-gdrive-shared.service`, `restic-backups-vaultwarden-hbox-shared.service` |

### Local Disk Volumes

| Volume | Mode | Size | Mountpoint |
| :--- | :--- | :--- | :--- |
| `authelia-data` | `reserved` | `256M` | `/var/lib/authelia-main` |
| `caddy-data` | `reserved` | `256M` | `/var/lib/caddy` |
| `emergency-headroom` | `reserved` | `2G` | *unmounted reservation* |
| `lldap-data` | `reserved` | `256M` | `/var/lib/lldap` |
| `ntfy-data` | `reserved` | `256M` | `/var/lib/ntfy-sh` |
| `rclone-cache` | `thin` | `25G` | `/var/cache/rclone` |
| `vaultwarden-data` | `reserved` | `512M` | `/var/lib/vaultwarden` |
| `victorialogs-data` | `thin` | `15G` | `/var/lib/victorialogs` |
| `victoriametrics-data` | `thin` | `25G` | `/var/lib/victoriametrics` |

### Remote Storage Budgets

| Storage Slice | Budget | Warn Threshold | Check Interval |
| :--- | :--- | :--- | :--- |
| `b2-backup-shared` | `10G` | `80%` | `24h` |
| `copyparty` | `250G` | `80%` | `6h` |
| `gdrive-backup-host` | `100G` | `80%` | `24h` |
| `hbox-backup-host` | `200G` | `85%` | `12h` |
| `hbox-backup-shared` | `100G` | `85%` | `12h` |
| `uchiyomi` | `250G` | `80%` | `6h` |

## Consumed Contracts

Capability contracts configured by `astrolabe`:

<details>
<summary><code><a href="../contracts/monitoring.md">monitoring</a></code></summary>

**Configures options**: `monitoring.dashboards`, `monitoring.exporters`, `monitoring.extraGrafanaSettings`, `monitoring.logs`, `monitoring.rules`

```nix
config = {
  monitoring.dashboards = {
  auth-security = {
    enable = true;
    folder = "02 · Infrastructure";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "Authelia SSO authentication attempts, forward-auth authorization decisions, latency percentiles, and SSH/LLDAP security logs.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 1;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [
                {
                  options = {
                    "0" = {
                      color = "red";
                      index = 0;
                      text = "DOWN";
                    };
                    "1" = {
                      color = "green";
                      index = 1;
                      text = "UP";
                    };
                  };
                  type = "value";
                }
              ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "red";
                    value = null;
                  }
                  {
                    color = "green";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "min(up{job=\"authelia\",host=~\"$host\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Authelia";
              range = false;
              refId = "A";
            }
          ];
          title = "Authelia Status";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 4;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(increase(authelia_authn{host=~\"$host\",success=\"true\"}[$__range]))";
              format = "time_series";
              instant = true;
              legendFormat = "Successes";
              range = false;
              refId = "A";
            }
          ];
          title = "Auth Successes";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "orange";
                    value = 1;
                  }
                  {
                    color = "red";
                    value = 5;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 9;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(increase(authelia_authn{host=~\"$host\",success=\"false\"}[$__range]))";
              format = "time_series";
              instant = true;
              legendFormat = "Failures";
              range = false;
              refId = "A";
            }
          ];
          title = "Auth Failures";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 14;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(increase(authelia_authz{host=~\"$host\",code=\"401\"}[$__range]))";
              format = "time_series";
              instant = true;
              legendFormat = "Denied";
              range = false;
              refId = "A";
            }
          ];
          title = "Forward-Auth Denied (401)";
          type = "stat";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "orange";
                    value = 1;
                  }
                  {
                    color = "red";
                    value = 5;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 19;
            y = 0;
          };
          id = 5;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) unit:=\"sshd.service\" _msg:~\"(?i)(invalid user|failed password|connection closed by authenticating user)\" | stats count() as total";
              legendFormat = "SSH Failures";
              queryType = "stats";
              refId = "A";
            }
          ];
          title = "SSH Auth Failures";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 4;
          };
          id = 6;
          panels = [ ];
          title = "Authelia SSO & Forward Auth";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "reqps";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?2[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "green";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?3[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "blue";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?4[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?5[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 5;
          };
          id = 7;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (code) (rate(authelia_authz{host=~\"$host\"}[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "HTTP {{code}}";
              range = true;
              refId = "A";
            }
          ];
          title = "Forward-Auth Decisions by Code";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "ops";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Success";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "green";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Failed";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Banned";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 5;
          };
          id = 8;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(rate(authelia_authn{host=~\"$host\",success=\"true\"}[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "Success";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(rate(authelia_authn{host=~\"$host\",success=\"false\",banned=\"false\"}[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "Failed";
              range = true;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(rate(authelia_authn{host=~\"$host\",banned=\"true\"}[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "Banned";
              range = true;
              refId = "C";
            }
          ];
          title = "Authentication Outcomes";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 0;
            y = 13;
          };
          id = 9;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "histogram_quantile(0.50, sum by (le) (rate(authelia_request_duration_bucket{host=~\"$host\"}[$__rate_interval])))";
              format = "time_series";
              instant = false;
              legendFormat = "p50";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "histogram_quantile(0.95, sum by (le) (rate(authelia_request_duration_bucket{host=~\"$host\"}[$__rate_interval])))";
              format = "time_series";
              instant = false;
              legendFormat = "p95";
              range = true;
              refId = "B";
            }
          ];
          title = "Authelia Request Latency (p50 / p95)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "bars";
                fillOpacity = 80;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "authelia-main.service";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "sshd.service";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 12;
            y = 13;
          };
          id = 10;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) unit:in(\"authelia-main.service\",\"sshd.service\") ((unit:=\"authelia-main.service\" _msg:~\"(?i)(unsuccessful authentication|banned)\") OR (unit:=\"sshd.service\" _msg:~\"(?i)(invalid user|failed password|connection closed by authenticating user)\")) | stats by (unit) count() as events";
              legendFormat = "{{unit}}";
              queryType = "statsRange";
              refId = "A";
            }
          ];
          title = "Security Failure Events (Logs)";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 20;
          };
          id = 11;
          panels = [ ];
          title = "Security Audit Logs";
          type = "row";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          gridPos = {
            h = 12;
            w = 24;
            x = 0;
            y = 21;
          };
          id = 12;
          options = {
            dedupStrategy = "none";
            enableLogDetails = true;
            prettifyLogMessage = true;
            showCommonLabels = false;
            showLabels = true;
            showTime = true;
            sortOrder = "Descending";
            wrapLogMessage = true;
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) unit:~\"authelia-main\\\\.service|lldap\\\\.service|sshd\\\\.service\"";
              legendFormat = "";
              maxLines = 500;
              queryType = "instant";
              refId = "A";
            }
          ];
          title = "Authelia, LLDAP & SSH Journal Stream";
          type = "logs";
        }
      ];
      refresh = "30s";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "authelia"
        "ssh"
        "security"
      ];
      templating = {
        list = [
          {
            allValue = ".*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_uname_info, host)";
            hide = 0;
            includeAll = true;
            label = "Host";
            multi = true;
            name = "host";
            query = {
              qryType = 1;
              query = "label_values(node_uname_info, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
        ];
      };
      time = {
        from = "now-3h";
        to = "now";
      };
      timezone = "browser";
      title = "Authentication & Security";
      uid = "nixconf-auth-security";
    };
    title = "Authentication & Security";
  };
  backups = {
    enable = true;
    folder = "02 · Infrastructure";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "Restic backup jobs (including telemetry archives on hbox and gdrive), Btrfs host snapshot timers, rclone FUSE mounts, and storage journal logs.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 1;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_systemd_unit_state{host=~\"$host\",name=~\"(restic-.*|host-snapshot-.*|rclone-config|storage-drift-check)\\\\.service|mnt-storage-.*\\\\.mount\",state=\"failed\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Failed";
              range = false;
              refId = "A";
            }
          ];
          title = "Failed Backup / Mount Units";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 5;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_systemd_unit_state{host=~\"$host\",name=~\"(restic-backups-.*|host-snapshot-.*)\\\\.timer\",state=\"active\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Timers";
              range = false;
              refId = "A";
            }
          ];
          title = "Active Timers";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 10;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(node_filesystem_size_bytes{host=~\"$host\",fstype=\"fuse.rclone\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Mounts";
              range = false;
              refId = "A";
            }
          ];
          title = "Active Rclone Mounts";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 9;
            x = 15;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (((node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"} - node_filesystem_avail_bytes{host=~\"$host\",mountpoint=\"/persist\"}) / clamp_min(node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"}, 1)) * 100)";
              format = "time_series";
              instant = true;
              legendFormat = "{{host}} %";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"} - node_filesystem_avail_bytes{host=~\"$host\",mountpoint=\"/persist\"})";
              format = "time_series";
              instant = true;
              legendFormat = "{{host}} Used";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"})";
              format = "time_series";
              instant = true;
              legendFormat = "{{host}} Total";
              range = false;
              refId = "C";
            }
          ];
          title = "/persist Disk Usage";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 4;
          };
          id = 5;
          panels = [ ];
          title = "Backup & Snapshot Units";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "View Unit Logs";
                  url = "/d/nixconf-logs-explorer?var-host=\${__data.fields.Host}&var-unit=\${__data.fields.Unit}&\${__url_time_range}";
                }
              ];
              noValue = "No failed units";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "State";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          activating = {
                            color = "yellow";
                            index = 1;
                            text = "activating";
                          };
                          active = {
                            color = "green";
                            index = 0;
                            text = "active";
                          };
                          failed = {
                            color = "red";
                            index = 3;
                            text = "failed";
                          };
                          inactive = {
                            color = "text";
                            index = 2;
                            text = "inactive";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 0;
            y = 5;
          };
          id = 6;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_systemd_unit_state{host=~\"$host\",name=~\"(restic-.*|host-snapshot-.*|rclone-config|storage-drift-check)\\\\.service|mnt-storage-.*\\\\.mount\",state=\"failed\"} == 1";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
          ];
          title = "Failed Backup, Snapshot & Mount Units";
          transformations = [
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                  Value = true;
                  __name__ = true;
                  instance = true;
                  job = true;
                  watched = true;
                };
                indexByName = {
                  host = 0;
                  name = 1;
                  state = 2;
                  type = 3;
                };
                renameByName = {
                  host = "Host";
                  name = "Unit";
                  state = "State";
                  type = "Type";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "View Unit Logs";
                  url = "/d/nixconf-logs-explorer?var-host=\${__data.fields.Host}&var-unit=\${__data.fields.Unit}&\${__url_time_range}";
                }
              ];
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "State";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          activating = {
                            color = "yellow";
                            index = 1;
                            text = "activating";
                          };
                          active = {
                            color = "green";
                            index = 0;
                            text = "active";
                          };
                          failed = {
                            color = "red";
                            index = 3;
                            text = "failed";
                          };
                          inactive = {
                            color = "text";
                            index = 2;
                            text = "inactive";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 12;
            y = 5;
          };
          id = 7;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_systemd_unit_state{host=~\"$host\",name=~\"(restic-backups-.*|host-snapshot-.*)\\\\.timer\",state=\"active\"} == 1";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
          ];
          title = "Active Backup & Snapshot Timers";
          transformations = [
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                  Value = true;
                  __name__ = true;
                  instance = true;
                  job = true;
                  watched = true;
                };
                indexByName = {
                  host = 0;
                  name = 1;
                  state = 2;
                  type = 3;
                };
                renameByName = {
                  host = "Host";
                  name = "Unit";
                  state = "State";
                  type = "Type";
                };
              };
            }
          ];
          type = "table";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 12;
          };
          id = 8;
          panels = [ ];
          title = "Rclone Remote Storage";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Used";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Available";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Total";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Usage %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 24;
            x = 0;
            y = 13;
          };
          id = 9;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "Usage %";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, device) (node_filesystem_size_bytes{host=~\"$host\",fstype=\"fuse.rclone\"} - node_filesystem_avail_bytes{host=~\"$host\",fstype=\"fuse.rclone\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, device) (node_filesystem_avail_bytes{host=~\"$host\",fstype=\"fuse.rclone\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, device) (node_filesystem_size_bytes{host=~\"$host\",fstype=\"fuse.rclone\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, device) (((node_filesystem_size_bytes{host=~\"$host\",fstype=\"fuse.rclone\"} - node_filesystem_avail_bytes{host=~\"$host\",fstype=\"fuse.rclone\"}) / clamp_min(node_filesystem_size_bytes{host=~\"$host\",fstype=\"fuse.rclone\"}, 1)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
          ];
          title = "Mounted Rclone Filesystems (Usage & Capacity)";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 3;
                  "Value #B" = 4;
                  "Value #C" = 5;
                  "Value #D" = 6;
                  device = 2;
                  host = 0;
                  mountpoint = 1;
                };
                renameByName = {
                  "Value #A" = "Used";
                  "Value #B" = "Available";
                  "Value #C" = "Total";
                  "Value #D" = "Usage %";
                  device = "Remote";
                  host = "Host";
                  mountpoint = "Mountpoint";
                };
              };
            }
          ];
          type = "table";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 20;
          };
          id = 10;
          panels = [ ];
          title = "Backup & Storage Logs";
          type = "row";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          gridPos = {
            h = 12;
            w = 24;
            x = 0;
            y = 21;
          };
          id = 11;
          options = {
            dedupStrategy = "none";
            enableLogDetails = true;
            prettifyLogMessage = true;
            showCommonLabels = false;
            showLabels = true;
            showTime = true;
            sortOrder = "Descending";
            wrapLogMessage = true;
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) unit:~\"(restic-.*|host-snapshot-.*|rclone-config|storage-drift-check)\\\\.service\"";
              legendFormat = "";
              maxLines = 500;
              queryType = "instant";
              refId = "A";
            }
          ];
          title = "Restic, Snapshot & Rclone Journal Stream";
          type = "logs";
        }
      ];
      refresh = "1m";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "restic"
        "snapshot"
        "rclone"
        "storage"
      ];
      templating = {
        list = [
          {
            allValue = ".*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_uname_info, host)";
            hide = 0;
            includeAll = true;
            label = "Host";
            multi = true;
            name = "host";
            query = {
              qryType = 1;
              query = "label_values(node_uname_info, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
        ];
      };
      time = {
        from = "now-24h";
        to = "now";
      };
      timezone = "browser";
      title = "Storage & Backups";
      uid = "nixconf-backups-storage";
    };
    title = "Storage & Backups";
  };
  containers = {
    enable = true;
    folder = "03 · Services";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "OCI container (Podman / Docker) memory, CPU, and runtime logs across hosts.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 1;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "(count(container_memory_working_set_bytes{host=~\"$host\",id=~\".*libpod-.*container\"}) or vector(0)) + (count(container_memory_working_set_bytes{host=~\"$host\",name!=\"\"}) or vector(0))";
              format = "time_series";
              instant = true;
              legendFormat = "Containers";
              range = false;
              refId = "A";
            }
          ];
          title = "Active OCI Containers";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 1;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 6;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "(sum(container_memory_working_set_bytes{host=~\"$host\",id=~\".*libpod-.*container\"}) or vector(0)) + (sum(container_memory_working_set_bytes{host=~\"$host\",name!=\"\"}) or vector(0))";
              format = "time_series";
              instant = true;
              legendFormat = "Memory";
              range = false;
              refId = "A";
            }
          ];
          title = "Container Memory Total";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 2;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 12;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "(sum(rate(container_cpu_usage_seconds_total{host=~\"$host\",id=~\".*libpod-.*container\"}[$__rate_interval])) or vector(0)) + (sum(rate(container_cpu_usage_seconds_total{host=~\"$host\",name!=\"\"}[$__rate_interval])) or vector(0))";
              format = "time_series";
              instant = true;
              legendFormat = "Cores";
              range = false;
              refId = "A";
            }
          ];
          title = "Container CPU Total (cores)";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 1;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 18;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemAvailable_bytes{host=~\"$host\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Available";
              range = false;
              refId = "A";
            }
          ];
          title = "Host Memory Available";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 4;
          };
          id = 5;
          panels = [ ];
          title = "OCI Containers (Podman / Docker)";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              noValue = "No active OCI containers";
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 5;
          };
          id = 6;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "label_replace(container_memory_working_set_bytes{host=~\"$host\",id=~\".*libpod-.*container\"}, \"container\", \"$1\", \"id\", \".*libpod-([0-9a-f]{12}).*\")";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} podman:{{container}}";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "container_memory_working_set_bytes{host=~\"$host\",name!=\"\"}";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} {{name}}";
              range = true;
              refId = "B";
            }
          ];
          title = "Container Memory Working Set";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              noValue = "No active OCI containers";
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 5;
          };
          id = 7;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "label_replace(rate(container_cpu_usage_seconds_total{host=~\"$host\",id=~\".*libpod-.*container\"}[$__rate_interval]), \"container\", \"$1\", \"id\", \".*libpod-([0-9a-f]{12}).*\")";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} podman:{{container}}";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(container_cpu_usage_seconds_total{host=~\"$host\",name!=\"\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} {{name}}";
              range = true;
              refId = "B";
            }
          ];
          title = "Container CPU Usage (cores)";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 13;
          };
          id = 8;
          panels = [ ];
          title = "Container Runtime Logs";
          type = "row";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          gridPos = {
            h = 10;
            w = 24;
            x = 0;
            y = 14;
          };
          id = 9;
          options = {
            dedupStrategy = "none";
            enableLogDetails = true;
            prettifyLogMessage = true;
            showCommonLabels = false;
            showLabels = true;
            showTime = true;
            sortOrder = "Descending";
            wrapLogMessage = true;
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) unit:~\"(podman-.*|docker|docker-.*)\\\\.service\"";
              legendFormat = "";
              maxLines = 500;
              queryType = "instant";
              refId = "A";
            }
          ];
          title = "Podman & Docker Service Logs";
          type = "logs";
        }
      ];
      refresh = "30s";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "cadvisor"
        "containers"
        "podman"
        "docker"
      ];
      templating = {
        list = [
          {
            allValue = ".*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_uname_info, host)";
            hide = 0;
            includeAll = true;
            label = "Host";
            multi = true;
            name = "host";
            query = {
              qryType = 1;
              query = "label_values(node_uname_info, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
        ];
      };
      time = {
        from = "now-3h";
        to = "now";
      };
      timezone = "browser";
      title = "Containers & OCI";
      uid = "nixconf-containers";
    };
    title = "Containers & OCI";
  };
  fleet-overview = {
    enable = true;
    folder = "00 · Overview";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "Fleet-wide operational pulse: online hosts, alerts, endpoint probes, backups, compute capacity, and storage budgets.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 1;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "red";
                          value = null;
                        }
                        {
                          color = "green";
                          value = 100;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "(count((time() - max by (host) (timestamp(node_uname_info{host=~\"$host\"}))) < bool 120) / clamp_min(count(max by (host) (last_over_time(node_uname_info{host=~\"$host\"}[7d]))), 1)) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "Online %";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(((time() - max by (host) (timestamp(node_uname_info{host=~\"$host\"}))) < bool 120) == 1) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Online";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(max by (host) (last_over_time(node_uname_info{host=~\"$host\"}[7d]))) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Known";
              range = false;
              refId = "C";
            }
          ];
          title = "Hosts Online";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 3;
            x = 4;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(ALERTS{alertstate=\"firing\",host=~\"$host\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Firing";
              range = false;
              refId = "A";
            }
          ];
          title = "Firing Alerts";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "red";
                          value = null;
                        }
                        {
                          color = "green";
                          value = 100;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 7;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "(avg(probe_success) or vector(1)) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "Up %";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(probe_success == 1) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Up";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(probe_success) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "Endpoint Probes";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 3;
            x = 12;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Failed";
              range = false;
              refId = "A";
            }
          ];
          title = "Failed Units";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 15;
            y = 0;
          };
          id = 5;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "((sum(node_memory_MemTotal_bytes{host=~\"$host\"}) - sum(node_memory_MemAvailable_bytes{host=~\"$host\"})) / clamp_min(sum(node_memory_MemTotal_bytes{host=~\"$host\"}), 1)) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "%";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemTotal_bytes{host=~\"$host\"} - node_memory_MemAvailable_bytes{host=~\"$host\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Used";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemTotal_bytes{host=~\"$host\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "Fleet RAM";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 19;
            y = 0;
          };
          id = 6;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "((sum(last_over_time(node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m])) - sum(last_over_time(node_filesystem_avail_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m]))) / clamp_min(sum(last_over_time(node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m])), 1)) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "%";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(last_over_time(node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m]) - last_over_time(node_filesystem_avail_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m]))";
              format = "time_series";
              instant = true;
              legendFormat = "Used";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(last_over_time(node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m]))";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "Fleet /persist";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 4;
          };
          id = 7;
          panels = [ ];
          title = "Host Matrix (Click Any Row to Drill Down)";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "Open Task Manager";
                  url = "/d/nixconf-task-manager?var-host=\${__data.fields.Host}&\${__url_time_range}";
                }
                {
                  title = "Open Incident Time Machine";
                  url = "/d/nixconf-time-machine?var-host=\${__data.fields.Host}&\${__url_time_range}";
                }
                {
                  title = "Open Host & Hardware";
                  url = "/d/nixconf-host-hardware?var-host=\${__data.fields.Host}&\${__url_time_range}";
                }
              ];
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Status";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          "0" = {
                            color = "red";
                            index = 0;
                            text = "DOWN";
                          };
                          "1" = {
                            color = "green";
                            index = 1;
                            text = "UP";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Uptime";
                };
                properties = [
                  {
                    id = "unit";
                    value = "s";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Uptime";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 0;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "CPU (cores)";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 2;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "CPU %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "RAM Used";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "RAM Total";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "RAM %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "/persist Used";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "/persist Total";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "/persist %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Failed";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 0;
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 6;
            w = 24;
            x = 0;
            y = 5;
          };
          id = 8;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) ((time() - timestamp(node_uname_info{host=~\"$host\"})) < bool 120)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (last_over_time(node_time_seconds{host=~\"$host\"}[5m]) - last_over_time(node_boot_time_seconds{host=~\"$host\"}[5m]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (host) (1 - rate(node_cpu_seconds_total{host=~\"$host\",mode=\"idle\"}[$__rate_interval]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "100 - (avg by (host) (rate(node_cpu_seconds_total{host=~\"$host\",mode=\"idle\"}[$__rate_interval])) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (node_memory_MemTotal_bytes{host=~\"$host\"} - node_memory_MemAvailable_bytes{host=~\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "E";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (node_memory_MemTotal_bytes{host=~\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "F";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (((node_memory_MemTotal_bytes{host=~\"$host\"} - node_memory_MemAvailable_bytes{host=~\"$host\"}) / clamp_min(node_memory_MemTotal_bytes{host=~\"$host\"}, 1)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "G";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (last_over_time(node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m]) - last_over_time(node_filesystem_avail_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "H";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (last_over_time(node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "I";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (((last_over_time(node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m]) - last_over_time(node_filesystem_avail_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m])) / clamp_min(last_over_time(node_filesystem_size_bytes{host=~\"$host\",mountpoint=\"/persist\"}[5m]), 1)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "J";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (host) (node_systemd_unit_state{host=~\"$host\",state=\"failed\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "K";
            }
          ];
          title = "Hosts Capacity & Health";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 1;
                  "Value #B" = 2;
                  "Value #C" = 3;
                  "Value #D" = 4;
                  "Value #E" = 5;
                  "Value #F" = 6;
                  "Value #G" = 7;
                  "Value #H" = 8;
                  "Value #I" = 9;
                  "Value #J" = 10;
                  "Value #K" = 11;
                  host = 0;
                };
                renameByName = {
                  "Value #A" = "Status";
                  "Value #B" = "Uptime";
                  "Value #C" = "CPU (cores)";
                  "Value #D" = "CPU %";
                  "Value #E" = "RAM Used";
                  "Value #F" = "RAM Total";
                  "Value #G" = "RAM %";
                  "Value #H" = "/persist Used";
                  "Value #I" = "/persist Total";
                  "Value #J" = "/persist %";
                  "Value #K" = "Failed";
                  host = "Host";
                };
              };
            }
          ];
          type = "table";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 11;
          };
          id = 9;
          panels = [ ];
          title = "Alerts & Public Endpoints";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "Open Incident Time Machine";
                  url = "/d/nixconf-time-machine?var-host=\${__data.fields.Host}&\${__url_time_range}";
                }
              ];
              noValue = "All clear — no active alerts";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "State";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          firing = {
                            color = "red";
                            index = 0;
                            text = "firing";
                          };
                          pending = {
                            color = "orange";
                            index = 1;
                            text = "pending";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 0;
            y = 12;
          };
          id = 10;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "ALERTS{alertstate=~\"firing|pending\",host=~\"$host\"}";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
          ];
          title = "Active Alerts (Firing / Pending)";
          transformations = [
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                  Value = true;
                  __name__ = true;
                };
                indexByName = {
                  alertname = 0;
                  alertstate = 1;
                  host = 3;
                  severity = 2;
                };
                renameByName = {
                  alertname = "Alert";
                  alertstate = "State";
                  host = "Host";
                  severity = "Severity";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              links = [
                {
                  title = "Inspect \${__field.labels.service}";
                  url = "/d/nixconf-service-inspector?var-service=\${__field.labels.service}&\${__url_time_range}";
                }
              ];
              mappings = [
                {
                  options = {
                    "0" = {
                      color = "red";
                      index = 0;
                      text = "DOWN";
                    };
                    "1" = {
                      color = "green";
                      index = 1;
                      text = "UP";
                    };
                  };
                  type = "value";
                }
              ];
              noValue = "No blackbox probes configured";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "red";
                    value = null;
                  }
                  {
                    color = "green";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 12;
            y = 12;
          };
          id = 11;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (vhost, service) (probe_success)";
              format = "time_series";
              instant = true;
              legendFormat = "{{vhost}}";
              range = false;
              refId = "A";
            }
          ];
          title = "Endpoint Probes";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 19;
          };
          id = 12;
          panels = [ ];
          title = "Remote Storage Budgets & Failed Backup Units";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              noValue = "No remote storage budgets configured";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Used";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Available";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Limit";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Objects";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 0;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Usage %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 6;
            w = 14;
            x = 0;
            y = 20;
          };
          id = 13;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "Usage %";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice) (nixconf_storage_budget_used_bytes{host=~\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice) (clamp_min(nixconf_storage_budget_limit_bytes{host=~\"$host\"} - nixconf_storage_budget_used_bytes{host=~\"$host\"}, 0))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice) (nixconf_storage_budget_limit_bytes{host=~\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice) (nixconf_storage_budget_objects{host=~\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice) ((nixconf_storage_budget_used_bytes{host=~\"$host\"} / clamp_min(nixconf_storage_budget_limit_bytes{host=~\"$host\"}, 1)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "E";
            }
          ];
          title = "Remote Storage Budgets";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 2;
                  "Value #B" = 3;
                  "Value #C" = 4;
                  "Value #D" = 5;
                  "Value #E" = 6;
                  host = 0;
                  slice = 1;
                };
                renameByName = {
                  "Value #A" = "Used";
                  "Value #B" = "Available";
                  "Value #C" = "Limit";
                  "Value #D" = "Objects";
                  "Value #E" = "Usage %";
                  host = "Host";
                  slice = "Slice";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "View Unit Logs";
                  url = "/d/nixconf-logs-explorer?var-host=\${__data.fields.Host}&var-unit=\${__data.fields.Unit}&\${__url_time_range}";
                }
              ];
              noValue = "No failed units across fleet";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "State";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          activating = {
                            color = "yellow";
                            index = 1;
                            text = "activating";
                          };
                          active = {
                            color = "green";
                            index = 0;
                            text = "active";
                          };
                          failed = {
                            color = "red";
                            index = 3;
                            text = "failed";
                          };
                          inactive = {
                            color = "text";
                            index = 2;
                            text = "inactive";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 6;
            w = 10;
            x = 14;
            y = 20;
          };
          id = 14;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
          ];
          title = "Failed Systemd Units (Fleet)";
          transformations = [
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                  Value = true;
                  __name__ = true;
                  instance = true;
                  job = true;
                  watched = true;
                };
                indexByName = {
                  host = 0;
                  name = 1;
                  state = 2;
                  type = 3;
                };
                renameByName = {
                  host = "Host";
                  name = "Unit";
                  state = "State";
                  type = "Type";
                };
              };
            }
          ];
          type = "table";
        }
      ];
      refresh = "30s";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "fleet"
        "overview"
        "command"
      ];
      templating = {
        list = [
          {
            allValue = ".*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_uname_info, host)";
            hide = 0;
            includeAll = true;
            label = "Host";
            multi = true;
            name = "host";
            query = {
              qryType = 1;
              query = "label_values(node_uname_info, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
        ];
      };
      time = {
        from = "now-3h";
        to = "now";
      };
      timezone = "browser";
      title = "Fleet Command Center";
      uid = "nixconf-fleet-overview";
    };
    title = "Fleet Command Center";
  };
  host-hardware = {
    enable = true;
    folder = "02 · Infrastructure";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "Single-host CPU, thermals, frequencies, memory breakdown, swap capacity, disk I/O, filesystems, network health, and systemd units.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 2;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max(last_over_time(node_time_seconds{host=\"$host\"}[5m]) - last_over_time(node_boot_time_seconds{host=\"$host\"}[5m]))";
              format = "time_series";
              instant = true;
              legendFormat = "Uptime";
              range = false;
              refId = "A";
            }
          ];
          title = "Uptime";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 4;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_systemd_unit_state{host=\"$host\",state=\"failed\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Failed";
              range = false;
              refId = "A";
            }
          ];
          title = "Failed Units";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 2;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 8;
            x = 8;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "100 - (avg(rate(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"}[$__rate_interval])) * 100)";
              format = "time_series";
              instant = true;
              legendFormat = "%";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(1 - rate(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"}[$__rate_interval]))";
              format = "time_series";
              instant = true;
              legendFormat = "Active";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Cores";
              range = false;
              refId = "C";
            }
          ];
          title = "CPU Usage";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 8;
            x = 16;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "((node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemAvailable_bytes{host=\"$host\"}) / clamp_min(node_memory_MemTotal_bytes{host=\"$host\"}, 1)) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "%";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemAvailable_bytes{host=\"$host\"}";
              format = "time_series";
              instant = true;
              legendFormat = "Used";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_memory_MemTotal_bytes{host=\"$host\"}";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "Memory Usage";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 12;
            x = 0;
            y = 4;
          };
          id = 5;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "((last_over_time(node_filesystem_size_bytes{host=\"$host\",mountpoint=\"/persist\"}[5m]) - last_over_time(node_filesystem_avail_bytes{host=\"$host\",mountpoint=\"/persist\"}[5m])) / clamp_min(last_over_time(node_filesystem_size_bytes{host=\"$host\",mountpoint=\"/persist\"}[5m]), 1)) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "%";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "last_over_time(node_filesystem_size_bytes{host=\"$host\",mountpoint=\"/persist\"}[5m]) - last_over_time(node_filesystem_avail_bytes{host=\"$host\",mountpoint=\"/persist\"}[5m])";
              format = "time_series";
              instant = true;
              legendFormat = "Used";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "last_over_time(node_filesystem_size_bytes{host=\"$host\",mountpoint=\"/persist\"}[5m])";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "/persist Disk";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 12;
            x = 12;
            y = 4;
          };
          id = 6;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "((node_filesystem_size_bytes{host=\"$host\",mountpoint=\"/\",fstype=\"tmpfs\"} - node_filesystem_avail_bytes{host=\"$host\",mountpoint=\"/\",fstype=\"tmpfs\"}) / clamp_min(node_filesystem_size_bytes{host=\"$host\",mountpoint=\"/\",fstype=\"tmpfs\"}, 1)) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "%";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_filesystem_size_bytes{host=\"$host\",mountpoint=\"/\",fstype=\"tmpfs\"} - node_filesystem_avail_bytes{host=\"$host\",mountpoint=\"/\",fstype=\"tmpfs\"}";
              format = "time_series";
              instant = true;
              legendFormat = "Used";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_filesystem_size_bytes{host=\"$host\",mountpoint=\"/\",fstype=\"tmpfs\"}";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "/ Root tmpfs";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 8;
          };
          id = 7;
          panels = [ ];
          title = "CPU, Load & Hardware Thermals";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              max = 100;
              min = 0;
              unit = "percent";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "user";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "green";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "system";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "blue";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "iowait";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "steal";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "softirq";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "purple";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "irq";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "yellow";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 14;
            x = 0;
            y = 9;
          };
          id = 8;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "avg by (mode) (rate(node_cpu_seconds_total{host=\"$host\",mode!=\"idle\"}[$__rate_interval])) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "{{mode}}";
              range = true;
              refId = "A";
            }
          ];
          title = "CPU Utilization by Mode";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              min = 0;
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/cores/";
                };
                properties = [
                  {
                    id = "custom.lineStyle";
                    value = {
                      dash = [
                        6
                        4
                      ];
                      fill = "dash";
                    };
                  }
                  {
                    id = "custom.fillOpacity";
                    value = 0;
                  }
                  {
                    id = "custom.stacking";
                    value = {
                      group = "A";
                      mode = "none";
                    };
                  }
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 10;
            x = 14;
            y = 9;
          };
          id = 9;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_load1{host=\"$host\"}";
              format = "time_series";
              instant = false;
              legendFormat = "1m";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_load5{host=\"$host\"}";
              format = "time_series";
              instant = false;
              legendFormat = "5m";
              range = true;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_load15{host=\"$host\"}";
              format = "time_series";
              instant = false;
              legendFormat = "15m";
              range = true;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"})";
              format = "time_series";
              instant = false;
              legendFormat = "cores";
              range = true;
              refId = "D";
            }
          ];
          title = "Load Average & CPU Cores";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "line";
                };
              };
              noValue = "No hwmon temperature sensors";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "yellow";
                    value = 75;
                  }
                  {
                    color = "red";
                    value = 90;
                  }
                ];
              };
              unit = "celsius";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 6;
            w = 12;
            x = 0;
            y = 17;
          };
          id = 10;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (chip, sensor) (node_hwmon_temp_celsius{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "{{chip}} {{sensor}}";
              range = true;
              refId = "A";
            }
          ];
          title = "Hardware Temperatures";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              noValue = "No cpufreq telemetry";
              unit = "hertz";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 6;
            w = 12;
            x = 12;
            y = 17;
          };
          id = 11;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_cpu_scaling_frequency_hertz{host=\"$host\"}";
              format = "time_series";
              instant = false;
              legendFormat = "CPU {{cpu}}";
              range = true;
              refId = "A";
            }
          ];
          title = "CPU Core Frequencies";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 23;
          };
          id = 12;
          panels = [ ];
          title = "Memory & Swap";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              min = 0;
              unit = "bytes";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/Total/";
                };
                properties = [
                  {
                    id = "custom.lineStyle";
                    value = {
                      dash = [
                        6
                        4
                      ];
                      fill = "dash";
                    };
                  }
                  {
                    id = "custom.fillOpacity";
                    value = 0;
                  }
                  {
                    id = "custom.stacking";
                    value = {
                      group = "A";
                      mode = "none";
                    };
                  }
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 14;
            x = 0;
            y = 24;
          };
          id = 13;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemFree_bytes{host=\"$host\"} - node_memory_Buffers_bytes{host=\"$host\"} - node_memory_Cached_bytes{host=\"$host\"} - node_memory_SReclaimable_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Used";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_Cached_bytes{host=\"$host\"} + node_memory_SReclaimable_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Cached";
              range = true;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_Buffers_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Buffers";
              range = true;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemFree_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Free";
              range = true;
              refId = "D";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemTotal_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Total";
              range = true;
              refId = "E";
            }
          ];
          title = "Memory Breakdown";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "line";
                };
              };
              max = 100;
              min = 0;
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "yellow";
                    value = 75;
                  }
                  {
                    color = "red";
                    value = 90;
                  }
                ];
              };
              unit = "percent";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 10;
            x = 14;
            y = 24;
          };
          id = 14;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "((node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemAvailable_bytes{host=\"$host\"}) / clamp_min(node_memory_MemTotal_bytes{host=\"$host\"}, 1)) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "RAM %";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "((node_memory_SwapTotal_bytes{host=\"$host\"} - node_memory_SwapFree_bytes{host=\"$host\"}) / clamp_min(node_memory_SwapTotal_bytes{host=\"$host\"}, 1)) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "Swap %";
              range = true;
              refId = "B";
            }
          ];
          title = "Memory & Swap Pressure (%)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "RAM Used";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "RAM Total";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "RAM %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Swap Used";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Swap Total";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Swap %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 5;
            w = 24;
            x = 0;
            y = 32;
          };
          id = 15;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemAvailable_bytes{host=\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (node_memory_MemTotal_bytes{host=\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (((node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemAvailable_bytes{host=\"$host\"}) / clamp_min(node_memory_MemTotal_bytes{host=\"$host\"}, 1)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (node_memory_SwapTotal_bytes{host=\"$host\"} - node_memory_SwapFree_bytes{host=\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (node_memory_SwapTotal_bytes{host=\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "E";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host) (((node_memory_SwapTotal_bytes{host=\"$host\"} - node_memory_SwapFree_bytes{host=\"$host\"}) / clamp_min(node_memory_SwapTotal_bytes{host=\"$host\"}, 1)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "F";
            }
          ];
          title = "Memory & Swap Capacity";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 1;
                  "Value #B" = 2;
                  "Value #C" = 3;
                  "Value #D" = 4;
                  "Value #E" = 5;
                  "Value #F" = 6;
                  host = 0;
                };
                renameByName = {
                  "Value #A" = "RAM Used";
                  "Value #B" = "RAM Total";
                  "Value #C" = "RAM %";
                  "Value #D" = "Swap Used";
                  "Value #E" = "Swap Total";
                  "Value #F" = "Swap %";
                  host = "Host";
                };
              };
            }
          ];
          type = "table";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 37;
          };
          id = 16;
          panels = [ ];
          title = "Storage & Network";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Used";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Available";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Total";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Usage %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 24;
            x = 0;
            y = 38;
          };
          id = 17;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "Usage %";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, fstype) (node_filesystem_size_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var|tmp|run|sys|proc|dev).*\"} - node_filesystem_avail_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var|tmp|run|sys|proc|dev).*\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, fstype) (node_filesystem_avail_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var|tmp|run|sys|proc|dev).*\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, fstype) (node_filesystem_size_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var|tmp|run|sys|proc|dev).*\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, fstype) (((node_filesystem_size_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var|tmp|run|sys|proc|dev).*\"} - node_filesystem_avail_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var|tmp|run|sys|proc|dev).*\"}) / clamp_min(node_filesystem_size_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var|tmp|run|sys|proc|dev).*\"}, 1)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
          ];
          title = "Local Filesystems (Usage & Capacity)";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 3;
                  "Value #B" = 4;
                  "Value #C" = 5;
                  "Value #D" = 6;
                  fstype = 2;
                  host = 0;
                  mountpoint = 1;
                };
                renameByName = {
                  "Value #A" = "Used";
                  "Value #B" = "Available";
                  "Value #C" = "Total";
                  "Value #D" = "Usage %";
                  fstype = "FS";
                  host = "Host";
                  mountpoint = "Mountpoint";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "Bps";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/Write/";
                };
                properties = [
                  {
                    id = "custom.transform";
                    value = "negative-Y";
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 24;
            x = 0;
            y = 45;
          };
          id = 18;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_disk_read_bytes_total{host=\"$host\",device!~\"dm-.*|loop.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} Read";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_disk_written_bytes_total{host=\"$host\",device!~\"dm-.*|loop.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} Write";
              range = true;
              refId = "B";
            }
          ];
          title = "Disk I/O Throughput (Read / -Write)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "Bps";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/TX/";
                };
                properties = [
                  {
                    id = "custom.transform";
                    value = "negative-Y";
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 14;
            x = 0;
            y = 52;
          };
          id = 19;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_network_receive_bytes_total{host=\"$host\",device!~\"lo|veth.*|docker.*|br-.*|podman.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} RX";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_network_transmit_bytes_total{host=\"$host\",device!~\"lo|veth.*|docker.*|br-.*|podman.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} TX";
              range = true;
              refId = "B";
            }
          ];
          title = "Network Throughput (RX / -TX)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              min = 0;
              unit = "pps";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 10;
            x = 14;
            y = 52;
          };
          id = 20;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_network_receive_errs_total{host=\"$host\",device!=\"lo\"}[$__rate_interval]) + rate(node_network_transmit_errs_total{host=\"$host\",device!=\"lo\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} errs";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_network_receive_drop_total{host=\"$host\",device!=\"lo\"}[$__rate_interval]) + rate(node_network_transmit_drop_total{host=\"$host\",device!=\"lo\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} drops";
              range = true;
              refId = "B";
            }
          ];
          title = "Network Errors & Drops";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 60;
          };
          id = 21;
          panels = [ ];
          title = "Systemd Services (Click Row for Unit Logs)";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "View Unit Logs";
                  url = "/d/nixconf-logs-explorer?var-host=\${__data.fields.Host}&var-unit=\${__data.fields.Unit}&\${__url_time_range}";
                }
              ];
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "State";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          activating = {
                            color = "yellow";
                            index = 1;
                            text = "activating";
                          };
                          active = {
                            color = "green";
                            index = 0;
                            text = "active";
                          };
                          failed = {
                            color = "red";
                            index = 3;
                            text = "failed";
                          };
                          inactive = {
                            color = "text";
                            index = 2;
                            text = "inactive";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 61;
          };
          id = 22;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_systemd_unit_state{host=\"$host\",watched=\"true\"} == 1";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
          ];
          title = "Watched Units Health";
          transformations = [
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                  Value = true;
                  __name__ = true;
                  instance = true;
                  job = true;
                  watched = true;
                };
                indexByName = {
                  host = 0;
                  name = 1;
                  state = 2;
                  type = 3;
                };
                renameByName = {
                  host = "Host";
                  name = "Unit";
                  state = "State";
                  type = "Type";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "View Unit Logs";
                  url = "/d/nixconf-logs-explorer?var-host=\${__data.fields.Host}&var-unit=\${__data.fields.Unit}&\${__url_time_range}";
                }
              ];
              noValue = "No failed units";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "State";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          activating = {
                            color = "yellow";
                            index = 1;
                            text = "activating";
                          };
                          active = {
                            color = "green";
                            index = 0;
                            text = "active";
                          };
                          failed = {
                            color = "red";
                            index = 3;
                            text = "failed";
                          };
                          inactive = {
                            color = "text";
                            index = 2;
                            text = "inactive";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 61;
          };
          id = 23;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_systemd_unit_state{host=\"$host\",state=\"failed\"} == 1";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
          ];
          title = "Failed Systemd Units";
          transformations = [
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                  Value = true;
                  __name__ = true;
                  instance = true;
                  job = true;
                  watched = true;
                };
                indexByName = {
                  host = 0;
                  name = 1;
                  state = 2;
                  type = 3;
                };
                renameByName = {
                  host = "Host";
                  name = "Unit";
                  state = "State";
                  type = "Type";
                };
              };
            }
          ];
          type = "table";
        }
      ];
      refresh = "30s";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "host"
        "hardware"
        "systemd"
        "node"
      ];
      templating = {
        list = [
          {
            current = { };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_uname_info, host)";
            hide = 0;
            includeAll = false;
            label = "Host";
            multi = false;
            name = "host";
            query = {
              qryType = 1;
              query = "label_values(node_uname_info, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
        ];
      };
      time = {
        from = "now-3h";
        to = "now";
      };
      timezone = "browser";
      title = "Host & Hardware";
      uid = "nixconf-host-hardware";
    };
    title = "Host & Hardware";
  };
  ingress = {
    enable = true;
    folder = "02 · Infrastructure";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "Caddy virtual host HTTP traffic, response status codes, latency percentiles, upstream health, and blackbox probes.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 1;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "red";
                          value = null;
                        }
                        {
                          color = "green";
                          value = 100;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 7;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "avg(probe_success{vhost=~\"$probe\"}) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "Availability %";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(probe_success{vhost=~\"$probe\"} == 1) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Up";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(probe_success{vhost=~\"$probe\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "Probe Availability";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [
                {
                  options = {
                    "0" = {
                      color = "red";
                      index = 0;
                      text = "FAIL";
                    };
                    "1" = {
                      color = "green";
                      index = 1;
                      text = "OK";
                    };
                  };
                  type = "value";
                }
              ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "red";
                    value = null;
                  }
                  {
                    color = "green";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 3;
            x = 7;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "min(caddy_config_last_reload_successful)";
              format = "time_series";
              instant = true;
              legendFormat = "Reload";
              range = false;
              refId = "A";
            }
          ];
          title = "Caddy Config Reload";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "red";
                          value = null;
                        }
                        {
                          color = "green";
                          value = 100;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 7;
            x = 10;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "avg(caddy_reverse_proxy_upstreams_healthy) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "Healthy %";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(caddy_reverse_proxy_upstreams_healthy == 1) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Healthy";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(caddy_reverse_proxy_upstreams_healthy) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "Healthy Upstreams";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 3;
            x = 17;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(caddy_http_requests_in_flight{host=~\"$vhost\"})";
              format = "time_series";
              instant = true;
              legendFormat = "In-Flight";
              range = false;
              refId = "A";
            }
          ];
          title = "In-Flight Requests";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 2;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "reqps";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 20;
            y = 0;
          };
          id = 5;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(rate(caddy_http_requests_total{server=\"srv0\",host=~\"$vhost\"}[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "RPS";
              range = true;
              refId = "A";
            }
          ];
          title = "Request Rate";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 4;
          };
          id = 6;
          panels = [ ];
          title = "Endpoint Health Probes";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              links = [
                {
                  title = "Inspect \${__field.labels.service}";
                  url = "/d/nixconf-service-inspector?var-service=\${__field.labels.service}&\${__url_time_range}";
                }
              ];
              mappings = [
                {
                  options = {
                    "0" = {
                      color = "red";
                      index = 0;
                      text = "DOWN";
                    };
                    "1" = {
                      color = "green";
                      index = 1;
                      text = "UP";
                    };
                  };
                  type = "value";
                }
              ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "red";
                    value = null;
                  }
                  {
                    color = "green";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 6;
            w = 12;
            x = 0;
            y = 5;
          };
          id = 7;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (vhost, service) (probe_success{vhost=~\"$probe\"})";
              format = "time_series";
              instant = true;
              legendFormat = "{{vhost}}";
              range = false;
              refId = "A";
            }
          ];
          title = "Endpoint Status";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Status";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          "0" = {
                            color = "red";
                            index = 0;
                            text = "DOWN";
                          };
                          "1" = {
                            color = "green";
                            index = 1;
                            text = "UP";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Latency";
                };
                properties = [
                  {
                    id = "unit";
                    value = "s";
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 6;
            w = 12;
            x = 12;
            y = 5;
          };
          id = 8;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, vhost) (probe_success{vhost=~\"$probe\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, vhost) (probe_http_status_code{vhost=~\"$probe\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, vhost) (probe_duration_seconds{vhost=~\"$probe\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
          ];
          title = "Probe Summary";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 1;
                  "Value #B" = 2;
                  "Value #C" = 3;
                  host = 4;
                  vhost = 0;
                };
                renameByName = {
                  "Value #A" = "Status";
                  "Value #B" = "HTTP";
                  "Value #C" = "Latency";
                  host = "Prober";
                  vhost = "Endpoint";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "line";
                };
              };
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "yellow";
                    value = 0.25;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 11;
          };
          id = 9;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (vhost) (probe_duration_seconds{vhost=~\"$probe\"})";
              format = "time_series";
              instant = false;
              legendFormat = "{{vhost}}";
              range = true;
              refId = "A";
            }
          ];
          title = "Probe Latency";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 11;
          };
          id = 10;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "avg by (phase) (probe_http_duration_seconds{vhost=~\"$probe\"})";
              format = "time_series";
              instant = false;
              legendFormat = "{{phase}}";
              range = true;
              refId = "A";
            }
          ];
          title = "HTTP Probe Phase Breakdown";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 19;
          };
          id = 11;
          panels = [ ];
          title = "Caddy Edge Traffic & Latency";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "reqps";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 20;
          };
          id = 12;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (host) (rate(caddy_http_requests_total{server=\"srv0\",host=~\"$vhost\"}[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}}";
              range = true;
              refId = "A";
            }
          ];
          title = "Request Rate by Virtual Host";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "reqps";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?2[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "green";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?3[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "blue";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?4[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?5[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 20;
          };
          id = 13;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (code) (rate(caddy_http_request_duration_seconds_count{server=\"srv0\",host=~\"$vhost\"}[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "HTTP {{code}}";
              range = true;
              refId = "A";
            }
          ];
          title = "HTTP Responses by Status Code";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 28;
          };
          id = 14;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "histogram_quantile(0.50, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server=\"srv0\",host=~\"$vhost\"}[$__rate_interval])))";
              format = "time_series";
              instant = false;
              legendFormat = "p50";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "histogram_quantile(0.95, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server=\"srv0\",host=~\"$vhost\"}[$__rate_interval])))";
              format = "time_series";
              instant = false;
              legendFormat = "p95";
              range = true;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "histogram_quantile(0.99, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server=\"srv0\",host=~\"$vhost\"}[$__rate_interval])))";
              format = "time_series";
              instant = false;
              legendFormat = "p99";
              range = true;
              refId = "C";
            }
          ];
          title = "Request Latency Percentiles (p50 / p95 / p99)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Status";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          "0" = {
                            color = "red";
                            index = 0;
                            text = "DOWN";
                          };
                          "1" = {
                            color = "green";
                            index = 1;
                            text = "UP";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 28;
          };
          id = 15;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "caddy_reverse_proxy_upstreams_healthy";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
          ];
          title = "Reverse Proxy Upstream Health";
          transformations = [
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                  __name__ = true;
                  instance = true;
                  job = true;
                };
                indexByName = {
                  Value = 2;
                  host = 0;
                  upstream = 1;
                };
                renameByName = {
                  Value = "Status";
                  host = "Host";
                  upstream = "Upstream";
                };
              };
            }
          ];
          type = "table";
        }
      ];
      refresh = "30s";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "caddy"
        "blackbox"
        "ingress"
      ];
      templating = {
        list = [
          {
            allValue = ".*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(probe_success, vhost)";
            hide = 0;
            includeAll = true;
            label = "Probe";
            multi = true;
            name = "probe";
            query = {
              qryType = 1;
              query = "label_values(probe_success, vhost)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
          {
            allValue = ".*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(caddy_http_requests_total, host)";
            hide = 0;
            includeAll = true;
            label = "Virtual Host";
            multi = true;
            name = "vhost";
            query = {
              qryType = 1;
              query = "label_values(caddy_http_requests_total, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
        ];
      };
      time = {
        from = "now-3h";
        to = "now";
      };
      timezone = "browser";
      title = "Ingress & Edge";
      uid = "nixconf-ingress";
    };
    title = "Ingress & Edge";
  };
  logs-explorer = {
    enable = true;
    folder = "01 · Investigate";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "Interactive journald full-text and LogsQL exploration in VictoriaLogs across hosts, units, severity levels, and watched units.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 1;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) unit:in($unit) level:in($level) $watched $search | stats count() as total";
              legendFormat = "Total";
              queryType = "stats";
              refId = "A";
            }
          ];
          title = "Total Log Lines";
          type = "stat";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 6;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) unit:in($unit) level:in(\"emerg\",\"alert\",\"crit\",\"err\",\"error\") $watched $search | stats count() as total";
              legendFormat = "Errors";
              queryType = "stats";
              refId = "A";
            }
          ];
          title = "Errors & Critical";
          type = "stat";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "orange";
                    value = 1;
                  }
                  {
                    color = "red";
                    value = 5;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 12;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) unit:in($unit) level:=\"warning\" $watched $search | stats count() as total";
              legendFormat = "Warnings";
              queryType = "stats";
              refId = "A";
            }
          ];
          title = "Warnings";
          type = "stat";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 18;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) watched:=\"true\" level:in(\"emerg\",\"alert\",\"crit\",\"err\",\"error\") $search | stats count() as total";
              legendFormat = "Watched Errors";
              queryType = "stats";
              refId = "A";
            }
          ];
          title = "Watched Unit Errors";
          type = "stat";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "bars";
                fillOpacity = 80;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(emerg|emergency|alert|crit|critical|err|error)$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^warning$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^notice$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "yellow";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^info$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "blue";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^debug$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "purple";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 14;
            x = 0;
            y = 4;
          };
          id = 5;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) unit:in($unit) level:in($level) $watched $search | stats by (level) count() as lines";
              legendFormat = "{{level}}";
              queryType = "statsRange";
              refId = "A";
            }
          ];
          title = "Log Volume by Severity";
          type = "timeseries";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              min = 0;
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 7;
            w = 10;
            x = 14;
            y = 4;
          };
          id = 6;
          options = {
            displayMode = "gradient";
            minVizHeight = 10;
            minVizWidth = 0;
            namePlacement = "auto";
            orientation = "horizontal";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            showUnfilled = true;
            sizing = "auto";
            valueMode = "color";
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) unit:in($unit) level:in($level) $watched $search | stats by (host, unit) count() as lines | sort by (lines desc) limit 10";
              legendFormat = "{{host}} / {{unit}}";
              queryType = "stats";
              refId = "A";
            }
          ];
          title = "Top 10 Noisiest Units";
          type = "bargauge";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          gridPos = {
            h = 16;
            w = 24;
            x = 0;
            y = 11;
          };
          id = 7;
          options = {
            dedupStrategy = "none";
            enableLogDetails = true;
            prettifyLogMessage = true;
            showCommonLabels = false;
            showLabels = true;
            showTime = true;
            sortOrder = "Descending";
            wrapLogMessage = true;
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) unit:in($unit) level:in($level) $watched $search";
              legendFormat = "";
              maxLines = 500;
              queryType = "instant";
              refId = "A";
            }
          ];
          title = "Journald Log Stream (VictoriaLogs)";
          type = "logs";
        }
      ];
      refresh = "30s";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "victorialogs"
        "journald"
        "logs"
      ];
      templating = {
        list = [
          {
            allValue = ".*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_uname_info, host)";
            hide = 0;
            includeAll = true;
            label = "Host";
            multi = true;
            name = "host";
            query = {
              qryType = 1;
              query = "label_values(node_uname_info, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
          {
            allValue = "*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "victoriametrics-logs-datasource";
              uid = "victorialogs";
            };
            definition = "fieldValue:unit";
            hide = 0;
            includeAll = true;
            label = "Unit";
            multi = true;
            name = "unit";
            query = {
              field = "unit";
              query = "job:=\"systemd-journal\" host:in($host)";
              type = "fieldValue";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
          {
            allValue = "*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            hide = 0;
            includeAll = true;
            label = "Level";
            multi = true;
            name = "level";
            options = [
              {
                selected = true;
                text = "All";
                value = "$__all";
              }
              {
                selected = false;
                text = "emerg";
                value = "emerg";
              }
              {
                selected = false;
                text = "alert";
                value = "alert";
              }
              {
                selected = false;
                text = "crit";
                value = "crit";
              }
              {
                selected = false;
                text = "err";
                value = "err";
              }
              {
                selected = false;
                text = "error";
                value = "error";
              }
              {
                selected = false;
                text = "warning";
                value = "warning";
              }
              {
                selected = false;
                text = "notice";
                value = "notice";
              }
              {
                selected = false;
                text = "info";
                value = "info";
              }
              {
                selected = false;
                text = "debug";
                value = "debug";
              }
            ];
            query = "emerg,alert,crit,err,error,warning,notice,info,debug";
            type = "custom";
          }
          {
            current = {
              selected = true;
              text = "All Units";
              value = "*";
            };
            hide = 0;
            includeAll = false;
            label = "Scope";
            multi = false;
            name = "watched";
            options = [
              {
                selected = true;
                text = "All Units";
                value = "*";
              }
              {
                selected = false;
                text = "Watched Only";
                value = "watched:=\"true\"";
              }
            ];
            query = "All Units : *,Watched Only : watched:=\"true\"";
            type = "custom";
          }
          {
            current = {
              selected = true;
              text = "";
              value = "";
            };
            hide = 0;
            label = "Search (LogsQL / Phrase / ~Regex)";
            name = "search";
            options = [
              {
                selected = true;
                text = "";
                value = "";
              }
            ];
            query = "";
            type = "textbox";
          }
        ];
      };
      time = {
        from = "now-3h";
        to = "now";
      };
      timezone = "browser";
      title = "Logs Explorer";
      uid = "nixconf-logs-explorer";
    };
    title = "Logs Explorer";
  };
  observability-health = {
    enable = true;
    folder = "02 · Infrastructure";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "VictoriaMetrics TSDB storage & ingestion, VictoriaLogs compression & disk budget, vmalert rule evaluation, Alertmanager delivery, Alloy agents, and Grafana traffic.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 1;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "red";
                          value = null;
                        }
                        {
                          color = "green";
                          value = 100;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "avg(up) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "Healthy %";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(up == 1) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Up";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(up) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "Scrape Targets Healthy";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 6;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(ALERTS{alertstate=\"firing\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Alerts";
              range = false;
              refId = "A";
            }
          ];
          title = "Firing Alerts";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 10;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(vm_rows{type=\"storage/big\"}) or sum(vm_rows)";
              format = "time_series";
              instant = false;
              legendFormat = "Rows";
              range = true;
              refId = "A";
            }
          ];
          title = "VictoriaMetrics Stored Rows";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 1;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 14;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(vm_data_size_bytes)";
              format = "time_series";
              instant = false;
              legendFormat = "Disk Used";
              range = true;
              refId = "A";
            }
          ];
          title = "VictoriaMetrics Data Size";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 1;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 19;
            y = 0;
          };
          id = 5;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(vl_compressed_data_size_bytes)";
              format = "time_series";
              instant = false;
              legendFormat = "Compressed";
              range = true;
              refId = "A";
            }
          ];
          title = "VictoriaLogs Compressed Size";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 4;
          };
          id = 6;
          panels = [ ];
          title = "Alerts & Scrape Targets";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "Open Incident Time Machine";
                  url = "/d/nixconf-time-machine?var-host=\${__data.fields.Host}&\${__url_time_range}";
                }
              ];
              noValue = "No active alerts";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "State";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          firing = {
                            color = "red";
                            index = 0;
                            text = "firing";
                          };
                          pending = {
                            color = "orange";
                            index = 1;
                            text = "pending";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 0;
            y = 5;
          };
          id = 7;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "ALERTS{alertstate=~\"firing|pending\"}";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
          ];
          title = "Active Alerts (Firing / Pending)";
          transformations = [
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                  Value = true;
                  __name__ = true;
                };
                indexByName = {
                  alertname = 0;
                  alertstate = 1;
                  host = 3;
                  severity = 2;
                };
                renameByName = {
                  alertname = "Alert";
                  alertstate = "State";
                  host = "Host";
                  severity = "Severity";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Status";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          "0" = {
                            color = "red";
                            index = 0;
                            text = "DOWN";
                          };
                          "1" = {
                            color = "green";
                            index = 1;
                            text = "UP";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 12;
            y = 5;
          };
          id = 8;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "up";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
          ];
          title = "Scrape Targets Status";
          transformations = [
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                  __name__ = true;
                  vhost = true;
                };
                indexByName = {
                  Value = 3;
                  host = 0;
                  instance = 2;
                  job = 1;
                };
                renameByName = {
                  Value = "Status";
                  host = "Host";
                  instance = "Instance";
                  job = "Job";
                };
              };
            }
          ];
          type = "table";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 12;
          };
          id = 9;
          panels = [ ];
          title = "VictoriaMetrics & VictoriaLogs Ingestion & Compression";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "ops";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 13;
          };
          id = 10;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (type) (rate(vm_rows_inserted_total[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "{{type}} rows/s";
              range = true;
              refId = "A";
            }
          ];
          title = "VictoriaMetrics Row Ingestion Rate";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "Bps";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 13;
          };
          id = 11;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(rate(vl_bytes_ingested_total[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "Ingested bytes/s";
              range = true;
              refId = "A";
            }
          ];
          title = "VictoriaLogs Ingestion Rate (Lines & Bytes/s)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "bytes";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/Uncompressed/";
                };
                properties = [
                  {
                    id = "custom.lineStyle";
                    value = {
                      dash = [
                        6
                        4
                      ];
                      fill = "dash";
                    };
                  }
                  {
                    id = "custom.fillOpacity";
                    value = 0;
                  }
                  {
                    id = "custom.stacking";
                    value = {
                      group = "A";
                      mode = "none";
                    };
                  }
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 21;
          };
          id = 12;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(vl_compressed_data_size_bytes)";
              format = "time_series";
              instant = false;
              legendFormat = "Compressed on disk";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(vl_uncompressed_data_size_bytes)";
              format = "time_series";
              instant = false;
              legendFormat = "Uncompressed logical";
              range = true;
              refId = "B";
            }
          ];
          title = "VictoriaLogs Compression Footprint";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 21;
          };
          id = 13;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "min(vm_free_disk_space_bytes)";
              format = "time_series";
              instant = false;
              legendFormat = "VM free";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "min(vl_free_disk_space_bytes)";
              format = "time_series";
              instant = false;
              legendFormat = "VL free";
              range = true;
              refId = "B";
            }
          ];
          title = "VictoriaMetrics & VictoriaLogs Free Disk Headroom";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 29;
          };
          id = 14;
          panels = [ ];
          title = "Stack Services & Grafana Traffic";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 30;
          };
          id = 15;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "container_memory_working_set_bytes{unit=~\"(victoriametrics|victorialogs|vmalert-metrics|vmalert-logs|alertmanager|grafana|alloy)\\\\.service\"}";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} {{unit}}";
              range = true;
              refId = "A";
            }
          ];
          title = "Observability Services Memory Working Set";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "reqps";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?2[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "green";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?3[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "blue";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?4[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?5[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 30;
          };
          id = 16;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (status_code) (rate(grafana_http_request_duration_seconds_count{status_code!=\"\"}[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "HTTP {{status_code}}";
              range = true;
              refId = "A";
            }
          ];
          title = "Grafana HTTP Request Rate by Status";
          type = "timeseries";
        }
      ];
      refresh = "30s";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "victoria"
        "victoriametrics"
        "victorialogs"
        "vmalert"
        "alertmanager"
        "grafana"
      ];
      templating = {
        list = [ ];
      };
      time = {
        from = "now-3h";
        to = "now";
      };
      timezone = "browser";
      title = "Observability Health";
      uid = "nixconf-observability-health";
    };
    title = "Observability Health";
  };
  resources = {
    enable = true;
    folder = "02 · Infrastructure";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "Cgroups v2 workload tiers, Linux PSI pressure stalls, CPU throttling, memory headroom, local volumes, and remote storage budgets.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 1;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 1;
              mappings = [ ];
              noValue = "0%";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "yellow";
                    value = 75;
                  }
                  {
                    color = "red";
                    value = 90;
                  }
                ];
              };
              unit = "percent";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "avg(rate(node_pressure_cpu_waiting_seconds_total{host=~\"$host\"}[$__rate_interval])) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "CPU PSI";
              range = true;
              refId = "A";
            }
          ];
          title = "CPU PSI (some %)";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 1;
              mappings = [ ];
              noValue = "0%";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "yellow";
                    value = 75;
                  }
                  {
                    color = "red";
                    value = 90;
                  }
                ];
              };
              unit = "percent";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 4;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "avg(rate(node_pressure_memory_stalled_seconds_total{host=~\"$host\"}[$__rate_interval])) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "Mem PSI";
              range = true;
              refId = "A";
            }
          ];
          title = "Memory PSI (full %)";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 1;
              mappings = [ ];
              noValue = "0%";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "yellow";
                    value = 75;
                  }
                  {
                    color = "red";
                    value = 90;
                  }
                ];
              };
              unit = "percent";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 8;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "avg(rate(node_pressure_io_stalled_seconds_total{host=~\"$host\"}[$__rate_interval])) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "I/O PSI";
              range = true;
              refId = "A";
            }
          ];
          title = "I/O PSI (full %)";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "orange";
                    value = 1;
                  }
                  {
                    color = "red";
                    value = 5;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 12;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(rate(container_cpu_cfs_throttled_periods_total{host=~\"$host\",unit!=\"\"}[$__rate_interval]) > 0) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Throttled";
              range = false;
              refId = "A";
            }
          ];
          title = "Throttled Units";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 16;
            y = 0;
          };
          id = 5;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(increase(container_oom_events_total{host=~\"$host\"}[$__range])) or vector(0)";
              format = "time_series";
              instant = false;
              legendFormat = "OOM Kills";
              range = true;
              refId = "A";
            }
          ];
          title = "OOM Kills (range)";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [
                {
                  options = {
                    "0" = {
                      color = "orange";
                      index = 0;
                      text = "Battery";
                    };
                    "1" = {
                      color = "green";
                      index = 1;
                      text = "AC";
                    };
                  };
                  type = "value";
                }
              ];
              noValue = "N/A (Mains Only)";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "red";
                    value = null;
                  }
                  {
                    color = "green";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 20;
            y = 0;
          };
          id = 6;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max(last_over_time(node_power_supply_online{host=~\"$host\"}[5m]))";
              format = "time_series";
              instant = true;
              legendFormat = "Power";
              range = false;
              refId = "A";
            }
          ];
          title = "AC Power Status";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 4;
          };
          id = 7;
          panels = [ ];
          title = "Tier & Slice Resource Allocation";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "bytes";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/Host Total/";
                };
                properties = [
                  {
                    id = "custom.lineStyle";
                    value = {
                      dash = [
                        6
                        4
                      ];
                      fill = "dash";
                    };
                  }
                  {
                    id = "custom.fillOpacity";
                    value = 0;
                  }
                  {
                    id = "custom.stacking";
                    value = {
                      group = "A";
                      mode = "none";
                    };
                  }
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 5;
          };
          id = 8;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (host, slice) (container_memory_working_set_bytes{host=~\"$host\",id=~\"/[^/]+\\\\.slice\",slice=~\"$slice\"})";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} {{slice}}.slice";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemTotal_bytes{host=~\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Host Total RAM";
              range = true;
              refId = "B";
            }
          ];
          title = "Memory Working Set by Slice";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/Host Total/";
                };
                properties = [
                  {
                    id = "custom.lineStyle";
                    value = {
                      dash = [
                        6
                        4
                      ];
                      fill = "dash";
                    };
                  }
                  {
                    id = "custom.fillOpacity";
                    value = 0;
                  }
                  {
                    id = "custom.stacking";
                    value = {
                      group = "A";
                      mode = "none";
                    };
                  }
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 5;
          };
          id = 9;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (host, slice) (rate(container_cpu_usage_seconds_total{host=~\"$host\",id=~\"/[^/]+\\\\.slice\",slice=~\"$slice\"}[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} {{slice}}.slice";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(node_cpu_seconds_total{host=~\"$host\",mode=\"idle\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Host Total Cores";
              range = true;
              refId = "B";
            }
          ];
          title = "CPU Usage by Slice (cores)";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 13;
          };
          id = 10;
          panels = [ ];
          title = "Contention & Pressure (Linux PSI)";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "line";
                };
              };
              min = 0;
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "yellow";
                    value = 75;
                  }
                  {
                    color = "red";
                    value = 90;
                  }
                ];
              };
              unit = "percent";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 0;
            y = 14;
          };
          id = 11;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_pressure_cpu_waiting_seconds_total{host=~\"$host\"}[$__rate_interval]) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} CPU waiting";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_pressure_memory_stalled_seconds_total{host=~\"$host\"}[$__rate_interval]) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} Memory stalled";
              range = true;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_pressure_io_stalled_seconds_total{host=~\"$host\"}[$__rate_interval]) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} I/O stalled";
              range = true;
              refId = "C";
            }
          ];
          title = "Host Pressure Stall Rates (CPU / Memory / I/O)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              min = 0;
              noValue = "No CPU quota throttling";
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 12;
            x = 12;
            y = 14;
          };
          id = 12;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "topk(12, rate(container_cpu_cfs_throttled_seconds_total{host=~\"$host\",slice=~\"$slice\",unit!=\"\"}[$__rate_interval]) > 0)";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} {{unit}} ({{slice}})";
              range = true;
              refId = "A";
            }
          ];
          title = "Cgroup CPU Throttling (cores throttled)";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 22;
          };
          id = 13;
          panels = [ ];
          title = "Service Right-Sizing & Headroom";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "View Unit Logs";
                  url = "/d/nixconf-logs-explorer?var-host=\${__data.fields.Host}&var-unit=\${__data.fields.Unit}&\${__url_time_range}";
                }
              ];
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Memory";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Mem Limit";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Headroom";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Limit %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "CPU (cores)";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 2;
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 10;
            w = 24;
            x = 0;
            y = 23;
          };
          id = 14;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "Limit %";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) (container_memory_working_set_bytes{host=~\"$host\",slice=~\"$slice\",unit!=\"\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) (container_spec_memory_limit_bytes{host=~\"$host\",slice=~\"$slice\",unit!=\"\"} > 0)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) (clamp_min((container_spec_memory_limit_bytes{host=~\"$host\",slice=~\"$slice\",unit!=\"\"} > 0) - container_memory_working_set_bytes{host=~\"$host\",slice=~\"$slice\",unit!=\"\"}, 0))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) ((container_memory_working_set_bytes{host=~\"$host\",slice=~\"$slice\",unit!=\"\"} / (container_spec_memory_limit_bytes{host=~\"$host\",slice=~\"$slice\",unit!=\"\"} > 0)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) (rate(container_cpu_usage_seconds_total{host=~\"$host\",slice=~\"$slice\",unit!=\"\"}[$__rate_interval]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "E";
            }
          ];
          title = "Managed Services — Memory, Limits & CPU";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 3;
                  "Value #B" = 4;
                  "Value #C" = 5;
                  "Value #D" = 6;
                  "Value #E" = 7;
                  host = 0;
                  slice = 1;
                  unit = 2;
                };
                renameByName = {
                  "Value #A" = "Memory";
                  "Value #B" = "Mem Limit";
                  "Value #C" = "Headroom";
                  "Value #D" = "Limit %";
                  "Value #E" = "CPU (cores)";
                  host = "Host";
                  slice = "Slice";
                  unit = "Unit";
                };
              };
            }
          ];
          type = "table";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 33;
          };
          id = 15;
          panels = [ ];
          title = "Local Volumes & Remote Storage Budgets";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Used";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Available";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Total";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Usage %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 24;
            x = 0;
            y = 34;
          };
          id = 16;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "Usage %";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, fstype) (node_filesystem_size_bytes{host=~\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"} - node_filesystem_avail_bytes{host=~\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, fstype) (node_filesystem_avail_bytes{host=~\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, fstype) (node_filesystem_size_bytes{host=~\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint, fstype) (((node_filesystem_size_bytes{host=~\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"} - node_filesystem_avail_bytes{host=~\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"}) / clamp_min(node_filesystem_size_bytes{host=~\"$host\",fstype!~\"ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"}, 1)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
          ];
          title = "Local Filesystems & Dedicated Volumes";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 3;
                  "Value #B" = 4;
                  "Value #C" = 5;
                  "Value #D" = 6;
                  fstype = 2;
                  host = 0;
                  mountpoint = 1;
                };
                renameByName = {
                  "Value #A" = "Used";
                  "Value #B" = "Available";
                  "Value #C" = "Total";
                  "Value #D" = "Usage %";
                  fstype = "FS";
                  host = "Host";
                  mountpoint = "Mountpoint";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              noValue = "No remote storage budgets configured";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Used";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Available";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Limit";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Objects";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 0;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Usage %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 6;
            w = 24;
            x = 0;
            y = 42;
          };
          id = 17;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "Usage %";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice) (nixconf_storage_budget_used_bytes{host=~\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice) (clamp_min(nixconf_storage_budget_limit_bytes{host=~\"$host\"} - nixconf_storage_budget_used_bytes{host=~\"$host\"}, 0))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice) (nixconf_storage_budget_limit_bytes{host=~\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice) (nixconf_storage_budget_objects{host=~\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice) ((nixconf_storage_budget_used_bytes{host=~\"$host\"} / clamp_min(nixconf_storage_budget_limit_bytes{host=~\"$host\"}, 1)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "E";
            }
          ];
          title = "Remote Storage Budgets";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 2;
                  "Value #B" = 3;
                  "Value #C" = 4;
                  "Value #D" = 5;
                  "Value #E" = 6;
                  host = 0;
                  slice = 1;
                };
                renameByName = {
                  "Value #A" = "Used";
                  "Value #B" = "Available";
                  "Value #C" = "Limit";
                  "Value #D" = "Objects";
                  "Value #E" = "Usage %";
                  host = "Host";
                  slice = "Slice";
                };
              };
            }
          ];
          type = "table";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 48;
          };
          id = 18;
          panels = [ ];
          title = "OOM & Power Policy Events";
          type = "row";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          gridPos = {
            h = 10;
            w = 24;
            x = 0;
            y = 49;
          };
          id = 19;
          options = {
            dedupStrategy = "none";
            enableLogDetails = true;
            prettifyLogMessage = true;
            showCommonLabels = false;
            showLabels = true;
            showTime = true;
            sortOrder = "Descending";
            wrapLogMessage = true;
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) _msg:~\"(?i)(systemd-oomd|Out of memory|Killed process|resources-power-policy|oom-kill)\"";
              legendFormat = "";
              maxLines = 500;
              queryType = "instant";
              refId = "A";
            }
          ];
          title = "OOM Killer & Power Policy Journal Stream";
          type = "logs";
        }
      ];
      refresh = "30s";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "resources"
        "cgroups"
        "psi"
        "oom"
        "storage"
      ];
      templating = {
        list = [
          {
            allValue = ".*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_uname_info, host)";
            hide = 0;
            includeAll = true;
            label = "Host";
            multi = true;
            name = "host";
            query = {
              qryType = 1;
              query = "label_values(node_uname_info, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
          {
            allValue = ".*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(container_memory_working_set_bytes{slice!=\"\"}, slice)";
            hide = 0;
            includeAll = true;
            label = "Slice";
            multi = true;
            name = "slice";
            query = {
              qryType = 1;
              query = "label_values(container_memory_working_set_bytes{slice!=\"\"}, slice)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
        ];
      };
      time = {
        from = "now-3h";
        to = "now";
      };
      timezone = "browser";
      title = "Resources & Allocation";
      uid = "nixconf-resources";
    };
    title = "Resources & Allocation";
  };
  service-inspector = {
    enable = true;
    folder = "03 · Services";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "Vertical per-service drilldown correlating HTTP traffic, blackbox probes, systemd units, cgroup compute, storage mounts, and VictoriaLogs.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 2;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "red";
                    value = null;
                  }
                  {
                    color = "green";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_systemd_unit_state{host=~\"$host\",service=\"$service\",state=\"active\",name!~\"restic-.*\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Active";
              range = false;
              refId = "A";
            }
          ];
          title = "Units Active";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 4;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_systemd_unit_state{host=~\"$host\",service=\"$service\",state=\"failed\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Failed";
              range = false;
              refId = "A";
            }
          ];
          title = "Failed Units";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [
                {
                  options = {
                    "0" = {
                      color = "red";
                      index = 0;
                      text = "DOWN";
                    };
                    "1" = {
                      color = "green";
                      index = 1;
                      text = "UP";
                    };
                  };
                  type = "value";
                }
              ];
              noValue = "N/A";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "red";
                    value = null;
                  }
                  {
                    color = "green";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 8;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "min(probe_success{service=\"$service\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Probe";
              range = false;
              refId = "A";
            }
          ];
          title = "Endpoint Probe";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 2;
              mappings = [ ];
              noValue = "—";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "reqps";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 12;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(rate(caddy_http_requests_total{server=\"srv0\",service=\"$service\"}[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "RPS";
              range = true;
              refId = "A";
            }
          ];
          title = "HTTP Request Rate";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 1;
              mappings = [ ];
              noValue = "—";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 16;
            y = 0;
          };
          id = 5;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(container_memory_working_set_bytes{host=~\"$host\",service=\"$service\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Memory";
              range = true;
              refId = "A";
            }
          ];
          title = "Memory Working Set";
          type = "stat";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 20;
            y = 0;
          };
          id = 6;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) service:=\"$service\" level:in(\"emerg\",\"alert\",\"crit\",\"err\",\"error\") $search | stats count() as total";
              legendFormat = "Errors";
              queryType = "stats";
              refId = "A";
            }
          ];
          title = "Error Logs";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 4;
          };
          id = 7;
          panels = [ ];
          title = "HTTP Traffic & Endpoint Health";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              noValue = "No HTTP traffic";
              unit = "reqps";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?2[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "green";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?3[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "blue";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?4[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(HTTP )?5[0-9]{2}$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 0;
            y = 5;
          };
          id = 8;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (code) (rate(caddy_http_request_duration_seconds_count{server=\"srv0\",service=\"$service\"}[$__rate_interval]))";
              format = "time_series";
              instant = false;
              legendFormat = "HTTP {{code}}";
              range = true;
              refId = "A";
            }
          ];
          title = "HTTP Responses by Status Code";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              noValue = "No HTTP traffic";
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 12;
            y = 5;
          };
          id = 9;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "histogram_quantile(0.50, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server=\"srv0\",service=\"$service\"}[$__rate_interval])))";
              format = "time_series";
              instant = false;
              legendFormat = "p50";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "histogram_quantile(0.95, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server=\"srv0\",service=\"$service\"}[$__rate_interval])))";
              format = "time_series";
              instant = false;
              legendFormat = "p95";
              range = true;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "histogram_quantile(0.99, sum by (le) (rate(caddy_http_request_duration_seconds_bucket{server=\"srv0\",service=\"$service\"}[$__rate_interval])))";
              format = "time_series";
              instant = false;
              legendFormat = "p99";
              range = true;
              refId = "C";
            }
          ];
          title = "HTTP Latency Percentiles (p50 / p95 / p99)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "line";
                };
              };
              noValue = "No blackbox probe configured";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "yellow";
                    value = 0.25;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 6;
            w = 12;
            x = 0;
            y = 12;
          };
          id = 10;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (vhost) (probe_duration_seconds{service=\"$service\"})";
              format = "time_series";
              instant = false;
              legendFormat = "{{vhost}}";
              range = true;
              refId = "A";
            }
          ];
          title = "Blackbox Probe Latency";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              noValue = "No blackbox probe configured";
              unit = "s";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 6;
            w = 12;
            x = 12;
            y = 12;
          };
          id = 11;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "avg by (phase) (probe_http_duration_seconds{service=\"$service\"})";
              format = "time_series";
              instant = false;
              legendFormat = "{{phase}}";
              range = true;
              refId = "A";
            }
          ];
          title = "HTTP Probe Phase Breakdown";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 18;
          };
          id = 12;
          panels = [ ];
          title = "Compute, Units & Storage";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              noValue = "No systemd cgroup metrics";
              unit = "bytes";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/limit/";
                };
                properties = [
                  {
                    id = "custom.lineStyle";
                    value = {
                      dash = [
                        6
                        4
                      ];
                      fill = "dash";
                    };
                  }
                  {
                    id = "custom.fillOpacity";
                    value = 0;
                  }
                  {
                    id = "custom.stacking";
                    value = {
                      group = "A";
                      mode = "none";
                    };
                  }
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 0;
            y = 19;
          };
          id = 13;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "container_memory_working_set_bytes{host=~\"$host\",service=\"$service\"}";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} {{unit}} ({{slice}})";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "container_spec_memory_limit_bytes{host=~\"$host\",service=\"$service\"} > 0";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} {{unit}} limit";
              range = true;
              refId = "B";
            }
          ];
          title = "Memory Working Set";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              noValue = "No systemd cgroup metrics";
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/throttled/";
                };
                properties = [
                  {
                    id = "custom.lineStyle";
                    value = {
                      dash = [
                        6
                        4
                      ];
                      fill = "dash";
                    };
                  }
                  {
                    id = "custom.fillOpacity";
                    value = 0;
                  }
                  {
                    id = "custom.stacking";
                    value = {
                      group = "A";
                      mode = "none";
                    };
                  }
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 12;
            y = 19;
          };
          id = 14;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(container_cpu_usage_seconds_total{host=~\"$host\",service=\"$service\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} {{unit}} ({{slice}})";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(container_cpu_cfs_throttled_seconds_total{host=~\"$host\",service=\"$service\"}[$__rate_interval]) > 0";
              format = "time_series";
              instant = false;
              legendFormat = "{{host}} {{unit}} throttled";
              range = true;
              refId = "B";
            }
          ];
          title = "CPU Usage (cores)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "View Unit Logs";
                  url = "/d/nixconf-logs-explorer?var-host=\${__data.fields.Host}&var-unit=\${__data.fields.Unit}&\${__url_time_range}";
                }
              ];
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "State";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          activating = {
                            color = "yellow";
                            index = 1;
                            text = "activating";
                          };
                          active = {
                            color = "green";
                            index = 0;
                            text = "active";
                          };
                          failed = {
                            color = "red";
                            index = 3;
                            text = "failed";
                          };
                          inactive = {
                            color = "text";
                            index = 2;
                            text = "inactive";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 6;
            w = 10;
            x = 0;
            y = 26;
          };
          id = 15;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_systemd_unit_state{host=~\"$host\",service=\"$service\"} == 1";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
          ];
          title = "Service & Backup Units Health";
          transformations = [
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                  Value = true;
                  __name__ = true;
                  instance = true;
                  job = true;
                  watched = true;
                };
                indexByName = {
                  host = 0;
                  name = 1;
                  state = 2;
                  type = 3;
                };
                renameByName = {
                  host = "Host";
                  name = "Unit";
                  state = "State";
                  type = "Type";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              noValue = "No dedicated storage mounts";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Used";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Available";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Total";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Usage %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 6;
            w = 14;
            x = 10;
            y = 26;
          };
          id = 16;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "Usage %";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint) (node_filesystem_size_bytes{host=~\"$host\",service=\"$service\"} - node_filesystem_avail_bytes{host=~\"$host\",service=\"$service\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint) (node_filesystem_avail_bytes{host=~\"$host\",service=\"$service\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint) (node_filesystem_size_bytes{host=~\"$host\",service=\"$service\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint) (((node_filesystem_size_bytes{host=~\"$host\",service=\"$service\"} - node_filesystem_avail_bytes{host=~\"$host\",service=\"$service\"}) / clamp_min(node_filesystem_size_bytes{host=~\"$host\",service=\"$service\"}, 1)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
          ];
          title = "Service Storage Mounts";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 2;
                  "Value #B" = 3;
                  "Value #C" = 4;
                  "Value #D" = 5;
                  host = 0;
                  mountpoint = 1;
                };
                renameByName = {
                  "Value #A" = "Used";
                  "Value #B" = "Available";
                  "Value #C" = "Total";
                  "Value #D" = "Usage %";
                  host = "Host";
                  mountpoint = "Mountpoint";
                };
              };
            }
          ];
          type = "table";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 32;
          };
          id = 17;
          panels = [ ];
          title = "Service Logs";
          type = "row";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "bars";
                fillOpacity = 80;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(emerg|emergency|alert|crit|critical|err|error)$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^warning$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^notice$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "yellow";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^info$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "blue";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^debug$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "purple";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 6;
            w = 24;
            x = 0;
            y = 33;
          };
          id = 18;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) service:=\"$service\" level:in($level) $search | stats by (level) count() as lines";
              legendFormat = "{{level}}";
              queryType = "statsRange";
              refId = "A";
            }
          ];
          title = "Log Volume by Severity";
          type = "timeseries";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          gridPos = {
            h = 14;
            w = 24;
            x = 0;
            y = 39;
          };
          id = 19;
          options = {
            dedupStrategy = "none";
            enableLogDetails = true;
            prettifyLogMessage = true;
            showCommonLabels = false;
            showLabels = true;
            showTime = true;
            sortOrder = "Descending";
            wrapLogMessage = true;
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:in($host) service:=\"$service\" level:in($level) $search";
              legendFormat = "";
              maxLines = 500;
              queryType = "instant";
              refId = "A";
            }
          ];
          title = "Live Service Journal Stream";
          type = "logs";
        }
      ];
      refresh = "30s";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "service"
        "app"
        "inspector"
      ];
      templating = {
        list = [
          {
            current = { };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_systemd_unit_state{service=~\".+\"}, service)";
            hide = 0;
            includeAll = false;
            label = "Service";
            multi = false;
            name = "service";
            query = {
              qryType = 1;
              query = "label_values(node_systemd_unit_state{service=~\".+\"}, service)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
          {
            allValue = ".*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_uname_info, host)";
            hide = 0;
            includeAll = true;
            label = "Host";
            multi = true;
            name = "host";
            query = {
              qryType = 1;
              query = "label_values(node_uname_info, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
          {
            allValue = "*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            hide = 0;
            includeAll = true;
            label = "Log Level";
            multi = true;
            name = "level";
            options = [
              {
                selected = true;
                text = "All";
                value = "$__all";
              }
              {
                selected = false;
                text = "emerg";
                value = "emerg";
              }
              {
                selected = false;
                text = "alert";
                value = "alert";
              }
              {
                selected = false;
                text = "crit";
                value = "crit";
              }
              {
                selected = false;
                text = "err";
                value = "err";
              }
              {
                selected = false;
                text = "error";
                value = "error";
              }
              {
                selected = false;
                text = "warning";
                value = "warning";
              }
              {
                selected = false;
                text = "notice";
                value = "notice";
              }
              {
                selected = false;
                text = "info";
                value = "info";
              }
              {
                selected = false;
                text = "debug";
                value = "debug";
              }
            ];
            query = "emerg,alert,crit,err,error,warning,notice,info,debug";
            type = "custom";
          }
          {
            current = {
              selected = true;
              text = "";
              value = "";
            };
            hide = 0;
            label = "Log Search (LogsQL)";
            name = "search";
            options = [
              {
                selected = true;
                text = "";
                value = "";
              }
            ];
            query = "";
            type = "textbox";
          }
        ];
      };
      time = {
        from = "now-3h";
        to = "now";
      };
      timezone = "browser";
      title = "Service Inspector";
      uid = "nixconf-service-inspector";
    };
    title = "Service Inspector";
  };
  services-catalog = {
    enable = true;
    folder = "03 · Services";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "Unified directory across every declared nixconf service: unit state, blackbox probes, HTTP throughput, memory limits, and CPU usage.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 1;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(count by (service) (node_systemd_unit_state{host=~\"$host\",service!=\"\"})) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Services";
              range = false;
              refId = "A";
            }
          ];
          title = "Registered Services";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "red";
                          value = null;
                        }
                        {
                          color = "green";
                          value = 100;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 7;
            x = 5;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "(avg(probe_success{service!=\"\"}) or vector(1)) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "Up %";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(probe_success{service!=\"\"} == 1) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Up";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(probe_success{service!=\"\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "Service Probes Healthy";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 2;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "reqps";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 12;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(rate(caddy_http_requests_total{server=\"srv0\",service!=\"\"}[$__rate_interval])) or vector(0)";
              format = "time_series";
              instant = false;
              legendFormat = "RPS";
              range = true;
              refId = "A";
            }
          ];
          title = "Total HTTP RPS";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 1;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 18;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "value";
            graphMode = "area";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(container_memory_working_set_bytes{host=~\"$host\",service!=\"\"})";
              format = "time_series";
              instant = false;
              legendFormat = "RAM";
              range = true;
              refId = "A";
            }
          ];
          title = "Total Services RAM";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 4;
          };
          id = 5;
          panels = [ ];
          title = "All Monitored Services (Click Any Service Row to Inspect)";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "Inspect Service";
                  url = "/d/nixconf-service-inspector?var-service=\${__data.fields.Service}&\${__url_time_range}";
                }
              ];
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Active Units";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 0;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Failed Units";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 0;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Probe";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          "0" = {
                            color = "red";
                            index = 0;
                            text = "DOWN";
                          };
                          "1" = {
                            color = "green";
                            index = 1;
                            text = "UP";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "HTTP RPS";
                };
                properties = [
                  {
                    id = "unit";
                    value = "reqps";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "HTTP RPS";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 2;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "RAM Working Set";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "RAM Limit";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Limit %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "CPU (cores)";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 3;
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 12;
            w = 24;
            x = 0;
            y = 5;
          };
          id = 6;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "RAM Working Set";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (service) (node_systemd_unit_state{host=~\"$host\",service!=\"\",state=\"active\",name!~\"restic-.*\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (service) (node_systemd_unit_state{host=~\"$host\",service!=\"\",state=\"failed\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "min by (service) (probe_success{service!=\"\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (service) (rate(caddy_http_requests_total{server=\"srv0\",service!=\"\"}[$__rate_interval]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (service) (container_memory_working_set_bytes{host=~\"$host\",service!=\"\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "E";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (service) (container_spec_memory_limit_bytes{host=~\"$host\",service!=\"\"} > 0)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "F";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "(sum by (service) (container_memory_working_set_bytes{host=~\"$host\",service!=\"\"}) / (sum by (service) (container_spec_memory_limit_bytes{host=~\"$host\",service!=\"\"} > 0))) * 100";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "G";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (service) (rate(container_cpu_usage_seconds_total{host=~\"$host\",service!=\"\"}[$__rate_interval]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "H";
            }
          ];
          title = "Services Overview";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 1;
                  "Value #B" = 2;
                  "Value #C" = 3;
                  "Value #D" = 4;
                  "Value #E" = 5;
                  "Value #F" = 6;
                  "Value #G" = 7;
                  "Value #H" = 8;
                  service = 0;
                };
                renameByName = {
                  "Value #A" = "Active Units";
                  "Value #B" = "Failed Units";
                  "Value #C" = "Probe";
                  "Value #D" = "HTTP RPS";
                  "Value #E" = "RAM Working Set";
                  "Value #F" = "RAM Limit";
                  "Value #G" = "Limit %";
                  "Value #H" = "CPU (cores)";
                  service = "Service";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              links = [
                {
                  title = "Inspect \${__field.labels.service}";
                  url = "/d/nixconf-service-inspector?var-service=\${__field.labels.service}&\${__url_time_range}";
                }
              ];
              mappings = [
                {
                  options = {
                    "0" = {
                      color = "red";
                      index = 0;
                      text = "DOWN";
                    };
                    "1" = {
                      color = "green";
                      index = 1;
                      text = "UP";
                    };
                  };
                  type = "value";
                }
              ];
              noValue = "No service probes configured";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "red";
                    value = null;
                  }
                  {
                    color = "green";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 5;
            w = 24;
            x = 0;
            y = 17;
          };
          id = 7;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (vhost, service) (probe_success{service!=\"\"})";
              format = "time_series";
              instant = true;
              legendFormat = "{{vhost}}";
              range = false;
              refId = "A";
            }
          ];
          title = "Service Endpoints";
          type = "stat";
        }
      ];
      refresh = "30s";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "services"
        "catalog"
        "apps"
      ];
      templating = {
        list = [
          {
            allValue = ".*";
            current = {
              selected = true;
              text = "All";
              value = "$__all";
            };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_uname_info, host)";
            hide = 0;
            includeAll = true;
            label = "Host";
            multi = true;
            name = "host";
            query = {
              qryType = 1;
              query = "label_values(node_uname_info, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
        ];
      };
      time = {
        from = "now-3h";
        to = "now";
      };
      timezone = "browser";
      title = "Services Catalog";
      uid = "nixconf-services-catalog";
    };
    title = "Services Catalog";
  };
  task-manager = {
    enable = true;
    folder = "01 · Investigate";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "Historical and live htop/btop/Task Manager equivalent: per-process CPU, memory, swap, disk I/O, open FDs, per-core CPU, thermals, sockets, and systemd cgroups.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 2;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "clock";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Time Machine";
          tooltip = "Investigate host state at a point in time";
          type = "link";
          url = "/d/nixconf-time-machine";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 2;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 0;
            y = 0;
          };
          id = 1;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "100 - (avg(rate(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"}[$__rate_interval])) * 100)";
              format = "time_series";
              instant = true;
              legendFormat = "%";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(1 - rate(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"}[$__rate_interval]))";
              format = "time_series";
              instant = true;
              legendFormat = "Active Cores";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Total Cores";
              range = false;
              refId = "C";
            }
          ];
          title = "CPU Utilization";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 6;
            y = 0;
          };
          id = 2;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "((node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemAvailable_bytes{host=\"$host\"}) / clamp_min(node_memory_MemTotal_bytes{host=\"$host\"}, 1)) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "%";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemAvailable_bytes{host=\"$host\"}";
              format = "time_series";
              instant = true;
              legendFormat = "Used";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_memory_MemTotal_bytes{host=\"$host\"}";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "Memory";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 5;
            x = 12;
            y = 0;
          };
          id = 3;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "((node_memory_SwapTotal_bytes{host=\"$host\"} - node_memory_SwapFree_bytes{host=\"$host\"}) / clamp_min(node_memory_SwapTotal_bytes{host=\"$host\"}, 1)) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "%";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_memory_SwapTotal_bytes{host=\"$host\"} - node_memory_SwapFree_bytes{host=\"$host\"}";
              format = "time_series";
              instant = true;
              legendFormat = "Used";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_memory_SwapTotal_bytes{host=\"$host\"}";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "Swap";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              noValue = "N/A";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "celsius";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "hertz";
                  }
                  {
                    id = "decimals";
                    value = 2;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 17;
            y = 0;
          };
          id = 4;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max(node_hwmon_temp_celsius{host=\"$host\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Max Temp";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "avg(node_cpu_scaling_frequency_hertz{host=\"$host\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Avg Clock";
              range = false;
              refId = "B";
            }
          ];
          title = "Temp & Clock";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 3;
            x = 21;
            y = 0;
          };
          id = 5;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(namedprocess_namegroup_num_procs{host=\"$host\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Procs";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(namedprocess_namegroup_num_threads{host=\"$host\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Threads";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max(node_procs_running{host=\"$host\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Running";
              range = false;
              refId = "C";
            }
          ];
          title = "Processes & Threads";
          type = "stat";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 4;
          };
          id = 6;
          panels = [ ];
          title = "Processes (Grouped by Executable)";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Procs";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 0;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Threads";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 0;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "CPU (cores)";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 3;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "CPU %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "RAM (RSS)";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Swapped";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Disk Read/s";
                };
                properties = [
                  {
                    id = "unit";
                    value = "Bps";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Disk Write/s";
                };
                properties = [
                  {
                    id = "unit";
                    value = "Bps";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Open FDs";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 0;
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 12;
            w = 24;
            x = 0;
            y = 5;
          };
          id = 7;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "CPU %";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (groupname) (namedprocess_namegroup_num_procs{host=\"$host\",groupname=~\"$proc\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (groupname) (namedprocess_namegroup_num_threads{host=\"$host\",groupname=~\"$proc\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (groupname) (rate(namedprocess_namegroup_cpu_seconds_total{host=\"$host\",groupname=~\"$proc\"}[$__rate_interval]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "(sum by (groupname) (rate(namedprocess_namegroup_cpu_seconds_total{host=\"$host\",groupname=~\"$proc\"}[$__rate_interval])) / on() group_left() clamp_min(count(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"}), 1)) * 100";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (groupname) (namedprocess_namegroup_memory_bytes{host=\"$host\",groupname=~\"$proc\",memtype=\"resident\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "E";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (groupname) (namedprocess_namegroup_memory_bytes{host=\"$host\",groupname=~\"$proc\",memtype=\"swapped\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "F";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (groupname) (rate(namedprocess_namegroup_read_bytes_total{host=\"$host\",groupname=~\"$proc\"}[$__rate_interval]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "G";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (groupname) (rate(namedprocess_namegroup_write_bytes_total{host=\"$host\",groupname=~\"$proc\"}[$__rate_interval]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "H";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (groupname) (namedprocess_namegroup_open_filedesc{host=\"$host\",groupname=~\"$proc\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "I";
            }
          ];
          title = "All Tracked Processes on $host";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 1;
                  "Value #B" = 2;
                  "Value #C" = 3;
                  "Value #D" = 4;
                  "Value #E" = 5;
                  "Value #F" = 6;
                  "Value #G" = 7;
                  "Value #H" = 8;
                  "Value #I" = 9;
                  groupname = 0;
                };
                renameByName = {
                  "Value #A" = "Procs";
                  "Value #B" = "Threads";
                  "Value #C" = "CPU (cores)";
                  "Value #D" = "CPU %";
                  "Value #E" = "RAM (RSS)";
                  "Value #F" = "Swapped";
                  "Value #G" = "Disk Read/s";
                  "Value #H" = "Disk Write/s";
                  "Value #I" = "Open FDs";
                  groupname = "Process";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              min = 0;
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 8;
            x = 0;
            y = 17;
          };
          id = 8;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "topk(10, sum by (groupname) (rate(namedprocess_namegroup_cpu_seconds_total{host=\"$host\",groupname=~\"$proc\"}[$__rate_interval])))";
              format = "time_series";
              instant = false;
              legendFormat = "{{groupname}}";
              range = true;
              refId = "A";
            }
          ];
          title = "Top 10 Processes — CPU (cores)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              min = 0;
              unit = "bytes";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 8;
            x = 8;
            y = 17;
          };
          id = 9;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "topk(10, sum by (groupname) (namedprocess_namegroup_memory_bytes{host=\"$host\",groupname=~\"$proc\",memtype=\"resident\"}))";
              format = "time_series";
              instant = false;
              legendFormat = "{{groupname}}";
              range = true;
              refId = "A";
            }
          ];
          title = "Top 10 Processes — RAM (RSS)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "Bps";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/Write/";
                };
                properties = [
                  {
                    id = "custom.transform";
                    value = "negative-Y";
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 8;
            x = 16;
            y = 17;
          };
          id = 10;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "topk(10, sum by (groupname) (rate(namedprocess_namegroup_read_bytes_total{host=\"$host\",groupname=~\"$proc\"}[$__rate_interval])))";
              format = "time_series";
              instant = false;
              legendFormat = "{{groupname}} Read";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "topk(10, sum by (groupname) (rate(namedprocess_namegroup_write_bytes_total{host=\"$host\",groupname=~\"$proc\"}[$__rate_interval])))";
              format = "time_series";
              instant = false;
              legendFormat = "{{groupname}} Write";
              range = true;
              refId = "B";
            }
          ];
          title = "Top 10 Processes — Disk I/O (Read / -Write)";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 25;
          };
          id = 11;
          panels = [ ];
          title = "Hardware Performance (CPU Cores, Memory, Disk, Network)";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              max = 100;
              min = 0;
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "yellow";
                    value = 75;
                  }
                  {
                    color = "red";
                    value = 90;
                  }
                ];
              };
              unit = "percent";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 10;
            x = 0;
            y = 26;
          };
          id = 12;
          options = {
            displayMode = "gradient";
            minVizHeight = 10;
            minVizWidth = 0;
            namePlacement = "auto";
            orientation = "horizontal";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            showUnfilled = true;
            sizing = "auto";
            valueMode = "color";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "100 - (avg by (cpu) (rate(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"}[$__rate_interval])) * 100)";
              format = "time_series";
              instant = true;
              legendFormat = "CPU {{cpu}}";
              range = false;
              refId = "A";
            }
          ];
          title = "Per-Core CPU Utilization (%)";
          type = "bargauge";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              min = 0;
              unit = "bytes";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/Total/";
                };
                properties = [
                  {
                    id = "custom.lineStyle";
                    value = {
                      dash = [
                        6
                        4
                      ];
                      fill = "dash";
                    };
                  }
                  {
                    id = "custom.fillOpacity";
                    value = 0;
                  }
                  {
                    id = "custom.stacking";
                    value = {
                      group = "A";
                      mode = "none";
                    };
                  }
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 14;
            x = 10;
            y = 26;
          };
          id = 13;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemFree_bytes{host=\"$host\"} - node_memory_Buffers_bytes{host=\"$host\"} - node_memory_Cached_bytes{host=\"$host\"} - node_memory_SReclaimable_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Active / Used";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_Cached_bytes{host=\"$host\"} + node_memory_SReclaimable_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Page Cache";
              range = true;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_Buffers_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Buffers";
              range = true;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemFree_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Free";
              range = true;
              refId = "D";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemTotal_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Total RAM";
              range = true;
              refId = "E";
            }
          ];
          title = "Memory Breakdown";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "Bps";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/Write/";
                };
                properties = [
                  {
                    id = "custom.transform";
                    value = "negative-Y";
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 0;
            y = 34;
          };
          id = 14;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_disk_read_bytes_total{host=\"$host\",device!~\"dm-.*|loop.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} Read";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_disk_written_bytes_total{host=\"$host\",device!~\"dm-.*|loop.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} Write";
              range = true;
              refId = "B";
            }
          ];
          title = "Disk I/O Throughput (Read / -Write)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "Bps";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/TX/";
                };
                properties = [
                  {
                    id = "custom.transform";
                    value = "negative-Y";
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 12;
            y = 34;
          };
          id = 15;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_network_receive_bytes_total{host=\"$host\",device!~\"lo|veth.*|docker.*|br-.*|podman.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} RX";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_network_transmit_bytes_total{host=\"$host\",device!~\"lo|veth.*|docker.*|br-.*|podman.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} TX";
              range = true;
              refId = "B";
            }
          ];
          title = "Network Throughput (RX / -TX)";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 41;
          };
          id = 16;
          panels = [ ];
          title = "Systemd Units & Network Sockets";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "View Unit Logs";
                  url = "/d/nixconf-logs-explorer?var-host=\${__data.fields.Host}&var-unit=\${__data.fields.Unit}&\${__url_time_range}";
                }
              ];
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Memory";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Mem Limit";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Limit %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "CPU (cores)";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 3;
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 16;
            x = 0;
            y = 42;
          };
          id = 17;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "Memory";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) (container_memory_working_set_bytes{host=\"$host\",unit!=\"\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) (container_spec_memory_limit_bytes{host=\"$host\",unit!=\"\"} > 0)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) ((container_memory_working_set_bytes{host=\"$host\",unit!=\"\"} / (container_spec_memory_limit_bytes{host=\"$host\",unit!=\"\"} > 0)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) (rate(container_cpu_usage_seconds_total{host=\"$host\",unit!=\"\"}[$__rate_interval]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
          ];
          title = "Systemd Units by Memory & CPU (Click Row for Logs)";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 3;
                  "Value #B" = 4;
                  "Value #C" = 5;
                  "Value #D" = 6;
                  host = 0;
                  slice = 1;
                  unit = 2;
                };
                renameByName = {
                  "Value #A" = "Memory";
                  "Value #B" = "Mem Limit";
                  "Value #C" = "Limit %";
                  "Value #D" = "CPU (cores)";
                  host = "Host";
                  slice = "Slice";
                  unit = "Unit";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              decimals = 0;
              min = 0;
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 8;
            w = 8;
            x = 16;
            y = 42;
          };
          id = 18;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_sockstat_TCP_inuse{host=\"$host\"}";
              format = "time_series";
              instant = false;
              legendFormat = "In Use";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_sockstat_TCP_tw{host=\"$host\"}";
              format = "time_series";
              instant = false;
              legendFormat = "TIME_WAIT";
              range = true;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_sockstat_TCP_alloc{host=\"$host\"}";
              format = "time_series";
              instant = false;
              legendFormat = "Allocated";
              range = true;
              refId = "C";
            }
          ];
          title = "TCP Socket States";
          type = "timeseries";
        }
      ];
      refresh = "10s";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "task-manager"
        "processes"
        "htop"
        "btop"
        "performance"
      ];
      templating = {
        list = [
          {
            current = { };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_uname_info, host)";
            hide = 0;
            includeAll = false;
            label = "Host";
            multi = false;
            name = "host";
            query = {
              qryType = 1;
              query = "label_values(node_uname_info, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
          {
            current = {
              selected = true;
              text = ".*";
              value = ".*";
            };
            hide = 0;
            label = "Process Filter (Regex)";
            name = "proc";
            options = [
              {
                selected = true;
                text = ".*";
                value = ".*";
              }
            ];
            query = ".*";
            type = "textbox";
          }
        ];
      };
      time = {
        from = "now-1h";
        to = "now";
      };
      timezone = "browser";
      title = "Task Manager";
      uid = "nixconf-task-manager";
    };
    title = "Task Manager";
  };
  time-machine = {
    enable = true;
    folder = "01 · Investigate";
    json = {
      annotations = {
        list = [
          {
            builtIn = 1;
            datasource = {
              type = "grafana";
              uid = "-- Grafana --";
            };
            enable = true;
            hide = true;
            iconColor = "rgba(0, 211, 255, 1)";
            name = "Annotations & Alerts";
            type = "dashboard";
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_boot_time_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "orange";
            name = "Reboots";
            step = "60s";
            tagKeys = "host";
            textFormat = "{{host}} booted";
            titleFormat = "Host Reboot";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(nixconf_deployment_timestamp_seconds{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "blue";
            name = "NixOS Deployments";
            step = "60s";
            tagKeys = "host,rev";
            textFormat = "{{host}} deployed {{rev}}";
            titleFormat = "NixOS Deploy";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "increase(container_oom_events_total{host=~\"$host\"}[2m]) > 0";
            hide = false;
            iconColor = "red";
            name = "OOM Kills";
            step = "60s";
            tagKeys = "host,unit";
            textFormat = "OOM in {{unit}} on {{host}}";
            titleFormat = "OOM Event";
            useValueForTime = false;
          }
          {
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            enable = true;
            expr = "changes(node_systemd_unit_state{host=~\"$host\",state=\"failed\"}[2m]) > 0 and node_systemd_unit_state{host=~\"$host\",state=\"failed\"} == 1";
            hide = false;
            iconColor = "purple";
            name = "Unit Failures";
            step = "60s";
            tagKeys = "host,name";
            textFormat = "{{name}} failed on {{host}}";
            titleFormat = "Unit Failed";
            useValueForTime = false;
          }
        ];
      };
      description = "Point-in-time forensic reconstruction: scrub or zoom the Master Timeline Strip to inspect exact process, service, pressure, filesystem, and log states at any moment.";
      editable = false;
      fiscalYearStartMonth = 0;
      graphTooltip = 2;
      links = [
        {
          asDropdown = true;
          icon = "external link";
          includeVars = true;
          keepTime = true;
          tags = [
            "nixconf"
          ];
          targetBlank = false;
          title = "Dashboards";
          tooltip = "Switch to another nixconf dashboard";
          type = "dashboards";
        }
        {
          icon = "home";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Fleet Home";
          tooltip = "Open Fleet Command Center";
          type = "link";
          url = "/d/nixconf-fleet-overview";
        }
        {
          icon = "bolt";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Task Manager";
          tooltip = "Open per-host process & hardware Task Manager";
          type = "link";
          url = "/d/nixconf-task-manager";
        }
        {
          icon = "apps";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Services";
          tooltip = "Browse all monitored services and jump to Service Inspector";
          type = "link";
          url = "/d/nixconf-services-catalog";
        }
        {
          icon = "doc";
          includeVars = true;
          keepTime = true;
          targetBlank = false;
          title = "Logs";
          tooltip = "Search centralized journald logs in VictoriaLogs";
          type = "link";
          url = "/d/nixconf-logs-explorer";
        }
      ];
      liveNow = false;
      panels = [
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 0;
          };
          id = 1;
          panels = [ ];
          title = "Master Timeline Strip (Drag-Zoom Any Spike or Use Time Step Arrows)";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "line";
                };
              };
              min = 0;
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "yellow";
                    value = 75;
                  }
                  {
                    color = "red";
                    value = 90;
                  }
                ];
              };
              unit = "percent";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 6;
            w = 24;
            x = 0;
            y = 1;
          };
          id = 2;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "100 - (avg(rate(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"}[$__rate_interval])) * 100)";
              format = "time_series";
              instant = false;
              legendFormat = "CPU %";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "((node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemAvailable_bytes{host=\"$host\"}) / clamp_min(node_memory_MemTotal_bytes{host=\"$host\"}, 1)) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "Memory %";
              range = true;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_pressure_cpu_waiting_seconds_total{host=\"$host\"}[$__rate_interval]) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "CPU PSI %";
              range = true;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_pressure_memory_stalled_seconds_total{host=\"$host\"}[$__rate_interval]) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "Memory PSI %";
              range = true;
              refId = "D";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_pressure_io_stalled_seconds_total{host=\"$host\"}[$__rate_interval]) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "I/O PSI %";
              range = true;
              refId = "E";
            }
          ];
          title = "System Pulse & Contention (%)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "bars";
                fillOpacity = 80;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^(emerg|emergency|alert|crit|critical|err|error)$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^warning$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^notice$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "yellow";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^info$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "blue";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byRegexp";
                  options = "/^debug$/";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "purple";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 24;
            x = 0;
            y = 7;
          };
          id = 3;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "list";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:=\"$host\" level:in(\"emerg\",\"alert\",\"crit\",\"err\",\"error\",\"warning\") | stats by (level) count() as lines";
              legendFormat = "{{level}}";
              queryType = "statsRange";
              refId = "A";
            }
          ];
          title = "Error & Warning Log Bursts";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 11;
          };
          id = 4;
          panels = [ ];
          title = "Snapshot State at Selected Window End ($__to)";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 2;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "short";
                  }
                  {
                    id = "decimals";
                    value = 0;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 0;
            y = 12;
          };
          id = 5;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "100 - (avg(rate(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"}[$__rate_interval])) * 100)";
              format = "time_series";
              instant = true;
              legendFormat = "%";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(1 - rate(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"}[$__rate_interval]))";
              format = "time_series";
              instant = true;
              legendFormat = "Active Cores";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(node_cpu_seconds_total{host=\"$host\",mode=\"idle\"})";
              format = "time_series";
              instant = true;
              legendFormat = "Total Cores";
              range = false;
              refId = "C";
            }
          ];
          title = "CPU at Snapshot";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "blue";
                    value = null;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "A";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "yellow";
                          value = 75;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "B";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byFrameRefID";
                  options = "C";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "blue";
                          value = null;
                        }
                      ];
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 4;
            w = 6;
            x = 6;
            y = 12;
          };
          id = 6;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "((node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemAvailable_bytes{host=\"$host\"}) / clamp_min(node_memory_MemTotal_bytes{host=\"$host\"}, 1)) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "%";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemAvailable_bytes{host=\"$host\"}";
              format = "time_series";
              instant = true;
              legendFormat = "Used";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_memory_MemTotal_bytes{host=\"$host\"}";
              format = "time_series";
              instant = true;
              legendFormat = "Total";
              range = false;
              refId = "C";
            }
          ];
          title = "Memory at Snapshot";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 1;
              mappings = [ ];
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "yellow";
                    value = 75;
                  }
                  {
                    color = "red";
                    value = 90;
                  }
                ];
              };
              unit = "percent";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 12;
            y = 12;
          };
          id = 7;
          options = {
            colorMode = "value";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "value_and_name";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_pressure_cpu_waiting_seconds_total{host=\"$host\"}[$__rate_interval]) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "CPU";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_pressure_memory_stalled_seconds_total{host=\"$host\"}[$__rate_interval]) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "Mem";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_pressure_io_stalled_seconds_total{host=\"$host\"}[$__rate_interval]) * 100";
              format = "time_series";
              instant = true;
              legendFormat = "I/O";
              range = false;
              refId = "C";
            }
          ];
          title = "PSI at Snapshot (%)";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 16;
            y = 12;
          };
          id = 8;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_systemd_unit_state{host=\"$host\",state=\"failed\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Failed";
              range = false;
              refId = "A";
            }
          ];
          title = "Failed Units";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "thresholds";
              };
              decimals = 0;
              mappings = [ ];
              noValue = "0";
              thresholds = {
                mode = "absolute";
                steps = [
                  {
                    color = "green";
                    value = null;
                  }
                  {
                    color = "red";
                    value = 1;
                  }
                ];
              };
              unit = "short";
            };
            overrides = [ ];
          };
          gridPos = {
            h = 4;
            w = 4;
            x = 20;
            y = 12;
          };
          id = 9;
          options = {
            colorMode = "background";
            graphMode = "none";
            justifyMode = "auto";
            orientation = "auto";
            reduceOptions = {
              calcs = [
                "lastNotNull"
              ];
              fields = "";
              values = false;
            };
            textMode = "auto";
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "count(ALERTS{host=\"$host\",alertstate=\"firing\"}) or vector(0)";
              format = "time_series";
              instant = true;
              legendFormat = "Firing";
              range = false;
              refId = "A";
            }
          ];
          title = "Active Alerts";
          type = "stat";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Procs";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 0;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "CPU (cores)";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 3;
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "RAM (RSS)";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Disk Read/s";
                };
                properties = [
                  {
                    id = "unit";
                    value = "Bps";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Disk Write/s";
                };
                properties = [
                  {
                    id = "unit";
                    value = "Bps";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Open FDs";
                };
                properties = [
                  {
                    id = "decimals";
                    value = 0;
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 14;
            x = 0;
            y = 16;
          };
          id = 10;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "RAM (RSS)";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (groupname) (namedprocess_namegroup_num_procs{host=\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (groupname) (rate(namedprocess_namegroup_cpu_seconds_total{host=\"$host\"}[$__rate_interval]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "topk(25, sum by (groupname) (namedprocess_namegroup_memory_bytes{host=\"$host\",memtype=\"resident\"}))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (groupname) (rate(namedprocess_namegroup_read_bytes_total{host=\"$host\"}[$__rate_interval]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum by (groupname) (rate(namedprocess_namegroup_write_bytes_total{host=\"$host\"}[$__rate_interval]))";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "E";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (groupname) (namedprocess_namegroup_open_filedesc{host=\"$host\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "F";
            }
          ];
          title = "Top Processes at Snapshot";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 1;
                  "Value #B" = 2;
                  "Value #C" = 3;
                  "Value #D" = 4;
                  "Value #E" = 5;
                  "Value #F" = 6;
                  groupname = 0;
                };
                renameByName = {
                  "Value #A" = "Procs";
                  "Value #B" = "CPU (cores)";
                  "Value #C" = "RAM (RSS)";
                  "Value #D" = "Disk Read/s";
                  "Value #E" = "Disk Write/s";
                  "Value #F" = "Open FDs";
                  groupname = "Process";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "View Unit Logs";
                  url = "/d/nixconf-logs-explorer?var-host=\${__data.fields.Host}&var-unit=\${__data.fields.Unit}&\${__url_time_range}";
                }
              ];
              noValue = "No failed systemd units";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "State";
                };
                properties = [
                  {
                    id = "mappings";
                    value = [
                      {
                        options = {
                          activating = {
                            color = "yellow";
                            index = 1;
                            text = "activating";
                          };
                          active = {
                            color = "green";
                            index = 0;
                            text = "active";
                          };
                          failed = {
                            color = "red";
                            index = 3;
                            text = "failed";
                          };
                          inactive = {
                            color = "text";
                            index = 2;
                            text = "inactive";
                          };
                        };
                        type = "value";
                      }
                    ];
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "basic";
                      type = "color-background";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 8;
            w = 10;
            x = 14;
            y = 16;
          };
          id = 11;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [ ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "node_systemd_unit_state{host=\"$host\",state=\"failed\"} == 1";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
          ];
          title = "Failed Units at Snapshot";
          transformations = [
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                  Value = true;
                  __name__ = true;
                  instance = true;
                  job = true;
                  watched = true;
                };
                indexByName = {
                  host = 0;
                  name = 1;
                  state = 2;
                  type = 3;
                };
                renameByName = {
                  host = "Host";
                  name = "Unit";
                  state = "State";
                  type = "Type";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
              links = [
                {
                  title = "View Unit Logs";
                  url = "/d/nixconf-logs-explorer?var-host=\${__data.fields.Host}&var-unit=\${__data.fields.Unit}&\${__url_time_range}";
                }
              ];
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Memory";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Mem Limit";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Limit %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 0;
            y = 24;
          };
          id = 12;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "Memory";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) (container_memory_working_set_bytes{host=\"$host\",unit!=\"\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) (container_spec_memory_limit_bytes{host=\"$host\",unit!=\"\"} > 0)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, slice, unit) ((container_memory_working_set_bytes{host=\"$host\",unit!=\"\"} / (container_spec_memory_limit_bytes{host=\"$host\",unit!=\"\"} > 0)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
          ];
          title = "Services & Cgroup Limits at Snapshot";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 3;
                  "Value #B" = 4;
                  "Value #C" = 5;
                  host = 0;
                  slice = 1;
                  unit = 2;
                };
                renameByName = {
                  "Value #A" = "Memory";
                  "Value #B" = "Mem Limit";
                  "Value #C" = "Limit %";
                  host = "Host";
                  slice = "Slice";
                  unit = "Unit";
                };
              };
            }
          ];
          type = "table";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              custom = {
                align = "auto";
                cellOptions = {
                  type = "auto";
                };
                filterable = true;
                inspect = false;
              };
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "Used";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Available";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Total";
                };
                properties = [
                  {
                    id = "unit";
                    value = "bytes";
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "Usage %";
                };
                properties = [
                  {
                    id = "unit";
                    value = "percent";
                  }
                  {
                    id = "decimals";
                    value = 1;
                  }
                  {
                    id = "min";
                    value = 0;
                  }
                  {
                    id = "max";
                    value = 100;
                  }
                  {
                    id = "thresholds";
                    value = {
                      mode = "absolute";
                      steps = [
                        {
                          color = "green";
                          value = null;
                        }
                        {
                          color = "orange";
                          value = 80;
                        }
                        {
                          color = "red";
                          value = 90;
                        }
                      ];
                    };
                  }
                  {
                    id = "color";
                    value = {
                      mode = "thresholds";
                    };
                  }
                  {
                    id = "custom.cellOptions";
                    value = {
                      mode = "gradient";
                      type = "gauge";
                      valueDisplayMode = "color";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 12;
            y = 24;
          };
          id = 13;
          options = {
            cellHeight = "sm";
            footer = {
              countRows = false;
              fields = "";
              reducer = [
                "sum"
              ];
              show = false;
            };
            showHeader = true;
            sortBy = [
              {
                desc = true;
                displayName = "Usage %";
              }
            ];
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint) (node_filesystem_size_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"} - node_filesystem_avail_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint) (node_filesystem_avail_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint) (node_filesystem_size_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"})";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "max by (host, mountpoint) (((node_filesystem_size_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"} - node_filesystem_avail_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"}) / clamp_min(node_filesystem_size_bytes{host=\"$host\",fstype!~\"ramfs|squashfs|overlay\",mountpoint!~\"/(etc|nix|var/run|run|sys|proc|dev).*\"}, 1)) * 100)";
              format = "table";
              instant = true;
              legendFormat = "";
              range = false;
              refId = "D";
            }
          ];
          title = "Filesystems at Snapshot";
          transformations = [
            {
              id = "merge";
              options = { };
            }
            {
              id = "organize";
              options = {
                excludeByName = {
                  Time = true;
                };
                indexByName = {
                  "Value #A" = 2;
                  "Value #B" = 3;
                  "Value #C" = 4;
                  "Value #D" = 5;
                  host = 0;
                  mountpoint = 1;
                };
                renameByName = {
                  "Value #A" = "Used";
                  "Value #B" = "Available";
                  "Value #C" = "Total";
                  "Value #D" = "Usage %";
                  host = "Host";
                  mountpoint = "Mountpoint";
                };
              };
            }
          ];
          type = "table";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 31;
          };
          id = 14;
          panels = [ ];
          title = "Correlated Subsystem Curves";
          type = "row";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              max = 100;
              min = 0;
              unit = "percent";
            };
            overrides = [
              {
                matcher = {
                  id = "byName";
                  options = "user";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "green";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "system";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "blue";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "iowait";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "orange";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "steal";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "softirq";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "purple";
                      mode = "fixed";
                    };
                  }
                ];
              }
              {
                matcher = {
                  id = "byName";
                  options = "irq";
                };
                properties = [
                  {
                    id = "color";
                    value = {
                      fixedColor = "yellow";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 0;
            y = 32;
          };
          id = 15;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "avg by (mode) (rate(node_cpu_seconds_total{host=\"$host\",mode!=\"idle\"}[$__rate_interval])) * 100";
              format = "time_series";
              instant = false;
              legendFormat = "{{mode}}";
              range = true;
              refId = "A";
            }
          ];
          title = "CPU Utilization by Mode";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "normal";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              min = 0;
              unit = "bytes";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/Total/";
                };
                properties = [
                  {
                    id = "custom.lineStyle";
                    value = {
                      dash = [
                        6
                        4
                      ];
                      fill = "dash";
                    };
                  }
                  {
                    id = "custom.fillOpacity";
                    value = 0;
                  }
                  {
                    id = "custom.stacking";
                    value = {
                      group = "A";
                      mode = "none";
                    };
                  }
                  {
                    id = "color";
                    value = {
                      fixedColor = "red";
                      mode = "fixed";
                    };
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 12;
            y = 32;
          };
          id = 16;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemTotal_bytes{host=\"$host\"} - node_memory_MemFree_bytes{host=\"$host\"} - node_memory_Buffers_bytes{host=\"$host\"} - node_memory_Cached_bytes{host=\"$host\"} - node_memory_SReclaimable_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Used";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_Cached_bytes{host=\"$host\"} + node_memory_SReclaimable_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Cached";
              range = true;
              refId = "B";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_Buffers_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Buffers";
              range = true;
              refId = "C";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "sum(node_memory_MemTotal_bytes{host=\"$host\"})";
              format = "time_series";
              instant = false;
              legendFormat = "Total RAM";
              range = true;
              refId = "D";
            }
          ];
          title = "Memory Breakdown";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "Bps";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/Write/";
                };
                properties = [
                  {
                    id = "custom.transform";
                    value = "negative-Y";
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 0;
            y = 39;
          };
          id = 17;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_disk_read_bytes_total{host=\"$host\",device!~\"dm-.*|loop.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} Read";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_disk_written_bytes_total{host=\"$host\",device!~\"dm-.*|loop.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} Write";
              range = true;
              refId = "B";
            }
          ];
          title = "Disk I/O Throughput (Read / -Write)";
          type = "timeseries";
        }
        {
          datasource = {
            type = "prometheus";
            uid = "prometheus";
          };
          fieldConfig = {
            defaults = {
              color = {
                mode = "palette-classic";
              };
              custom = {
                axisBorderShow = false;
                axisCenteredZero = false;
                axisColorMode = "text";
                axisPlacement = "auto";
                barAlignment = 0;
                drawStyle = "line";
                fillOpacity = 15;
                gradientMode = "opacity";
                hideFrom = {
                  legend = false;
                  tooltip = false;
                  viz = false;
                };
                lineInterpolation = "smooth";
                lineStyle = {
                  fill = "solid";
                };
                lineWidth = 2;
                pointSize = 5;
                scaleDistribution = {
                  type = "linear";
                };
                showPoints = "never";
                spanNulls = false;
                stacking = {
                  group = "A";
                  mode = "none";
                };
                thresholdsStyle = {
                  mode = "off";
                };
              };
              unit = "Bps";
            };
            overrides = [
              {
                matcher = {
                  id = "byRegexp";
                  options = "/TX/";
                };
                properties = [
                  {
                    id = "custom.transform";
                    value = "negative-Y";
                  }
                ];
              }
            ];
          };
          gridPos = {
            h = 7;
            w = 12;
            x = 12;
            y = 39;
          };
          id = 18;
          options = {
            legend = {
              calcs = [
                "mean"
                "max"
                "lastNotNull"
              ];
              displayMode = "table";
              placement = "bottom";
              showLegend = true;
            };
            tooltip = {
              mode = "multi";
              sort = "desc";
            };
          };
          targets = [
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_network_receive_bytes_total{host=\"$host\",device!~\"lo|veth.*|docker.*|br-.*|podman.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} RX";
              range = true;
              refId = "A";
            }
            {
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              expr = "rate(node_network_transmit_bytes_total{host=\"$host\",device!~\"lo|veth.*|docker.*|br-.*|podman.*\"}[$__rate_interval])";
              format = "time_series";
              instant = false;
              legendFormat = "{{device}} TX";
              range = true;
              refId = "B";
            }
          ];
          title = "Network Throughput (RX / -TX)";
          type = "timeseries";
        }
        {
          collapsed = false;
          gridPos = {
            h = 1;
            w = 24;
            x = 0;
            y = 46;
          };
          id = 19;
          panels = [ ];
          title = "Synchronized Journald Logs";
          type = "row";
        }
        {
          datasource = {
            type = "victoriametrics-logs-datasource";
            uid = "victorialogs";
          };
          gridPos = {
            h = 12;
            w = 24;
            x = 0;
            y = 47;
          };
          id = 20;
          options = {
            dedupStrategy = "none";
            enableLogDetails = true;
            prettifyLogMessage = true;
            showCommonLabels = false;
            showLabels = true;
            showTime = true;
            sortOrder = "Descending";
            wrapLogMessage = true;
          };
          targets = [
            {
              datasource = {
                type = "victoriametrics-logs-datasource";
                uid = "victorialogs";
              };
              editorMode = "code";
              expr = "job:=\"systemd-journal\" host:=\"$host\" $search";
              legendFormat = "";
              maxLines = 500;
              queryType = "instant";
              refId = "A";
            }
          ];
          title = "Journald Stream Locked to Window ($host)";
          type = "logs";
        }
      ];
      refresh = "off";
      schemaVersion = 39;
      tags = [
        "nixconf"
        "forensics"
        "time-machine"
        "incident"
        "logs"
      ];
      templating = {
        list = [
          {
            current = { };
            datasource = {
              type = "prometheus";
              uid = "prometheus";
            };
            definition = "label_values(node_uname_info, host)";
            hide = 0;
            includeAll = false;
            label = "Host";
            multi = false;
            name = "host";
            query = {
              qryType = 1;
              query = "label_values(node_uname_info, host)";
            };
            refresh = 2;
            sort = 1;
            type = "query";
          }
          {
            current = {
              selected = true;
              text = "";
              value = "";
            };
            hide = 0;
            label = "Log Filter (LogsQL)";
            name = "search";
            options = [
              {
                selected = true;
                text = "";
                value = "";
              }
            ];
            query = "";
            type = "textbox";
          }
        ];
      };
      time = {
        from = "now-6h";
        to = "now";
      };
      timezone = "browser";
      title = "Incident Time Machine";
      uid = "nixconf-time-machine";
    };
    title = "Incident Time Machine";
  };
};
  monitoring.exporters = {
  blackbox = {
    enable = false;
  };
  cadvisor = {
    dockerOnly = false;
    enable = true;
  };
  extraBlocks = { };
  process = {
    enable = true;
  };
  unix = {
    collectors = [
      "cpu"
      "cpufreq"
      "hwmon"
      "meminfo"
      "loadavg"
      "netdev"
      "sockstat"
      "systemd"
      "textfile"
      "uname"
      "vmstat"
      "time"
      "processes"
      "boottime"
      "stat"
      "filesystem"
      "diskstats"
      "pressure"
      "textfile"
    ];
    enable = true;
    setCollectors = [ ];
    textfileDirectory = "/var/lib/alloy/textfile";
  };
};
  monitoring.extraGrafanaSettings = {
  users = {
    home_page = "/d/nixconf-fleet-overview";
  };
};
  monitoring.logs = {
  files = { };
  journal = {
    enable = true;
    labels = { };
    maxAge = "12h";
    stages = [ ];
    units = [
      "agy-remote-control.service"
      "copyparty.service"
      "podman-uchiyomi.service"
      "podman-uchiyomi-flaresolverr.service"
      "podman-uchiyomi-suwayomi.service"
      "agy-hub.service"
      "ttyd-web.service"
      "vaultwarden.service"
      "host-snapshot-gdrive.service"
      "host-snapshot-hbox.service"
      "restic-backups-agy-gdrive-host.service"
      "restic-backups-agy-hbox-host.service"
      "restic-backups-authelia-gdrive-host.service"
      "restic-backups-authelia-hbox-host.service"
      "restic-backups-copyparty-gdrive-host.service"
      "restic-backups-copyparty-hbox-host.service"
      "restic-backups-grafana-gdrive-host.service"
      "restic-backups-grafana-hbox-host.service"
      "restic-backups-lldap-gdrive-host.service"
      "restic-backups-lldap-hbox-host.service"
      "restic-backups-telemetry-gdrive-host.service"
      "restic-backups-telemetry-hbox-host.service"
      "restic-backups-uchiyomi-gdrive-host.service"
      "restic-backups-uchiyomi-hbox-host.service"
      "restic-backups-vaultwarden-b2-shared.service"
      "restic-backups-vaultwarden-gdrive-shared.service"
      "restic-backups-vaultwarden-hbox-shared.service"
      "restic-restore-authelia.service"
      "restic-restore-copyparty.service"
      "restic-restore-grafana.service"
      "restic-restore-lldap.service"
      "restic-restore-uchiyomi.service"
      "restic-restore-vaultwarden.service"
      "ntfy-sh.service"
      "victoriametrics.service"
      "victorialogs.service"
      "alertmanager.service"
      "grafana.service"
      "vmalert-metrics.service"
      "vmalert-logs.service"
      "authelia-main.service"
      "lldap.service"
      "caddy.service"
      "sshd.service"
      "nix-daemon.service"
      "nix-gc.service"
      "cachix-watch-store-agent.service"
      "_type.service"
      "contents.service"
    ];
  };
};
  monitoring.rules = {
  authelia = {
    backend = "metrics";
    enable = true;
    interval = "1m";
    rules = [
      {
        alert = "AutheliaDown";
        annotations = {
          description = "Authelia metrics scrape target on {{ $labels.host }} has been down for 2 minutes.";
          summary = "Authelia SSO metrics endpoint unreachable";
        };
        expr = "up{job=\"authelia\"} == 0";
        for = "2m";
        labels = {
          severity = "critical";
        };
        record = null;
      }
    ];
  };
  authelia-logs = {
    backend = "logs";
    enable = true;
    interval = "1m";
    rules = [
      {
        alert = "AutheliaRepeatedAuthFailures";
        annotations = {
          description = "More than 10 failed login or ban events occurred in Authelia over 5 minutes.";
          summary = "Repeated authentication failures in Authelia on {{ $labels.host }}";
        };
        expr = "_time:5m unit:=\"authelia-main.service\" _msg:~\"(?i)(unsuccessful authentication|banned)\" | stats by (host) count() as failures | filter failures:>10";
        for = "1m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
    ];
  };
  caddy = {
    backend = "metrics";
    enable = true;
    interval = "1m";
    rules = [
      {
        alert = "EndpointProbeFailed";
        annotations = {
          description = "Blackbox probe {{ $labels.vhost }} from {{ $labels.host }} has been failing for 3 minutes.";
          summary = "Health probe failed for {{ $labels.vhost }} ({{ $labels.host }})";
        };
        expr = "probe_success == 0";
        for = "3m";
        labels = {
          severity = "critical";
        };
        record = null;
      }
      {
        alert = "CaddyHttp5xxSpike";
        annotations = {
          description = "Caddy is returning more than 0.1 5xx responses/sec for {{ $labels.host }}.";
          summary = "Elevated 5xx responses on {{ $labels.host }}";
        };
        expr = "sum by (host) (rate(caddy_http_request_duration_seconds_count{code=~\"5..\"}[5m])) > 0.1";
        for = "5m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
    ];
  };
  disk = {
    backend = "metrics";
    enable = true;
    interval = "1m";
    rules = [
      {
        alert = "FilesystemSpaceLow";
        annotations = {
          description = "Less than 15% free space remains on {{ $labels.mountpoint }} ({{ $labels.host }}).";
          summary = "Filesystem {{ $labels.mountpoint }} low on space ({{ $labels.host }})";
        };
        expr = "(node_filesystem_avail_bytes{fstype!~\"tmpfs|ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var|tmp|run|sys|proc|dev).*\"} / node_filesystem_size_bytes{fstype!~\"tmpfs|ramfs|squashfs|overlay|fuse\\\\..*\",mountpoint!~\"/(etc|nix|var|tmp|run|sys|proc|dev).*\"}) < 0.15";
        for = "10m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
      {
        alert = "RootTmpfsSpaceLow";
        annotations = {
          description = "Less than 15% free space remains on root tmpfs / ({{ $labels.host }}).";
          summary = "Ephemeral root tmpfs low on space ({{ $labels.host }})";
        };
        expr = "(node_filesystem_avail_bytes{mountpoint=\"/\",fstype=\"tmpfs\"} / node_filesystem_size_bytes{mountpoint=\"/\",fstype=\"tmpfs\"}) < 0.15";
        for = "5m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
    ];
  };
  host = {
    backend = "metrics";
    enable = true;
    interval = "1m";
    rules = [
      {
        alert = "SystemdUnitFailed";
        annotations = {
          description = "Unit {{ $labels.name }} on {{ $labels.host }} has been in failed state for more than 2 minutes.";
          summary = "Systemd unit {{ $labels.name }} failed on {{ $labels.host }}";
        };
        expr = "node_systemd_unit_state{state=\"failed\"} == 1";
        for = "2m";
        labels = {
          severity = "critical";
        };
        record = null;
      }
      {
        alert = "HostHighMemoryUsage";
        annotations = {
          description = "Memory utilization on {{ $labels.host }} is above 90%.";
          summary = "High memory usage on {{ $labels.host }}";
        };
        expr = "((node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / clamp_min(node_memory_MemTotal_bytes, 1)) * 100 > 90";
        for = "5m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
      {
        alert = "HostHighCpuLoad";
        annotations = {
          description = "5-minute load per CPU core exceeded 2.0 on {{ $labels.host }}.";
          summary = "High 5m load average on {{ $labels.host }}";
        };
        expr = "node_load5 / count without (cpu, mode) (node_cpu_seconds_total{mode=\"idle\"}) > 2";
        for = "10m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
    ];
  };
  persistence = {
    backend = "metrics";
    enable = true;
    interval = "1m";
    rules = [
      {
        alert = "PersistVolumeSpaceCritical";
        annotations = {
          description = "Less than 10% free space remains on /persist on {{ $labels.host }}.";
          summary = "Low free space on /persist on {{ $labels.host }}";
        };
        expr = "(node_filesystem_avail_bytes{mountpoint=\"/persist\"} / node_filesystem_size_bytes{mountpoint=\"/persist\"}) < 0.10";
        for = "5m";
        labels = {
          severity = "critical";
        };
        record = null;
      }
    ];
  };
  resources = {
    backend = "metrics";
    enable = true;
    interval = "1m";
    rules = [
      {
        alert = "CgroupMemoryNearLimit";
        annotations = {
          description = "Unit {{ $labels.unit }} in {{ $labels.slice }} slice has used more than 85% of its memory limit for 5 minutes.";
          summary = "Cgroup {{ $labels.unit }} near memory limit on {{ $labels.host }}";
        };
        expr = "(container_memory_working_set_bytes{unit!=\"\"} / (container_spec_memory_limit_bytes{unit!=\"\"} > 0)) * 100 > 85";
        for = "5m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
      {
        alert = "CgroupCpuThrottled";
        annotations = {
          description = "Unit {{ $labels.unit }} experienced CPU CFS quota throttling on over 25% of periods for 10 minutes.";
          summary = "Cgroup {{ $labels.unit }} CPU-throttled on {{ $labels.host }}";
        };
        expr = "(rate(container_cpu_cfs_throttled_periods_total{unit!=\"\"}[5m]) / clamp_min(rate(container_cpu_cfs_periods_total{unit!=\"\"}[5m]), 1)) * 100 > 25";
        for = "10m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
      {
        alert = "HostMemoryPressureHigh";
        annotations = {
          description = "Memory PSI stall rate on {{ $labels.host }} exceeded 10% over 5 minutes.";
          summary = "Elevated Linux PSI memory pressure on {{ $labels.host }}";
        };
        expr = "rate(node_pressure_memory_stalled_seconds_total[5m]) * 100 > 10";
        for = "5m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
      {
        alert = "CgroupOomKilled";
        annotations = {
          description = "Kernel or cgroup OOM kill recorded for {{ $labels.unit }} on {{ $labels.host }}.";
          summary = "Cgroup OOM event in {{ $labels.unit }} on {{ $labels.host }}";
        };
        expr = "increase(container_oom_events_total{unit!=\"\"}[5m]) > 0";
        for = null;
        labels = {
          severity = "critical";
        };
        record = null;
      }
      {
        alert = "LocalVolumeSpaceWarning";
        annotations = {
          description = "Declarative volume {{ $labels.volume }} ({{ $labels.mountpoint }}, {{ $labels.mode }}) has less than 20% free space remaining on {{ $labels.host }}.";
          summary = "Local volume {{ $labels.volume }} low on free space on {{ $labels.host }}";
        };
        expr = "(((node_filesystem_avail_bytes / clamp_min(node_filesystem_size_bytes, 1)) * 100) * on (host, mountpoint) group_left (volume, mode) (nixconf_disk_volume_size_bytes{mountpoint!=\"reserved-unmounted\"} * 0 + 1)) < 20";
        for = "10m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
      {
        alert = "LocalVolumeSpaceCritical";
        annotations = {
          description = "Declarative volume {{ $labels.volume }} ({{ $labels.mountpoint }}, {{ $labels.mode }}) has less than 10% free space remaining on {{ $labels.host }}.";
          summary = "Local volume {{ $labels.volume }} critically full on {{ $labels.host }}";
        };
        expr = "(((node_filesystem_avail_bytes / clamp_min(node_filesystem_size_bytes, 1)) * 100) * on (host, mountpoint) group_left (volume, mode) (nixconf_disk_volume_size_bytes{mountpoint!=\"reserved-unmounted\"} * 0 + 1)) < 10";
        for = "5m";
        labels = {
          severity = "critical";
        };
        record = null;
      }
      {
        alert = "LocalVolumeInodesLow";
        annotations = {
          description = "Declarative volume {{ $labels.volume }} ({{ $labels.mountpoint }}) has less than 15% free inodes remaining on {{ $labels.host }}.";
          summary = "Local volume {{ $labels.volume }} low on free inodes on {{ $labels.host }}";
        };
        expr = "(((node_filesystem_files_free / clamp_min(node_filesystem_files, 1)) * 100) * on (host, mountpoint) group_left (volume, mode) (nixconf_disk_volume_size_bytes{mountpoint!=\"reserved-unmounted\"} * 0 + 1)) < 15";
        for = "10m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
      {
        alert = "RemoteStorageBudgetWarning";
        annotations = {
          description = "Storage slice {{ $labels.slice }} exceeded its warning percentage threshold.";
          summary = "Remote storage slice {{ $labels.slice }} approaching budget on {{ $labels.host }}";
        };
        expr = "(nixconf_storage_budget_used_bytes / clamp_min(nixconf_storage_budget_limit_bytes, 1)) * 100 > nixconf_storage_budget_warn_percent";
        for = "15m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
      {
        alert = "RemoteStorageBudgetExceeded";
        annotations = {
          description = "Storage slice {{ $labels.slice }} usage is at or above its configured maxSize budget.";
          summary = "Remote storage slice {{ $labels.slice }} exceeded budget on {{ $labels.host }}";
        };
        expr = "nixconf_storage_budget_used_bytes >= nixconf_storage_budget_limit_bytes";
        for = "5m";
        labels = {
          severity = "critical";
        };
        record = null;
      }
    ];
  };
  resources-logs = {
    backend = "logs";
    enable = true;
    interval = "1m";
    rules = [
      {
        alert = "OomKillDetected";
        annotations = {
          description = "Kernel OOM killer or systemd-oomd terminated a process on {{ $labels.host }}.";
          summary = "OOM kill detected in journal on {{ $labels.host }}";
        };
        expr = "_time:5m job:=\"systemd-journal\" _msg:~\"(?i)(Out of memory: Killed process|systemd-oomd.*Killed)\" | stats by (host) count() as kills | filter kills:>0";
        for = null;
        labels = {
          severity = "critical";
        };
        record = null;
      }
    ];
  };
  restic = {
    backend = "metrics";
    enable = true;
    interval = "1m";
    rules = [
      {
        alert = "ResticBackupUnitFailed";
        annotations = {
          description = "Restic backup or restore unit {{ $labels.name }} entered failed state on {{ $labels.host }}.";
          summary = "Restic unit {{ $labels.name }} failed on {{ $labels.host }}";
        };
        expr = "node_systemd_unit_state{name=~\"restic-(backups|restore)-.*\\\\.service\",state=\"failed\"} == 1";
        for = "1m";
        labels = {
          severity = "critical";
        };
        record = null;
      }
      {
        alert = "ResticBackupStale";
        annotations = {
          description = "Restic backup timer {{ $labels.name }} has not triggered in over 48 hours on {{ $labels.host }}. It may be permanently deferred due to missing AC power.";
          summary = "Restic backup timer {{ $labels.name }} is stale on {{ $labels.host }}";
        };
        expr = "time() - (node_systemd_timer_last_trigger_seconds{name=~\"restic-backups-.*\\\\.timer\"} or vector(time())) > 2 * 24 * 3600";
        for = "1h";
        labels = {
          severity = "warning";
        };
        record = null;
      }
    ];
  };
  snapshot = {
    backend = "metrics";
    enable = true;
    interval = "1m";
    rules = [
      {
        alert = "HostSnapshotUnitFailed";
        annotations = {
          description = "Btrfs/restic host snapshot unit {{ $labels.name }} failed on {{ $labels.host }}.";
          summary = "Host snapshot unit {{ $labels.name }} failed on {{ $labels.host }}";
        };
        expr = "node_systemd_unit_state{name=~\"host-snapshot-.*\\\\.service\",state=\"failed\"} == 1";
        for = "1m";
        labels = {
          severity = "critical";
        };
        record = null;
      }
      {
        alert = "HostSnapshotStale";
        annotations = {
          description = "Host snapshot timer {{ $labels.name }} has not triggered in over 48 hours on {{ $labels.host }}. It may be permanently deferred due to missing AC power.";
          summary = "Host snapshot timer {{ $labels.name }} is stale on {{ $labels.host }}";
        };
        expr = "time() - (node_systemd_timer_last_trigger_seconds{name=~\"host-snapshot-.*\\\\.timer\"} or vector(time())) > 2 * 24 * 3600";
        for = "1h";
        labels = {
          severity = "warning";
        };
        record = null;
      }
    ];
  };
  ssh = {
    backend = "logs";
    enable = true;
    interval = "5m";
    rules = [
      {
        alert = "SshInvalidAuthSpike";
        annotations = {
          description = "More than 15 failed SSH authentication attempts in 5 minutes on {{ $labels.host }}.";
          summary = "SSH failed authentication spike on {{ $labels.host }}";
        };
        expr = "_time:5m unit:=\"sshd.service\" _msg:~\"(?i)(invalid user|failed password|connection closed by authenticating user)\" | stats by (host) count() as failures | filter failures:>15";
        for = "1m";
        labels = {
          severity = "warning";
        };
        record = null;
      }
    ];
  };
};
};
```

</details>


<details>
<summary><code><a href="../contracts/resources.md">resources</a></code></summary>

**Configures options**: `resources.oom`, `resources.profile`, `resources.storageBudgets`, `resources.tiers`, `resources.volumes`

```nix
# modules/hosts/astrolabe/resources.nix
...
3: astrolabe-resources = {config, ...}: let
...
6: services.uchiyomi-server.resources.tier = "media";
...
8: resources = {
9: profile = "server";
10: # VPS relies solely on zram; disable swapKill to avoid false-positive kills under compressed swap pressure.
11: oom.swapKill = false;
...
```

</details>


<details>
<summary><code><a href="../contracts/reverse-proxy.md">reverse-proxy</a></code></summary>

**Configures options**: `reverse-proxy.domain`

```nix
# modules/hosts/astrolabe/services.nix
...
20: reverse-proxy.domain = "adje.app";
...
```

</details>

## Installation & Deployment

### Track 1: Remote Automated Deployment via `nixos-anywhere`

For headless cloud instances or network-accessible hosts booted into a live environment:

```bash
# 1. Obtain and verify SSH root access to target IP
ssh root@<TARGET-IP>

# 2. Deploy system, format partitions via Disko, and copy SOPS secret key
nix run github:nix-community/nixos-anywhere -- \
  --flake .#astrolabe \
  --copy-secret /path/to/host-key.txt /persist/sops-nix/key.txt \
  root@<TARGET-IP>
```

### Track 2: Local Host Installation (NixOS Live ISO)

For bare-metal physical hosts booted from a standard NixOS Live ISO USB drive:

```bash
# 1. Elevate to root in the live environment
sudo -i

# 2. Clone repository to live memory
git clone https://github.com/LW-54/nixconf /tmp/nixconf
cd /tmp/nixconf

# 3. Format disk and mount partitions declaratively via Disko
nix --extra-experimental-features 'nix-command flakes' run github:nix-community/disko -- \
  --mode zap_create_mount \
  --flake .#astrolabe

# 4. Provision SOPS age secret key on mounted persistence volume
install -d -m 0700 /mnt/persist/sops-nix
install -m 0400 /path/to/host-key.txt /mnt/persist/sops-nix/key.txt

# 5. Install NixOS to target disk and reboot
nixos-install --flake .#astrolabe --no-root-passwd
reboot
```

### Track 3: Host Maintenance & System Rebuilds

```bash
# Rebuild and switch locally on the host
sudo nixos-rebuild switch --flake .#astrolabe

# Remote deployment over SSH from a management machine
nixos-rebuild switch --flake .#astrolabe --target-host root@<TARGET-IP>
```
