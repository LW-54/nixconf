# Library: `user`

Normal user account helper functions and querying utilities.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.user`
- **Definition File**: [`modules/features/user.nix`](../../modules/features/user.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__user_forNormalUsers["user.forNormalUsers"]:::defaultNode
    urn__nixconf__ast__function__user_normalUserNames["user.normalUserNames"]:::defaultNode
    urn__nixconf__ast__function__user_normalUsers["user.normalUsers"]:::defaultNode
    urn__nixconf__onto__lib__user["user"]:::defaultNode

    urn__nixconf__onto__lib__user -->|outputs| urn__nixconf__ast__function__user_forNormalUsers
    urn__nixconf__onto__lib__user -->|outputs| urn__nixconf__ast__function__user_normalUserNames
    urn__nixconf__onto__lib__user -->|outputs| urn__nixconf__ast__function__user_normalUsers


    click urn__nixconf__ast__function__user_forNormalUsers href "user.md" "user.forNormalUsers"
    click urn__nixconf__ast__function__user_normalUserNames href "user.md" "user.normalUserNames"
    click urn__nixconf__ast__function__user_normalUsers href "user.md" "user.normalUsers"
    click urn__nixconf__onto__lib__user href "user.md" "user"

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
  example = self.lib.user.forNormalUsers;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.user.forNormalUsers;
  };
}
```

## Exported Symbols

<a id="forNormalUsers"></a>
### `forNormalUsers`

Maps an attribute set generation function across all normal users.

#### Inputs

- `config`: Evaluated NixOS system configuration.
- `f`: Function `(userName -> userAttrs -> AttrSet)`.

#### Type

```
forNormalUsers :: Config -> (String -> AttrSet -> AttrSet) -> AttrSet
```

#### Examples

```nix
forNormalUsers config (userName: user: {
  data.directories = [".config/example"];
})
```

<a id="normalUserNames"></a>
### `normalUserNames`

Returns list of usernames for all normal users on the system.

#### Inputs

- `config`: Evaluated NixOS system configuration.

#### Type

```
normalUserNames :: Config -> [String]
```

#### Examples

```nix
normalUserNames config
```

<a id="normalUsers"></a>
### `normalUsers`

Filters `config.users.users` down to normal human user accounts (`isNormalUser = true`).

#### Inputs

- `config`: Evaluated NixOS system configuration.

#### Type

```
normalUsers :: Config -> AttrSet
```

#### Examples

```nix
normalUsers config
```
