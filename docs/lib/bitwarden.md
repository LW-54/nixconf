# Library: `bitwarden`

Bitwarden password manager CLI wrapper, desktop application, and vault retrieval helpers.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.bitwarden`
- **Definition File**: [`modules/features/bitwarden.nix`](../../modules/features/bitwarden.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__bitwarden_mkShell["bitwarden.mkShell"]:::defaultNode
    urn__nixconf__ast__function__bitwarden_mkValue["bitwarden.mkValue"]:::defaultNode
    urn__nixconf__onto__lib__bitwarden["bitwarden"]:::defaultNode

    urn__nixconf__onto__lib__bitwarden -->|outputs| urn__nixconf__ast__function__bitwarden_mkShell
    urn__nixconf__onto__lib__bitwarden -->|outputs| urn__nixconf__ast__function__bitwarden_mkValue


    click urn__nixconf__ast__function__bitwarden_mkShell href "bitwarden.md" "bitwarden.mkShell"
    click urn__nixconf__ast__function__bitwarden_mkValue href "bitwarden.md" "bitwarden.mkValue"
    click urn__nixconf__onto__lib__bitwarden href "bitwarden.md" "bitwarden"

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
  example = self.lib.bitwarden.mkShell;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.bitwarden.mkShell;
  };
}
```

## Exported Symbols

<a id="mkShell"></a>
### `mkShell`

Creates a development shell pre-configured with Bitwarden CLI and jq for secrets manipulation.

#### Inputs

- `pkgs`: Package set supplying jq and shell dependencies.
- `bw`: Wrapped Bitwarden CLI package derivation.

#### Type

```
mkShell :: AttrSet -> Derivation
```

#### Examples

```nix
bitwarden.mkShell {
  inherit pkgs;
  bw = pkgs.bitwarden-cli;
}
```

<a id="mkValue"></a>
### `mkValue`

Generates a bash snippet that retrieves and optionally exports a Bitwarden vault value via jq.

#### Inputs

- `itemId`: Bitwarden vault item UUID.
- `jqFilter`: jq filter expression extracting the required field.
- `variable`: Environment variable name to store the secret into (optional).
- `exportVariable`: Whether to export the assigned environment variable (default: true).
- `bw`: Path or executable name for Bitwarden CLI binary (default: "bw").
- `jq`: Path or executable name for jq binary (default: "jq").

#### Type

```
mkValue :: AttrSet -> String
```

#### Examples

```nix
bitwarden.mkValue {
  itemId = "00000000-0000-0000-0000-000000000000";
  jqFilter = ".login.password";
}
```
