# Feature: `cosmic`

Next-generation COSMIC desktop environment and greeter.

[← Back to Features Documentation](README.md) | [← Back to Main README](../../README.md)

- **Feature**: `cosmic`
- **Definition File**: [`modules/features/cosmic.nix`](../../modules/features/cosmic.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__cosmic["nixosModule/cosmic"]:::defaultNode
    urn__nixconf__onto__feature__cosmic("cosmic"):::featureNode

    urn__nixconf__onto__feature__cosmic -->|outputs| urn__nixconf__ast__module__cosmic


    click urn__nixconf__ast__module__cosmic href "../modules/cosmic.md" "cosmic"
    click urn__nixconf__onto__feature__cosmic href "cosmic.md" "cosmic"

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

## Outputs

### NixOS Modules

| Module | Description | Docs |
| :--- | :--- | :--- |
| [`cosmic`](../modules/cosmic.md) | Next-generation COSMIC desktop environment and greeter. | [More →](../modules/cosmic.md) |
