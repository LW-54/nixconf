# Contract: `backup`

Declarative multi-provider backup contract separating per-provider schedules/retention, host vs shared repository scopes, per-service units, and boot-time most-recent auto-restore.

[← Back to Contracts Documentation](README.md) | [← Back to Main README](../../README.md)

- **Contract**: `backup`
- **Definition File**: [`modules/contracts/backup/default.nix`](../../modules/contracts/backup/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__agy["nixosModule/agy"]:::defaultNode
    urn__nixconf__ast__module__agy_config["nixosModule/agy-config"]:::defaultNode
    urn__nixconf__ast__module__agy_hub["nixosModule/agy-hub"]:::defaultNode
    urn__nixconf__ast__module__agy_remote_control["nixosModule/agy-remote-control"]:::defaultNode
    urn__nixconf__ast__module__alloy["nixosModule/alloy"]:::defaultNode
    urn__nixconf__ast__module__authelia["nixosModule/authelia"]:::defaultNode
    urn__nixconf__ast__module__cgroups["nixosModule/cgroups"]:::defaultNode
    urn__nixconf__ast__module__copyparty["nixosModule/copyparty"]:::defaultNode
    urn__nixconf__ast__module__grafana["nixosModule/grafana"]:::defaultNode
    urn__nixconf__ast__module__rclone["nixosModule/rclone"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__uchiyomi["nixosModule/uchiyomi"]:::defaultNode
    urn__nixconf__ast__module__vaultwarden["nixosModule/vaultwarden"]:::defaultNode
    urn__nixconf__ast__module__x240["nixosModule/x240"]:::defaultNode
    urn__nixconf__ast__module__x240_desktop["nixosModule/x240-desktop"]:::defaultNode
    urn__nixconf__ast__module__x240_disk["nixosModule/x240-disk"]:::defaultNode
    urn__nixconf__ast__module__x240_hardware["nixosModule/x240-hardware"]:::defaultNode
    urn__nixconf__ast__module__x240_resources["nixosModule/x240-resources"]:::defaultNode
    urn__nixconf__ast__module__x240_system["nixosModule/x240-system"]:::defaultNode
    urn__nixconf__ast__option__backup_destinations[/"backup.destinations"/]:::optNode
    urn__nixconf__ast__option__backup_enable[/"backup.enable"/]:::optNode
    urn__nixconf__ast__option__backup_exclude[/"backup.exclude"/]:::optNode
    urn__nixconf__ast__option__backup_paths[/"backup.paths"/]:::optNode
    urn__nixconf__ast__option__backup_units[/"backup.units"/]:::optNode
    urn__nixconf__ast__type__backup_destination[["backup.destination"]]:::typeNode
    urn__nixconf__ast__type__backup_destinationOverride[["backup.destinationOverride"]]:::typeNode
    urn__nixconf__ast__type__backup_retention[["backup.retention"]]:::typeNode
    urn__nixconf__ast__type__backup_schedule[["backup.schedule"]]:::typeNode
    urn__nixconf__ast__type__backup_unit[["backup.unit"]]:::typeNode
    urn__nixconf__drv__devShell__gemini_api["devShell/gemini-api"]:::devShellNode
    urn__nixconf__drv__package__agy[("package/agy")]:::pkgNode
    urn__nixconf__drv__package__agy_api[("package/agy-api")]:::pkgNode
    urn__nixconf__drv__package__antigravity[("package/antigravity")]:::pkgNode
    urn__nixconf__drv__package__antigravity_ide[("package/antigravity-ide")]:::pkgNode
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
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__tack("tack"):::featureNode
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
    urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
    urn__nixconf__onto__implementation__grafana["grafana"]:::implNode
    urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__rclone["rclone"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode
    urn__nixconf__onto__implementation__uwsm["uwsm"]:::implNode

    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__agy -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__agy -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy_config -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy_hub -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__agy_hub -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__agy_hub -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__agy_remote_control -->|dependsOn| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__alloy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__alloy -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__alloy -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__cgroups -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__cgroups -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__authelia
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__x240 -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__x240 -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__x240_resources -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__alloy
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__backup_units
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
    urn__nixconf__drv__devShell__gemini_api -->|dependsOn| urn__nixconf__drv__package__agy_api
    urn__nixconf__eval__configuration__x240 -->|dependsOn| urn__nixconf__drv__package__agy
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__agy
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__alloy
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__cgroups
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__rclone
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_disk
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_resources
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_system
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
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_config
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_hub
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__ast__module__agy_remote_control
    urn__nixconf__onto__feature__antigravity -->|outputs| urn__nixconf__drv__devShell__gemini_api
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
    urn__nixconf__onto__feature__bitwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__copyparty -->|outputs| urn__nixconf__ast__module__copyparty
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__feature__direnv -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__disko -.->|consumes| urn__nixconf__onto__contract__monitoring
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
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__noctalia -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__secrets
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
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__tack
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__uchiyomi
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__authelia
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
    click urn__nixconf__ast__module__authelia href "../modules/authelia.md" "authelia"
    click urn__nixconf__ast__module__cgroups href "../modules/cgroups.md" "cgroups"
    click urn__nixconf__ast__module__copyparty href "../modules/copyparty.md" "copyparty"
    click urn__nixconf__ast__module__grafana href "../modules/grafana.md" "grafana"
    click urn__nixconf__ast__module__rclone href "../modules/rclone.md" "rclone"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__uchiyomi href "../modules/uchiyomi.md" "uchiyomi"
    click urn__nixconf__ast__module__vaultwarden href "../modules/vaultwarden.md" "vaultwarden"
    click urn__nixconf__ast__module__x240 href "../modules/x240.md" "x240"
    click urn__nixconf__ast__module__x240_desktop href "../modules/x240-desktop.md" "x240-desktop"
    click urn__nixconf__ast__module__x240_disk href "../modules/x240-disk.md" "x240-disk"
    click urn__nixconf__ast__module__x240_hardware href "../modules/x240-hardware.md" "x240-hardware"
    click urn__nixconf__ast__module__x240_resources href "../modules/x240-resources.md" "x240-resources"
    click urn__nixconf__ast__module__x240_system href "../modules/x240-system.md" "x240-system"
    click urn__nixconf__ast__option__backup_destinations href "backup.md" "backup.destinations"
    click urn__nixconf__ast__option__backup_enable href "backup.md" "backup.enable"
    click urn__nixconf__ast__option__backup_exclude href "backup.md" "backup.exclude"
    click urn__nixconf__ast__option__backup_paths href "backup.md" "backup.paths"
    click urn__nixconf__ast__option__backup_units href "backup.md" "backup.units"
    click urn__nixconf__ast__type__backup_destination href "backup.md" "backup.destination"
    click urn__nixconf__ast__type__backup_destinationOverride href "backup.md" "backup.destinationOverride"
    click urn__nixconf__ast__type__backup_retention href "backup.md" "backup.retention"
    click urn__nixconf__ast__type__backup_schedule href "backup.md" "backup.schedule"
    click urn__nixconf__ast__type__backup_unit href "backup.md" "backup.unit"
    click urn__nixconf__drv__devShell__gemini_api href "../devshells.md#gemini-api" "gemini-api"
    click urn__nixconf__drv__package__agy href "../packages.md#agy" "agy"
    click urn__nixconf__drv__package__agy_api href "../packages.md#agy-api" "agy-api"
    click urn__nixconf__drv__package__antigravity href "../packages.md#antigravity" "antigravity"
    click urn__nixconf__drv__package__antigravity_ide href "../packages.md#antigravity-ide" "antigravity-ide"
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
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__tack href "../features/tack.md" "tack"
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
| [`backup`](../modules/backup.md) | Declarative multi-provider backup contract separating per-provider schedules/retention, host vs shared repository scopes, per-service units, and boot-time most-recent auto-restore. | [More →](../modules/backup.md) |

### Library Helpers

| Symbol | Type | Description | Docs |
| :--- | :--- | :--- | :--- |
| [`mkConfig`](../lib/backup.md#mkConfig) | `backup.mkConfig :: AttrSet -> AttrSet` | Auto-derived configuration binding helper for the 'backup' contract. | [More →](../lib/backup.md#mkConfig) |
| [`mkOption`](../lib/backup.md#mkOption) | `backup.mkOption :: AttrSet -> AttrSet` | Auto-derived option constructor for the 'backup' contract. | [More →](../lib/backup.md#mkOption) |
| [`retentionToPruneOpts`](../lib/backup.md#retentionToPruneOpts) | `retentionToPruneOpts :: Retention -> [String]` | Convert a structured retention policy attrset into `restic forget --prune` CLI flags. | [More →](../lib/backup.md#retentionToPruneOpts) |
| [`scheduleToTimerConfig`](../lib/backup.md#scheduleToTimerConfig) | `scheduleToTimerConfig :: Schedule -> Attrs` | Convert a structured backup schedule attrset into systemd `timerConfig` attributes. | [More →](../lib/backup.md#scheduleToTimerConfig) |

### Custom Types

- `destination`: submodule
- `destinationOverride`: submodule
- `retention`: submodule
- `schedule`: submodule
- `unit`: submodule

## Option Schema Definitions

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `backup.destinations` | `attribute set of (submodule)` | `{ }` | Named backup destinations parameterized by backing storage slice, `host`/`shared` scope, priority, schedule, and per-tier retention. |
| `backup.enable` | `boolean` | `false` | Whether to enable declarative backup configuration. |
| `backup.exclude` | `list of string` | `[ ]` | Global exclusion patterns applied across backup units. |
| `backup.paths` | `list of string` | `[ ]` | Host-level filesystem paths included in synthetic `system` backups when not claimed by any declared `backup.units` entry. |
| `backup.units` | `attribute set of (submodule)` | `{ }` | Logical backup units with independent paths, scopes, destination overrides, and boot-time most-recent auto-restore configuration. |

## Fulfilling Implementations

Providers satisfying the `backup` contract capability:

| Implementation | Description | Definition | Docs |
| :--- | :--- | :--- | :--- |
| [`restic`](../implementations/restic.md) | Multi-provider restic backup implementation backed by rclone storage slices, per-provider schedules/retention, and boot-time most-recent auto-restore. | [`modules/implementations/restic/default.nix`](../../modules/implementations/restic/default.nix) | [More →](../implementations/restic.md) |

## Contract Consumers

Modules and instances configuring options under the `backup` contract capability:

### Hosts

<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

**Configures options**: `backup.enable`, `backup.units`

```nix
# modules/hosts/x240/system.nix
...
56: backup = {
57: enable = true;
58: units.lw = {
59: paths = [
...
```

</details>



### Implementations

<details>
<summary><code><a href="../implementations/alloy.md">alloy</a></code></summary>

**Configures options**: `backup.exclude`

```nix
config = {
  backup.exclude = ...;
};
```

</details>


<details>
<summary><code><a href="../implementations/authelia.md">authelia</a></code></summary>

**Configures options**: `backup.paths`, `backup.units`

```nix
# modules/implementations/authelia/default.nix
...
382: backup = lib.mkIf (config.backup.enable or false) {
383: paths =
384: ["/var/lib/authelia-main"]
385: ++ lib.optional cfg.directory.enable "/var/lib/lldap";
...
```

</details>


<details>
<summary><code><a href="../implementations/cgroups.md">cgroups</a></code></summary>

**Configures options**: `backup.exclude`

```nix
config = {
  backup.exclude = ...;
};
```

</details>


<details>
<summary><code><a href="../implementations/grafana.md">grafana</a></code></summary>

**Configures options**: `backup.exclude`, `backup.paths`, `backup.units`

```nix
config = {
  backup.exclude = ...;
  backup.paths = ...;
  backup.units = ...;
};
```

</details>


<details>
<summary><code><a href="../implementations/rclone.md">rclone</a></code></summary>

**Configures options**: `backup.exclude`

```nix
# modules/implementations/rclone/default.nix
...
61: backup.exclude = ["/var/cache/rclone"];
...
```

</details>


<details>
<summary><code><a href="../implementations/restic.md">restic</a></code></summary>

**Configures options**: `backup.exclude`

```nix
# modules/implementations/restic/default.nix
...
30: backupLib = self.lib.backup;
...
58: backup.exclude = cacheDirs;
...
```

</details>



### Features

<details>
<summary><code><a href="../features/antigravity.md">antigravity</a></code></summary>

**Configures options**: `backup.units`

```nix
# modules/features/antigravity/default.nix
...
56: (lib.mkIf (config.backup.enable or false) {
57: backup.units.agy = {
58: enable = lib.mkDefault true;
59: paths = ["/home/${backupUser}/.gemini"];
...
57: backup.units.agy = {
58: enable = lib.mkDefault true;
59: paths = ["/home/${backupUser}/.gemini"];
60: exclude = [
...
```

</details>


<details>
<summary><code><a href="../features/copyparty.md">copyparty</a></code></summary>

**Configures options**: `backup.enable`, `backup.exclude`, `backup.paths`, `backup.units`

```nix
# modules/features/copyparty.nix
...
321: (self.lib.backup.mkConfig {inherit config cfg;})
...
```

</details>


<details>
<summary><code><a href="../features/uchiyomi.md">uchiyomi</a></code></summary>

**Configures options**: `backup.enable`, `backup.exclude`, `backup.paths`, `backup.units`

```nix
# modules/features/uchiyomi.nix
...
289: (self.lib.backup.mkConfig {inherit config cfg;})
...
```

</details>


<details>
<summary><code><a href="../features/vaultwarden.md">vaultwarden</a></code></summary>

**Configures options**: `backup.enable`, `backup.exclude`, `backup.paths`, `backup.units`

```nix
# modules/features/vaultwarden.nix
...
57: (self.lib.backup.mkConfig {inherit config cfg;})
...
```

</details>
