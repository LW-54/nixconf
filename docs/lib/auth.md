# Library: `auth`

Library helpers and constructors for the 'auth' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.auth`
- **Definition File**: [`modules/contracts/auth/default.nix`](../../modules/contracts/auth/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__auth_mkConfig["auth.mkConfig"]:::defaultNode
    urn__nixconf__ast__function__auth_mkOption["auth.mkOption"]:::defaultNode
    urn__nixconf__onto__lib__auth["auth"]:::defaultNode

    urn__nixconf__onto__lib__auth -->|outputs| urn__nixconf__ast__function__auth_mkConfig
    urn__nixconf__onto__lib__auth -->|outputs| urn__nixconf__ast__function__auth_mkOption


    click urn__nixconf__ast__function__auth_mkConfig href "auth.md" "auth.mkConfig"
    click urn__nixconf__ast__function__auth_mkOption href "auth.md" "auth.mkOption"
    click urn__nixconf__onto__lib__auth href "auth.md" "auth"

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
  example = self.lib.auth.mkConfig;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.auth.mkConfig;
  };
}
```

## Exported Symbols

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'auth' contract.

#### Inputs

- `cfg`: Configuration binding parameter for the 'auth' contract.
- `config`: Configuration binding parameter for the 'auth' contract.

#### Type

```
auth.mkConfig :: AttrSet -> AttrSet
```

#### Examples

```nix
auth.mkConfig { inherit config cfg; }
```

<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'auth' contract.

#### Inputs

- `policy`: Submodule option parameter for the 'auth' contract.
- `resources`: Submodule option parameter for the 'auth' contract.
- `subject`: Submodule option parameter for the 'auth' contract.

#### Type

```
auth.mkOption :: AttrSet -> AttrSet
```

#### Examples

```nix
auth.mkOption { ... }
```

<a id="types"></a>
### `types`

Custom option types declared under this library namespace:

- `directory`: submodule
- `policy`: one of "bypass", "one_factor", "two_factor", "deny"
- `rule`: submodule
