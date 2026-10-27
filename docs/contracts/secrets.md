# Contract: `secrets`

Declarative encrypted secrets provisioning, filesystem mounting, and permission management.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `secrets`
- **Description**: Declarative encrypted secrets provisioning, filesystem mounting, and permission management.
- **Definition File**: [`modules/contracts/secrets.nix`](../../modules/contracts/secrets.nix)

## Architecture Diagram

```mermaid
flowchart LR
  urn__nixconf__ast__module__lw["nixosModule/lw"]:::defaultNode
    urn__nixconf__ast__module__nix["nixosModule/nix"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__sops["nixosModule/sops"]:::defaultNode
    urn__nixconf__ast__module__ssh["nixosModule/ssh"]:::defaultNode
    urn__nixconf__ast__module__wifi_eduroam["nixosModule/wifi-eduroam"]:::defaultNode
    urn__nixconf__ast__option__secrets_defaultFile[/"secrets.defaultFile"/]:::optNode
    urn__nixconf__ast__option__secrets_enable[/"secrets.enable"/]:::optNode
    urn__nixconf__ast__option__secrets_files[/"secrets.files"/]:::optNode
    urn__nixconf__ast__type__secrets_secret[["secrets.secret"]]:::typeNode
    urn__nixconf__drv__devShell__master_ssh["devShell/master-ssh"]:::devShellNode
    urn__nixconf__drv__devShell__sops_admin["devShell/sops-admin"]:::devShellNode
    urn__nixconf__drv__devShell__sops_host["devShell/sops-host"]:::devShellNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__default_user{{"default-user"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__resources{{"resources"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__wayland{{"wayland"}}:::contractNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__wifi_eduroam("wifi-eduroam"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode
    urn__nixconf__onto__primitive__contract["contract"]:::defaultNode
    urn__nixconf__onto__primitive__feature["feature"]:::defaultNode
    urn__nixconf__onto__primitive__implementation["implementation"]:::defaultNode

    urn__nixconf__ast__module__lw -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__lw -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__nix -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__nix -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__sops -.->|reads| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__ssh -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__ssh -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__module__wifi_eduroam -.->|flowsTo| urn__nixconf__ast__module__sops
    urn__nixconf__ast__module__wifi_eduroam -.->|writes| urn__nixconf__ast__option__secrets_files
    urn__nixconf__ast__option__secrets_files -.->|typedBy| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_defaultFile
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_enable
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__option__secrets_files
    urn__nixconf__onto__contract__secrets -->|declares| urn__nixconf__ast__type__secrets_secret
    urn__nixconf__onto__feature__nix -->|outputs| urn__nixconf__ast__module__nix
    urn__nixconf__onto__feature__nix -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__ast__module__ssh
    urn__nixconf__onto__feature__ssh -->|outputs| urn__nixconf__drv__devShell__master_ssh
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__wifi_eduroam -->|outputs| urn__nixconf__ast__module__wifi_eduroam
    urn__nixconf__onto__feature__wifi_eduroam -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__feature__wifi_eduroam
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__implementation__lw -->|outputs| urn__nixconf__ast__module__lw
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw ==>|implements| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__restic -->|outputs| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic ==>|implements| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__ast__module__sops
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__drv__devShell__sops_admin
    urn__nixconf__onto__implementation__sops -->|outputs| urn__nixconf__drv__devShell__sops_host
    urn__nixconf__onto__implementation__sops ==>|implements| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__home
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__feature -->|contains| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__primitive__feature -->|contains| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__primitive__feature -->|contains| urn__nixconf__onto__feature__wifi_eduroam
    urn__nixconf__onto__primitive__implementation -->|contains| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__primitive__implementation -->|contains| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__primitive__implementation -->|contains| urn__nixconf__onto__implementation__sops


    click urn__nixconf__ast__module__lw href "../modules/lw.md" "lw"
    click urn__nixconf__ast__module__nix href "../modules/nix.md" "nix"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__sops href "../modules/sops.md" "sops"
    click urn__nixconf__ast__module__ssh href "../modules/ssh.md" "ssh"
    click urn__nixconf__ast__module__wifi_eduroam href "../modules/wifi-eduroam.md" "wifi-eduroam"
    click urn__nixconf__drv__devShell__master_ssh href "../DEVSHELLS.md#master-ssh" "master-ssh"
    click urn__nixconf__drv__devShell__sops_admin href "../DEVSHELLS.md#sops-admin" "sops-admin"
    click urn__nixconf__drv__devShell__sops_host href "../DEVSHELLS.md#sops-host" "sops-host"
    click urn__nixconf__onto__contract__backup href "../contracts/backup.md" "backup"
    click urn__nixconf__onto__contract__default_user href "../contracts/default-user.md" "default-user"
    click urn__nixconf__onto__contract__home href "../contracts/home.md" "home"
    click urn__nixconf__onto__contract__persistence href "../contracts/persistence.md" "persistence"
    click urn__nixconf__onto__contract__resources href "../contracts/resources.md" "resources"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "../contracts/secrets.md" "secrets"
    click urn__nixconf__onto__contract__wayland href "../contracts/wayland.md" "wayland"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__wifi_eduroam href "../features/wifi-eduroam.md" "wifi-eduroam"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__lw href "../implementations/lw.md" "lw"
    click urn__nixconf__onto__implementation__restic href "../implementations/restic.md" "restic"
    click urn__nixconf__onto__implementation__sops href "../implementations/sops.md" "sops"

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


## Option Schema Definitions

| Option | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `options.secrets.defaultFile` | `null or absolute path` | *null* | `{ ... }` | Default YAML/JSON file containing encrypted secrets for this host. Can be overridden on a per-secret basis by consumer features. |
| `options.secrets.enable` | `boolean` | `1` | `1` | Whether to enable system secrets management contract. |
| `options.secrets.files` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Attribute set of declarative secret items required by system services. Mapped to the active secrets provider implementation (e.g. SOPS). |

## Outputs

### Custom Submodule Types

| Type | Description | Details |
| :--- | :--- | :--- |
| [`secrets.secret`](../lib/secrets.md#secrets.secret) | submodule | [More →](../lib/secrets.md#secrets.secret) |

### Library Helpers

| Symbol | Description | Details |
| :--- | :--- | :--- |
| [`flake.lib.secrets.mkOption`](../lib/secrets.md#mkOption) | Contract option constructor / binding helper | [More →](../lib/secrets.md#mkOption) |
| [`flake.lib.secrets.mkConfig`](../lib/secrets.md#mkConfig) | Contract option constructor / binding helper | [More →](../lib/secrets.md#mkConfig) |
| [`flake.lib.secrets.types`](../lib/secrets.md#types) | Contract option constructor / binding helper | [More →](../lib/secrets.md#types) |

## Implementations

Providers satisfying the `secrets` contract capability:

| Implementation | Description | Docs |
| :--- | :--- | :--- |
| [`sops`](../implementations/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [More →](../implementations/sops.md) |

## Contract Consumers

Modules configuring options under the `secrets` contract capability:

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
<summary><code><a href="../implementations/restic.md">restic</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


### Features

<details>
<summary><code><a href="../features/nix.md">nix</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/ssh.md">ssh</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/wifi-eduroam.md">wifi-eduroam</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>

