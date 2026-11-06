# Library: `home`

Library helpers and constructors for the 'home' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.home`
- **Definition File**: [`modules/contracts/home.nix`](../../modules/contracts/home.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__home_mkConfig["home.mkConfig"]:::defaultNode
    urn__nixconf__ast__function__home_mkOption["home.mkOption"]:::defaultNode
    urn__nixconf__onto__lib__home["home"]:::defaultNode

    urn__nixconf__onto__lib__home -->|outputs| urn__nixconf__ast__function__home_mkConfig
    urn__nixconf__onto__lib__home -->|outputs| urn__nixconf__ast__function__home_mkOption


    click urn__nixconf__ast__function__home_mkConfig href "home.md" "home.mkConfig"
    click urn__nixconf__ast__function__home_mkOption href "home.md" "home.mkOption"
    click urn__nixconf__onto__lib__home href "home.md" "home"

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
  example = self.lib.home.mkConfig;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.home.mkConfig;
  };
}
```

## Exported Symbols

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'home' contract.

#### Inputs

- `config`: Configuration binding parameter for the 'home' contract.
- `homeConfig`: Configuration binding parameter for the 'home' contract.
- `lib`: Configuration binding parameter for the 'home' contract.

#### Type

```
home.mkConfig :: AttrSet -> AttrSet
```

#### Examples

```nix
home.mkConfig { inherit config cfg; }
```

<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'home' contract.

#### Inputs

- `defaultEnable`: Submodule option parameter for the 'home' contract.
- `description`: Submodule option parameter for the 'home' contract.
- `lib`: Submodule option parameter for the 'home' contract.
- `name`: Submodule option parameter for the 'home' contract.
- `userOptions`: Submodule option parameter for the 'home' contract.

#### Type

```
home.mkOption :: AttrSet -> AttrSet
```

#### Examples

```nix
home.mkOption { ... }
```

<a id="types"></a>
### `types`

Custom option types declared under this library namespace:

- `file`: open submodule of attribute set of anything
- `files`: attribute set of (open submodule of attribute set of anything)
- `relativeHomePath`: Relative path within home directory (no leading '/' or '..')
- `userHome`: submodule
- `xdg`: submodule
