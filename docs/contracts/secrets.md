# Contract: `secrets`

Declarative encrypted secrets provisioning, filesystem mounting, and permission management.

[← Back to Contracts Documentation](README.md) | [← Back to Main README](../../README.md)

- **Contract**: `secrets`
- **Definition File**: [`modules/contracts/secrets.nix`](../../modules/contracts/secrets.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__authelia["nixosModule/authelia"]:::defaultNode
    urn__nixconf__ast__module__grafana["nixosModule/grafana"]:::defaultNode
    urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__module__nix["nixosModule/nix"]:::defaultNode
    urn__nixconf__ast__module__ntfy["nixosModule/ntfy"]:::defaultNode
    urn__nixconf__ast__module__rclone["nixosModule/rclone"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__snapshot["nixosModule/snapshot"]:::defaultNode
    urn__nixconf__ast__module__sops["nixosModule/sops"]:::defaultNode
    urn__nixconf__ast__module__ssh["nixosModule/ssh"]:::defaultNode
    urn__nixconf__ast__module__wifi_eduroam["nixosModule/wifi-eduroam"]:::defaultNode
    urn__nixconf__ast__module__x240["nixosModule/x240"]:::defaultNode
    urn__nixconf__ast__module__x240_desktop["nixosModule/x240-desktop"]:::defaultNode
    urn__nixconf__ast__module__x240_disk["nixosModule/x240-disk"]:::defaultNode
    urn__nixconf__ast__module__x240_hardware["nixosModule/x240-hardware"]:::defaultNode
    urn__nixconf__ast__module__x240_resources["nixosModule/x240-resources"]:::defaultNode
    urn__nixconf__ast__module__x240_system["nixosModule/x240-system"]:::defaultNode
    urn__nixconf__ast__option__secrets_defaultFile[/"secrets.defaultFile"/]:::optNode
    urn__nixconf__ast__option__secrets_enable[/"secrets.enable"/]:::optNode
    urn__nixconf__ast__option__secrets_files[/"secrets.files"/]:::optNode
    urn__nixconf__ast__option__secrets_placeholder[/"secrets.placeholder"/]:::optNode
    urn__nixconf__ast__option__secrets_templates[/"secrets.templates"/]:::optNode
    urn__nixconf__ast__type__secrets_secret[["secrets.secret"]]:::typeNode
    urn__nixconf__ast__type__secrets_template[["secrets.template"]]:::typeNode
    urn__nixconf__drv__devShell__master_ssh["devShell/master-ssh"]:::devShellNode
    urn__nixconf__drv__devShell__sops_admin["devShell/sops-admin"]:::devShellNode
    urn__nixconf__drv__devShell__sops_host["devShell/sops-host"]:::devShellNode
    urn__nixconf__eval__configuration__x240(["nixosConfiguration/x240"]):::hostNode
    urn__nixconf__onto__contract__auth{{"auth"}}:::contractNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__default_user{{"default-user"}}:::contractNode
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
    urn__nixconf__onto__feature__snapshot("snapshot"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__tack("tack"):::featureNode
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

    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__authelia
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__grafana -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__grafana -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__lw -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__ntfy -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ntfy -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__rclone -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__rclone -.->|writes| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__rclone
    urn__nixconf__ast__module__snapshot -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__snapshot -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__sops -.->|writes| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__grafana
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__wifi_eduroam -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__wifi_eduroam -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__wifi_eduroam -.->|writes| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__x240_system -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__x240_system -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__option__secrets_files -.->|typedBy| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__ast__option__secrets_files -.->|typedBy| urn__nixconf__ast__type__secrets_template
    urn__nixconf__ast__option__secrets_templates -.->|typedBy| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__ast__option__secrets_templates -.->|typedBy| urn__nixconf__ast__type__secrets_template
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__rclone
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__wifi_eduroam
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_disk
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_resources
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__x240_system
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_defaultFile
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_enable
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_files
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_placeholder
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_templates
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__type__secrets_template
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__antigravity -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__bitwarden -.->|consumes| urn__nixconf__onto__contract__persistence
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
    urn__nixconf__onto__feature__vivaldi -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__wifi_eduroam -->|outputs| urn__nixconf__ast__module__wifi_eduroam
    urn__nixconf__onto__feature__wifi_eduroam -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__zed -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__zed -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__bitwarden
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
    urn__nixconf__onto__implementation__lw -->|outputs| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw ==>|implements| urn__nixconf__onto__contract__default_user
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
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__ast__module__sops
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__drv__devShell__sops_admin
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__drv__devShell__sops_host
    urn__nixconf__onto__implementation__sops -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops ==>|implements| urn__nixconf__onto__contract__secrets


    click urn__nixconf__ast__module__authelia href "../modules/authelia.md" "authelia"
    click urn__nixconf__ast__module__grafana href "../modules/grafana.md" "grafana"
    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__ast__module__nix href "../modules/nix.md" "nix"
    click urn__nixconf__ast__module__ntfy href "../modules/ntfy.md" "ntfy"
    click urn__nixconf__ast__module__rclone href "../modules/rclone.md" "rclone"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__snapshot href "../modules/snapshot.md" "snapshot"
    click urn__nixconf__ast__module__sops href "../modules/sops.md" "sops"
    click urn__nixconf__ast__module__ssh href "../modules/ssh.md" "ssh"
    click urn__nixconf__ast__module__wifi_eduroam href "../modules/wifi-eduroam.md" "wifi-eduroam"
    click urn__nixconf__ast__module__x240 href "../modules/x240.md" "x240"
    click urn__nixconf__ast__module__x240_desktop href "../modules/x240-desktop.md" "x240-desktop"
    click urn__nixconf__ast__module__x240_disk href "../modules/x240-disk.md" "x240-disk"
    click urn__nixconf__ast__module__x240_hardware href "../modules/x240-hardware.md" "x240-hardware"
    click urn__nixconf__ast__module__x240_resources href "../modules/x240-resources.md" "x240-resources"
    click urn__nixconf__ast__module__x240_system href "../modules/x240-system.md" "x240-system"
    click urn__nixconf__ast__option__secrets_defaultFile href "secrets.md" "secrets.defaultFile"
    click urn__nixconf__ast__option__secrets_enable href "secrets.md" "secrets.enable"
    click urn__nixconf__ast__option__secrets_files href "secrets.md" "secrets.files"
    click urn__nixconf__ast__option__secrets_placeholder href "secrets.md" "secrets.placeholder"
    click urn__nixconf__ast__option__secrets_templates href "secrets.md" "secrets.templates"
    click urn__nixconf__ast__type__secrets_secret href "secrets.md" "secrets.secret"
    click urn__nixconf__ast__type__secrets_template href "secrets.md" "secrets.template"
    click urn__nixconf__drv__devShell__master_ssh href "../devshells.md#master-ssh" "master-ssh"
    click urn__nixconf__drv__devShell__sops_admin href "../devshells.md#sops-admin" "sops-admin"
    click urn__nixconf__drv__devShell__sops_host href "../devshells.md#sops-host" "sops-host"
    click urn__nixconf__eval__configuration__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__contract__auth href "auth.md" "auth"
    click urn__nixconf__onto__contract__backup href "backup.md" "backup"
    click urn__nixconf__onto__contract__default_user href "default-user.md" "default-user"
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
    click urn__nixconf__onto__feature__snapshot href "../features/snapshot.md" "snapshot"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__tack href "../features/tack.md" "tack"
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
| [`secrets`](../modules/secrets.md) | Declarative encrypted secrets provisioning, filesystem mounting, and permission management. | [More →](../modules/secrets.md) |

### Library Helpers

| Symbol | Type | Description | Docs |
| :--- | :--- | :--- | :--- |
| [`mkConfig`](../lib/secrets.md#mkConfig) | `secrets.mkConfig :: AttrSet -> AttrSet` | Auto-derived configuration binding helper for the 'secrets' contract. | [More →](../lib/secrets.md#mkConfig) |
| [`mkOption`](../lib/secrets.md#mkOption) | `secrets.mkOption :: AttrSet -> AttrSet` | Auto-derived option constructor for the 'secrets' contract. | [More →](../lib/secrets.md#mkOption) |

### Custom Types

- `secret`: submodule
- `template`: submodule

## Option Schema Definitions

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `secrets.defaultFile` | `null or absolute path` | *null* | Default YAML/JSON file containing encrypted secrets for this host. Can be overridden on a per-secret basis by consumer features. |
| `secrets.enable` | `boolean` | `true` | Whether to enable system secrets management contract. |
| `secrets.files` | `attribute set of (submodule)` | `{ }` | Attribute set of declarative secret items required by system services. Mapped to the active secrets provider implementation (e.g. SOPS). |
| `secrets.placeholder` | `attribute set of string` | `{ }` | Map of secret names to placeholder tokens for safe interpolation inside `secrets.templates.<name>.content`. |
| `secrets.templates` | `attribute set of (submodule)` | `{ }` | Attribute set of rendered secret-interpolated configuration files managed by the active secrets provider implementation. |

## Fulfilling Implementations

Providers satisfying the `secrets` contract capability:

| Implementation | Description | Definition | Docs |
| :--- | :--- | :--- | :--- |
| [`sops`](../implementations/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [`modules/implementations/sops.nix`](../../modules/implementations/sops.nix) | [More →](../implementations/sops.md) |

## Contract Consumers

Modules and instances configuring options under the `secrets` contract capability:

### Hosts

<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

**Configures options**: `secrets.files`

```nix
# modules/hosts/x240/system.nix
...
42: secrets.files.telemetry-ingest-token = {
43: store = "services/monitoring";
44: key = "telemetryIngestToken";
45: owner = "alloy";
...
53: bearerTokenFile = config.secrets.files.telemetry-ingest-token.path;
...
```

</details>



### Implementations

<details>
<summary><code><a href="../implementations/authelia.md">authelia</a></code></summary>

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


<details>
<summary><code><a href="../implementations/grafana.md">grafana</a></code></summary>

**Configures options**: `secrets.files`

```nix
config = {
  secrets.files = ...;
};
```

</details>


<details>
<summary><code><a href="../implementations/lw.md">lw</a></code></summary>

**Configures options**: `secrets.files`

```nix
# modules/implementations/lw.nix
...
63: secrets.files.default-user-password-hash = {
64: file = ../../secrets/users/default.yaml;
65: key = "passwordHash";
66: neededForUsers = true;
...
94: hashedPasswordFile = config.secrets.files.default-user-password-hash.path;
...
98: hashedPasswordFile = config.secrets.files.default-user-password-hash.path;
...
```

</details>


<details>
<summary><code><a href="../implementations/rclone.md">rclone</a></code></summary>

**Configures options**: `secrets.files`, `secrets.templates`

```nix
# modules/implementations/rclone/default.nix
...
51: secrets = {
52: files = state.secretFileAttrs;
53: 
54: templates."rclone.conf" = {
...
```

</details>


<details>
<summary><code><a href="../implementations/restic.md">restic</a></code></summary>

**Configures options**: `secrets.files`

```nix
# modules/implementations/restic/default.nix
...
26: passwordFile = config.secrets.files.restic-password.path;
...
50: secrets.files.restic-password = {
51: store = "backup/restic";
52: key = "password";
53: testValue = "test-restic-password";
...
```

</details>


<details>
<summary><code><a href="../implementations/sops.md">sops</a></code></summary>

**Configures options**: `secrets.placeholder`

```nix
# modules/implementations/sops.nix
...
49: meta.description = "Throwaway age key and SOPS files holding non-sensitive stand-ins for host secrets.";
...
96: secrets.api-token = { key = "token"; format = "yaml"; value = "dummy"; };
...
134: description = "Host-level development shell configured to decrypt local host SOPS secrets.";
...
142: sops -d modules/secrets/secrets.yaml
...
145: sops -d --extract '["default-user-password-hash"]' modules/secrets/secrets.yaml
...
233: secrets =
234: lib.mapAttrs (name: s: {
235: inherit (s) key;
236: inherit (cfg.secrets.${name}) format;
...
236: inherit (cfg.secrets.${name}) format;
...
239: config.secrets.files;
...
261: sops.defaultSopsFile = lib.mkIf (config.secrets.defaultFile != null) config.secrets.defaultFile;
...
263: sops.secrets =
264: lib.mapAttrs (name: s: {
265: sopsFile =
266: if testMode
...
275: config.secrets.files;
...
277: secrets.placeholder = lib.mkIf (config.secrets.templates != {}) (
...
279: config.secrets.files
...
286: config.secrets.templates;
...
289: assertion = lib.all (name: config.secrets.files ? ${name}) (builtins.attrNames cfg.secrets);
...
290: message = "sops.secrets {${lib.concatStringsSep ", " (lib.filter (n: !(config.secrets.files ? ${n})) (builtins.attrNames cfg.secrets))}} bypass the `secrets` contract, so tests cannot substitute stand-ins for them; declare them via `secrets.files` instead.";
...
294: assertion = lib.all (name: config.secrets.templates ? ${name}) (builtins.attrNames cfg.templates);
...
295: message = "sops.templates {${lib.concatStringsSep ", " (lib.filter (n: !(config.secrets.templates ? ${n})) (builtins.attrNames cfg.templates))}} bypass the `secrets` contract; declare them via `secrets.templates` instead.";
...
303: for _path, _owner in ${builtins.toJSON (lib.mapAttrsToList (_: s: [s.path s.owner]) config.secrets.files)}:
...
354: Used to inspect, edit, and re-key encrypted repository secrets in `modules/secrets/secrets.yaml`:
...
358: sops modules/secrets/secrets.yaml
...
361: sops updatekeys modules/secrets/secrets.yaml
...
```

</details>



### Features

<details>
<summary><code><a href="../features/nix.md">nix</a></code></summary>

**Configures options**: `secrets.files`

```nix
# modules/features/nix.nix
...
28: secrets.files = lib.mkIf config.nix.cachixWatchStore {
29: cachix-token = {
30: file = ../../secrets/cachix/cachix.yaml;
31: key = "token";
...
76: cachixTokenFile = config.secrets.files.cachix-token.path;
...
```

</details>


<details>
<summary><code><a href="../features/ntfy.md">ntfy</a></code></summary>

**Configures options**: `secrets.files`

```nix
# modules/features/ntfy.nix
...
70: secrets.files.ntfy-admin-password = {
71: store = "services/auth";
72: key = "lldapAdminPassword";
73: owner = "ntfy-sh";
...
97: after = ["sops-install-secrets.service"];
...
98: wants = ["sops-install-secrets.service"];
...
114: export NTFY_PASSWORD="$(${pkgs.coreutils}/bin/cat ${lib.escapeShellArg config.secrets.files.ntfy-admin-password.path})"
...
144: passwordFile = lib.mkDefault config.secrets.files.ntfy-admin-password.path;
...
166: "pw=$(cat ${config.secrets.files.ntfy-admin-password.path}) && "
...
```

</details>


<details>
<summary><code><a href="../features/snapshot.md">snapshot</a></code></summary>

**Configures options**: `secrets.files`

```nix
# modules/features/snapshot.nix
...
162: export RESTIC_PASSWORD_FILE="''${RESTIC_PASSWORD_FILE:-${lib.escapeShellArg config.secrets.files.restic-password.path}}"
...
324: secrets.files.restic-password = lib.mkDefault {
325: store = "backup/restic";
326: key = "password";
327: testValue = "test-restic-password";
...
341: "sops-install-secrets.service"
...
348: RESTIC_PASSWORD_FILE = config.secrets.files.restic-password.path;
...
```

</details>


<details>
<summary><code><a href="../features/ssh.md">ssh</a></code></summary>

**Configures options**: `secrets.files`

```nix
# modules/features/ssh.nix
...
80: secrets.files =
81: lib.listToAttrs (map (name: {
82: name = "ssh/public/${name}";
83: value = {
...
170: if [ ! -s /etc/ssh/ssh_host_ed25519_key ] || ! ${pkgs.diffutils}/bin/cmp -s /etc/ssh/ssh_host_ed25519_key ${config.secrets.files."ssh/host-key".path}; then
...
172: install -m 600 ${config.secrets.files."ssh/host-key".path} /etc/ssh/ssh_host_ed25519_key
...
192: AuthorizedKeysFile /etc/ssh/authorized_keys.d/%u ${config.secrets.files."ssh/public/master".path}
...
```

</details>


<details>
<summary><code><a href="../features/wifi-eduroam.md">wifi-eduroam</a></code></summary>

**Configures options**: `secrets.files`, `secrets.templates`

```nix
# modules/features/wifi.nix
...
14: environmentTemplate = config.secrets.templates."wifi-eduroam-networkmanager".path;
...
81: secrets.files = {
82: ${usernameSecret} = {
83: file = cfg.secretFile;
84: key = cfg.usernameKey;
...
92: secrets.templates."wifi-eduroam-networkmanager" = {
93: mode = "0400";
94: content = ''
95: EDUROAM_USERNAME=${config.secrets.placeholder.${usernameSecret}}
...
95: EDUROAM_USERNAME=${config.secrets.placeholder.${usernameSecret}}
...
96: EDUROAM_PASSWORD=${config.secrets.placeholder.${passwordSecret}}
...
```

</details>
