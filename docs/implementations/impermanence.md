# Implementation: `impermanence`

Ephemeral root filesystem with persistent state bind-mounts via Impermanence.

[← Back to Implementations Documentation](../IMPLEMENTATIONS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Provider Name**: `impermanence`
- **Contract Satisfied**: [`persistence`](../contracts/persistence.md)
- **Contract Description**: Declarative state preservation across ephemeral reboots for system and user directories.
- **Source File**: [`modules/implementations/impermanence.nix`](../../modules/implementations/impermanence.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        urn__nixconf__onto__host__astrolabe["astrolabe"]:::hostNode
        urn__nixconf__onto__host__x240["x240"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        urn__nixconf__onto__contract__persistence(["persistence"]):::contractNode
        urn__nixconf__onto__contract__reverse_proxy(["reverse-proxy"]):::contractNode
        urn__nixconf__onto__contract__wayland(["wayland"]):::contractNode
    end

    subgraph Features["Features"]
        urn__nixconf__onto__feature__antigravity["antigravity"]:::featureNode
        urn__nixconf__onto__feature__audio["audio"]:::featureNode
        urn__nixconf__onto__feature__bitwarden["bitwarden"]:::featureNode
        urn__nixconf__onto__feature__cursor["cursor"]:::featureNode
        urn__nixconf__onto__feature__direnv["direnv"]:::featureNode
        urn__nixconf__onto__feature__disko["disko"]:::featureNode
        urn__nixconf__onto__feature__dolphin["dolphin"]:::featureNode
        urn__nixconf__onto__feature__fonts["fonts"]:::featureNode
        urn__nixconf__onto__feature__foot["foot"]:::featureNode
        urn__nixconf__onto__feature__git["git"]:::featureNode
        urn__nixconf__onto__feature__greetd["greetd"]:::featureNode
        urn__nixconf__onto__feature__labwc["labwc"]:::featureNode
        urn__nixconf__onto__feature__locale["locale"]:::featureNode
        urn__nixconf__onto__feature__nix["nix"]:::featureNode
        urn__nixconf__onto__feature__noctalia["noctalia"]:::featureNode
        urn__nixconf__onto__feature__ssh["ssh"]:::featureNode
        urn__nixconf__onto__feature__tack["tack"]:::featureNode
        urn__nixconf__onto__feature__ttyd["ttyd"]:::featureNode
        urn__nixconf__onto__feature__vaultwarden["vaultwarden"]:::featureNode
        urn__nixconf__onto__feature__vivaldi["vivaldi"]:::featureNode
        urn__nixconf__onto__feature__vscode["vscode"]:::featureNode
        urn__nixconf__onto__feature__wifi_eduroam["wifi-eduroam"]:::featureNode
    end

    subgraph ContractTypes["Contract Types"]
        urn__nixconf__ast__type__persistence_entries{{"persistence.entries"}}:::typeNode
        urn__nixconf__ast__type__persistence_user{{"persistence.user"}}:::typeNode
    end

    subgraph OtherNodes["Other Entities"]
        urn__nixconf__ast__module__antigravity_ide["antigravity-ide"]
        urn__nixconf__ast__module__astrolabe["astrolabe"]
        urn__nixconf__ast__module__astrolabe_disk["astrolabe-disk"]
        urn__nixconf__ast__module__astrolabe_hardware["astrolabe-hardware"]
        urn__nixconf__ast__module__astrolabe_packages["astrolabe-packages"]
        urn__nixconf__ast__module__astrolabe_services["astrolabe-services"]
        urn__nixconf__ast__module__astrolabe_system["astrolabe-system"]
        urn__nixconf__ast__module__bw["bw"]
        urn__nixconf__ast__module__caddy["caddy"]
        urn__nixconf__ast__module__direnv["direnv"]
        urn__nixconf__ast__module__dolphin["dolphin"]
        urn__nixconf__ast__module__foot["foot"]
        urn__nixconf__ast__module__impermanence["impermanence"]
        urn__nixconf__ast__module__labwc["labwc"]
        urn__nixconf__ast__module__lw["lw"]
        urn__nixconf__ast__module__noctalia["noctalia"]
        urn__nixconf__ast__module__ssh["ssh"]
        urn__nixconf__ast__module__vaultwarden["vaultwarden"]
        urn__nixconf__ast__module__vivaldi["vivaldi"]
        urn__nixconf__ast__module__vscode["vscode"]
        urn__nixconf__ast__module__x240["x240"]
        urn__nixconf__ast__module__x240_desktop["x240-desktop"]
        urn__nixconf__ast__module__x240_desktop_features["x240-desktop-features"]
        urn__nixconf__ast__module__x240_disk["x240-disk"]
        urn__nixconf__ast__module__x240_hardware["x240-hardware"]
        urn__nixconf__ast__module__x240_packages["x240-packages"]
        urn__nixconf__ast__module__x240_system["x240-system"]
        urn__nixconf__ast__module__x240_system_features["x240-system-features"]
        urn__nixconf__ast__option__persistence_directories[/"persistence.directories: list of (string or attribute set of anything)"/]:::optNode
        urn__nixconf__ast__option__persistence_enable[/"persistence.enable: boolean"/]:::optNode
        urn__nixconf__ast__option__persistence_files[/"persistence.files: list of (string or attribute set of anything)"/]:::optNode
        urn__nixconf__ast__option__persistence_users[/"persistence.users: attribute set of (submodule)"/]:::optNode
        urn__nixconf__eval__configuration__astrolabe["astrolabe"]
        urn__nixconf__eval__configuration__x240["x240"]
        urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
        urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
        urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
        urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
        urn__nixconf__onto__implementation__lw["lw"]:::implNode
        urn__nixconf__onto__implementation__restic["restic"]:::implNode
        urn__nixconf__onto__implementation__sops["sops"]:::implNode
        urn__nixconf__onto__implementation__uwsm["uwsm"]:::implNode
        urn__nixconf__onto__primitive__contract["contract"]
        urn__nixconf__onto__primitive__host["host"]
        urn__nixconf__onto__primitive__implementation["implementation"]
    end


    urn__nixconf__ast__module__antigravity_ide ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__antigravity_ide -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__astrolabe_services ==>|"flowsTo"| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__bw ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__bw -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__caddy ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__caddy -->|"writes"| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__direnv ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__direnv -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__dolphin ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__dolphin -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__foot ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__foot -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_enable
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_enable
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__labwc ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__labwc -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__lw ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__lw ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__lw -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__noctalia ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__noctalia -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__ssh ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ssh ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__ssh -->|"writes"| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__ssh -->|"writes"| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__vaultwarden ==>|"flowsTo"| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__vaultwarden ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vaultwarden ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vaultwarden -->|"writes"| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__vaultwarden -->|"writes"| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__vivaldi ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vivaldi -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__vscode ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__vscode -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__option__persistence_directories -.->|"typedBy"| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_files -.->|"typedBy"| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_users -.->|"typedBy"| urn__nixconf__ast__type__persistence_user
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__caddy
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__antigravity_ide
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__bw
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__direnv
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__dolphin
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__foot
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__impermanence
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__labwc
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__lw
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__noctalia
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__ssh
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__vivaldi
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__vscode
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_desktop_features
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_disk
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_packages
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_system
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_system_features
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__option__persistence_directories
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__option__persistence_enable
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__option__persistence_files
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__option__persistence_users
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__type__persistence_entries
    urn__nixconf__onto__contract__persistence --- urn__nixconf__ast__type__persistence_user
    urn__nixconf__onto__feature__antigravity -->|"outputs"| urn__nixconf__ast__module__antigravity_ide
    urn__nixconf__onto__feature__antigravity -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__bitwarden -->|"outputs"| urn__nixconf__ast__module__bw
    urn__nixconf__onto__feature__bitwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__direnv -->|"outputs"| urn__nixconf__ast__module__direnv
    urn__nixconf__onto__feature__direnv -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__dolphin -->|"outputs"| urn__nixconf__ast__module__dolphin
    urn__nixconf__onto__feature__dolphin -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__foot -->|"outputs"| urn__nixconf__ast__module__foot
    urn__nixconf__onto__feature__foot -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -->|"outputs"| urn__nixconf__ast__module__labwc
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__feature__noctalia -->|"outputs"| urn__nixconf__ast__module__noctalia
    urn__nixconf__onto__feature__noctalia -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -->|"outputs"| urn__nixconf__ast__module__ssh
    urn__nixconf__onto__feature__ssh -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ttyd -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -->|"outputs"| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vivaldi -->|"outputs"| urn__nixconf__ast__module__vivaldi
    urn__nixconf__onto__feature__vivaldi -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -->|"outputs"| urn__nixconf__ast__module__vscode
    urn__nixconf__onto__feature__vscode -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__eval__configuration__astrolabe
    urn__nixconf__onto__host__astrolabe -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_desktop_features
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_disk
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_packages
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_system
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__ast__module__x240_system_features
    urn__nixconf__onto__host__x240 -->|"outputs"| urn__nixconf__eval__configuration__x240
    urn__nixconf__onto__host__x240 -->|"consumes"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__audio
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__cursor
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__dolphin
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__fonts
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__foot
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__greetd
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__tack
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__wifi_eduroam
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__uwsm
    urn__nixconf__onto__implementation__caddy -->|"outputs"| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy -.->|"implements"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy -.->|"implements"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__impermanence -->|"outputs"| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|"outputs"| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__host --- urn__nixconf__onto__host__astrolabe
    urn__nixconf__onto__primitive__host --- urn__nixconf__onto__host__x240
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__uwsm

classDef hostNode fill:#1e1e2e,stroke:#cba6f7,stroke-width:2px,color:#cdd6f4;
classDef contractNode fill:#181825,stroke:#89b4fa,stroke-width:2px,color:#cdd6f4;
classDef implNode fill:#181825,stroke:#a6e3a1,stroke-width:2px,color:#cdd6f4;
classDef featureNode fill:#181825,stroke:#f38ba8,stroke-width:2px,color:#cdd6f4;
classDef libNode fill:#181825,stroke:#94e2d5,stroke-width:2px,color:#cdd6f4;
classDef optNode fill:#11111b,stroke:#fab387,stroke-width:1px,color:#cdd6f4;
classDef typeNode fill:#11111b,stroke:#f9e2af,stroke-width:1px,color:#cdd6f4;
classDef fnNode fill:#181825,stroke:#94e2d5,stroke-width:1px,color:#cdd6f4;
classDef pkgNode fill:#181825,stroke:#b4befe,stroke-width:1px,color:#cdd6f4;
classDef shellNode fill:#181825,stroke:#f5c2e7,stroke-width:1px,color:#cdd6f4;

```


## Outputs

### NixOS Modules

| Module Attribute | Description | Docs |
| :--- | :--- | :--- |
| [`impermanence`](../modules/impermanence.md) | Provider module satisfying `persistence` contract | [More →](../modules/impermanence.md) |

### Executable Packages

*No executable packages exported.*

### Development Shells

*No development shells exported.*

### Library Helpers

*No library helpers exported.*

## Importing Hosts

Hosts enabling this provider to fulfill the [`persistence`](../contracts/persistence.md) contract:

- [`astrolabe`](../hosts/astrolabe.md) (`x86_64-linux`): Headless VPS Server (adje.app public edge and core services).
- [`x240`](../hosts/x240.md) (`x86_64-linux`): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Consumed Contracts

Contracts configured by this implementation:

*No external contracts consumed by this implementation.*
