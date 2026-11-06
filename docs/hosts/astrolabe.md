# Host: `astrolabe`

Headless VPS Server (adje.app public edge and core services).

[← Back to Hosts Documentation](README.md) | [← Back to Main README](../../README.md)

- **Host**: `astrolabe`
- **System**: `x86_64-linux`
- **State Version**: `25.11`
- **Definition File**: [`modules/hosts/astrolabe.nix`](../../modules/hosts/astrolabe.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__antigravity_ide["nixosModule/antigravity-ide"]:::defaultNode
    urn__nixconf__ast__module__astrolabe["nixosModule/astrolabe"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_disk["nixosModule/astrolabe-disk"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_hardware["nixosModule/astrolabe-hardware"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_packages["nixosModule/astrolabe-packages"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_services["nixosModule/astrolabe-services"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_system["nixosModule/astrolabe-system"]:::defaultNode
    urn__nixconf__ast__module__backup["nixosModule/backup"]:::defaultNode
    urn__nixconf__ast__module__bw["nixosModule/bw"]:::defaultNode
    urn__nixconf__ast__module__caddy["nixosModule/caddy"]:::defaultNode
    urn__nixconf__ast__module__contracts["nixosModule/contracts"]:::defaultNode
    urn__nixconf__ast__module__default_user["nixosModule/default-user"]:::defaultNode
    urn__nixconf__ast__module__direnv["nixosModule/direnv"]:::defaultNode
    urn__nixconf__ast__module__disko["nixosModule/disko"]:::defaultNode
    urn__nixconf__ast__module__docker["nixosModule/docker"]:::defaultNode
    urn__nixconf__ast__module__dolphin["nixosModule/dolphin"]:::defaultNode
    urn__nixconf__ast__module__foot["nixosModule/foot"]:::defaultNode
    urn__nixconf__ast__module__git["nixosModule/git"]:::defaultNode
    urn__nixconf__ast__module__hjem["nixosModule/hjem"]:::defaultNode
    urn__nixconf__ast__module__home["nixosModule/home"]:::defaultNode
    urn__nixconf__ast__module__impermanence["nixosModule/impermanence"]:::defaultNode
    urn__nixconf__ast__module__labwc["nixosModule/labwc"]:::defaultNode
    urn__nixconf__ast__module__locale["nixosModule/locale"]:::defaultNode
    urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__module__nix["nixosModule/nix"]:::defaultNode
    urn__nixconf__ast__module__noctalia["nixosModule/noctalia"]:::defaultNode
    urn__nixconf__ast__module__persistence["nixosModule/persistence"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__reverse_proxy["nixosModule/reverse-proxy"]:::defaultNode
    urn__nixconf__ast__module__secrets["nixosModule/secrets"]:::defaultNode
    urn__nixconf__ast__module__sops["nixosModule/sops"]:::defaultNode
    urn__nixconf__ast__module__ssh["nixosModule/ssh"]:::defaultNode
    urn__nixconf__ast__module__ttyd["nixosModule/ttyd"]:::defaultNode
    urn__nixconf__ast__module__uchiyomi["nixosModule/uchiyomi"]:::defaultNode
    urn__nixconf__ast__module__vaultwarden["nixosModule/vaultwarden"]:::defaultNode
    urn__nixconf__ast__module__vivaldi["nixosModule/vivaldi"]:::defaultNode
    urn__nixconf__ast__module__vscode["nixosModule/vscode"]:::defaultNode
    urn__nixconf__ast__module__wayland["nixosModule/wayland"]:::defaultNode
    urn__nixconf__ast__module__wifi_eduroam["nixosModule/wifi-eduroam"]:::defaultNode
    urn__nixconf__ast__option__backup_exclude[/"backup.exclude"/]:::optNode
    urn__nixconf__ast__option__backup_paths[/"backup.paths"/]:::optNode
    urn__nixconf__ast__option__default_user_email[/"default-user.email"/]:::optNode
    urn__nixconf__ast__option__default_user_githubUsername[/"default-user.githubUsername"/]:::optNode
    urn__nixconf__ast__option__default_user_username[/"default-user.username"/]:::optNode
    urn__nixconf__ast__option__home_shared[/"home.shared"/]:::optNode
    urn__nixconf__ast__option__home_users[/"home.users"/]:::optNode
    urn__nixconf__ast__option__persistence_directories[/"persistence.directories"/]:::optNode
    urn__nixconf__ast__option__persistence_files[/"persistence.files"/]:::optNode
    urn__nixconf__ast__option__persistence_users[/"persistence.users"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_domain[/"reverse-proxy.domain"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_hosts[/"reverse-proxy.hosts"/]:::optNode
    urn__nixconf__ast__option__secrets_files[/"secrets.files"/]:::optNode
    urn__nixconf__drv__package__git[("package/git")]:::pkgNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__eval__configuration__x240(["nixosConfiguration/x240"]):::hostNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__feature__disko("disko"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__uchiyomi("uchiyomi"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode

    urn__nixconf__ast__module__antigravity_ide -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__antigravity_ide -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__astrolabe_services -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__astrolabe_services -.->|writes| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__bw -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__bw -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__caddy -.->|reads| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__direnv -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__direnv -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__docker -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__docker -.->|writes| urn__nixconf__ast__option__persistence_directories
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
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|reads| urn__nixconf__ast__option__persistence_users
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
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__noctalia -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__noctalia -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__restic -.->|reads| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__uchiyomi -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__uchiyomi -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_exclude
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__backup_paths
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__vivaldi -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vivaldi -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__vscode -.->|flowsTo| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vscode -.->|writes| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__wifi_eduroam -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__wifi_eduroam -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__eval__configuration__astrolabe -->|dependsOn| urn__nixconf__drv__package__git
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__backup
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__caddy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__contracts
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__default_user
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__disko
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__git
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__home
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__locale
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__persistence
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__reverse_proxy
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__secrets
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__ttyd
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__eval__configuration__astrolabe -->|imports| urn__nixconf__ast__module__wayland
    urn__nixconf__eval__configuration__x240 -->|dependsOn| urn__nixconf__drv__package__git
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__antigravity_ide
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__backup
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__bw
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__contracts
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__default_user
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__direnv
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__disko
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__docker
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__dolphin
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__foot
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__git
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__hjem
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__home
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__labwc
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__locale
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__nix
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__noctalia
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__persistence
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__reverse_proxy
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__secrets
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__sops
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__vivaldi
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__vscode
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__wayland
    urn__nixconf__eval__configuration__x240 -->|imports| urn__nixconf__ast__module__wifi_eduroam
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__onto__contract__reverse_proxy -->|declares| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__onto__feature__disko -->|outputs| urn__nixconf__ast__module__disko
    urn__nixconf__onto__feature__git -->|outputs| urn__nixconf__ast__module__git
    urn__nixconf__onto__feature__git -->|outputs| urn__nixconf__drv__package__git
    urn__nixconf__onto__feature__locale -->|outputs| urn__nixconf__ast__module__locale
    urn__nixconf__onto__feature__nix -->|outputs| urn__nixconf__ast__module__nix
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__ast__module__ssh
    urn__nixconf__onto__feature__ttyd -->|outputs| urn__nixconf__ast__module__ttyd
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__uchiyomi -->|outputs| urn__nixconf__ast__module__uchiyomi
    urn__nixconf__onto__feature__uchiyomi -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -->|outputs| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__onto__host__astrolabe -->|outputs| urn__nixconf__eval__configuration__astrolabe
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__uchiyomi
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__implementation__caddy -->|outputs| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy ==>|implements| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__impermanence -->|outputs| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__lw -->|outputs| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__restic -->|outputs| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__ast__module__sops


    click urn__nixconf__ast__module__antigravity_ide href "../modules/antigravity-ide.md" "antigravity-ide"
    click urn__nixconf__ast__module__astrolabe href "../modules/astrolabe.md" "astrolabe"
    click urn__nixconf__ast__module__astrolabe_disk href "../modules/astrolabe-disk.md" "astrolabe-disk"
    click urn__nixconf__ast__module__astrolabe_hardware href "../modules/astrolabe-hardware.md" "astrolabe-hardware"
    click urn__nixconf__ast__module__astrolabe_packages href "../modules/astrolabe-packages.md" "astrolabe-packages"
    click urn__nixconf__ast__module__astrolabe_services href "../modules/astrolabe-services.md" "astrolabe-services"
    click urn__nixconf__ast__module__astrolabe_system href "../modules/astrolabe-system.md" "astrolabe-system"
    click urn__nixconf__ast__module__backup href "../modules/backup.md" "backup"
    click urn__nixconf__ast__module__bw href "../modules/bw.md" "bw"
    click urn__nixconf__ast__module__caddy href "../modules/caddy.md" "caddy"
    click urn__nixconf__ast__module__contracts href "../modules/contracts.md" "contracts"
    click urn__nixconf__ast__module__default_user href "../modules/default-user.md" "default-user"
    click urn__nixconf__ast__module__direnv href "../modules/direnv.md" "direnv"
    click urn__nixconf__ast__module__disko href "../modules/disko.md" "disko"
    click urn__nixconf__ast__module__docker href "../modules/docker.md" "docker"
    click urn__nixconf__ast__module__dolphin href "../modules/dolphin.md" "dolphin"
    click urn__nixconf__ast__module__foot href "../modules/foot.md" "foot"
    click urn__nixconf__ast__module__git href "../modules/git.md" "git"
    click urn__nixconf__ast__module__hjem href "../modules/hjem.md" "hjem"
    click urn__nixconf__ast__module__home href "../modules/home.md" "home"
    click urn__nixconf__ast__module__impermanence href "../modules/impermanence.md" "impermanence"
    click urn__nixconf__ast__module__labwc href "../modules/labwc.md" "labwc"
    click urn__nixconf__ast__module__locale href "../modules/locale.md" "locale"
    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__ast__module__nix href "../modules/nix.md" "nix"
    click urn__nixconf__ast__module__noctalia href "../modules/noctalia.md" "noctalia"
    click urn__nixconf__ast__module__persistence href "../modules/persistence.md" "persistence"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__reverse_proxy href "../modules/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__ast__module__secrets href "../modules/secrets.md" "secrets"
    click urn__nixconf__ast__module__sops href "../modules/sops.md" "sops"
    click urn__nixconf__ast__module__ssh href "../modules/ssh.md" "ssh"
    click urn__nixconf__ast__module__ttyd href "../modules/ttyd.md" "ttyd"
    click urn__nixconf__ast__module__uchiyomi href "../modules/uchiyomi.md" "uchiyomi"
    click urn__nixconf__ast__module__vaultwarden href "../modules/vaultwarden.md" "vaultwarden"
    click urn__nixconf__ast__module__vivaldi href "../modules/vivaldi.md" "vivaldi"
    click urn__nixconf__ast__module__vscode href "../modules/vscode.md" "vscode"
    click urn__nixconf__ast__module__wayland href "../modules/wayland.md" "wayland"
    click urn__nixconf__ast__module__wifi_eduroam href "../modules/wifi-eduroam.md" "wifi-eduroam"
    click urn__nixconf__ast__option__backup_exclude href "../contracts/backup.md" "backup.exclude"
    click urn__nixconf__ast__option__backup_paths href "../contracts/backup.md" "backup.paths"
    click urn__nixconf__ast__option__default_user_email href "../contracts/default-user.md" "default-user.email"
    click urn__nixconf__ast__option__default_user_githubUsername href "../contracts/default-user.md" "default-user.githubUsername"
    click urn__nixconf__ast__option__default_user_username href "../contracts/default-user.md" "default-user.username"
    click urn__nixconf__ast__option__home_shared href "../contracts/home.md" "home.shared"
    click urn__nixconf__ast__option__home_users href "../contracts/home.md" "home.users"
    click urn__nixconf__ast__option__persistence_directories href "../contracts/persistence.md" "persistence.directories"
    click urn__nixconf__ast__option__persistence_files href "../contracts/persistence.md" "persistence.files"
    click urn__nixconf__ast__option__persistence_users href "../contracts/persistence.md" "persistence.users"
    click urn__nixconf__ast__option__reverse_proxy_domain href "../contracts/reverse-proxy.md" "reverse-proxy.domain"
    click urn__nixconf__ast__option__reverse_proxy_hosts href "../contracts/reverse-proxy.md" "reverse-proxy.hosts"
    click urn__nixconf__ast__option__secrets_files href "../contracts/secrets.md" "secrets.files"
    click urn__nixconf__drv__package__git href "../packages.md#git" "git"
    click urn__nixconf__eval__configuration__astrolabe href "astrolabe.md" "astrolabe"
    click urn__nixconf__eval__configuration__x240 href "x240.md" "x240"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__feature__disko href "../features/disko.md" "disko"
    click urn__nixconf__onto__feature__git href "../features/git.md" "git"
    click urn__nixconf__onto__feature__locale href "../features/locale.md" "locale"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__uchiyomi href "../features/uchiyomi.md" "uchiyomi"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__host__astrolabe href "astrolabe.md" "astrolabe"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__impermanence href "../implementations/impermanence.md" "impermanence"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"
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
| [`reverse-proxy`](../contracts/reverse-proxy.md) | Declarative HTTP/TLS reverse proxy virtual host ingress and routing management. | [`caddy`](../implementations/caddy.md) | Automated TLS virtual host reverse proxy implementation using Caddy. | [More →](../contracts/reverse-proxy.md) |
| [`persistence`](../contracts/persistence.md) | Declarative state preservation across ephemeral reboots for system and user directories. | [`impermanence`](../implementations/impermanence.md) | Ephemeral root filesystem with persistent state bind-mounts via Impermanence. | [More →](../contracts/persistence.md) |
| [`default-user`](../contracts/default-user.md) | Default primary user account identification, credentials, and configuration injection. | [`lw`](../implementations/lw.md) | Primary human user account orchestration and identity provisioning. | [More →](../contracts/default-user.md) |
| [`backup`](../contracts/backup.md) | Automated snapshot backup configuration, inclusion paths, exclusions, and retention rules. | [`restic`](../implementations/restic.md) | Automated encrypted remote backups using Restic and systemd timers. | [More →](../contracts/backup.md) |
| [`secrets`](../contracts/secrets.md) | Declarative encrypted secrets provisioning, filesystem mounting, and permission management. | [`sops`](../implementations/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [More →](../contracts/secrets.md) |

## Enabled Features

The following system and desktop features are imported by `astrolabe`:

| Feature | Description | Outputs Used | Docs |
| :--- | :--- | :--- | :--- |
| [`disko`](../features/disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | [`disko`](../modules/disko.md) (module) | [More →](../features/disko.md) |
| [`git`](../features/git.md) | Git version control system, global/per-user configuration, and Bitwarden SSH key agent shell. | [`git`](../modules/git.md) (module), [`git`](../packages.md#git) (package) | [More →](../features/git.md) |
| [`locale`](../features/locale.md) | System internationalization, time zone, and language locale configuration. | [`locale`](../modules/locale.md) (module) | [More →](../features/locale.md) |
| [`nix`](../features/nix.md) | Nix package manager daemon settings, binary caches, garbage collection, and nix-ld. | [`nix`](../modules/nix.md) (module) | [More →](../features/nix.md) |
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
<summary><code><a href="../modules/astrolabe-packages.md">astrolabe-packages</a></code></summary>

```nix
astrolabe-packages = {pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nano
    rsync
    btop
  ];
};
```

</details>

<details>
<summary><code><a href="../modules/astrolabe-services.md">astrolabe-services</a></code></summary>

```nix
astrolabe-services = {...}: {
  imports = [
    self.nixosModules.caddy
    self.nixosModules.restic
    self.nixosModules.vaultwarden
    self.nixosModules.ttyd
    self.nixosModules.uchiyomi
  ];

  config = {
    reverse-proxy.domain = "adje.app";
    services.resticBackup.repository = "s3:https://s3.eu-central-003.backblazeb2.com/cyclostyle-docker";
  };
};
```

</details>

<details>
<summary><code><a href="../modules/astrolabe-system.md">astrolabe-system</a></code></summary>

```nix
astrolabe-system = {
  imports = [
    self.nixosModules.contracts
    self.nixosModules.sops
    self.nixosModules.lw
    self.nixosModules.nix
    self.nixosModules.locale
    self.nixosModules.ssh
    self.nixosModules.git
  ];

  config = {
    networking.hostName = "astrolabe";
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
├── [dir]  /var/cache/uchiyomi/
├── [dir]  /var/lib/caddy/
├── [dir]  /var/lib/nixos/
├── [dir]  /var/lib/systemd/coredump/
├── [dir]  /var/lib/uchiyomi/
├── [dir]  /var/lib/vaultwarden/
├── [dir]  /var/log/
├── [file] /etc/machine-id
├── [file] /etc/ssh/ssh_host_ed25519_key
├── [file] /etc/ssh/ssh_host_ed25519_key.pub
├── [file] /etc/ssh/ssh_host_rsa_key
└── [file] /etc/ssh/ssh_host_rsa_key.pub

/persist/users/lw/data
├── [dir]  ~lw/.ssh/
├── [dir]  ~lw/Documents/
├── [dir]  ~lw/Downloads/
├── [dir]  ~lw/Projects/
└── [dir]  ~lw/nixconf/
```

## Consumed Contracts

Capability contracts configured by `astrolabe`:

<details>
<summary><code><a href="../contracts/reverse-proxy.md">reverse-proxy</a></code></summary>

**Configures options**: `reverse-proxy.domain`

```nix
# modules/hosts/astrolabe.nix
...
32: reverse-proxy.domain = "adje.app";
...
```

</details>

## Installation & Deployment

### Track 1: Remote Automated Provisioning (`nixos-anywhere`)

For remote servers or headless machines booted into a live environment:

```bash
# Remote deployment over SSH with SOPS secret key copy
nix run github:nix-community/nixos-anywhere -- \
  --flake .#astrolabe \
  --copy-secret /path/to/host-key.txt /persist/var/lib/sops-nix/key.txt \
  root@<TARGET-IP>
```

### Track 2: Local Installation from Live ISO

For physical machines booted from a NixOS Live ISO installer drive:

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
install -d -m 0700 /mnt/persist/var/lib/sops-nix
install -m 0400 /path/to/host-key.txt /mnt/persist/var/lib/sops-nix/key.txt

# 5. Install NixOS to target disk and reboot
nixos-install --flake .#astrolabe --no-root-passwd
reboot
```

### Track 3: Routine Maintenance & System Rebuilds

```bash
# Local rebuild and switch on running system
sudo nixos-rebuild switch --flake .#astrolabe

# Remote rebuild over SSH from a management machine
nixos-rebuild switch --flake .#astrolabe --target-host root@<TARGET-IP>
```
