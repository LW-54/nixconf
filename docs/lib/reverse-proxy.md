# Library: `reverse-proxy`

Library helpers and constructors for the 'reverse-proxy' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.reverse-proxy`
- **Definition File**: [`modules/contracts/reverse-proxy.nix`](../../modules/contracts/reverse-proxy.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__reverse_proxy_mkConfig["reverse-proxy.mkConfig"]:::defaultNode
    urn__nixconf__ast__function__reverse_proxy_mkOption["reverse-proxy.mkOption"]:::defaultNode
    urn__nixconf__onto__lib__reverse_proxy["reverse-proxy"]:::defaultNode

    urn__nixconf__onto__lib__reverse_proxy -->|outputs| urn__nixconf__ast__function__reverse_proxy_mkConfig
    urn__nixconf__onto__lib__reverse_proxy -->|outputs| urn__nixconf__ast__function__reverse_proxy_mkOption


    click urn__nixconf__ast__function__reverse_proxy_mkConfig href "reverse-proxy.md" "reverse-proxy.mkConfig"
    click urn__nixconf__ast__function__reverse_proxy_mkOption href "reverse-proxy.md" "reverse-proxy.mkOption"
    click urn__nixconf__onto__lib__reverse_proxy href "reverse-proxy.md" "reverse-proxy"

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
  example = self.lib.reverse-proxy.mkConfig;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.reverse-proxy.mkConfig;
  };
}
```

## Exported Symbols

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'reverse-proxy' contract.

#### Inputs

- `cfg`: Configuration binding parameter for the 'reverse-proxy' contract.
- `config`: Configuration binding parameter for the 'reverse-proxy' contract.

#### Type

```
reverse-proxy.mkConfig :: AttrSet -> AttrSet
```

#### Examples

```nix
reverse-proxy.mkConfig { inherit config cfg; }
```

<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'reverse-proxy' contract.

#### Inputs

- `address`: Submodule option parameter for the 'reverse-proxy' contract.
- `basicAuth`: Submodule option parameter for the 'reverse-proxy' contract.
- `port`: Submodule option parameter for the 'reverse-proxy' contract.
- `subdomain`: Submodule option parameter for the 'reverse-proxy' contract.

#### Type

```
reverse-proxy.mkOption :: AttrSet -> AttrSet
```

#### Examples

```nix
reverse-proxy.mkOption { ... }
```

<a id="types"></a>
### `types`

Custom option types declared under this library namespace:

- `fqdn`: Fully qualified domain name
- `host`: submodule
