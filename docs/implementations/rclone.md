# Implementation: `rclone`

Declarative multi-provider storage mounts, crypt/union tiering, and rclone configuration provisioning.

[← Back to Implementations Documentation](README.md) | [← Back to Main README](../../README.md)

- **Implementation**: `rclone`
- **Fulfills Contract**: [`storage`](../contracts/storage.md)
- **Definition File**: [`modules/implementations/rclone/default.nix`](../../modules/implementations/rclone/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__astrolabe["nixosModule/astrolabe"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_disk["nixosModule/astrolabe-disk"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_hardware["nixosModule/astrolabe-hardware"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_packages["nixosModule/astrolabe-packages"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_services["nixosModule/astrolabe-services"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_system["nixosModule/astrolabe-system"]:::defaultNode
    urn__nixconf__ast__module__copyparty["nixosModule/copyparty"]:::defaultNode
    urn__nixconf__ast__module__impermanence["nixosModule/impermanence"]:::defaultNode
    urn__nixconf__ast__module__rclone["nixosModule/rclone"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__snapshot["nixosModule/snapshot"]:::defaultNode
    urn__nixconf__ast__module__sops["nixosModule/sops"]:::defaultNode
    urn__nixconf__ast__module__uchiyomi["nixosModule/uchiyomi"]:::defaultNode
    urn__nixconf__ast__module__x240["nixosModule/x240"]:::defaultNode
    urn__nixconf__ast__module__x240_desktop["nixosModule/x240-desktop"]:::defaultNode
    urn__nixconf__ast__module__x240_desktop_features["nixosModule/x240-desktop-features"]:::defaultNode
    urn__nixconf__ast__module__x240_disk["nixosModule/x240-disk"]:::defaultNode
    urn__nixconf__ast__module__x240_hardware["nixosModule/x240-hardware"]:::defaultNode
    urn__nixconf__ast__module__x240_packages["nixosModule/x240-packages"]:::defaultNode
    urn__nixconf__ast__module__x240_system["nixosModule/x240-system"]:::defaultNode
    urn__nixconf__ast__module__x240_system_features["nixosModule/x240-system-features"]:::defaultNode
    urn__nixconf__ast__option__backup_destinations[/"backup.destinations"/]:::optNode
    urn__nixconf__ast__option__backup_enable[/"backup.enable"/]:::optNode
    urn__nixconf__ast__option__backup_exclude[/"backup.exclude"/]:::optNode
    urn__nixconf__ast__option__backup_paths[/"backup.paths"/]:::optNode
    urn__nixconf__ast__option__backup_units[/"backup.units"/]:::optNode
    urn__nixconf__ast__option__persistence_directories[/"persistence.directories"/]:::optNode
    urn__nixconf__ast__option__persistence_enable[/"persistence.enable"/]:::optNode
    urn__nixconf__ast__option__persistence_files[/"persistence.files"/]:::optNode
    urn__nixconf__ast__option__persistence_users[/"persistence.users"/]:::optNode
    urn__nixconf__ast__option__secrets_defaultFile[/"secrets.defaultFile"/]:::optNode
    urn__nixconf__ast__option__secrets_enable[/"secrets.enable"/]:::optNode
    urn__nixconf__ast__option__secrets_files[/"secrets.files"/]:::optNode
    urn__nixconf__ast__option__secrets_placeholder[/"secrets.placeholder"/]:::optNode
    urn__nixconf__ast__option__secrets_templates[/"secrets.templates"/]:::optNode
    urn__nixconf__ast__option__storage_activeSlices[/"storage.activeSlices"/]:::optNode
    urn__nixconf__ast__option__storage_driftCheck_enable[/"storage.driftCheck.enable"/]:::optNode
    urn__nixconf__ast__option__storage_driftCheck_onCalendar[/"storage.driftCheck.onCalendar"/]:::optNode
    urn__nixconf__ast__option__storage_drivers[/"storage.drivers"/]:::optNode
    urn__nixconf__ast__option__storage_enable[/"storage.enable"/]:::optNode
    urn__nixconf__ast__option__storage_mounts[/"storage.mounts"/]:::optNode
    urn__nixconf__ast__option__storage_providers[/"storage.providers"/]:::optNode
    urn__nixconf__ast__option__storage_slices[/"storage.slices"/]:::optNode
    urn__nixconf__ast__type__backup_destination[["backup.destination"]]:::typeNode
    urn__nixconf__ast__type__backup_destinationOverride[["backup.destinationOverride"]]:::typeNode
    urn__nixconf__ast__type__backup_retention[["backup.retention"]]:::typeNode
    urn__nixconf__ast__type__backup_schedule[["backup.schedule"]]:::typeNode
    urn__nixconf__ast__type__backup_unit[["backup.unit"]]:::typeNode
    urn__nixconf__ast__type__persistence_entries[["persistence.entries"]]:::typeNode
    urn__nixconf__ast__type__persistence_user[["persistence.user"]]:::typeNode
    urn__nixconf__ast__type__secrets_secret[["secrets.secret"]]:::typeNode
    urn__nixconf__ast__type__secrets_template[["secrets.template"]]:::typeNode
    urn__nixconf__ast__type__storage_driver[["storage.driver"]]:::typeNode
    urn__nixconf__ast__type__storage_mount[["storage.mount"]]:::typeNode
    urn__nixconf__ast__type__storage_provider[["storage.provider"]]:::typeNode
    urn__nixconf__ast__type__storage_slice[["storage.slice"]]:::typeNode
    urn__nixconf__drv__devShell__storage_admin["devShell/storage-admin"]:::devShellNode
    urn__nixconf__drv__package__storage[("package/storage")]:::pkgNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__eval__configuration__x240(["nixosConfiguration/x240"]):::hostNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__storage{{"storage"}}:::contractNode
    urn__nixconf__onto__contract__wayland{{"wayland"}}:::contractNode
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
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__noctalia("noctalia"):::featureNode
    urn__nixconf__onto__feature__snapshot("snapshot"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__tack("tack"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__uchiyomi("uchiyomi"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__feature__vivaldi("vivaldi"):::featureNode
    urn__nixconf__onto__feature__vscode("vscode"):::featureNode
    urn__nixconf__onto__feature__wifi_eduroam("wifi-eduroam"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__rclone["rclone"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode
    urn__nixconf__onto__implementation__uwsm["uwsm"]:::implNode

    urn__nixconf__ast__module__astrolabe_services -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__astrolabe_services -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__copyparty -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__storage_enable
    urn__nixconf__ast__module__copyparty -.->|writes| urn__nixconf__ast__option__storage_mounts
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__rclone -.->|reads| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__ast__module__rclone -.->|reads| urn__nixconf__ast__option__storage_enable
    urn__nixconf__ast__module__rclone -.->|reads| urn__nixconf__ast__option__storage_mounts
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__sops -.->|writes| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_enable
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_units
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__storage_enable
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__storage_mounts
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
    urn__nixconf__ast__option__persistence_directories -.->|typedBy| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_files -.->|typedBy| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_users -.->|typedBy| urn__nixconf__ast__type__persistence_user
    urn__nixconf__ast__option__secrets_files -.->|typedBy| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__ast__option__secrets_files -.->|typedBy| urn__nixconf__ast__type__secrets_template
    urn__nixconf__ast__option__secrets_templates -.->|typedBy| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__ast__option__secrets_templates -.->|typedBy| urn__nixconf__ast__type__secrets_template
    urn__nixconf__ast__option__storage_drivers -.->|typedBy| urn__nixconf__ast__type__storage_driver
    urn__nixconf__ast__option__storage_drivers -.->|typedBy| urn__nixconf__ast__type__storage_mount
    urn__nixconf__ast__option__storage_drivers -.->|typedBy| urn__nixconf__ast__type__storage_provider
    urn__nixconf__ast__option__storage_drivers -.->|typedBy| urn__nixconf__ast__type__storage_slice
    urn__nixconf__ast__option__storage_mounts -.->|typedBy| urn__nixconf__ast__type__storage_driver
    urn__nixconf__ast__option__storage_mounts -.->|typedBy| urn__nixconf__ast__type__storage_mount
    urn__nixconf__ast__option__storage_mounts -.->|typedBy| urn__nixconf__ast__type__storage_provider
    urn__nixconf__ast__option__storage_mounts -.->|typedBy| urn__nixconf__ast__type__storage_slice
    urn__nixconf__ast__option__storage_providers -.->|typedBy| urn__nixconf__ast__type__storage_driver
    urn__nixconf__ast__option__storage_providers -.->|typedBy| urn__nixconf__ast__type__storage_mount
    urn__nixconf__ast__option__storage_providers -.->|typedBy| urn__nixconf__ast__type__storage_provider
    urn__nixconf__ast__option__storage_providers -.->|typedBy| urn__nixconf__ast__type__storage_slice
    urn__nixconf__ast__option__storage_slices -.->|typedBy| urn__nixconf__ast__type__storage_driver
    urn__nixconf__ast__option__storage_slices -.->|typedBy| urn__nixconf__ast__type__storage_mount
    urn__nixconf__ast__option__storage_slices -.->|typedBy| urn__nixconf__ast__type__storage_provider
    urn__nixconf__ast__option__storage_slices -.->|typedBy| urn__nixconf__ast__type__storage_slice
    urn__nixconf__drv__devShell__storage_admin -->|dependsOn| urn__nixconf__drv__package__storage
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__copyparty
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__rclone
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__snapshot
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__rclone
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_desktop_features
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_disk
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_packages
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_system
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_system_features
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
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_enable
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_files
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__option__persistence_users
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__onto__contract__persistence -->|declares| urn__nixconf__ast__type__persistence_user
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_defaultFile
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_enable
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_files
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__type__secrets_template
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__option__storage_activeSlices
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__option__storage_driftCheck_enable
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__option__storage_driftCheck_onCalendar
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__option__storage_drivers
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__option__storage_enable
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__option__storage_mounts
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__option__storage_providers
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__option__storage_slices
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__type__storage_driver
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__type__storage_mount
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__type__storage_provider
    urn__nixconf__onto__contract__storage -->|declares| urn__nixconf__ast__type__storage_slice
    urn__nixconf__onto__contract__storage -->|outputs| urn__nixconf__drv__devShell__storage_admin
    urn__nixconf__onto__contract__storage -->|outputs| urn__nixconf__drv__package__storage
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__bitwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__copyparty -->|outputs| urn__nixconf__ast__module__copyparty
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__copyparty -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__feature__direnv -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__docker -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__dolphin -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__foot -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -.->|consumes| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__noctalia -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__snapshot -->|outputs| urn__nixconf__ast__module__snapshot
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__snapshot -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -->|outputs| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vivaldi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__wifi_eduroam -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__eval__configuration__astrolabe
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__copyparty
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__snapshot
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__uchiyomi
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__rclone
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_desktop_features
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_disk
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_packages
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_system
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__ast__module__x240_system_features
    urn__nixconf__onto__host__x240 -->|outputs| urn__nixconf__eval__configuration__x240
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__wayland
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
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__tack
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__wifi_eduroam
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__rclone
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__uwsm
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy ==>|implements| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__impermanence -->|outputs| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence ==>|implements| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__rclone -->|outputs| urn__nixconf__ast__module__rclone
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__rclone -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__rclone ==>|implements| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__implementation__restic -->|outputs| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__storage
    urn__nixconf__onto__implementation__restic ==>|implements| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__ast__module__sops
    urn__nixconf__onto__implementation__sops -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops ==>|implements| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__uwsm ==>|implements| urn__nixconf__onto__contract__wayland


    click urn__nixconf__ast__module__astrolabe href "../modules/astrolabe.md" "astrolabe"
    click urn__nixconf__ast__module__astrolabe_disk href "../modules/astrolabe-disk.md" "astrolabe-disk"
    click urn__nixconf__ast__module__astrolabe_hardware href "../modules/astrolabe-hardware.md" "astrolabe-hardware"
    click urn__nixconf__ast__module__astrolabe_packages href "../modules/astrolabe-packages.md" "astrolabe-packages"
    click urn__nixconf__ast__module__astrolabe_services href "../modules/astrolabe-services.md" "astrolabe-services"
    click urn__nixconf__ast__module__astrolabe_system href "../modules/astrolabe-system.md" "astrolabe-system"
    click urn__nixconf__ast__module__copyparty href "../modules/copyparty.md" "copyparty"
    click urn__nixconf__ast__module__impermanence href "../modules/impermanence.md" "impermanence"
    click urn__nixconf__ast__module__rclone href "../modules/rclone.md" "rclone"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__snapshot href "../modules/snapshot.md" "snapshot"
    click urn__nixconf__ast__module__sops href "../modules/sops.md" "sops"
    click urn__nixconf__ast__module__uchiyomi href "../modules/uchiyomi.md" "uchiyomi"
    click urn__nixconf__ast__module__x240 href "../modules/x240.md" "x240"
    click urn__nixconf__ast__module__x240_desktop href "../modules/x240-desktop.md" "x240-desktop"
    click urn__nixconf__ast__module__x240_desktop_features href "../modules/x240-desktop-features.md" "x240-desktop-features"
    click urn__nixconf__ast__module__x240_disk href "../modules/x240-disk.md" "x240-disk"
    click urn__nixconf__ast__module__x240_hardware href "../modules/x240-hardware.md" "x240-hardware"
    click urn__nixconf__ast__module__x240_packages href "../modules/x240-packages.md" "x240-packages"
    click urn__nixconf__ast__module__x240_system href "../modules/x240-system.md" "x240-system"
    click urn__nixconf__ast__module__x240_system_features href "../modules/x240-system-features.md" "x240-system-features"
    click urn__nixconf__ast__option__backup_destinations href "../contracts/backup.md" "backup.destinations"
    click urn__nixconf__ast__option__backup_enable href "../contracts/backup.md" "backup.enable"
    click urn__nixconf__ast__option__backup_exclude href "../contracts/backup.md" "backup.exclude"
    click urn__nixconf__ast__option__backup_paths href "../contracts/backup.md" "backup.paths"
    click urn__nixconf__ast__option__backup_units href "../contracts/backup.md" "backup.units"
    click urn__nixconf__ast__option__persistence_directories href "../contracts/persistence.md" "persistence.directories"
    click urn__nixconf__ast__option__persistence_enable href "../contracts/persistence.md" "persistence.enable"
    click urn__nixconf__ast__option__persistence_files href "../contracts/persistence.md" "persistence.files"
    click urn__nixconf__ast__option__persistence_users href "../contracts/persistence.md" "persistence.users"
    click urn__nixconf__ast__option__secrets_defaultFile href "../contracts/secrets.md" "secrets.defaultFile"
    click urn__nixconf__ast__option__secrets_enable href "../contracts/secrets.md" "secrets.enable"
    click urn__nixconf__ast__option__secrets_files href "../contracts/secrets.md" "secrets.files"
    click urn__nixconf__ast__option__secrets_placeholder href "../contracts/secrets.md" "secrets.placeholder"
    click urn__nixconf__ast__option__secrets_templates href "../contracts/secrets.md" "secrets.templates"
    click urn__nixconf__ast__option__storage_activeSlices href "../contracts/storage.md" "storage.activeSlices"
    click urn__nixconf__ast__option__storage_driftCheck_enable href "../contracts/storage.md" "storage.driftCheck.enable"
    click urn__nixconf__ast__option__storage_driftCheck_onCalendar href "../contracts/storage.md" "storage.driftCheck.onCalendar"
    click urn__nixconf__ast__option__storage_drivers href "../contracts/storage.md" "storage.drivers"
    click urn__nixconf__ast__option__storage_enable href "../contracts/storage.md" "storage.enable"
    click urn__nixconf__ast__option__storage_mounts href "../contracts/storage.md" "storage.mounts"
    click urn__nixconf__ast__option__storage_providers href "../contracts/storage.md" "storage.providers"
    click urn__nixconf__ast__option__storage_slices href "../contracts/storage.md" "storage.slices"
    click urn__nixconf__ast__type__backup_destination href "../contracts/backup.md" "backup.destination"
    click urn__nixconf__ast__type__backup_destinationOverride href "../contracts/backup.md" "backup.destinationOverride"
    click urn__nixconf__ast__type__backup_retention href "../contracts/backup.md" "backup.retention"
    click urn__nixconf__ast__type__backup_schedule href "../contracts/backup.md" "backup.schedule"
    click urn__nixconf__ast__type__backup_unit href "../contracts/backup.md" "backup.unit"
    click urn__nixconf__ast__type__persistence_entries href "../contracts/persistence.md" "persistence.entries"
    click urn__nixconf__ast__type__persistence_user href "../contracts/persistence.md" "persistence.user"
    click urn__nixconf__ast__type__secrets_secret href "../contracts/secrets.md" "secrets.secret"
    click urn__nixconf__ast__type__secrets_template href "../contracts/secrets.md" "secrets.template"
    click urn__nixconf__ast__type__storage_driver href "../contracts/storage.md" "storage.driver"
    click urn__nixconf__ast__type__storage_mount href "../contracts/storage.md" "storage.mount"
    click urn__nixconf__ast__type__storage_provider href "../contracts/storage.md" "storage.provider"
    click urn__nixconf__ast__type__storage_slice href "../contracts/storage.md" "storage.slice"
    click urn__nixconf__drv__devShell__storage_admin href "../devshells.md#storage-admin" "storage-admin"
    click urn__nixconf__drv__package__storage href "../packages.md#storage" "storage"
    click urn__nixconf__eval__configuration__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__eval__configuration__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__contract__backup href "../contracts/backup.md" "backup"
    click urn__nixconf__onto__contract__persistence href "../contracts/persistence.md" "persistence"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "../contracts/secrets.md" "secrets"
    click urn__nixconf__onto__contract__storage href "../contracts/storage.md" "storage"
    click urn__nixconf__onto__contract__wayland href "../contracts/wayland.md" "wayland"
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
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__noctalia href "../features/noctalia.md" "noctalia"
    click urn__nixconf__onto__feature__snapshot href "../features/snapshot.md" "snapshot"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__tack href "../features/tack.md" "tack"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__uchiyomi href "../features/uchiyomi.md" "uchiyomi"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__feature__vivaldi href "../features/vivaldi.md" "vivaldi"
    click urn__nixconf__onto__feature__vscode href "../features/vscode.md" "vscode"
    click urn__nixconf__onto__feature__wifi_eduroam href "../features/wifi-eduroam.md" "wifi-eduroam"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__caddy href "caddy.md" "caddy"
    click urn__nixconf__onto__implementation__hjem href "hjem.md" "hjem"
    click urn__nixconf__onto__implementation__impermanence href "impermanence.md" "impermanence"
    click urn__nixconf__onto__implementation__lw href "lw.md" "lw"
    click urn__nixconf__onto__implementation__rclone href "rclone.md" "rclone"
    click urn__nixconf__onto__implementation__restic href "restic.md" "restic"
    click urn__nixconf__onto__implementation__sops href "sops.md" "sops"
    click urn__nixconf__onto__implementation__uwsm href "uwsm.md" "uwsm"

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
| [`rclone`](../modules/rclone.md) | Declarative multi-provider storage mounts, crypt/union tiering, and rclone configuration provisioning. | [More →](../modules/rclone.md) |

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).
- [`x240`](../hosts/x240.md): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Consumed Contracts

Capability contracts configured by this implementation:

<details>
<summary><code><a href="../contracts/backup.md">backup</a></code></summary>

**Configures options**: `backup.exclude`

```nix
# modules/implementations/rclone/default.nix
...
60: backup.exclude = ["/var/cache/rclone"];
...
```

</details>


<details>
<summary><code><a href="../contracts/persistence.md">persistence</a></code></summary>

**Configures options**: `persistence.directories`

```nix
# modules/implementations/rclone/default.nix
...
59: persistence.directories = ["/var/cache/rclone"];
...
```

</details>


<details>
<summary><code><a href="../contracts/secrets.md">secrets</a></code></summary>

**Configures options**: `secrets.files`, `secrets.templates`

```nix
# modules/implementations/rclone/default.nix
...
50: secrets = {
51: files = state.secretFileAttrs;
52: 
53: templates."rclone.conf" = {
...
```

</details>
