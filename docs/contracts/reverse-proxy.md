# Contract: `reverse-proxy`

Declarative HTTP/TLS reverse proxy virtual host ingress and routing management.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `reverse-proxy`
- **Description**: Declarative HTTP/TLS reverse proxy virtual host ingress and routing management.
- **Definition File**: [`modules/contracts/reverse-proxy.nix`](../../modules/contracts/reverse-proxy.nix)

## Architecture Diagram

```mermaid
flowchart TD
    subgraph Hosts["Hosts"]
        host__astrolabe["astrolabe"]:::hostNode
    end

    subgraph Contracts["Contracts"]
        contract__backup(["backup"]):::contractNode
        contract__persistence(["persistence"]):::contractNode
        contract__resources(["resources"]):::contractNode
        contract__reverse_proxy(["reverse-proxy"]):::contractNode
    end

    subgraph Implementations["Implementations"]
        impl__caddy["caddy"]:::implNode
        impl__cgroups["cgroups"]:::implNode
        impl__impermanence["impermanence"]:::implNode
        impl__lw["lw"]:::implNode
        impl__restic["restic"]:::implNode
        impl__sops["sops"]:::implNode
    end

    subgraph Features["Features"]
        feature__disko["disko"]:::featureNode
        feature__git["git"]:::featureNode
        feature__locale["locale"]:::featureNode
        feature__nix["nix"]:::featureNode
        feature__ssh["ssh"]:::featureNode
        feature__ttyd["ttyd"]:::featureNode
        feature__vaultwarden["vaultwarden"]:::featureNode
    end

    subgraph Libraries["Libraries"]
        lib__reverse_proxy(["lib: reverse-proxy"]):::libNode
    end

    subgraph ContractOptions["Contract Options"]
        opt__reverse_proxy_domain[/"reverse-proxy.domain: null or (Fully qualified domain name)"/]:::optNode
        opt__reverse_proxy_enable[/"reverse-proxy.enable: boolean"/]:::optNode
        opt__reverse_proxy_hosts[/"reverse-proxy.hosts: attribute set of (submodule)"/]:::optNode
    end

    subgraph ContractTypes["Contract Types"]
        type__reverse_proxy_fqdn{{"reverse-proxy.fqdn"}}:::typeNode
        type__reverse_proxy_host{{"reverse-proxy.host"}}:::typeNode
    end

    subgraph Functions["Library Functions"]
        fn__reverse_proxy_mkConfig(["reverse-proxy.mkConfig"]):::fnNode
        fn__reverse_proxy_mkOption(["reverse-proxy.mkOption"]):::fnNode
    end


    host__astrolabe -->|"imports"| impl__caddy
    host__astrolabe -->|"imports"| impl__cgroups
    host__astrolabe -->|"imports"| impl__impermanence
    host__astrolabe -->|"imports"| impl__lw
    host__astrolabe -->|"imports"| impl__restic
    host__astrolabe -->|"imports"| impl__sops
    host__astrolabe -->|"imports"| feature__disko
    host__astrolabe -->|"imports"| feature__git
    host__astrolabe -->|"imports"| feature__locale
    host__astrolabe -->|"imports"| feature__nix
    host__astrolabe -->|"imports"| feature__ssh
    host__astrolabe -->|"imports"| feature__ttyd
    host__astrolabe -->|"imports"| feature__vaultwarden
    impl__caddy -.->|"implements"| contract__reverse_proxy
    impl__cgroups -.->|"implements"| contract__resources
    impl__impermanence -.->|"implements"| contract__persistence
    impl__restic -.->|"implements"| contract__backup
    host__astrolabe -->|"consumes (reverse-proxy.domain)"| contract__reverse_proxy
    feature__ssh -->|"consumes (persistence.files, persistence.enable)"| contract__persistence
    feature__ttyd -->|"consumes (resources.enable)"| contract__resources
    feature__ttyd -->|"consumes (reverse-proxy.enable)"| contract__reverse_proxy
    feature__vaultwarden -->|"consumes (backup.enable)"| contract__backup
    feature__vaultwarden -->|"consumes (persistence.enable)"| contract__persistence
    feature__vaultwarden -->|"consumes (resources.enable)"| contract__resources
    feature__vaultwarden -->|"consumes (reverse-proxy.domain)"| contract__reverse_proxy
    impl__caddy -->|"consumes (persistence.directories, persistence.enable)"| contract__persistence
    impl__caddy -->|"consumes (resources.services.caddy, resources.enable, resources.services)"| contract__resources
    impl__cgroups -->|"consumes (resources.enable)"| contract__resources
    impl__impermanence -->|"consumes (persistence.users)"| contract__persistence
    impl__lw -->|"consumes (persistence.users)"| contract__persistence
    impl__restic -->|"consumes (resources.services.restic-backups-main, resources.enable, resources.services)"| contract__resources
    contract__reverse_proxy -.->|"provides"| lib__reverse_proxy
    contract__reverse_proxy --- opt__reverse_proxy_domain
    contract__reverse_proxy --- opt__reverse_proxy_enable
    contract__reverse_proxy --- opt__reverse_proxy_hosts
    contract__reverse_proxy --- type__reverse_proxy_fqdn
    contract__reverse_proxy --- type__reverse_proxy_host
    lib__reverse_proxy -->|"exports"| fn__reverse_proxy_mkConfig
    lib__reverse_proxy -->|"exports"| fn__reverse_proxy_mkOption

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
| `options.reverse-proxy.domain` | `null or (Fully qualified domain name)` | *null* | `adje.app` | Base root domain name used for virtual host construction. Services providing a subdomain prefix will be exposed as `<subdomain>.<domain>`. |
| `options.reverse-proxy.enable` | `boolean` | `1` | `1` | Whether to enable system reverse proxy contract. |
| `options.reverse-proxy.hosts` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Attribute set of virtual host fully-qualified domain names (FQDN) mapped to upstream backend endpoints and proxy policies. |


## Outputs

### Custom Submodule Types

| Type Name | Description | Docs |
| :--- | :--- | :--- |
| [`reverse-proxy.fqdn`](../lib/reverse-proxy.md#reverse-proxy.fqdn) | Fully qualified domain name | [More →](../lib/reverse-proxy.md#reverse-proxy.fqdn) |
| [`reverse-proxy.host`](../lib/reverse-proxy.md#reverse-proxy.host) | submodule | [More →](../lib/reverse-proxy.md#reverse-proxy.host) |


### Library Helpers

| Symbol | Description | Docs |
| :--- | :--- | :--- |
| [`flake.lib.reverse-proxy.mkOption`](../lib/reverse-proxy.md#mkOption) | Contract option constructor / binding helper | [More →](../lib/reverse-proxy.md#mkOption) |
| [`flake.lib.reverse-proxy.mkConfig`](../lib/reverse-proxy.md#mkConfig) | Contract option constructor / binding helper | [More →](../lib/reverse-proxy.md#mkConfig) |
| [`flake.lib.reverse-proxy.types`](../lib/reverse-proxy.md#types) | Contract option constructor / binding helper | [More →](../lib/reverse-proxy.md#types) |


## Implementations

Providers satisfying the `reverse-proxy` contract capability:

| Implementation | Description | Docs |
| :--- | :--- | :--- |
| [`caddy`](../implementations/caddy.md) | Automated TLS virtual host reverse proxy implementation using Caddy. | [More →](../implementations/caddy.md) |

## Contract Consumers

Modules configuring options under the `reverse-proxy` contract capability:

### Hosts

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

Configures options: `reverse-proxy.domain`

```nix
reverse-proxy.domain = "adje.app";
```

</details>


### Implementations

*No implementations configure this contract.*

### Features

<details>
<summary><code><a href="../features/ttyd.md">ttyd</a></code></summary>

Configures options: `reverse-proxy.enable`

```nix
// self.lib.reverse-proxy.mkOption {
  subdomain = "ttyd";
  port = 7681;
  basicAuth = {admin = "$2a$14$vYmK17NeNy4sdgvOm6SAheSigD5Lnus70w8aJfQgLBceSG0hlVrPK";};
}

(self.lib.reverse-proxy.mkConfig {inherit config cfg;})
```

</details>


<details>
<summary><code><a href="../features/vaultwarden.md">vaultwarden</a></code></summary>

Configures options: `reverse-proxy.domain`

```nix
// self.lib.reverse-proxy.mkOption {
  subdomain = "vaultwarden";
  port = 8222;
}

domain = config.reverse-proxy.domain or null;

(self.lib.reverse-proxy.mkConfig {inherit config cfg;})
```

</details>

