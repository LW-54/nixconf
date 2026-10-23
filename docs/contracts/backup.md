# Contract: `backup`

Automated snapshot backup configuration, inclusion paths, exclusions, and retention rules.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `backup`
- **Description**: Automated snapshot backup configuration, inclusion paths, exclusions, and retention rules.
- **Definition File**: [`modules/contracts/backup.nix`](../../modules/contracts/backup.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        host__astrolabe["astrolabe"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        contract__backup(["backup"]):::contractNode
        contract__persistence(["persistence"]):::contractNode
        contract__resources(["resources"]):::contractNode
        contract__reverse_proxy(["reverse-proxy"]):::contractNode
        contract__secrets(["secrets"]):::contractNode
    end

    subgraph Implementations["Implementations"]
        impl__restic["restic"]:::implNode
    end

    subgraph Features["Features"]
        feature__vaultwarden["vaultwarden"]:::featureNode
    end

    subgraph ContractOptions["Contract Options"]
        opt__backup_enable[/"backup.enable: boolean"/]:::optNode
        opt__backup_exclude[/"backup.exclude: list of string"/]:::optNode
        opt__backup_paths[/"backup.paths: list of absolute path"/]:::optNode
        opt__backup_pruneOpts[/"backup.pruneOpts: list of string"/]:::optNode
        opt__backup_timerConfig[/"backup.timerConfig: attribute set of anything"/]:::optNode
    end


    host__astrolabe -->|"imports"| impl__restic
    host__astrolabe -->|"imports"| feature__vaultwarden
    impl__restic -.->|"implements"| contract__backup
    host__astrolabe -->|"consumes (reverse-proxy.domain)"| contract__reverse_proxy
    feature__vaultwarden -->|"consumes (backup.enable)"| contract__backup
    feature__vaultwarden -->|"consumes (persistence.enable)"| contract__persistence
    feature__vaultwarden -->|"consumes (resources.enable)"| contract__resources
    feature__vaultwarden -->|"consumes (reverse-proxy.domain)"| contract__reverse_proxy
    impl__restic -->|"consumes (resources.services.restic-backups-main, resources.enable, resources.services)"| contract__resources
    impl__restic -->|"consumes (secrets.files)"| contract__secrets
    contract__backup --- opt__backup_enable
    contract__backup --- opt__backup_exclude
    contract__backup --- opt__backup_paths
    contract__backup --- opt__backup_pruneOpts
    contract__backup --- opt__backup_timerConfig

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
| `options.backup.enable` | `boolean` | `1` | `1` | Whether to enable system backup automation contract. |
| `options.backup.exclude` | `list of string` | `[ ... ]` | `[ ... ]` | List of glob patterns, file paths, or directories to explicitly exclude from backup snapshots (e.g. cache directories, transient sockets). |
| `options.backup.paths` | `list of absolute path` | `[ ... ]` | `[ ... ]` | List of absolute filesystem directory or file paths to include in the backup snapshot. Aggregated across all active service modules via `mkConfig`. |
| `options.backup.pruneOpts` | `list of string` | `[ ... ]` | *none* | Command-line argument rules passed to the backup backend pruning command to enforce snapshot retention and prevent unbounded remote storage usage. |
| `options.backup.timerConfig` | `attribute set of anything` | `{ ... }` | *none* | Systemd timer specification governing when automated backup snapshots run. Defaults to executing daily at 04:00 with persistence enabled. |


## Outputs

### Custom Submodule Types

*No custom types declared directly on this contract.*

### Library Helpers

| Symbol | Description | Docs |
| :--- | :--- | :--- |
| [`flake.lib.backup.defaultPruneOpts`](../lib/backup.md#defaultPruneOpts) | Contract option constructor / binding helper | [More →](../lib/backup.md#defaultPruneOpts) |
| [`flake.lib.backup.defaultTimerConfig`](../lib/backup.md#defaultTimerConfig) | Contract option constructor / binding helper | [More →](../lib/backup.md#defaultTimerConfig) |
| [`flake.lib.backup.mkConfig`](../lib/backup.md#mkConfig) | Contract option constructor / binding helper | [More →](../lib/backup.md#mkConfig) |
| [`flake.lib.backup.mkOption`](../lib/backup.md#mkOption) | Contract option constructor / binding helper | [More →](../lib/backup.md#mkOption) |


## Implementations

Providers satisfying the `backup` contract capability:

| Implementation | Description | Docs |
| :--- | :--- | :--- |
| [`restic`](../implementations/restic.md) | Automated encrypted remote backups using Restic and systemd timers. | [More →](../implementations/restic.md) |

## Contract Consumers

Modules configuring options under the `backup` contract capability:

### Hosts

*No hosts configure this contract directly.*

### Implementations

*No implementations configure this contract.*

### Features

<details>
<summary><code><a href="../features/vaultwarden.md">vaultwarden</a></code></summary>

Configures options: `backup.enable`

```nix
// self.lib.backup.mkOption {
  paths = ["/var/lib/vaultwarden"];
};

(self.lib.backup.mkConfig {inherit config cfg;})
```

</details>

