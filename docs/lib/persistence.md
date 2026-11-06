# Library: `persistence`

Library helpers and constructors for the 'persistence' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.persistence`
- **Definition File**: [`modules/contracts/persistence.nix`](../../modules/contracts/persistence.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__persistence_mkConfig["persistence.mkConfig"]:::defaultNode
    urn__nixconf__ast__function__persistence_mkOption["persistence.mkOption"]:::defaultNode
    urn__nixconf__ast__symbol__persistence_entries["persistence.entries"]:::defaultNode
    urn__nixconf__onto__lib__persistence["persistence"]:::defaultNode

    urn__nixconf__onto__lib__persistence -->|outputs| urn__nixconf__ast__function__persistence_mkConfig
    urn__nixconf__onto__lib__persistence -->|outputs| urn__nixconf__ast__function__persistence_mkOption
    urn__nixconf__onto__lib__persistence -->|outputs| urn__nixconf__ast__symbol__persistence_entries


    click urn__nixconf__ast__function__persistence_mkConfig href "persistence.md" "persistence.mkConfig"
    click urn__nixconf__ast__function__persistence_mkOption href "persistence.md" "persistence.mkOption"
    click urn__nixconf__ast__symbol__persistence_entries href "persistence.md" "persistence.entries"
    click urn__nixconf__onto__lib__persistence href "persistence.md" "persistence"

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
  example = self.lib.persistence.entries;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.persistence.entries;
  };
}
```

## Exported Symbols

<a id="entries"></a>
### `entries`

List of directory or file paths to persist, either strings or custom bind-mount attribute sets.

#### Type

```
entries :: Type
```

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'persistence' contract.

#### Inputs

- `cfg`: Configuration binding parameter for the 'persistence' contract.
- `config`: Configuration binding parameter for the 'persistence' contract.

#### Type

```
persistence.mkConfig :: AttrSet -> AttrSet
```

#### Examples

```nix
persistence.mkConfig { inherit config cfg; }
```

<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'persistence' contract.

#### Inputs

- `args`: Service-specific options to include.

#### Type

```
persistence.mkOption :: AttrSet -> AttrSet
```

#### Examples

```nix
persistence.mkOption { ... }
```

<a id="types"></a>
### `types`

Custom option types declared under this library namespace:

- `entries`: list of (string or attribute set of anything)
- `user`: submodule
