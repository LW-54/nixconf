# Contract: `persistence`

Declarative state preservation across ephemeral reboots for system and user directories.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `persistence`
- **Description**: Declarative state preservation across ephemeral reboots for system and user directories.
- **Definition File**: [`modules/contracts/persistence.nix`](../../modules/contracts/persistence.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        urn__nixconf__onto__host__astrolabe["astrolabe"]:::hostNode
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
        urn__nixconf__onto__feature__bitwarden["bitwarden"]:::featureNode
        urn__nixconf__onto__feature__direnv["direnv"]:::featureNode
        urn__nixconf__onto__feature__dolphin["dolphin"]:::featureNode
        urn__nixconf__onto__feature__foot["foot"]:::featureNode
        urn__nixconf__onto__feature__labwc["labwc"]:::featureNode
        urn__nixconf__onto__feature__noctalia["noctalia"]:::featureNode
        urn__nixconf__onto__feature__ssh["ssh"]:::featureNode
        urn__nixconf__onto__feature__vaultwarden["vaultwarden"]:::featureNode
        urn__nixconf__onto__feature__vivaldi["vivaldi"]:::featureNode
        urn__nixconf__onto__feature__vscode["vscode"]:::featureNode
    end

    subgraph ContractTypes["Contract Types"]
        urn__nixconf__ast__type__persistence_entries{{"persistence.entries"}}:::typeNode
        urn__nixconf__ast__type__persistence_user{{"persistence.user"}}:::typeNode
    end

    subgraph OtherNodes["Other Entities"]
        urn__nixconf__ast__module__antigravity["antigravity"]
        urn__nixconf__ast__module__antigravity_cli["antigravity-cli"]
        urn__nixconf__ast__module__antigravity_ide["antigravity-ide"]
        urn__nixconf__ast__module__bitwarden_desktop["bitwarden-desktop"]
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
        urn__nixconf__ast__option__persistence_directories[/"persistence.directories: list of (string or attribute set of anything)"/]:::optNode
        urn__nixconf__ast__option__persistence_enable[/"persistence.enable: boolean"/]:::optNode
        urn__nixconf__ast__option__persistence_files[/"persistence.files: list of (string or attribute set of anything)"/]:::optNode
        urn__nixconf__ast__option__persistence_users[/"persistence.users: attribute set of (submodule)"/]:::optNode
        urn__nixconf__drv__devShell__master_ssh["shell: master-ssh"]:::shellNode
        urn__nixconf__drv__package__antigravity["pkg: antigravity"]:::pkgNode
        urn__nixconf__drv__package__antigravity_cli["pkg: antigravity-cli"]:::pkgNode
        urn__nixconf__drv__package__antigravity_ide["pkg: antigravity-ide"]:::pkgNode
        urn__nixconf__drv__package__bw["pkg: bw"]:::pkgNode
        urn__nixconf__drv__package__dolphin["pkg: dolphin"]:::pkgNode
        urn__nixconf__drv__package__foot["pkg: foot"]:::pkgNode
        urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
        urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
        urn__nixconf__onto__implementation__lw["lw"]:::implNode
        urn__nixconf__onto__primitive__contract["contract"]
        urn__nixconf__onto__primitive__feature["feature"]
        urn__nixconf__onto__primitive__implementation["implementation"]
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
    urn__nixconf__ast__module__bitwarden_desktop -->|"dependsOn"| urn__nixconf__drv__package__bw
    urn__nixconf__ast__module__bw -->|"dependsOn"| urn__nixconf__drv__package__bw
    urn__nixconf__ast__module__bw ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__bw -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__caddy ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__caddy -->|"writes"| urn__nixconf__ast__option__persistence_directories
    urn__nixconf__ast__module__direnv ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__direnv -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__dolphin -->|"dependsOn"| urn__nixconf__drv__package__dolphin
    urn__nixconf__ast__module__dolphin ==>|"flowsTo"| urn__nixconf__ast__module__impermanence
    urn__nixconf__ast__module__dolphin -->|"writes"| urn__nixconf__ast__option__persistence_users
    urn__nixconf__ast__module__foot -->|"dependsOn"| urn__nixconf__drv__package__foot
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
    urn__nixconf__drv__devShell__master_ssh -->|"dependsOn"| urn__nixconf__drv__package__bw
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
    urn__nixconf__onto__feature__bitwarden -->|"outputs"| urn__nixconf__ast__module__bitwarden_desktop
    urn__nixconf__onto__feature__bitwarden -->|"outputs"| urn__nixconf__ast__module__bw
    urn__nixconf__onto__feature__bitwarden -->|"outputs"| urn__nixconf__drv__package__bw
    urn__nixconf__onto__feature__bitwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__direnv -->|"outputs"| urn__nixconf__ast__module__direnv
    urn__nixconf__onto__feature__direnv -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__dolphin -->|"outputs"| urn__nixconf__ast__module__dolphin
    urn__nixconf__onto__feature__dolphin -->|"outputs"| urn__nixconf__drv__package__dolphin
    urn__nixconf__onto__feature__dolphin -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__foot -->|"outputs"| urn__nixconf__ast__module__foot
    urn__nixconf__onto__feature__foot -->|"outputs"| urn__nixconf__drv__package__foot
    urn__nixconf__onto__feature__foot -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__foot -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__foot -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -->|"outputs"| urn__nixconf__ast__module__labwc
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__labwc -->|"consumes"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__feature__noctalia -->|"outputs"| urn__nixconf__ast__module__noctalia
    urn__nixconf__onto__feature__noctalia -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -->|"outputs"| urn__nixconf__ast__module__ssh
    urn__nixconf__onto__feature__ssh -->|"outputs"| urn__nixconf__drv__devShell__master_ssh
    urn__nixconf__onto__feature__ssh -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__vaultwarden -->|"outputs"| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__vaultwarden -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vivaldi -->|"outputs"| urn__nixconf__ast__module__vivaldi
    urn__nixconf__onto__feature__vivaldi -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vscode -->|"outputs"| urn__nixconf__ast__module__vscode
    urn__nixconf__onto__feature__vscode -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__host__astrolabe -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -->|"consumes"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__dolphin
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__foot
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__implementation__caddy -->|"outputs"| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__caddy -->|"consumes"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy -.->|"implements"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy -.->|"implements"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__impermanence -->|"outputs"| urn__nixconf__ast__module__impermanence
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__impermanence -.->|"implements"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|"outputs"| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -->|"consumes"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw -.->|"implements"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -.->|"implements"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__backup
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__home
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__resources
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract --- urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__antigravity
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__bitwarden
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__direnv
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__dolphin
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__foot
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__labwc
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__noctalia
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__vivaldi
    urn__nixconf__onto__primitive__feature --- urn__nixconf__onto__feature__vscode
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__primitive__implementation --- urn__nixconf__onto__implementation__lw

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
| `options.persistence.directories` | `list of (string or attribute set of anything)` | `[ ... ]` | `[ ... ]` | List of directory paths to persist across reboots, as absolute system paths under `/persist/system`. Can be string paths or attribute sets defining custom ownership and bind-mount modes. |
| `options.persistence.enable` | `boolean` | `1` | `1` | Whether to enable declarative filesystem persistence contract mapped to impermanence. |
| `options.persistence.files` | `list of (string or attribute set of anything)` | `[ ... ]` | `[ ... ]` | List of individual file paths to persist across reboots, as absolute system paths under `/persist/system`. Can be string paths or attribute sets defining custom ownership and bind-mount modes. |
| `options.persistence.users` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Per-user persistence declarations keyed by username. `data` and `cache` root names are repository conventions, not upstream impermanence requirements. |


## Outputs

### Custom Submodule Types

| Type Name | Description | Docs |
| :--- | :--- | :--- |
| [`persistence.entries`](../lib/persistence.md#persistence.entries) | list of (string or attribute set of anything) | [More →](../lib/persistence.md#persistence.entries) |
| [`persistence.user`](../lib/persistence.md#persistence.user) | submodule | [More →](../lib/persistence.md#persistence.user) |


### Library Helpers

| Symbol | Description | Docs |
| :--- | :--- | :--- |
| [`flake.lib.persistence.types`](../lib/persistence.md#types) | Contract option constructor / binding helper | [More →](../lib/persistence.md#types) |
| [`flake.lib.persistence.entries`](../lib/persistence.md#entries) | Contract option constructor / binding helper | [More →](../lib/persistence.md#entries) |


## Implementations

Providers satisfying the `persistence` contract capability:

| Implementation | Description | Docs |
| :--- | :--- | :--- |
| [`impermanence`](../implementations/impermanence.md) | Ephemeral root filesystem with persistent state bind-mounts via Impermanence. | [More →](../implementations/impermanence.md) |

## Contract Consumers

Modules configuring options under the `persistence` contract capability:

### Hosts

*No hosts configure this contract directly.*

### Implementations

<details>
<summary><code><a href="../implementations/caddy.md">caddy</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../implementations/lw.md">lw</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


### Features

<details>
<summary><code><a href="../features/antigravity.md">antigravity</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/bitwarden.md">bitwarden</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/direnv.md">direnv</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/dolphin.md">dolphin</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/foot.md">foot</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/labwc.md">labwc</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/noctalia.md">noctalia</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/ssh.md">ssh</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/vaultwarden.md">vaultwarden</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/vaultwarden.md">vaultwarden</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/vivaldi.md">vivaldi</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/vscode.md">vscode</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>

