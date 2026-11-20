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
  urn__nixconf__ast__module__antigravity_ide["nixosModule/antigravity-ide"]:::defaultNode
    urn__nixconf__ast__module__astrolabe["nixosModule/astrolabe"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_disk["nixosModule/astrolabe-disk"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_hardware["nixosModule/astrolabe-hardware"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_resources["nixosModule/astrolabe-resources"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_services["nixosModule/astrolabe-services"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_system["nixosModule/astrolabe-system"]:::defaultNode
    urn__nixconf__ast__module__authelia["nixosModule/authelia"]:::defaultNode
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
    urn__nixconf__ast__module__hjem["nixosModule/hjem"]:::defaultNode
    urn__nixconf__ast__module__impermanence["nixosModule/impermanence"]:::defaultNode
    urn__nixconf__ast__module__labwc["nixosModule/labwc"]:::defaultNode
    urn__nixconf__ast__module__locale["nixosModule/locale"]:::defaultNode
    urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__module__nix["nixosModule/nix"]:::defaultNode
    urn__nixconf__ast__module__noctalia["nixosModule/noctalia"]:::defaultNode
    urn__nixconf__ast__module__ntfy["nixosModule/ntfy"]:::defaultNode
    urn__nixconf__ast__module__rclone["nixosModule/rclone"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__snapshot["nixosModule/snapshot"]:::defaultNode
    urn__nixconf__ast__module__sops["nixosModule/sops"]:::defaultNode
    urn__nixconf__ast__module__ssh["nixosModule/ssh"]:::defaultNode
    urn__nixconf__ast__module__ttyd["nixosModule/ttyd"]:::defaultNode
    urn__nixconf__ast__module__uchiyomi["nixosModule/uchiyomi"]:::defaultNode
    urn__nixconf__ast__module__vaultwarden["nixosModule/vaultwarden"]:::defaultNode
    urn__nixconf__ast__module__victoria["nixosModule/victoria"]:::defaultNode
    urn__nixconf__ast__module__vivaldi["nixosModule/vivaldi"]:::defaultNode
    urn__nixconf__ast__module__vscode["nixosModule/vscode"]:::defaultNode
    urn__nixconf__ast__module__wifi_eduroam["nixosModule/wifi-eduroam"]:::defaultNode
    urn__nixconf__ast__module__x240["nixosModule/x240"]:::defaultNode
    urn__nixconf__ast__module__x240_resources["nixosModule/x240-resources"]:::defaultNode
    urn__nixconf__ast__module__x240_system["nixosModule/x240-system"]:::defaultNode
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
    urn__nixconf__ast__option__monitoring_agent[/"monitoring.agent"/]:::optNode
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
    urn__nixconf__drv__devShell__github_cli["devShell/github-cli"]:::devShellNode
    urn__nixconf__drv__package__git[("package/git")]:::pkgNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__eval__configuration__x240(["nixosConfiguration/x240"]):::hostNode
    urn__nixconf__onto__contract__monitoring{{"monitoring"}}:::contractNode
    urn__nixconf__onto__contract__resources{{"resources"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__feature__copyparty("copyparty"):::featureNode
    urn__nixconf__onto__feature__disko("disko"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__ntfy("ntfy"):::featureNode
    urn__nixconf__onto__feature__snapshot("snapshot"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__uchiyomi("uchiyomi"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__implementation__authelia["authelia"]:::implNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__rclone["rclone"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode
    urn__nixconf__onto__implementation__victoria["victoria"]:::implNode

    urn__nixconf__ast__module__antigravity_ide -.->|flowsTo| urn__nixconf__ast__module__hjem
    urn__nixconf__ast__module__antigravity_ide -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__antigravity_ide -.->|writes| urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__antigravity_ide -.->|writes| urn__nixconf__ast__option__persistence_users
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
    urn__nixconf__ast__module__bw -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__bw -.->|writes| urn__nixconf__ast__option__persistence_users
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
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__rclone
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
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__victoria
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
    urn__nixconf__ast__module__disko -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__disko -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__disko -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__docker -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__docker -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__docker -.->|flowsTo| urn__nixconf__ast__module__victoria
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
    urn__nixconf__ast__module__hjem -.->|reads| urn__nixconf__ast__option__home_shared
    urn__nixconf__ast__module__hjem -.->|reads| urn__nixconf__ast__option__home_users
    urn__nixconf__ast__module__impermanence -.->|flowsTo| urn__nixconf__ast__module__victoria
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
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__noctalia -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__noctalia -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__victoria
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
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__rclone -.->|reads| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__ast__module__rclone -.->|reads| urn__nixconf__ast__option__storage_enable
    urn__nixconf__ast__module__rclone -.->|reads| urn__nixconf__ast__option__storage_mounts
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__rclone
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
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__sops -.->|writes| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_services
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__monitoring_watchedUnits
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__victoria
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
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__victoria
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
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__victoria
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
    urn__nixconf__ast__module__vivaldi -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vivaldi -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__vscode -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vscode -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__wifi_eduroam -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__wifi_eduroam -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__wifi_eduroam -.->|writes| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__x240 -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__x240 -.->|writes| urn__nixconf__ast__option__monitoring_dashboards
    urn__nixconf__ast__module__x240 -.->|writes| urn__nixconf__ast__option__monitoring_exporters
    urn__nixconf__ast__module__x240 -.->|writes| urn__nixconf__ast__option__monitoring_extraGrafanaSettings
    urn__nixconf__ast__module__x240 -.->|writes| urn__nixconf__ast__option__monitoring_logs
    urn__nixconf__ast__module__x240 -.->|writes| urn__nixconf__ast__option__monitoring_rules
    urn__nixconf__ast__module__x240_resources -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__x240_resources -.->|writes| urn__nixconf__ast__option__resources_disk
    urn__nixconf__ast__module__x240_resources -.->|writes| urn__nixconf__ast__option__resources_profile
    urn__nixconf__ast__module__x240_resources -.->|writes| urn__nixconf__ast__option__resources_units
    urn__nixconf__ast__module__x240_resources -.->|writes| urn__nixconf__ast__option__resources_volumes
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__victoria
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__monitoring_agent
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__drv__devShell__default -->|dependsOn| urn__nixconf__drv__package__git
    urn__nixconf__drv__devShell__github_cli -->|dependsOn| urn__nixconf__drv__package__git
    urn__nixconf__eval__configuration__astrolabe -->|dependsOn| urn__nixconf__drv__package__git
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_resources
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__authelia
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__caddy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__cgroups
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__copyparty
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__disko
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__git
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__locale
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ntfy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__rclone
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__snapshot
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ttyd
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__victoria
    urn__nixconf__eval__configuration__x240 -->|dependsOn| urn__nixconf__drv__package__git
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__antigravity_ide
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
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__noctalia
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__rclone
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__victoria
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__vivaldi
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__vscode
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__wifi_eduroam
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_resources
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_system
    urn__nixconf__onto__contract__monitoring -->|declares| urn__nixconf__ast__option__monitoring_agent
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
    urn__nixconf__onto__feature__copyparty -->|outputs| urn__nixconf__ast__module__copyparty
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__disko -->|outputs| urn__nixconf__ast__module__disko
    urn__nixconf__onto__feature__disko -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__git -->|outputs| urn__nixconf__ast__module__git
    urn__nixconf__onto__feature__git -->|outputs| urn__nixconf__drv__devShell__github_cli
    urn__nixconf__onto__feature__git -->|outputs| urn__nixconf__drv__package__git
    urn__nixconf__onto__feature__locale -->|outputs| urn__nixconf__ast__module__locale
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
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__resources
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
    urn__nixconf__onto__implementation__impermanence -->|outputs| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__lw -->|outputs| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__rclone -->|outputs| urn__nixconf__ast__module__rclone
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__restic -->|outputs| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__ast__module__sops
    urn__nixconf__onto__implementation__victoria -->|outputs| urn__nixconf__ast__module__victoria
    urn__nixconf__onto__implementation__victoria -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__victoria -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__victoria -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__victoria ==>|implements| urn__nixconf__onto__contract__monitoring


    click urn__nixconf__ast__module__antigravity_ide href "../modules/antigravity-ide.md" "antigravity-ide"
    click urn__nixconf__ast__module__astrolabe href "../modules/astrolabe.md" "astrolabe"
    click urn__nixconf__ast__module__astrolabe_disk href "../modules/astrolabe-disk.md" "astrolabe-disk"
    click urn__nixconf__ast__module__astrolabe_hardware href "../modules/astrolabe-hardware.md" "astrolabe-hardware"
    click urn__nixconf__ast__module__astrolabe_resources href "../modules/astrolabe-resources.md" "astrolabe-resources"
    click urn__nixconf__ast__module__astrolabe_services href "../modules/astrolabe-services.md" "astrolabe-services"
    click urn__nixconf__ast__module__astrolabe_system href "../modules/astrolabe-system.md" "astrolabe-system"
    click urn__nixconf__ast__module__authelia href "../modules/authelia.md" "authelia"
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
    click urn__nixconf__ast__module__hjem href "../modules/hjem.md" "hjem"
    click urn__nixconf__ast__module__impermanence href "../modules/impermanence.md" "impermanence"
    click urn__nixconf__ast__module__labwc href "../modules/labwc.md" "labwc"
    click urn__nixconf__ast__module__locale href "../modules/locale.md" "locale"
    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__ast__module__nix href "../modules/nix.md" "nix"
    click urn__nixconf__ast__module__noctalia href "../modules/noctalia.md" "noctalia"
    click urn__nixconf__ast__module__ntfy href "../modules/ntfy.md" "ntfy"
    click urn__nixconf__ast__module__rclone href "../modules/rclone.md" "rclone"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__snapshot href "../modules/snapshot.md" "snapshot"
    click urn__nixconf__ast__module__sops href "../modules/sops.md" "sops"
    click urn__nixconf__ast__module__ssh href "../modules/ssh.md" "ssh"
    click urn__nixconf__ast__module__ttyd href "../modules/ttyd.md" "ttyd"
    click urn__nixconf__ast__module__uchiyomi href "../modules/uchiyomi.md" "uchiyomi"
    click urn__nixconf__ast__module__vaultwarden href "../modules/vaultwarden.md" "vaultwarden"
    click urn__nixconf__ast__module__victoria href "../modules/victoria.md" "victoria"
    click urn__nixconf__ast__module__vivaldi href "../modules/vivaldi.md" "vivaldi"
    click urn__nixconf__ast__module__vscode href "../modules/vscode.md" "vscode"
    click urn__nixconf__ast__module__wifi_eduroam href "../modules/wifi-eduroam.md" "wifi-eduroam"
    click urn__nixconf__ast__module__x240 href "../modules/x240.md" "x240"
    click urn__nixconf__ast__module__x240_resources href "../modules/x240-resources.md" "x240-resources"
    click urn__nixconf__ast__module__x240_system href "../modules/x240-system.md" "x240-system"
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
    click urn__nixconf__ast__option__monitoring_agent href "../contracts/monitoring.md" "monitoring.agent"
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
    click urn__nixconf__drv__devShell__github_cli href "../devshells.md#github-cli" "github-cli"
    click urn__nixconf__drv__package__git href "../packages.md#git" "git"
    click urn__nixconf__eval__configuration__astrolabe href "astrolabe.md" "astrolabe"
    click urn__nixconf__eval__configuration__x240 href "x240.md" "x240"
    click urn__nixconf__onto__contract__monitoring href "../contracts/monitoring.md" "monitoring"
    click urn__nixconf__onto__contract__resources href "../contracts/resources.md" "resources"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__feature__copyparty href "../features/copyparty.md" "copyparty"
    click urn__nixconf__onto__feature__disko href "../features/disko.md" "disko"
    click urn__nixconf__onto__feature__git href "../features/git.md" "git"
    click urn__nixconf__onto__feature__locale href "../features/locale.md" "locale"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__ntfy href "../features/ntfy.md" "ntfy"
    click urn__nixconf__onto__feature__snapshot href "../features/snapshot.md" "snapshot"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__uchiyomi href "../features/uchiyomi.md" "uchiyomi"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__host__astrolabe href "astrolabe.md" "astrolabe"
    click urn__nixconf__onto__implementation__authelia href "../implementations/authelia.md" "authelia"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__cgroups href "../implementations/cgroups.md" "cgroups"
    click urn__nixconf__onto__implementation__impermanence href "../implementations/impermanence.md" "impermanence"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"
    click urn__nixconf__onto__implementation__rclone href "../implementations/rclone.md" "rclone"
    click urn__nixconf__onto__implementation__restic href "../implementations/restic.md" "restic"
    click urn__nixconf__onto__implementation__sops href "../implementations/sops.md" "sops"
    click urn__nixconf__onto__implementation__victoria href "../implementations/victoria.md" "victoria"

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
| [`persistence`](../contracts/persistence.md) | Declarative state preservation across ephemeral reboots for system and user directories. | [`impermanence`](../implementations/impermanence.md) | Ephemeral root filesystem with persistent state bind-mounts via Impermanence. | [More →](../contracts/persistence.md) |
| [`default-user`](../contracts/default-user.md) | Default primary user account identification, credentials, and configuration injection. | [`lw`](../implementations/lw.md) | Primary human user account orchestration and identity provisioning. | [More →](../contracts/default-user.md) |
| [`storage`](../contracts/storage.md) | Declarative multi-provider storage contract separating open driver definitions, logical providers, host/shared slices, and mount requests. | [`rclone`](../implementations/rclone.md) | Declarative multi-provider storage mounts, crypt/union tiering, and rclone configuration provisioning. | [More →](../contracts/storage.md) |
| [`backup`](../contracts/backup.md) | Declarative multi-provider backup contract separating per-provider schedules/retention, host vs shared repository scopes, per-service units, and boot-time most-recent auto-restore. | [`restic`](../implementations/restic.md) | Multi-provider restic backup implementation backed by rclone storage slices, per-provider schedules/retention, and boot-time most-recent auto-restore. | [More →](../contracts/backup.md) |
| [`secrets`](../contracts/secrets.md) | Declarative encrypted secrets provisioning, filesystem mounting, and permission management. | [`sops`](../implementations/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [More →](../contracts/secrets.md) |
| [`monitoring`](../contracts/monitoring.md) | Declarative metrics, logs, blackbox probing, alerting rules, and dashboard provisioning contract. | [`victoria`](../implementations/victoria.md) | Observability stack implementation using Grafana Alloy, VictoriaMetrics, VictoriaLogs, vmalert, Alertmanager, and Grafana. | [More →](../contracts/monitoring.md) |

## Enabled Features

The following system and desktop features are imported by `astrolabe`:

| Feature | Description | Outputs Used | Docs |
| :--- | :--- | :--- | :--- |
| [`copyparty`](../features/copyparty.md) | Self-hosted multi-protocol file server, resumable upload hub, and cloud storage browser via Copyparty. | [`copyparty`](../modules/copyparty.md) (module) | [More →](../features/copyparty.md) |
| [`disko`](../features/disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | [`disko`](../modules/disko.md) (module) | [More →](../features/disko.md) |
| [`git`](../features/git.md) | Git version control system, global/per-user configuration, and Bitwarden GitHub SSH/CLI shells. | [`git`](../modules/git.md) (module), [`git`](../packages.md#git) (package) | [More →](../features/git.md) |
| [`locale`](../features/locale.md) | System internationalization, time zone, and language locale configuration. | [`locale`](../modules/locale.md) (module) | [More →](../features/locale.md) |
| [`nix`](../features/nix.md) | Nix package manager daemon settings, binary caches, garbage collection, and nix-ld. | [`nix`](../modules/nix.md) (module) | [More →](../features/nix.md) |
| [`ntfy`](../features/ntfy.md) | Self-hosted push notification server (ntfy) with declarative admin credentials, metrics, probes, and Alertmanager wiring. | [`ntfy`](../modules/ntfy.md) (module) | [More →](../features/ntfy.md) |
| [`snapshot`](../features/snapshot.md) | Atomic local Btrfs read-only snapshots paired with deduplicated restic off-site host snapshots and manual CLI triggers. | [`snapshot`](../modules/snapshot.md) (module) | [More →](../features/snapshot.md) |
| [`ssh`](../features/ssh.md) | OpenSSH server daemon hardening, authorized key distribution, and master SSH key agent shell. | [`ssh`](../modules/ssh.md) (module) | [More →](../features/ssh.md) |
| [`ttyd`](../features/ttyd.md) | Web terminal server bridging browser sessions to system shells via ttyd. | [`ttyd`](../modules/ttyd.md) (module) | [More →](../features/ttyd.md) |
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
    self.nixosModules.victoria
    self.nixosModules.ntfy
    self.nixosModules.restic
    self.nixosModules.snapshot
    self.nixosModules.vaultwarden
    self.nixosModules.ttyd
    self.nixosModules.uchiyomi
    self.nixosModules.copyparty
  ];

  config = {
    reverse-proxy.domain = "adje.app";
    monitoring.server.enable = true;
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
    self.nixosModules.nix
    self.nixosModules.locale
    self.nixosModules.ssh
    self.nixosModules.git
  ];

  config = {
    networking.hostName = "astrolabe";
    environment.systemPackages = with pkgs; [
      nano
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
├── [dir]  ~lw/.cache/nix-index/
└── [dir]  ~lw/.cache/nix/

/persist/users/lw/data
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
| `standard.slice` | CPU:100, IO:100, MemHigh:75%, OOMKill:80%, Score:0 | — | `alertmanager.service`, `alloy.service`, `copyparty.service`, `grafana.service`, `ntfy-sh.service`, `ttyd-web.service`, `victorialogs.service`, `victoriametrics.service`, `vmalert-logs.service`, `vmalert-metrics.service` |
| `user.slice` | CPU:100, IO:100 | — | — |
| `media.slice` | CPU:60, IO:60, MemHigh:50%, MemMax:65%, OOMKill:70%, Score:200 | — | `podman-uchiyomi-flaresolverr.service`, `podman-uchiyomi-suwayomi.service`, `podman-uchiyomi.service` |
| `background.slice` | CPU:20, IO:20, MemHigh:80%, OOMKill:60%, Score:500 | — | `cachix-watch-store-agent.service`, `host-snapshot-gdrive.service`, `host-snapshot-hbox.service`, `nix-daemon.service`, `nix-gc.service`, `nix-optimise.service`, `resources-storage-budgets.service`, `restic-backups-authelia-gdrive-host.service`, `restic-backups-authelia-hbox-host.service`, `restic-backups-copyparty-gdrive-host.service`, `restic-backups-copyparty-hbox-host.service`, `restic-backups-grafana-gdrive-host.service`, `restic-backups-grafana-hbox-host.service`, `restic-backups-lldap-gdrive-host.service`, `restic-backups-lldap-hbox-host.service`, `restic-backups-telemetry-gdrive-host.service`, `restic-backups-telemetry-hbox-host.service`, `restic-backups-uchiyomi-gdrive-host.service`, `restic-backups-uchiyomi-hbox-host.service`, `restic-backups-vaultwarden-b2-shared.service`, `restic-backups-vaultwarden-gdrive-shared.service`, `restic-backups-vaultwarden-hbox-shared.service` |

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

**Configures options**: `monitoring.dashboards`, `monitoring.exporters`, `monitoring.extraGrafanaSettings`, `monitoring.logs`, `monitoring.rules`, `monitoring.server`

```nix
# modules/hosts/astrolabe/services.nix
...
19: monitoring.server.enable = true;
...
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
18: reverse-proxy.domain = "adje.app";
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
