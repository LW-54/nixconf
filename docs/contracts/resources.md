# Contract: `resources`

System resource limits, cgroup slices, memory/CPU quotas, and power-aware throttling.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `resources`
- **Description**: System resource limits, cgroup slices, memory/CPU quotas, and power-aware throttling.
- **Definition File**: [`modules/contracts/resources.nix`](../../modules/contracts/resources.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        host__astrolabe["astrolabe"]:::hostNode
        host__x240["x240"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        contract__backup(["backup"]):::contractNode
        contract__persistence(["persistence"]):::contractNode
        contract__resources(["resources"]):::contractNode
        contract__reverse_proxy(["reverse-proxy"]):::contractNode
        contract__secrets(["secrets"]):::contractNode
    end

    subgraph Implementations["Implementations"]
        impl__caddy["caddy"]:::implNode
        impl__cgroups["cgroups"]:::implNode
        impl__restic["restic"]:::implNode
    end

    subgraph Features["Features"]
        feature__ttyd["ttyd"]:::featureNode
        feature__vaultwarden["vaultwarden"]:::featureNode
    end

    subgraph Libraries["Libraries"]
        lib__resources(["lib: resources"]):::libNode
    end

    subgraph ContractOptions["Contract Options"]
        opt__resources_defaultSlices_enable[/"resources.defaultSlices.enable: boolean"/]:::optNode
        opt__resources_enable[/"resources.enable: boolean"/]:::optNode
        opt__resources_services[/"resources.services: attribute set of (submodule)"/]:::optNode
        opt__resources_slices[/"resources.slices: attribute set of (submodule)"/]:::optNode
    end

    subgraph ContractTypes["Contract Types"]
        type__resources_byteSize{{"resources.byteSize"}}:::typeNode
        type__resources_cgroupWeight{{"resources.cgroupWeight"}}:::typeNode
        type__resources_service{{"resources.service"}}:::typeNode
        type__resources_slice{{"resources.slice"}}:::typeNode
    end

    subgraph Functions["Library Functions"]
        fn__resources_mkConfig(["resources.mkConfig"]):::fnNode
        fn__resources_mkOption(["resources.mkOption"]):::fnNode
    end

    subgraph OtherNodes["Other Entities"]
        fn__resources_defaultSlices["resources.defaultSlices"]
        fn__resources_profiles["resources.profiles"]
    end


    host__astrolabe -->|"imports"| impl__caddy
    host__astrolabe -->|"imports"| impl__cgroups
    host__astrolabe -->|"imports"| impl__restic
    host__astrolabe -->|"imports"| feature__ttyd
    host__astrolabe -->|"imports"| feature__vaultwarden
    host__x240 -->|"imports"| impl__cgroups
    impl__caddy -.->|"implements"| contract__reverse_proxy
    impl__cgroups -.->|"implements"| contract__resources
    impl__restic -.->|"implements"| contract__backup
    host__astrolabe -->|"consumes (reverse-proxy.domain)"| contract__reverse_proxy
    feature__ttyd -->|"consumes (resources.enable)"| contract__resources
    feature__ttyd -->|"consumes (reverse-proxy.enable)"| contract__reverse_proxy
    feature__vaultwarden -->|"consumes (backup.enable)"| contract__backup
    feature__vaultwarden -->|"consumes (persistence.enable)"| contract__persistence
    feature__vaultwarden -->|"consumes (resources.enable)"| contract__resources
    feature__vaultwarden -->|"consumes (reverse-proxy.domain)"| contract__reverse_proxy
    impl__caddy -->|"consumes (persistence.directories, persistence.enable)"| contract__persistence
    impl__caddy -->|"consumes (resources.services.caddy, resources.enable, resources.services)"| contract__resources
    impl__cgroups -->|"consumes (resources.enable)"| contract__resources
    impl__restic -->|"consumes (resources.services.restic-backups-main, resources.enable, resources.services)"| contract__resources
    impl__restic -->|"consumes (secrets.files)"| contract__secrets
    contract__resources -.->|"provides"| lib__resources
    contract__resources --- opt__resources_defaultSlices_enable
    contract__resources --- opt__resources_enable
    contract__resources --- opt__resources_services
    contract__resources --- opt__resources_slices
    contract__resources --- type__resources_byteSize
    contract__resources --- type__resources_cgroupWeight
    contract__resources --- type__resources_service
    contract__resources --- type__resources_slice
    lib__resources -->|"exports"| fn__resources_defaultSlices
    lib__resources -->|"exports"| fn__resources_mkConfig
    lib__resources -->|"exports"| fn__resources_mkOption
    lib__resources -->|"exports"| fn__resources_profiles

classDef hostNode fill:#1e1e2e,stroke:#cba6f7,stroke-width:2px,color:#cdd6f4;
classDef contractNode fill:#181825,stroke:#89b4fa,stroke-width:2px,color:#cdd6f4;
classDef implNode fill:#181825,stroke:#a6e3a1,stroke-width:2px,color:#cdd6f4;
classDef featureNode fill:#181825,stroke:#f38ba8,stroke-width:2px,color:#cdd6f4;
classDef libNode fill:#181825,stroke:#94e2d5,stroke-width:2px,color:#cdd6f4;
classDef optNode fill:#11111b,stroke:#fab387,stroke-width:1px,color:#cdd6f4;
classDef typeNode fill:#11111b,stroke:#f9e2af,stroke-width:1px,color:#cdd6f4;
classDef fnNode fill:#181825,stroke:#94e2d5,stroke-width:1px,color:#cdd6f4;
classDef pkgNode fill:#181825,stroke:#b4befe,stroke-width:1px,color:#cdd6f4;
classDef shellNode fill:#181825,stroke:#f5c2e7,stroke-width:1px,color:#cdd6f4;

```


## Option Schema Definitions

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `options.resources.defaultSlices.enable` | `boolean` | `1` | *none* | Whether to automatically declare standard hierarchical resource slices (`system.slice`, `production.slice`, `services.slice`, and `background.slice`). |
| `options.resources.enable` | `boolean` | `1` | `1` | Whether to enable system resource allocation contract. |
| `options.resources.services` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Attribute set of per-service resource policies and constraints mapped directly to individual systemd service unit configurations. |
| `options.resources.slices` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Attribute set of hierarchical systemd slice definitions mapping directly to Linux cgroups v2 resource controllers (CPU, memory, IO, and task counts). |


## Outputs

### Custom Submodule Types

| Type Name | Description | Docs |
| :--- | :--- | :--- |
| [`resources.byteSize`](../lib/resources.md#resources.byteSize) | Size with units (e.g. '64M', '2G', '512K') | [More →](../lib/resources.md#resources.byteSize) |
| [`resources.cgroupWeight`](../lib/resources.md#resources.cgroupWeight) | Cgroup weight integer between 1 and 10000 | [More →](../lib/resources.md#resources.cgroupWeight) |
| [`resources.service`](../lib/resources.md#resources.service) | submodule | [More →](../lib/resources.md#resources.service) |
| [`resources.slice`](../lib/resources.md#resources.slice) | submodule | [More →](../lib/resources.md#resources.slice) |


### Library Helpers

| Symbol | Description | Docs |
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

Configures options: `resources.services.caddy`, `resources.enable`, `resources.services`

```nix
resources.services.caddy = lib.mkIf (config.resources.enable or false) {
  profile = "critical";
  memory.low = "32M";
  memory.high = "256M";
  memory.max = "512M";
};
```

</details>


<details>
<summary><code><a href="../implementations/cgroups.md">cgroups</a></code></summary>

Configures options: `resources.enable`

```nix
profiles = self.lib.resources.profiles;
```

</details>


<details>
<summary><code><a href="../implementations/restic.md">restic</a></code></summary>

Configures options: `resources.services.restic-backups-main`, `resources.enable`, `resources.services`

```nix
resources.services.restic-backups-main = lib.mkIf (config.resources.enable or false) {
  profile = "background";
  memory.high = "512M";
  battery = {
    throttleOnBattery = true;
    pauseOnBattery = true;
  };
};
```

</details>


### Features

<details>
<summary><code><a href="../features/ttyd.md">ttyd</a></code></summary>

Configures options: `resources.enable`

```nix
// self.lib.resources.mkOption {
  profile = "standard";
  memory.high = "256M";
  memory.max = "512M";
}

(self.lib.resources.mkConfig {
  inherit config cfg;
  serviceName = "ttyd-web";
})
```

</details>


<details>
<summary><code><a href="../features/vaultwarden.md">vaultwarden</a></code></summary>

Configures options: `resources.enable`

```nix
// self.lib.resources.mkOption {
  profile = "critical";
  memory.guarantee = "64M";
  memory.limit = "512M";
}

(self.lib.resources.mkConfig {
  inherit config cfg;
  serviceName = "vaultwarden";
})
```

</details>

