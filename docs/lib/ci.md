# Library: `ci`

Continuous integration workflow helpers, YAML serialization, and derivation collection utilities.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.ci`
- **Definition File**: [`meta/ci/lib.nix`](../../meta/ci/lib.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__ci_collectBuildables["ci.collectBuildables"]:::defaultNode
    urn__nixconf__ast__function__ci_fromYAML["ci.fromYAML"]:::defaultNode
    urn__nixconf__ast__function__ci_toYAML["ci.toYAML"]:::defaultNode
    urn__nixconf__onto__lib__ci["ci"]:::defaultNode

    urn__nixconf__onto__lib__ci -->|outputs| urn__nixconf__ast__function__ci_collectBuildables
    urn__nixconf__onto__lib__ci -->|outputs| urn__nixconf__ast__function__ci_fromYAML
    urn__nixconf__onto__lib__ci -->|outputs| urn__nixconf__ast__function__ci_toYAML


    click urn__nixconf__ast__function__ci_collectBuildables href "ci.md" "ci.collectBuildables"
    click urn__nixconf__ast__function__ci_fromYAML href "ci.md" "ci.fromYAML"
    click urn__nixconf__ast__function__ci_toYAML href "ci.md" "ci.toYAML"
    click urn__nixconf__onto__lib__ci href "ci.md" "ci"

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
  example = self.lib.ci.collectBuildables;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.ci.collectBuildables;
  };
}
```

## Exported Symbols

<a id="collectBuildables"></a>
### `collectBuildables`

Universally walks all outputs in self to collect buildable derivations for a system.

#### Inputs

- `system`: System architecture string (e.g. "x86_64-linux").

#### Type

```
collectBuildables :: String -> AttrSet
```

<a id="fromYAML"></a>
### `fromYAML`

Parses raw YAML text into a Nix attribute set via remarshal.

#### Inputs

- `pkgs`: Package set providing the remarshal tool.
- `str`: Raw YAML string content to parse.

#### Type

```
fromYAML :: Pkgs -> String -> AttrSet
```

<a id="toYAML"></a>
### `toYAML`

Compiles and formats YAML with yamlfmt, pre-linting with actionlint.

#### Inputs

- `pkgs`: Package set providing yamlfmt and actionlint.
- `name`: Workflow name string used for output file naming.
- `data`: Native Nix attribute set or raw YAML string representing the workflow.

#### Type

```
toYAML :: Pkgs -> String -> (AttrSet | String) -> Derivation
```
