# Feature: `antigravity`

Google Antigravity IDE, agentic workflow tools, and CLI runtime.

[← Back to Features Documentation](../FEATURES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Feature Name**: `antigravity`
- **Description**: Google Antigravity IDE, agentic workflow tools, and CLI runtime.
- **Definition File**: [`modules/features/antigravity.nix`](../../modules/features/antigravity.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        urn__nixconf__onto__host__x240["x240"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        urn__nixconf__onto__contract__persistence(["persistence"]):::contractNode
        urn__nixconf__onto__contract__wayland(["wayland"]):::contractNode
    end

    subgraph Features["Features"]
        urn__nixconf__onto__feature__antigravity["antigravity"]:::featureNode
        urn__nixconf__onto__feature__audio["audio"]:::featureNode
        urn__nixconf__onto__feature__bitwarden["bitwarden"]:::featureNode
        urn__nixconf__onto__feature__cosmic["cosmic"]:::featureNode
        urn__nixconf__onto__feature__cursor["cursor"]:::featureNode
        urn__nixconf__onto__feature__direnv["direnv"]:::featureNode
        urn__nixconf__onto__feature__disko["disko"]:::featureNode
        urn__nixconf__onto__feature__dolphin["dolphin"]:::featureNode
        urn__nixconf__onto__feature__fonts["fonts"]:::featureNode
        urn__nixconf__onto__feature__foot["foot"]:::featureNode
        urn__nixconf__onto__feature__git["git"]:::featureNode
        urn__nixconf__onto__feature__greetd["greetd"]:::featureNode
        urn__nixconf__onto__feature__helium["helium"]:::featureNode
        urn__nixconf__onto__feature__labwc["labwc"]:::featureNode
        urn__nixconf__onto__feature__locale["locale"]:::featureNode
        urn__nixconf__onto__feature__nix["nix"]:::featureNode
        urn__nixconf__onto__feature__noctalia["noctalia"]:::featureNode
        urn__nixconf__onto__feature__ssh["ssh"]:::featureNode
        urn__nixconf__onto__feature__tack["tack"]:::featureNode
        urn__nixconf__onto__feature__ttyd["ttyd"]:::featureNode
        urn__nixconf__onto__feature__user["user"]:::featureNode
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
        urn__nixconf__ast__module__antigravity["antigravity"]
        urn__nixconf__ast__module__antigravity_cli["antigravity-cli"]
        urn__nixconf__ast__module__antigravity_ide["antigravity-ide"]
        urn__nixconf__ast__module__impermanence["impermanence"]
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
        urn__nixconf__drv__package__antigravity["pkg: antigravity"]:::pkgNode
        urn__nixconf__drv__package__antigravity_cli["pkg: antigravity-cli"]:::pkgNode
        urn__nixconf__drv__package__antigravity_ide["pkg: antigravity-ide"]:::pkgNode
        urn__nixconf__eval__configuration__x240["x240"]
        urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
        urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
        urn__nixconf__onto__implementation__hjem["hjem"]:::implNode
        urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
        urn__nixconf__onto__implementation__lw["lw"]:::implNode
        urn__nixconf__onto__implementation__sops["sops"]:::implNode
        urn__nixconf__onto__implementation__uwsm["uwsm"]:::implNode
        urn__nixconf__onto__primitive__contract["contract"]
        urn__nixconf__onto__primitive__feature["feature"]
        urn__nixconf__onto__primitive__host["host"]
    end


    urn__nixconf__ast__module__antigravity -->|"dependsOn"| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__antigravity -->|"dependsOn"| urn__nixconf__drv__package__antigravity_cli
    urn__nixconf__ast__module__antigravity -->|"dependsOn"| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__antigravity_cli -->|"dependsOn"| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__antigravity_cli -->|"dependsOn"| urn__nixconf__drv__package__antigravity_cli
    urn__nixconf__ast__module__antigravity_cli -->|"dependsOn"| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__antigravity_ide -->|"dependsOn"| urn__nixconf__drv__package__antigravity
    urn__nixconf__ast__module__antigravity_ide -->|"dependsOn"| urn__nixconf__drv__package__antigravity_cli
    urn__nixconf__ast__module__antigravity_ide -->|"dependsOn"| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__ast__module__antigravity_ide ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__antigravity_ide -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_enable
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_enable
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_files
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__impermanence -.->|"reads"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__option__persistence_directories -.->|"typedBy"| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_files -.->|"typedBy"| urn__nixconf__ast__type__persistence_entries
    urn__nixconf__ast__option__persistence_users -.->|"typedBy"| urn__nixconf__ast__type__persistence_user
    urn__nixconf__eval__configuration__x240 -->|"dependsOn"| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__antigravity_ide
    urn__nixconf__eval__configuration__x240 -->|"imports"| urn__nixconf__ast__module__impermanence
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
    urn__nixconf__onto__feature__antigravity -->|"outputs"| urn__nixconf__ast__module__antigravity
    urn__nixconf__onto__feature__antigravity -->|"outputs"| urn__nixconf__ast__module__antigravity_cli
    urn__nixconf__onto__feature__antigravity -->|"outputs"| urn__nixconf__ast__module__antigravity_ide
    urn__nixconf__onto__feature__antigravity -->|"outputs"| urn__nixconf__drv__package__antigravity
    urn__nixconf__onto__feature__antigravity -->|"outputs"| urn__nixconf__drv__package__antigravity_cli
    urn__nixconf__onto__feature__antigravity -->|"outputs"| urn__nixconf__drv__package__antigravity_ide
    urn__nixconf__onto__feature__antigravity -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__bitwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__direnv -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__dolphin -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__foot -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__feature__noctalia -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vivaldi -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -->|"consumes"| urn__nixconf__onto__contract__persistence
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
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__impermanence -->|"outputs"| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__implementation__uwsm -.->|"implements"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__audio
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__cosmic
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__cursor
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__disko
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__dolphin
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__fonts
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__foot
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__git
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__greetd
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__helium
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__locale
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__nix
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__tack
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__user
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__wifi_eduroam
    urn__nixconf__onto__primitive__host --- urn__nixconf__onto__host__x240

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
| [`antigravity`](../modules/antigravity.md) | System service module exported by `antigravity` | [More →](../modules/antigravity.md) |
| [`antigravity-cli`](../modules/antigravity-cli.md) | System service module exported by `antigravity` | [More →](../modules/antigravity-cli.md) |
| [`antigravity-ide`](../modules/antigravity-ide.md) | System service module exported by `antigravity` | [More →](../modules/antigravity-ide.md) |


### Executable Packages

| Package Attribute | Command | Description | Docs |
| :--- | :--- | :--- | :--- |
| [`antigravity`](../PACKAGES.md#antigravity) | `nix run .#antigravity` | Executable application package | [More →](../PACKAGES.md#antigravity) |
| [`antigravity-cli`](../PACKAGES.md#antigravity-cli) | `nix run .#antigravity-cli` | Executable application package | [More →](../PACKAGES.md#antigravity-cli) |
| [`antigravity-ide`](../PACKAGES.md#antigravity-ide) | `nix run .#antigravity-ide` | Executable application package | [More →](../PACKAGES.md#antigravity-ide) |


### Development Shells

*No development shells exported.*

### Library Helpers

*No library helpers exported.*



## Consumed Contracts

Contracts configured by this feature:

<details>
<summary><code><a href="../contracts/persistence.md">persistence</a></code></summary>

Configures options: *general capability bindings*

```nix
config = {

};

```

</details>

