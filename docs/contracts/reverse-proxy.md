# Contract: `reverse-proxy`

Declarative HTTP/TLS reverse proxy virtual host ingress and routing management.

[← Back to Contracts Documentation](../CONTRACTS.md) | [← Back to Main README](../../README.md)

## Metadata

- **Contract Name**: `reverse-proxy`
- **Description**: Declarative HTTP/TLS reverse proxy virtual host ingress and routing management.
- **Definition File**: [`modules/contracts/reverse-proxy.nix`](../../modules/contracts/reverse-proxy.nix)

## Architecture Diagram

flowchart LR
  urn__nixconf__ast__module__astrolabe["nixosModule/astrolabe"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_disk["nixosModule/astrolabe-disk"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_hardware["nixosModule/astrolabe-hardware"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_packages["nixosModule/astrolabe-packages"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_services["nixosModule/astrolabe-services"]:::defaultNode
    urn__nixconf__ast__module__astrolabe_system["nixosModule/astrolabe-system"]:::defaultNode
    urn__nixconf__ast__module__caddy["nixosModule/caddy"]:::defaultNode
    urn__nixconf__ast__module__ttyd["nixosModule/ttyd"]:::defaultNode
    urn__nixconf__ast__module__vaultwarden["nixosModule/vaultwarden"]:::defaultNode
    urn__nixconf__ast__option__reverse_proxy_domain[/"reverse-proxy.domain"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_enable[/"reverse-proxy.enable"/]:::optNode
    urn__nixconf__ast__option__reverse_proxy_hosts[/"reverse-proxy.hosts"/]:::optNode
    urn__nixconf__ast__type__reverse_proxy_fqdn[["reverse-proxy.fqdn"]]:::typeNode
    urn__nixconf__ast__type__reverse_proxy_host[["reverse-proxy.host"]]:::typeNode
    urn__nixconf__eval__configuration__astrolabe(["nixosConfiguration/astrolabe"]):::hostNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__default_user{{"default-user"}}:::contractNode
    urn__nixconf__onto__contract__home{{"home"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__resources{{"resources"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__contract__wayland{{"wayland"}}:::contractNode
    urn__nixconf__onto__feature__disko("disko"):::featureNode
    urn__nixconf__onto__feature__git("git"):::featureNode
    urn__nixconf__onto__feature__locale("locale"):::featureNode
    urn__nixconf__onto__feature__nix("nix"):::featureNode
    urn__nixconf__onto__feature__ssh("ssh"):::featureNode
    urn__nixconf__onto__feature__ttyd("ttyd"):::featureNode
    urn__nixconf__onto__feature__vaultwarden("vaultwarden"):::featureNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__implementation__caddy["caddy"]:::implNode
    urn__nixconf__onto__implementation__cgroups["cgroups"]:::implNode
    urn__nixconf__onto__implementation__impermanence["impermanence"]:::implNode
    urn__nixconf__onto__implementation__lw["lw"]:::implNode
    urn__nixconf__onto__implementation__restic["restic"]:::implNode
    urn__nixconf__onto__implementation__sops["sops"]:::implNode
    urn__nixconf__onto__primitive__contract["contract"]:::defaultNode
    urn__nixconf__onto__primitive__feature["feature"]:::defaultNode
    urn__nixconf__onto__primitive__host["host"]:::defaultNode
    urn__nixconf__onto__primitive__implementation["implementation"]:::defaultNode

    urn__nixconf__ast__module__astrolabe_services -. "flowsTo = "adje.app"" .-> urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__astrolabe_services -. "writes = "adje.app"" .-> urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__caddy -. "reads" .-> urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__ast__module__caddy -. "reads" .-> urn__nixconf__ast__option__reverse_proxy_enable
    urn__nixconf__ast__module__caddy -. "reads" .-> urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__caddy -. "writes = true" .-> urn__nixconf__ast__option__reverse_proxy_enable
    urn__nixconf__ast__module__ttyd -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__ttyd -. "writes = "<set>"" .-> urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__module__vaultwarden -. "flowsTo = "<set>"" .-> urn__nixconf__ast__module__caddy
    urn__nixconf__ast__module__vaultwarden -. "writes = "<set>"" .-> urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__ast__option__reverse_proxy_domain -->|"typedBy"| urn__nixconf__ast__type__reverse_proxy_fqdn
    urn__nixconf__ast__option__reverse_proxy_hosts -->|"typedBy"| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__caddy
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__ttyd
    urn__nixconf__eval__configuration__astrolabe -->|"imports"| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__contract__reverse_proxy -->|"declares"| urn__nixconf__ast__option__reverse_proxy_domain
    urn__nixconf__onto__contract__reverse_proxy -->|"declares"| urn__nixconf__ast__option__reverse_proxy_enable
    urn__nixconf__onto__contract__reverse_proxy -->|"declares"| urn__nixconf__ast__option__reverse_proxy_hosts
    urn__nixconf__onto__contract__reverse_proxy -->|"declares"| urn__nixconf__ast__type__reverse_proxy_fqdn
    urn__nixconf__onto__contract__reverse_proxy -->|"declares"| urn__nixconf__ast__type__reverse_proxy_host
    urn__nixconf__onto__feature__git -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__git -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__locale -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__feature__nix -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ssh -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__ssh -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__feature__ttyd -->|"outputs"| urn__nixconf__ast__module__ttyd
    urn__nixconf__onto__feature__ttyd -. "consumes" .-> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__ttyd -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__feature__vaultwarden -->|"outputs"| urn__nixconf__ast__module__vaultwarden
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__backup
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__feature__vaultwarden -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_disk
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_hardware
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_packages
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_services
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__ast__module__astrolabe_system
    urn__nixconf__onto__host__astrolabe -->|"outputs"| urn__nixconf__eval__configuration__astrolabe
    urn__nixconf__onto__host__astrolabe -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__host__astrolabe -->|"imports"| urn__nixconf__onto__implementation__sops
    urn__nixconf__onto__implementation__caddy -->|"outputs"| urn__nixconf__ast__module__caddy
    urn__nixconf__onto__implementation__caddy -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__caddy -. "consumes" .-> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__caddy -. "consumes" .-> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy == "implements" ==> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__caddy == "implements" ==> urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__cgroups == "implements" ==> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__cgroups == "implements" ==> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__impermanence == "implements" ==> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__impermanence == "implements" ==> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__home
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lw -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lw == "implements" ==> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__lw == "implements" ==> urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__implementation__restic -. "consumes" .-> urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__restic -. "consumes" .-> urn__nixconf__onto__contract__resources
    urn__nixconf__onto__implementation__restic -. "consumes" .-> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__restic == "implements" ==> urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__restic == "implements" ==> urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__sops == "implements" ==> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__sops == "implements" ==> urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__default_user
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__home
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__resources
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__primitive__contract -->|"contains"| urn__nixconf__onto__contract__wayland
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__disko
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__git
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__locale
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__nix
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__ssh
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__ttyd
    urn__nixconf__onto__primitive__feature -->|"contains"| urn__nixconf__onto__feature__vaultwarden
    urn__nixconf__onto__primitive__host -->|"contains"| urn__nixconf__onto__host__astrolabe
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__caddy
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__cgroups
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__impermanence
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__lw
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__restic
    urn__nixconf__onto__primitive__implementation -->|"contains"| urn__nixconf__onto__implementation__sops


    click urn__nixconf__ast__module__astrolabe href "../modules/astrolabe.md" "astrolabe"
    click urn__nixconf__ast__module__astrolabe_disk href "../modules/astrolabe-disk.md" "astrolabe-disk"
    click urn__nixconf__ast__module__astrolabe_hardware href "../modules/astrolabe-hardware.md" "astrolabe-hardware"
    click urn__nixconf__ast__module__astrolabe_packages href "../modules/astrolabe-packages.md" "astrolabe-packages"
    click urn__nixconf__ast__module__astrolabe_services href "../modules/astrolabe-services.md" "astrolabe-services"
    click urn__nixconf__ast__module__astrolabe_system href "../modules/astrolabe-system.md" "astrolabe-system"
    click urn__nixconf__ast__module__caddy href "../modules/caddy.md" "caddy"
    click urn__nixconf__ast__module__ttyd href "../modules/ttyd.md" "ttyd"
    click urn__nixconf__ast__module__vaultwarden href "../modules/vaultwarden.md" "vaultwarden"
    click urn__nixconf__eval__configuration__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__contract__backup href "../contracts/backup.md" "backup"
    click urn__nixconf__onto__contract__default_user href "../contracts/default-user.md" "default-user"
    click urn__nixconf__onto__contract__home href "../contracts/home.md" "home"
    click urn__nixconf__onto__contract__persistence href "../contracts/persistence.md" "persistence"
    click urn__nixconf__onto__contract__resources href "../contracts/resources.md" "resources"
    click urn__nixconf__onto__contract__reverse_proxy href "../contracts/reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "../contracts/secrets.md" "secrets"
    click urn__nixconf__onto__contract__wayland href "../contracts/wayland.md" "wayland"
    click urn__nixconf__onto__feature__disko href "../features/disko.md" "disko"
    click urn__nixconf__onto__feature__git href "../features/git.md" "git"
    click urn__nixconf__onto__feature__locale href "../features/locale.md" "locale"
    click urn__nixconf__onto__feature__nix href "../features/nix.md" "nix"
    click urn__nixconf__onto__feature__ssh href "../features/ssh.md" "ssh"
    click urn__nixconf__onto__feature__ttyd href "../features/ttyd.md" "ttyd"
    click urn__nixconf__onto__feature__vaultwarden href "../features/vaultwarden.md" "vaultwarden"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__implementation__caddy href "../implementations/caddy.md" "caddy"
    click urn__nixconf__onto__implementation__cgroups href "../implementations/cgroups.md" "cgroups"
    click urn__nixconf__onto__implementation__impermanence href "../implementations/impermanence.md" "impermanence"
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


## Option Schema Definitions

| Option | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `options.reverse-proxy.domain` | `null or (Fully qualified domain name)` | *null* | `adje.app` | Base root domain name used for virtual host construction. Services providing a subdomain prefix will be exposed as `<subdomain>.<domain>`. |
| `options.reverse-proxy.enable` | `boolean` | `` | `1` | Whether to enable system reverse proxy contract. |
| `options.reverse-proxy.hosts` | `attribute set of (submodule)` | `{ ... }` | `{ ... }` | Attribute set of virtual host fully-qualified domain names (FQDN) mapped to upstream backend endpoints and proxy policies. |

## Outputs

### Custom Submodule Types

| Type | Description | Details |
| :--- | :--- | :--- |
| [`reverse-proxy.fqdn`](../lib/reverse-proxy.md#reverse-proxy.fqdn) | Fully qualified domain name | [More →](../lib/reverse-proxy.md#reverse-proxy.fqdn) |
| [`reverse-proxy.host`](../lib/reverse-proxy.md#reverse-proxy.host) | submodule | [More →](../lib/reverse-proxy.md#reverse-proxy.host) |

### Library Helpers

| Symbol | Description | Details |
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

Configures options: *general contract configuration*

```nix
config = {

};

```

</details>


### Implementations

<details>
<summary><code><a href="../implementations/caddy.md">caddy</a></code></summary>

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

