# Library: `secrets`

Library helpers and constructors for the 'secrets' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.secrets`
- **Definition File**: [`modules/contracts/secrets.nix`](../../modules/contracts/secrets.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__secrets_mkConfig["secrets.mkConfig"]:::defaultNode
    urn__nixconf__ast__function__secrets_mkOption["secrets.mkOption"]:::defaultNode
    urn__nixconf__onto__lib__secrets["secrets"]:::defaultNode

    urn__nixconf__onto__lib__secrets -->|outputs| urn__nixconf__ast__function__secrets_mkConfig
    urn__nixconf__onto__lib__secrets -->|outputs| urn__nixconf__ast__function__secrets_mkOption


    click urn__nixconf__ast__function__secrets_mkConfig href "secrets.md" "secrets.mkConfig"
    click urn__nixconf__ast__function__secrets_mkOption href "secrets.md" "secrets.mkOption"
    click urn__nixconf__onto__lib__secrets href "secrets.md" "secrets"

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
  example = self.lib.secrets.mkConfig;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.secrets.mkConfig;
  };
}
```

## Exported Symbols

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'secrets' contract.

#### Inputs

- `cfg`: Configuration binding parameter for the 'secrets' contract.
- `config`: Configuration binding parameter for the 'secrets' contract.
- `secrets`: Configuration binding parameter for the 'secrets' contract.

#### Type

```
secrets.mkConfig :: AttrSet -> AttrSet
```

#### Examples

```nix
secrets.mkConfig { inherit config cfg; }
```

<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'secrets' contract.

#### Inputs

- `secrets`: Submodule option parameter for the 'secrets' contract.

#### Type

```
secrets.mkOption :: AttrSet -> AttrSet
```

#### Examples

```nix
secrets.mkOption { ... }
```

<a id="types"></a>
### `types`

Custom option types declared under this library namespace:

- `secret`: submodule
