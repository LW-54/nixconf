# Implementation: `cgroups`

Systemd control groups slice hierarchy and resource quotas implementation.

[← Back to Implementations Documentation](../IMPLEMENTATIONS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Provider Name**: `cgroups`
- **Contract Satisfied**: [`resources`](../contracts/resources.md)
- **Contract Description**: System resource limits, cgroup slices, memory/CPU quotas, and power-aware throttling.
- **Source File**: [`modules/implementations/cgroups.nix`](../../modules/implementations/cgroups.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        urn__nixconf__onto__host__astrolabe["astrolabe"]:::hostNode
        urn__nixconf__onto__host__x240["x240"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        urn__nixconf__onto__contract__resources(["resources"]):::contractNode
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
        urn__nixconf__ast__type__resources_byteSize{{"resources.byteSize"}}:::typeNode
        urn__nixconf__ast__type__resources_cgroupWeight{{"resources.cgroupWeight"}}:::typeNode
        urn__nixconf__ast__type__resources_service{{"resources.service"}}:::typeNode
        urn__nixconf__ast__type__resources_slice{{"resources.slice"}}:::typeNode
    end

    subgraph OtherNodes["Other Entities"]
        urn__nixconf__ast__module__astrolabe["astrolabe"]
        urn__nixconf__ast__module__astrolabe_disk["astrolabe-disk"]
        urn__nixconf__ast__module__astrolabe_hardware["astrolabe-hardware"]
        urn__nixconf__ast__module__astrolabe_packages["astrolabe-packages"]
        urn__nixconf__ast__module__astrolabe_services["astrolabe-services"]
        urn__nixconf__ast__module__astrolabe_system["astrolabe-system"]
        urn__nixconf__ast__module__caddy["caddy"]
        urn__nixconf__ast__module__cgroups["cgroups"]
        urn__nixconf__ast__module__restic["restic"]
        urn__nixconf__ast__module__ttyd["ttyd"]
        urn__nixconf__ast__module__vaultwarden["vaultwarden"]
        urn__nixconf__ast__module__x240["x240"]
        urn__nixconf__ast__module__x240_desktop["x240-desktop"]
        urn__nixconf__ast__module__x240_desktop_features["x240-desktop-features"]
        urn__nixconf__ast__module__x240_disk["x240-disk"]
        urn__nixconf__ast__module__x240_hardware["x240-hardware"]
        urn__nixconf__ast__module__x240_packages["x240-packages"]
        urn__nixconf__ast__module__x240_system["x240-system"]
        urn__nixconf__ast__module__x240_system_features["x240-system-features"]
        urn__nixconf__ast__option__resources_defaultSlices_enable[/"resources.defaultSlices.enable: boolean"/]:::optNode
        urn__nixconf__ast__option__resources_enable[/"resources.enable: boolean"/]:::optNode
        urn__nixconf__ast__option__resources_services[/"resources.services: attribute set of (submodule)"/]:::optNode
        urn__nixconf__ast__option__resources_slices[/"resources.slices: attribute set of (submodule)"/]:::optNode
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


    urn__nixconf__ast__module__astrolabe_services ==>|"flowsTo"| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__caddy ==>|"flowsTo"| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__caddy -->|"writes"| urn__nixconf__ast__option__resources_services
    urn__nixconf__ast__module__cgroups -.->|"reads"| urn__nixconf__ast__option__resources_defaultSlices_enable
    urn__nixconf__ast__module__cgroups -.->|"reads"| urn__nixconf__ast__option__resources_defaultSlices_enable
    urn__nixconf__ast__module__cgroups -.->|"reads"| urn__nixconf__ast__option__resources_enable
    urn__nixconf__ast__module__cgroups -.->|"reads"| urn__nixconf__ast__option__resources_enable
    urn__nixconf__ast__module__cgroups -.->|"reads"| urn__nixconf__ast__option__resources_services
    urn__nixconf__ast__module__cgroups -.->|"reads"| urn__nixconf__ast__option__resources_services
    urn__nixconf__ast__module__cgroups -.->|"reads"| urn__nixconf__ast__option__resources_slices
    urn__nixconf__ast__module__cgroups -.->|"reads"| urn__nixconf__ast__option__resources_slices
    urn__nixconf__ast__module__restic ==>|"flowsTo"| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__restic -->|"writes"| urn__nixconf__ast__option__resources_services
    urn__nixconf__ast__module__ttyd ==>|"flowsTo"| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ttyd ==>|"flowsTo"| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ttyd -->|"writes"| urn__nixconf__ast__option__resources_services
    urn__nixconf__ast__module__vaultwarden ==>|"flowsTo"| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__vaultwarden ==>|"flowsTo"| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__vaultwarden ==>|"flowsTo"| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__vaultwarden ==>|"flowsTo"| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__vaultwarden -->|"writes"| urn__nixconf__ast__option__resources_services
    urn__nixconf__ast__option__resources_services -.->|"typedBy"| urn__nixconf__ast__type__resources_service
    urn__nixconf__ast__option__resources_services -.->|"typedBy"| urn__nixconf__ast__type__resources_slice
    urn__nixconf__ast__option__resources_slices -.->|"typedBy"| urn__nixconf__ast__type__resources_service
    urn__nixconf__ast__option__resources_slices -.->|"typedBy"| urn__nixconf__ast__type__resources_slice
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__caddy
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__cgroups
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__restic
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__ttyd
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__cgroups
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_desktop_features
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_disk
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_packages
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_system
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_system_features
    urn__nixconf__onto__contract__resources --- urn__nixconf__ast__option__resources_defaultSlices_enable
    urn__nixconf__onto__contract__resources --- urn__nixconf__ast__option__resources_enable
    urn__nixconf__onto__contract__resources --- urn__nixconf__ast__option__resources_services
    urn__nixconf__onto__contract__resources --- urn__nixconf__ast__option__resources_slices
    urn__nixconf__onto__contract__resources --- urn__nixconf__ast__type__resources_byteSize
    urn__nixconf__onto__contract__resources --- urn__nixconf__ast__type__resources_cgroupWeight
    urn__nixconf__onto__contract__resources --- urn__nixconf__ast__type__resources_service
    urn__nixconf__onto__contract__resources --- urn__nixconf__ast__type__resources_slice
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__feature__ttyd -->|"outputs"| urn__nixconf__ast__module__ttyd
    urn__nixconf__onto__feature__ttyd -->|"consumes"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ttyd -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -->|"outputs"| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
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
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy -.->|"implements"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy -.->|"implements"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__cgroups -->|"outputs"| urn__nixconf__ast__module__cgroups
    urn__nixconf__onto__implementation__cgroups -.->|"implements"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__cgroups -.->|"implements"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__restic -->|"outputs"| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__restic -->|"consumes"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__resources
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
| [`cgroups`](../modules/cgroups.md) | Provider module satisfying `resources` contract | [More →](../modules/cgroups.md) |

### Executable Packages

*No executable packages exported.*

### Development Shells

*No development shells exported.*

### Library Helpers

*No library helpers exported.*

## Importing Hosts

Hosts enabling this provider to fulfill the [`resources`](../contracts/resources.md) contract:

- [`astrolabe`](../hosts/astrolabe.md) (`x86_64-linux`): Headless VPS Server (adje.app public edge and core services).
- [`x240`](../hosts/x240.md) (`x86_64-linux`): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Consumed Contracts

Contracts configured by this implementation:

*No external contracts consumed by this implementation.*
