# Contract: `default-user`

Default primary user account identification, credentials, and configuration injection.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `default-user`
- **Description**: Default primary user account identification, credentials, and configuration injection.
- **Definition File**: [`modules/contracts/default-user.nix`](../../modules/contracts/default-user.nix)

## Architecture Diagram

flowchart LR
  urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__option__default_user_email[/"default-user.email"/]:::optNode
    urn__nixconf__ast__option__default_user_enable[/"default-user.enable"/]:::optNode
    urn__nixconf__ast__option__default_user_fullName[/"default-user.fullName"/]:::optNode
    urn__nixconf__ast__option__default_user_githubUsername[/"default-user.githubUsername"/]:::optNode
    urn__nixconf__ast__option__default_user_modules[/"default-user.modules"/]:::optNode
    urn__nixconf__ast__option__default_user_username[/"default-user.username"/]:::optNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__default_user{{"default-user"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__resources{{"resources"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__wayland{{"wayland"}}:::contractNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__primitive__contract["contract"]:::defaultNode
    urn__nixconf__onto__primitive__implementation["implementation"]:::defaultNode

    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_enable
    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_enable
    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_fullName
    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_fullName
    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_modules
    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_modules
    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_username
    urn__nixconf__ast__module__lw -. "reads" .-> urn__nixconf__ast__option__default_user_username
    urn__nixconf__ast__module__lw -. "writes = "leonardwilsonb@gmai" .-> urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -. "writes = "leonardwilsonb@gmai" .-> urn__nixconf__ast__option__default_user_email
    urn__nixconf__ast__module__lw -. "writes = "LW-54"" .-> urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -. "writes = "LW-54"" .-> urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__ast__module__lw -. "writes = "lw"" .-> urn__nixconf__ast__option__default_user_username
    urn__nixconf__ast__module__lw -. "writes = "lw"" .-> urn__nixconf__ast__option__default_user_username
    urn__nixconf__onto__contract__default_user -->|"declares"| urn__nixconf__ast__option__default_user_email
    urn__nixconf__onto__contract__default_user -->|"declares"| urn__nixconf__ast__option__default_user_enable
    urn__nixconf__onto__contract__default_user -->|"declares"| urn__nixconf__ast__option__default_user_fullName
    urn__nixconf__onto__contract__default_user -->|"declares"| urn__nixconf__ast__option__default_user_githubUsername
    urn__nixconf__onto__contract__default_user -->|"declares"| urn__nixconf__ast__option__default_user_modules
    urn__nixconf__onto__contract__default_user -->|"declares"| urn__nixconf__ast__option__default_user_username
    urn__nixconf__onto__host__astrolabe -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -. "consumes" .-> urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__host__x240 -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__implementation__lw -->|"outputs"| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw == "implements" ==> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw == "implements" ==> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__lw


    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__onto__contract__backup href "../contracts/backup.md" "backup"
    click urn__nixconf__onto__contract__default_user href "../contracts/default-user.md" "default-user"
    click urn__nixconf__onto__contract__home href "../contracts/home.md" "home"
    click urn__nixconf__onto__contract__persistence href "../contracts/persistence.md" "persistence"
    click urn__nixconf__onto__contract__resources href "../contracts/resources.md" "resources"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "../contracts/secrets.md" "secrets"
    click urn__nixconf__onto__contract__wayland href "../contracts/wayland.md" "wayland"
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


## Option Schema Definitions

| Option | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `options.default-user.email` | `string` | *null* | `alice@example.com` | Primary email address associated with the default user. |
| `options.default-user.enable` | `boolean` | `1` | `1` | Whether to enable system default user contract. |
| `options.default-user.fullName` | `null or string` | *null* | `Alice Smith` | Display name / GECOS description of the default user. |
| `options.default-user.githubUsername` | `string` | *null* | `alice` | GitHub username of the default user. |
| `options.default-user.modules` | `list of module` | `[ ... ]` | `[ ... ]` | Arbitrary NixOS configuration modules contributed by other features for the default user, evaluated and merged into the system when enabled. |
| `options.default-user.username` | `string` | *null* | `alice` | Username of the default user account. |

## Outputs

### Custom Submodule Types

*No custom types declared.*

### Library Helpers

| Symbol | Description | Details |
| :--- | :--- | :--- |
| [`flake.lib.default-user.forDefaultUser`](../lib/default-user.md#forDefaultUser) | Contract option constructor / binding helper | [More →](../lib/default-user.md#forDefaultUser) |

## Implementations

Providers satisfying the `default-user` contract capability:

| Implementation | Description | Docs |
| :--- | :--- | :--- |
| [`lw`](../implementations/lw.md) | Primary human user account orchestration and identity provisioning. | [More →](../implementations/lw.md) |

## Contract Consumers

Modules configuring options under the `default-user` contract capability:

### Hosts

*No hosts configure this contract directly.*

### Implementations

<details>
<summary><code><a href="../implementations/lw.md">lw</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../implementations/lw.md">lw</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../implementations/lw.md">lw</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


### Features

*No features configure this contract.*
