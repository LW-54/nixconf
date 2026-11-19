# Library: `monitoring`

Library helpers and constructors for the 'monitoring' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.monitoring`
- **Definition File**: [`modules/contracts/monitoring/default.nix`](../../modules/contracts/monitoring/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__monitoring_mkConfig["monitoring.mkConfig"]:::defaultNode
    urn__nixconf__ast__function__monitoring_mkOption["monitoring.mkOption"]:::defaultNode
    urn__nixconf__onto__lib__monitoring["monitoring"]:::defaultNode

    urn__nixconf__onto__lib__monitoring -->|outputs| urn__nixconf__ast__function__monitoring_mkConfig
    urn__nixconf__onto__lib__monitoring -->|outputs| urn__nixconf__ast__function__monitoring_mkOption


    click urn__nixconf__ast__function__monitoring_mkConfig href "monitoring.md" "monitoring.mkConfig"
    click urn__nixconf__ast__function__monitoring_mkOption href "monitoring.md" "monitoring.mkOption"
    click urn__nixconf__onto__lib__monitoring href "monitoring.md" "monitoring"

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
  example = self.lib.monitoring.mkConfig;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.monitoring.mkConfig;
  };
}
```

## Exported Symbols

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'monitoring' contract.

#### Inputs

- `cfg`: Configuration binding parameter for the 'monitoring' contract.
- `config`: Configuration binding parameter for the 'monitoring' contract.
- `name`: Configuration binding parameter for the 'monitoring' contract.

#### Type

```
monitoring.mkConfig :: AttrSet -> AttrSet
```

#### Examples

```nix
monitoring.mkConfig { inherit config cfg; }
```

<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'monitoring' contract.

#### Inputs

- `dashboards`: Submodule option parameter for the 'monitoring' contract.
- `enable`: Submodule option parameter for the 'monitoring' contract.
- `logFiles`: Submodule option parameter for the 'monitoring' contract.
- `metrics`: Submodule option parameter for the 'monitoring' contract.
- `probe`: Submodule option parameter for the 'monitoring' contract.
- `rules`: Submodule option parameter for the 'monitoring' contract.
- `units`: Submodule option parameter for the 'monitoring' contract.

#### Type

```
monitoring.mkOption :: AttrSet -> AttrSet
```

#### Examples

```nix
monitoring.mkOption { ... }
```

<a id="types"></a>
### `types`

Custom option types declared under this library namespace:

- `agent`: submodule
- `dashboard`: submodule
- `exporters`: submodule
- `fileLog`: submodule
- `journalLogs`: submodule
- `logs`: submodule
- `probe`: submodule
- `ruleGroup`: submodule
- `ruleItem`: submodule
- `scrape`: submodule
- `server`: submodule
