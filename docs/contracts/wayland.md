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
        host__x240["x240"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        contract__wayland(["wayland"]):::contractNode
    end

    subgraph Implementations["Implementations"]
        impl__uwsm["uwsm"]:::implNode
    end

    subgraph ContractOptions["Contract Options"]
        opt__wayland_compositors[/"wayland.compositors: attribute set of (submodule)"/]:::optNode
        opt__wayland_enable[/"wayland.enable: boolean"/]:::optNode
    end

    subgraph ContractTypes["Contract Types"]
        type__wayland_compositor{{"wayland.compositor"}}:::typeNode
    end


    host__x240 -->|"imports"| impl__uwsm
    impl__uwsm -.->|"implements"| contract__wayland
    contract__wayland --- opt__wayland_compositors
    contract__wayland --- opt__wayland_enable
    contract__wayland --- type__wayland_compositor

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

*No hosts configure this contract directly.*

### Implementations

*No implementations configure this contract.*

### Features

*No features configure this contract.*
