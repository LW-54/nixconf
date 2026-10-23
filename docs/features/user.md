# Feature: `user`

Normal user account helper functions and querying utilities.

[← Back to Features Documentation](../FEATURES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Feature Name**: `user`
- **Description**: Normal user account helper functions and querying utilities.
- **Definition File**: [`modules/features/user.nix`](../../modules/features/user.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Features["Features"]
        feature__user["user"]:::featureNode
    end




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

*No NixOS modules exported.*

### Executable Packages

*No executable packages exported.*

### Development Shells

*No development shells exported.*

### Library Helpers

| Symbol | Description | Docs |
| :--- | :--- | :--- |
| [`flake.lib.user.forNormalUsers`](../lib/user.md#forNormalUsers) | Library helper symbol | [More →](../lib/user.md#forNormalUsers) |
| [`flake.lib.user.normalUserNames`](../lib/user.md#normalUserNames) | Library helper symbol | [More →](../lib/user.md#normalUserNames) |
| [`flake.lib.user.normalUsers`](../lib/user.md#normalUsers) | Library helper symbol | [More →](../lib/user.md#normalUsers) |




## Consumed Contracts

Capability contracts configured by this feature:

*No contracts consumed by this feature.*
