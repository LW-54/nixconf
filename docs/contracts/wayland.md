# Contract: `wayland`

Wayland compositor registration, session targets, and graphical environment management.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `wayland`
- **Description**: Wayland compositor registration, session targets, and graphical environment management.
- **Definition File**: [`modules/contracts/wayland.nix`](../../modules/contracts/wayland.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        urn__nixconf__onto__host__x240["x240"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        urn__nixconf__onto__contract__backup(["backup"]):::contractNode
        urn__nixconf__onto__contract__default_user(["default-user"]):::contractNode
        urn__nixconf__onto__contract__home(["home"]):::contractNode
        urn__nixconf__onto__contract__persistence(["persistence"]):::contractNode
        urn__nixconf__onto__contract__resources(["resources"]):::contractNode
        urn__nixconf__onto__contract__reverse_proxy(["reverse-proxy"]):::contractNode
        urn__nixconf__onto__contract__secrets(["secrets"]):::contractNode
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
        urn__nixconf__onto__feature__vivaldi["vivaldi"]:::featureNode
        urn__nixconf__onto__feature__vscode["vscode"]:::featureNode
        urn__nixconf__onto__feature__wifi_eduroam["wifi-eduroam"]:::featureNode
    end

    subgraph ContractTypes["Contract Types"]
        urn__nixconf__ast__type__wayland_compositor{{"wayland.compositor"}}:::typeNode
    end

    subgraph OtherNodes["Other Entities"]
        urn__nixconf__ast__module__labwc["labwc"]
        urn__nixconf__ast__module__uwsm["uwsm"]
        urn__nixconf__ast__module__x240["x240"]
        urn__nixconf__ast__module__x240_desktop["x240-desktop"]
        urn__nixconf__ast__module__x240_desktop_features["x240-desktop-features"]
        urn__nixconf__ast__module__x240_disk["x240-disk"]
        urn__nixconf__ast__module__x240_hardware["x240-hardware"]
        urn__nixconf__ast__module__x240_packages["x240-packages"]
        urn__nixconf__ast__module__x240_system["x240-system"]
        urn__nixconf__ast__module__x240_system_features["x240-system-features"]
        urn__nixconf__ast__option__wayland_compositors[/"wayland.compositors: attribute set of (submodule)"/]:::optNode
        urn__nixconf__ast__option__wayland_enable[/"wayland.enable: boolean"/]:::optNode
        urn__nixconf__eval__configuration__x240["x240"]
        urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
        urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
        urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
        urn__nixconf__onto__implementation__lw["lw"]:::implNode
        urn__nixconf__onto__implementation__sops["sops"]:::implNode
        urn__nixconf__onto__implementation__uwsm["uwsm"]:::implNode
        urn__nixconf__onto__primitive__contract["contract"]
        urn__nixconf__onto__primitive__feature["feature"]
        urn__nixconf__onto__primitive__host["host"]
        urn__nixconf__onto__primitive__implementation["implementation"]
    end


    urn__nixconf__ast__module__labwc ==>|"flowsTo"| urn__nixconf__ast__module__uwsm
    urn__nixconf__ast__module__labwc -->|"writes"| urn__nixconf__ast__option__wayland_compositors
    urn__nixconf__ast__module__uwsm -.->|"reads"| urn__nixconf__ast__option__wayland_compositors
    urn__nixconf__ast__module__uwsm -.->|"reads"| urn__nixconf__ast__option__wayland_enable
    urn__nixconf__ast__module__x240_desktop ==>|"flowsTo"| urn__nixconf__ast__module__uwsm
    urn__nixconf__ast__module__x240_desktop -->|"writes"| urn__nixconf__ast__option__wayland_enable
    urn__nixconf__ast__option__wayland_compositors -.->|"typedBy"| urn__nixconf__ast__type__wayland_compositor
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__labwc
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__uwsm
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_desktop
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_desktop_features
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_disk
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_hardware
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_packages
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_system
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__x240_system_features
    urn__nixconf__onto__contract__wayland --- urn__nixconf__ast__option__wayland_compositors
    urn__nixconf__onto__contract__wayland --- urn__nixconf__ast__option__wayland_enable
    urn__nixconf__onto__contract__wayland --- urn__nixconf__ast__type__wayland_compositor
    urn__nixconf__onto__feature__antigravity -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__bitwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__direnv -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__dolphin -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__foot -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__foot -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__foot -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__git -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__git -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -->|"outputs"| urn__nixconf__ast__module__labwc
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__feature__locale -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__nix -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__noctalia -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__vivaldi -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__wifi_eduroam -->|"consumes"| urn__nixconf__onto__contract__secrets
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
    urn__nixconf__onto__implementation__cgroups -.->|"implements"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__cgroups -.->|"implements"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__hjem -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__hjem -.->|"implements"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__hjem -.->|"implements"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw -.->|"implements"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -.->|"implements"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__sops -.->|"implements"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops -.->|"implements"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__uwsm -->|"outputs"| urn__nixconf__ast__module__uwsm
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__backup
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__home
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__resources
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__audio
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__cursor
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__disko
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__dolphin
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__fonts
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__foot
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__git
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__greetd
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__locale
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__nix
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__tack
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__wifi_eduroam
    urn__nixconf__onto__primitive__host --- urn__nixconf__onto__host__x240
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__hjem
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__lw
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


## Option Schema Definitions

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `options.wayland.compositors` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Declarative Wayland compositor registrations managed by the session manager. |
| `options.wayland.enable` | `boolean` | `` | `1` | Whether to enable system-level Wayland session orchestration. When enabled, Wayland compositor backends (such as UWSM) will configure systemd graphical session targets, environment variables, and startup units. |


## Outputs

### Custom Submodule Types

| Type Name | Description | Docs |
| :--- | :--- | :--- |
| [`wayland.compositor`](../lib/wayland.md#wayland.compositor) | submodule | [More →](../lib/wayland.md#wayland.compositor) |


### Library Helpers

| Symbol | Description | Docs |
| :--- | :--- | :--- |
| [`flake.lib.wayland.mkOption`](../lib/wayland.md#mkOption) | Contract option constructor / binding helper | [More →](../lib/wayland.md#mkOption) |
| [`flake.lib.wayland.mkConfig`](../lib/wayland.md#mkConfig) | Contract option constructor / binding helper | [More →](../lib/wayland.md#mkConfig) |
| [`flake.lib.wayland.types`](../lib/wayland.md#types) | Contract option constructor / binding helper | [More →](../lib/wayland.md#types) |


## Implementations

Providers satisfying the `wayland` contract capability:

| Implementation | Description | Docs |
| :--- | :--- | :--- |
| [`uwsm`](../implementations/uwsm.md) | Universal Wayland Session Manager integration for desktop environments. | [More →](../implementations/uwsm.md) |

## Contract Consumers

Modules configuring options under the `wayland` contract capability:

### Hosts

<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


### Implementations

*No implementations configure this contract.*

### Features

<details>
<summary><code><a href="../features/labwc.md">labwc</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>

