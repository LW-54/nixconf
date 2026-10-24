# Contract: `home`

Declarative user home dotfile tree, XDG directory specifications, and session environment.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `home`
- **Description**: Declarative user home dotfile tree, XDG directory specifications, and session environment.
- **Definition File**: [`modules/contracts/home.nix`](../../modules/contracts/home.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        host__x240["x240"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        contract__home(["home"]):::contractNode
    end

    subgraph Implementations["Implementations"]
        impl__hjem["hjem"]:::implNode
    end

    subgraph ContractOptions["Contract Options"]
        opt__home_enable[/"home.enable: boolean"/]:::optNode
        opt__home_shared[/"home.shared: submodule"/]:::optNode
        opt__home_users[/"home.users: attribute set of (submodule)"/]:::optNode
    end

    subgraph ContractTypes["Contract Types"]
        type__home_file{{"home.file"}}:::typeNode
        type__home_files{{"home.files"}}:::typeNode
        type__home_relativeHomePath{{"home.relativeHomePath"}}:::typeNode
        type__home_userHome{{"home.userHome"}}:::typeNode
        type__home_xdg{{"home.xdg"}}:::typeNode
    end


    host__x240 -->|"imports"| impl__hjem
    impl__hjem -.->|"implements"| contract__home
    contract__home --- opt__home_enable
    contract__home --- opt__home_shared
    contract__home --- opt__home_users
    contract__home --- type__home_file
    contract__home --- type__home_files
    contract__home --- type__home_relativeHomePath
    contract__home --- type__home_userHome
    contract__home --- type__home_xdg

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
| `options.home.enable` | `boolean` | `1` | `1` | Whether to enable declarative user home dotfile and environment contract. |
| `options.home.shared` | `submodule` | `{ ... }` | `{ ... }` | Shared dotfile tree and environment configurations applied across all managed users. |
| `options.home.users` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Per-user dotfile tree and environment configurations mapped to active backend interpreters (e.g. Hjem). |


## Outputs

### Custom Submodule Types

| Type Name | Description | Docs |
| :--- | :--- | :--- |
| [`home.file`](../lib/home.md#home.file) | open submodule of attribute set of anything | [More →](../lib/home.md#home.file) |
| [`home.files`](../lib/home.md#home.files) | attribute set of (open submodule of attribute set of anything) | [More →](../lib/home.md#home.files) |
| [`home.relativeHomePath`](../lib/home.md#home.relativeHomePath) | Relative path within home directory (no leading '/' or '..') | [More →](../lib/home.md#home.relativeHomePath) |
| [`home.userHome`](../lib/home.md#home.userHome) | submodule | [More →](../lib/home.md#home.userHome) |
| [`home.xdg`](../lib/home.md#home.xdg) | submodule | [More →](../lib/home.md#home.xdg) |


### Library Helpers

| Symbol | Description | Docs |
| :--- | :--- | :--- |
| [`flake.lib.home.mkOption`](../lib/home.md#mkOption) | Contract option constructor / binding helper | [More →](../lib/home.md#mkOption) |
| [`flake.lib.home.mkConfig`](../lib/home.md#mkConfig) | Contract option constructor / binding helper | [More →](../lib/home.md#mkConfig) |
| [`flake.lib.home.types`](../lib/home.md#types) | Contract option constructor / binding helper | [More →](../lib/home.md#types) |


## Implementations

Providers satisfying the `home` contract capability:

| Implementation | Description | Docs |
| :--- | :--- | :--- |
| [`hjem`](../implementations/hjem.md) | Lightweight declarative home directory files and XDG environment manager. | [More →](../implementations/hjem.md) |

## Contract Consumers

Modules configuring options under the `home` contract capability:

### Hosts

*No hosts configure this contract directly.*

### Implementations

*No implementations configure this contract.*

### Features

*No features configure this contract.*
