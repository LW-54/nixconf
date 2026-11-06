# Library: `lw`

Primary human user account orchestration and identity provisioning.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.lw`
- **Definition File**: [`modules/implementations/lw.nix`](../../modules/implementations/lw.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__symbol__lw_email["lw.email"]:::defaultNode
    urn__nixconf__ast__symbol__lw_githubUsername["lw.githubUsername"]:::defaultNode
    urn__nixconf__ast__symbol__lw_username["lw.username"]:::defaultNode
    urn__nixconf__onto__lib__lw["lw"]:::defaultNode

    urn__nixconf__onto__lib__lw -->|outputs| urn__nixconf__ast__symbol__lw_email
    urn__nixconf__onto__lib__lw -->|outputs| urn__nixconf__ast__symbol__lw_githubUsername
    urn__nixconf__onto__lib__lw -->|outputs| urn__nixconf__ast__symbol__lw_username


    click urn__nixconf__ast__symbol__lw_email href "lw.md" "lw.email"
    click urn__nixconf__ast__symbol__lw_githubUsername href "lw.md" "lw.githubUsername"
    click urn__nixconf__ast__symbol__lw_username href "lw.md" "lw.username"
    click urn__nixconf__onto__lib__lw href "lw.md" "lw"

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
  example = self.lib.lw.email;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.lw.email;
  };
}
```

## Exported Symbols

<a id="email"></a>
### `email`

Primary email address for user account lw.

#### Type

```
email :: String
```

<a id="githubUsername"></a>
### `githubUsername`

Primary GitHub account username for user account lw.

#### Type

```
githubUsername :: String
```

<a id="username"></a>
### `username`

Primary login username for user account lw.

#### Type

```
username :: String
```
