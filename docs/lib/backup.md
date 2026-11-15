# Library: `backup`

Library helpers and constructors for the 'backup' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.backup`
- **Definition File**: [`modules/contracts/backup/default.nix`](../../modules/contracts/backup/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__backup_mkConfig["backup.mkConfig"]:::defaultNode
    urn__nixconf__ast__function__backup_mkOption["backup.mkOption"]:::defaultNode
    urn__nixconf__ast__function__backup_retentionToPruneOpts["backup.retentionToPruneOpts"]:::defaultNode
    urn__nixconf__ast__function__backup_scheduleToTimerConfig["backup.scheduleToTimerConfig"]:::defaultNode
    urn__nixconf__ast__symbol__backup_defaultPruneOpts["backup.defaultPruneOpts"]:::defaultNode
    urn__nixconf__ast__symbol__backup_defaultTimerConfig["backup.defaultTimerConfig"]:::defaultNode
    urn__nixconf__onto__lib__backup["backup"]:::defaultNode

    urn__nixconf__onto__lib__backup -->|outputs| urn__nixconf__ast__function__backup_mkConfig
    urn__nixconf__onto__lib__backup -->|outputs| urn__nixconf__ast__function__backup_mkOption
    urn__nixconf__onto__lib__backup -->|outputs| urn__nixconf__ast__function__backup_retentionToPruneOpts
    urn__nixconf__onto__lib__backup -->|outputs| urn__nixconf__ast__function__backup_scheduleToTimerConfig
    urn__nixconf__onto__lib__backup -->|outputs| urn__nixconf__ast__symbol__backup_defaultPruneOpts
    urn__nixconf__onto__lib__backup -->|outputs| urn__nixconf__ast__symbol__backup_defaultTimerConfig


    click urn__nixconf__ast__function__backup_mkConfig href "backup.md" "backup.mkConfig"
    click urn__nixconf__ast__function__backup_mkOption href "backup.md" "backup.mkOption"
    click urn__nixconf__ast__function__backup_retentionToPruneOpts href "backup.md" "backup.retentionToPruneOpts"
    click urn__nixconf__ast__function__backup_scheduleToTimerConfig href "backup.md" "backup.scheduleToTimerConfig"
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

Default restic snapshot retention arguments (`--keep-daily 7 --keep-weekly 4 --keep-monthly 6`).

#### Type

```
defaultPruneOpts :: [String]
```

<a id="defaultTimerConfig"></a>
### `defaultTimerConfig`

Default systemd timer configuration (`hourly`) for backup jobs.

#### Type

```
defaultTimerConfig :: Attrs
```

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'backup' contract.

#### Inputs

- `cfg`: Configuration binding parameter for the 'backup' contract.
- `name`: Configuration binding parameter for the 'backup' contract.

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

- `autoRestore`: Submodule option parameter for the 'backup' contract.
- `beforeUnits`: Submodule option parameter for the 'backup' contract.
- `destinationOverrides`: Submodule option parameter for the 'backup' contract.
- `destinations`: Submodule option parameter for the 'backup' contract.
- `enable`: Submodule option parameter for the 'backup' contract.
- `exclude`: Submodule option parameter for the 'backup' contract.
- `paths`: Submodule option parameter for the 'backup' contract.
- `scope`: Submodule option parameter for the 'backup' contract.

#### Type

```
backup.mkOption :: AttrSet -> AttrSet
```

#### Examples

```nix
backup.mkOption { ... }
```

<a id="retentionToPruneOpts"></a>
### `retentionToPruneOpts`

Convert a structured retention policy attrset into `restic forget --prune` CLI flags.

#### Type

```
retentionToPruneOpts :: Retention -> [String]
```

<a id="scheduleToTimerConfig"></a>
### `scheduleToTimerConfig`

Convert a structured backup schedule attrset into systemd `timerConfig` attributes.

#### Type

```
scheduleToTimerConfig :: Schedule -> Attrs
```

<a id="types"></a>
### `types`

Custom option types declared under this library namespace:

- `destination`: submodule
- `destinationOverride`: submodule
- `retention`: submodule
- `schedule`: submodule
- `unit`: submodule
