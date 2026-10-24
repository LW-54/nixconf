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
        host__astrolabe["astrolabe"]:::hostNode
        host__x240["x240"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        contract__persistence(["persistence"]):::contractNode
    end

    subgraph Implementations["Implementations"]
        impl__impermanence["impermanence"]:::implNode
    end

    subgraph ContractOptions["Contract Options"]
        opt__persistence_directories[/"persistence.directories: list of (string or attribute set of anything)"/]:::optNode
        opt__persistence_enable[/"persistence.enable: boolean"/]:::optNode
        opt__persistence_files[/"persistence.files: list of (string or attribute set of anything)"/]:::optNode
        opt__persistence_users[/"persistence.users: attribute set of (submodule)"/]:::optNode
    end

    subgraph ContractTypes["Contract Types"]
        type__persistence_entries{{"persistence.entries"}}:::typeNode
        type__persistence_user{{"persistence.user"}}:::typeNode
    end


    host__astrolabe -->|"imports"| impl__impermanence
    host__x240 -->|"imports"| impl__impermanence
    impl__impermanence -.->|"implements"| contract__persistence
    contract__persistence --- opt__persistence_directories
    contract__persistence --- opt__persistence_enable
    contract__persistence --- opt__persistence_files
    contract__persistence --- opt__persistence_users
    contract__persistence --- type__persistence_entries
    contract__persistence --- type__persistence_user

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
| [`flake.lib.persistence.mkConfig`](../lib/persistence.md#mkConfig) | Contract option constructor / binding helper | [More →](../lib/persistence.md#mkConfig) |
| [`flake.lib.persistence.mkOption`](../lib/persistence.md#mkOption) | Contract option constructor / binding helper | [More →](../lib/persistence.md#mkOption) |


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

*No implementations configure this contract.*

### Features

*No features configure this contract.*
