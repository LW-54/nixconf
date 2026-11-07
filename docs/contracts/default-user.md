# Contract: `default-user`

Default primary user account identification, credentials, and configuration injection.

[← Back to Contracts Documentation](README.md) | [← Back to Main README](../../README.md)

- **Contract**: `default-user`
- **Definition File**: [`modules/contracts/default-user.nix`](../../modules/contracts/default-user.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__option__default_user_email[/"default-user.email"/]:::optNode
    urn__nixconf__ast__option__default_user_enable[/"default-user.enable"/]:::optNode
    urn__nixconf__ast__option__default_user_fullName[/"default-user.fullName"/]:::optNode
    urn__nixconf__ast__option__default_user_githubUsername[/"default-user.githubUsername"/]:::optNode
    urn__nixconf__ast__option__default_user_username[/"default-user.username"/]:::optNode
    urn__nixconf__onto__contract__default_user{{"default-user"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__testing{{"testing"}}:::contractNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode

    urn__nixconf__ast__module__lw -.->|reads| urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -.->|reads| urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -.->|reads| urn__nixconf__ast__option__default_user_username
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__default_user_username
    urn__nixconf__onto__contract__default_user -->|declares| urn__nixconf__ast__option__default_user_email
    urn__nixconf__onto__contract__default_user -->|declares| urn__nixconf__ast__option__default_user_enable
    urn__nixconf__onto__contract__default_user -->|declares| urn__nixconf__ast__option__default_user_fullName
    urn__nixconf__onto__contract__default_user -->|declares| urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__onto__contract__default_user -->|declares| urn__nixconf__ast__option__default_user_username
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__implementation__lw -->|outputs| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__testing
    urn__nixconf__onto__implementation__lw ==>|implements| urn__nixconf__onto__contract__default_user


    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__ast__option__default_user_email href "default-user.md" "default-user.email"
    click urn__nixconf__ast__option__default_user_enable href "default-user.md" "default-user.enable"
    click urn__nixconf__ast__option__default_user_fullName href "default-user.md" "default-user.fullName"
    click urn__nixconf__ast__option__default_user_githubUsername href "default-user.md" "default-user.githubUsername"
    click urn__nixconf__ast__option__default_user_username href "default-user.md" "default-user.username"
    click urn__nixconf__onto__contract__default_user href "default-user.md" "default-user"
    click urn__nixconf__onto__contract__home href "home.md" "home"
    click urn__nixconf__onto__contract__persistence href "persistence.md" "persistence"
    click urn__nixconf__onto__contract__secrets href "secrets.md" "secrets"
    click urn__nixconf__onto__contract__testing href "testing.md" "testing"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"

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
| [`default-user`](../modules/default-user.md) | Default primary user account identification, credentials, and configuration injection. | [More →](../modules/default-user.md) |

## Option Schema Definitions

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `default-user.email` | `string` | *null* | Primary email address associated with the default user. |
| `default-user.enable` | `boolean` | `true` | Whether to enable system default user contract. |
| `default-user.fullName` | `null or string` | *null* | Display name / GECOS description of the default user. |
| `default-user.githubUsername` | `string` | *null* | GitHub username of the default user. |
| `default-user.username` | `string` | *null* | Username of the default user account. |

## Fulfilling Implementations

Providers satisfying the `default-user` contract capability:

| Implementation | Description | Definition | Docs |
| :--- | :--- | :--- | :--- |
| [`lw`](../implementations/lw.md) | Primary human user account orchestration and identity provisioning. | [`modules/implementations/lw.nix`](../../modules/implementations/lw.nix) | [More →](../implementations/lw.md) |

## Contract Consumers

Modules and instances configuring options under the `default-user` contract capability:



### Implementations

<details>
<summary><code><a href="../implementations/lw.md">lw</a></code></summary>

**Configures options**: `default-user.email`, `default-user.githubUsername`, `default-user.username`

```nix
# modules/implementations/lw.nix
...
56: default-user = {
57: username = Identity.username.value;
58: githubUsername = Identity.githubUsername.value;
59: email = Identity.email.value;
...
```

</details>
