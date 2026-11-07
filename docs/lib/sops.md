# Library: `sops`

Declarative encrypted secrets provisioning using SOPS and age keys.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.sops`
- **Definition File**: [`modules/implementations/sops.nix`](../../modules/implementations/sops.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__sops_mkHostShell["sops.mkHostShell"]:::defaultNode
    urn__nixconf__ast__function__sops_mkTestSecrets["sops.mkTestSecrets"]:::defaultNode
    urn__nixconf__onto__lib__sops["sops"]:::defaultNode

    urn__nixconf__onto__lib__sops -->|outputs| urn__nixconf__ast__function__sops_mkHostShell
    urn__nixconf__onto__lib__sops -->|outputs| urn__nixconf__ast__function__sops_mkTestSecrets


    click urn__nixconf__ast__function__sops_mkHostShell href "sops.md" "sops.mkHostShell"
    click urn__nixconf__ast__function__sops_mkTestSecrets href "sops.md" "sops.mkTestSecrets"
    click urn__nixconf__onto__lib__sops href "sops.md" "sops"

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
  example = self.lib.sops.mkHostShell;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.sops.mkHostShell;
  };
}
```

## Exported Symbols

<a id="mkHostShell"></a>
### `mkHostShell`

Constructs a developer shell configured to decrypt host SOPS secrets with the host's age key.

#### Inputs

- `pkgs`: Nixpkgs package set.
- `keyFile`: Path to the age private key file on the host (default: `/persist/sops-nix/key.txt`).

#### Type

```
mkHostShell :: { pkgs, keyFile ? Path } -> Derivation
```

#### Examples

```nix
self.lib.sops.mkHostShell { inherit pkgs; }
```

<a id="mkTestSecrets"></a>
### `mkTestSecrets`

Builds a deterministic test age key plus SOPS-encrypted files holding test stand-in values, used in test mode.

#### Inputs

- `pkgs`: Nixpkgs package set.
- `secrets`: Attribute set of `{ key, format, value }` keyed by secret name.

#### Type

```
mkTestSecrets :: { pkgs, secrets } -> Derivation
```

#### Examples

```nix
self.lib.sops.mkTestSecrets {
  inherit pkgs;
  secrets.api-token = { key = "token"; format = "yaml"; value = "dummy"; };
}
```
