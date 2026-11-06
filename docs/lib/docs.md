# Library: `docs`

Documentation generator turning the `docs` page registry, primitive metadata, and the architecture graph into markdown.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.docs`
- **Definition File**: [`meta/docs/render.nix`](../../meta/docs/render.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__docs_generateAll["docs.generateAll"]:::defaultNode
    urn__nixconf__ast__function__docs_relPath["docs.relPath"]:::defaultNode
    urn__nixconf__ast__symbol__docs_audit["docs.audit"]:::defaultNode
    urn__nixconf__onto__lib__docs["docs"]:::defaultNode

    urn__nixconf__onto__lib__docs -->|outputs| urn__nixconf__ast__function__docs_generateAll
    urn__nixconf__onto__lib__docs -->|outputs| urn__nixconf__ast__function__docs_relPath
    urn__nixconf__onto__lib__docs -->|outputs| urn__nixconf__ast__symbol__docs_audit


    click urn__nixconf__ast__function__docs_generateAll href "docs.md" "docs.generateAll"
    click urn__nixconf__ast__function__docs_relPath href "docs.md" "docs.relPath"
    click urn__nixconf__ast__symbol__docs_audit href "docs.md" "docs.audit"
    click urn__nixconf__onto__lib__docs href "docs.md" "docs"

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
  example = self.lib.docs.audit;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.docs.audit;
  };
}
```

## Exported Symbols

<a id="audit"></a>
### `audit`

Documentation coverage and quality health report.

#### Type

```
audit :: AttrSet
```

<a id="generateAll"></a>
### `generateAll`

Renders every page registered under `config.docs.pages` into an attribute set mapping repository-relative paths to markdown.

#### Inputs

- `system`: Platform used to evaluate packages and the architecture graph (default: "x86_64-linux").
- `cpg`: Pre-computed Semantic Code Property Graph (optional).
- `graph`: Pre-computed architecture graph (optional).

#### Type

```
generateAll :: AttrSet -> AttrSet
```

#### Examples

```nix
builtins.attrNames (self.lib.docs.generateAll {})
```

<a id="relPath"></a>
### `relPath`

Computes the relative markdown link from one repository file to another path (optionally with an `#anchor`).

#### Inputs

- `from`: Repository-relative path of the page containing the link.
- `to`: Repository-relative target path, optionally suffixed by `#anchor`.

#### Type

```
relPath :: String -> String -> String
```

#### Examples

```nix
relPath "docs/hosts/x240.md" "docs/contracts/home.md"
=> "../contracts/home.md"
```
