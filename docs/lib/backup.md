# Library: `backup`

Library helpers and constructors for the 'backup' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.backup`
- **Definition File**: [`modules/contracts/backup.nix`](../../modules/contracts/backup.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__backup_mkConfig["backup.mkConfig"]:::defaultNode
    urn__nixconf__ast__function__backup_mkOption["backup.mkOption"]:::defaultNode
    urn__nixconf__ast__symbol__backup_defaultPruneOpts["backup.defaultPruneOpts"]:::defaultNode
    urn__nixconf__ast__symbol__backup_defaultTimerConfig["backup.defaultTimerConfig"]:::defaultNode
    urn__nixconf__onto__lib__backup["backup"]:::defaultNode

    urn__nixconf__onto__lib__backup -->|outputs| urn__nixconf__ast__function__backup_mkConfig
    urn__nixconf__onto__lib__backup -->|outputs| urn__nixconf__ast__function__backup_mkOption
    urn__nixconf__onto__lib__backup -->|outputs| urn__nixconf__ast__symbol__backup_defaultPruneOpts
    urn__nixconf__onto__lib__backup -->|outputs| urn__nixconf__ast__symbol__backup_defaultTimerConfig


    click urn__nixconf__ast__function__backup_mkConfig href "backup.md" "backup.mkConfig"
    click urn__nixconf__ast__function__backup_mkOption href "backup.md" "backup.mkOption"
    click urn__nixconf__ast__symbol__backup_defaultPruneOpts href "backup.md" "backup.defaultPruneOpts"
    click urn__nixconf__ast__symbol__backup_defaultTimerConfig href "backup.md" "backup.defaultTimerConfig"
    click urn__nixconf__onto__lib__backup href "backup.md" "backup"

  %% Semantic Visual Classes
  classDef hostNode fill:#1e293b,stroke:#38bdf8,stroke-width:2px,color:#f8fafc;
  classDef contractNode fill:#1e1b4b,stroke:#818cf8,stroke-width:2px,color:#f8fafc;
  classDef implNode fill:#0f172a,stroke:#34d399,stroke-width:2px,color:#f8fafc;
  classDef featureNode fill:#134e4a,stroke:#2dd4bf,stroke-width:2px,color:#f8fafc;
  classDef optNode fill:#422006,stroke:#facc15,stroke-width:1px,color:#fefce8;
  classDef typeNode fill:#3b0764,stroke:#c084fc,stroke-width:1px,color:#faf5ff;
  classDef pkgNode fill:#4c0519,stroke:#fb7185,stroke-width:1px,color:#fff1f2;
  classDef devShellNode fill:#451a03,stroke:#fb923c,stroke-width:1px,color:#fff7ed;
  classDef drvNode fill:#18181b,stroke:#a1a1aa,stroke-width:1px,color:#f4f4f5;
  classDef defaultNode fill:#1e293b,stroke:#64748b,stroke-width:1px,color:#f8fafc;
```

</details>

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

```nix
{ self, lib, pkgs, ... }: {
  example = self.lib.backup.defaultPruneOpts;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.backup.defaultPruneOpts;
  };
}
```

## Exported Symbols

<a id="defaultPruneOpts"></a>
### `defaultPruneOpts`

Default snapshot retention rules passed to the backup backend pruning command.
Preserves 7 daily, 4 weekly, and 12 monthly snapshots.

#### Type

```
defaultPruneOpts :: [String]
```

<a id="defaultTimerConfig"></a>
### `defaultTimerConfig`

Default systemd timer configuration for automated backup operations.
Executes daily at 04:00 with persistent timer catch-up.

#### Type

```
defaultTimerConfig :: AttrSet
```

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'backup' contract.

#### Inputs

- `cfg`: Configuration binding parameter for the 'backup' contract.
- `config`: Configuration binding parameter for the 'backup' contract.

#### Type

```
backup.mkConfig :: AttrSet -> AttrSet
```

#### Examples

```nix
backup.mkConfig { inherit config cfg; }
```

<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'backup' contract.

#### Inputs

- `args`: Service-specific options to include.

#### Type

```
backup.mkOption :: AttrSet -> AttrSet
```

#### Examples

```nix
backup.mkOption { ... }
```
