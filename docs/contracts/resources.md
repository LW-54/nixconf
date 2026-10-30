# Contract: `resources`

System resource limits, cgroup slices, memory/CPU quotas, and power-aware throttling.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `resources`
- **Description**: System resource limits, cgroup slices, memory/CPU quotas, and power-aware throttling.
- **Definition File**: [`modules/contracts/resources.nix`](../../modules/contracts/resources.nix)

## Architecture Diagram

```mermaid
flowchart LR
  urn__nixconf__ast__module__caddy["nixosModule/caddy"]:::defaultNode
    urn__nixconf__ast__module__cgroups["nixosModule/cgroups"]:::defaultNode
    urn__nixconf__ast__module__restic["nixosModule/restic"]:::defaultNode
    urn__nixconf__ast__module__ttyd["nixosModule/ttyd"]:::defaultNode
    urn__nixconf__ast__module__vaultwarden["nixosModule/vaultwarden"]:::defaultNode
    urn__nixconf__ast__option__resources_defaultSlices_enable[/"resources.defaultSlices.enable"/]:::optNode
    urn__nixconf__ast__option__resources_enable[/"resources.enable"/]:::optNode
    urn__nixconf__ast__option__resources_services[/"resources.services"/]:::optNode
    urn__nixconf__ast__option__resources_slices[/"resources.slices"/]:::optNode
    urn__nixconf__ast__type__resources_byteSize[["resources.byteSize"]]:::typeNode
    urn__nixconf__ast__type__resources_cgroupWeight[["resources.cgroupWeight"]]:::typeNode
    urn__nixconf__ast__type__resources_service[["resources.service"]]:::typeNode
    urn__nixconf__ast__type__resources_slice[["resources.slice"]]:::typeNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__default_user{{"default-user"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__resources{{"resources"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__wayland{{"wayland"}}:::contractNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__primitive__contract["contract"]:::defaultNode
    urn__nixconf__onto__primitive__feature["feature"]:::defaultNode
    urn__nixconf__onto__primitive__implementation["implementation"]:::defaultNode

    urn__nixconf__ast__module__caddy -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__caddy -.->|writes| urn__nixconf__ast__option__resources_services
    urn__nixconf__ast__module__cgroups -.->|reads| urn__nixconf__ast__option__resources_services
    urn__nixconf__ast__module__restic -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__restic -.->|writes| urn__nixconf__ast__option__resources_services
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ttyd -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__ttyd -.->|writes| urn__nixconf__ast__option__resources_services
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__cgroups
    urn__nixconf__ast__module__vaultwarden -.->|flowsTo| urn__nixconf__ast__module__restic
    urn__nixconf__ast__module__vaultwarden -.->|writes| urn__nixconf__ast__option__resources_services
    urn__nixconf__ast__option__resources_services -.->|typedBy| urn__nixconf__ast__type__resources_service
    urn__nixconf__ast__option__resources_services -.->|typedBy| urn__nixconf__ast__type__resources_slice
    urn__nixconf__ast__option__resources_slices -.->|typedBy| urn__nixconf__ast__type__resources_service
    urn__nixconf__ast__option__resources_slices -.->|typedBy| urn__nixconf__ast__type__resources_slice
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_defaultSlices_enable
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_enable
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_services
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__option__resources_slices
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_byteSize
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_cgroupWeight
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_service
    urn__nixconf__onto__contract__resources -->|declares| urn__nixconf__ast__type__resources_slice
    urn__nixconf__onto__feature__ttyd -->|outputs| urn__nixconf__ast__module__ttyd
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ttyd -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -->|outputs| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__vaultwarden -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__implementation__caddy -->|outputs| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__caddy ==>|implements| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__cgroups -->|outputs| urn__nixconf__ast__module__cgroups
    urn__nixconf__onto__implementation__cgroups ==>|implements| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__restic -->|outputs| urn__nixconf__ast__module__restic
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__restic -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic ==>|implements| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__home
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract -->|contains| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__feature -->|contains| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__primitive__feature -->|contains| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__primitive__implementation -->|contains| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__primitive__implementation -->|contains| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__primitive__implementation -->|contains| urn__nixconf__onto__implementation__restic


    click urn__nixconf__ast__module__caddy href "../modules/caddy.md" "caddy"
    click urn__nixconf__ast__module__cgroups href "../modules/cgroups.md" "cgroups"
    click urn__nixconf__ast__module__restic href "../modules/restic.md" "restic"
    click urn__nixconf__ast__module__ttyd href "../modules/ttyd.md" "ttyd"
    click urn__nixconf__ast__module__vaultwarden href "../modules/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__contract__backup href "../contracts/backup.md" "backup"
    click urn__nixconf__onto__contract__default_user href "../contracts/default-user.md" "default-user"
    click urn__nixconf__onto__contract__home href "../contracts/home.md" "home"
    click urn__nixconf__onto__contract__persistence href "../contracts/persistence.md" "persistence"
    click urn__nixconf__onto__contract__resources href "../contracts/resources.md" "resources"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "../contracts/secrets.md" "secrets"
    click urn__nixconf__onto__contract__wayland href "../contracts/wayland.md" "wayland"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__cgroups href "../implementations/cgroups.md" "cgroups"
    click urn__nixconf__onto__implementation__restic href "../implementations/restic.md" "restic"

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
| `options.resources.defaultSlices.enable` | `boolean` | `1` | *none* | Whether to automatically declare standard hierarchical resource slices (`system.slice`, `production.slice`, `services.slice`, and `background.slice`). |
| `options.resources.enable` | `boolean` | `1` | `1` | Whether to enable system resource allocation contract. |
| `options.resources.services` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Attribute set of per-service resource policies and constraints mapped directly to individual systemd service unit configurations. |
| `options.resources.slices` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Attribute set of hierarchical systemd slice definitions mapping directly to Linux cgroups v2 resource controllers (CPU, memory, IO, and task counts). |

## Outputs

### Custom Submodule Types

| Type | Description | Details |
| :--- | :--- | :--- |
| [`resources.byteSize`](../lib/resources.md#resources.byteSize) | Size with units (e.g. '64M', '2G', '512K') | [More →](../lib/resources.md#resources.byteSize) |
| [`resources.cgroupWeight`](../lib/resources.md#resources.cgroupWeight) | Cgroup weight integer between 1 and 10000 | [More →](../lib/resources.md#resources.cgroupWeight) |
| [`resources.service`](../lib/resources.md#resources.service) | submodule | [More →](../lib/resources.md#resources.service) |
| [`resources.slice`](../lib/resources.md#resources.slice) | submodule | [More →](../lib/resources.md#resources.slice) |

### Library Helpers

| Symbol | Description | Details |
| :--- | :--- | :--- |
| [`flake.lib.resources.mkOption`](../lib/resources.md#mkOption) | Contract option constructor / binding helper | [More →](../lib/resources.md#mkOption) |
| [`flake.lib.resources.mkConfig`](../lib/resources.md#mkConfig) | Contract option constructor / binding helper | [More →](../lib/resources.md#mkConfig) |
| [`flake.lib.resources.types`](../lib/resources.md#types) | Contract option constructor / binding helper | [More →](../lib/resources.md#types) |
| [`flake.lib.resources.defaultSlices`](../lib/resources.md#defaultSlices) | Contract option constructor / binding helper | [More →](../lib/resources.md#defaultSlices) |
| [`flake.lib.resources.profiles`](../lib/resources.md#profiles) | Contract option constructor / binding helper | [More →](../lib/resources.md#profiles) |

## Implementations

Providers satisfying the `resources` contract capability:

| Implementation | Description | Docs |
| :--- | :--- | :--- |
| [`cgroups`](../implementations/cgroups.md) | Systemd control groups slice hierarchy and resource quotas implementation. | [More →](../implementations/cgroups.md) |

## Contract Consumers

Modules configuring options under the `resources` contract capability:

### Hosts

*No hosts configure this contract directly.*

### Implementations

<details>
<summary><code><a href="../implementations/caddy.md">caddy</a></code></summary>

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
<summary><code><a href="../features/ttyd.md">ttyd</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


<details>
<summary><code><a href="../features/vaultwarden.md">vaultwarden</a></code></summary>

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>

