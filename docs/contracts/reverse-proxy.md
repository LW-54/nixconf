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
        contract__reverse_proxy(["reverse-proxy"]):::contractNode
    end

    subgraph Implementations["Implementations"]
        impl__caddy["caddy"]:::implNode
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


    host__astrolabe -->|"imports"| impl__caddy
    impl__caddy -.->|"implements"| contract__reverse_proxy
    contract__reverse_proxy --- opt__reverse_proxy_domain
    contract__reverse_proxy --- opt__reverse_proxy_enable
    contract__reverse_proxy --- opt__reverse_proxy_hosts
    contract__reverse_proxy --- type__reverse_proxy_fqdn
    contract__reverse_proxy --- type__reverse_proxy_host

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

*No hosts configure this contract directly.*

### Implementations

*No implementations configure this contract.*

### Features

*No features configure this contract.*
