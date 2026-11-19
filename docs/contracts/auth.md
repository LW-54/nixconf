# Contract: `auth`

Declarative single sign-on (SSO), forward authentication, access control policy, and LDAP directory contract.

[← Back to Contracts Documentation](README.md) | [← Back to Main README](../../README.md)

- **Contract**: `auth`
- **Definition File**: [`modules/contracts/auth/default.nix`](../../modules/contracts/auth/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__module__authelia["nixosModule/authelia"]:::defaultNode
    urn__nixconf__ast__module__lgtm["nixosModule/lgtm"]:::defaultNode
    urn__nixconf__ast__option__auth_address[/"auth.address"/]:::optNode
    urn__nixconf__ast__option__auth_adminGroup[/"auth.adminGroup"/]:::optNode
    urn__nixconf__ast__option__auth_defaultPolicy[/"auth.defaultPolicy"/]:::optNode
    urn__nixconf__ast__option__auth_directory[/"auth.directory"/]:::optNode
    urn__nixconf__ast__option__auth_enable[/"auth.enable"/]:::optNode
    urn__nixconf__ast__option__auth_port[/"auth.port"/]:::optNode
    urn__nixconf__ast__option__auth_rules[/"auth.rules"/]:::optNode
    urn__nixconf__ast__option__auth_subdomain[/"auth.subdomain"/]:::optNode
    urn__nixconf__ast__type__auth_directory[["auth.directory"]]:::typeNode
    urn__nixconf__ast__type__auth_policy[["auth.policy"]]:::typeNode
    urn__nixconf__ast__type__auth_rule[["auth.rule"]]:::typeNode
    urn__nixconf__onto__contract__auth{{"auth"}}:::contractNode
    urn__nixconf__onto__contract__backup{{"backup"}}:::contractNode
    urn__nixconf__onto__contract__monitoring{{"monitoring"}}:::contractNode
    urn__nixconf__onto__contract__persistence{{"persistence"}}:::contractNode
    urn__nixconf__onto__contract__reverse_proxy{{"reverse-proxy"}}:::contractNode
    urn__nixconf__onto__contract__secrets{{"secrets"}}:::contractNode
    urn__nixconf__onto__host__astrolabe(["astrolabe"]):::hostNode
    urn__nixconf__onto__host__x240(["x240"]):::hostNode
    urn__nixconf__onto__implementation__authelia["authelia"]:::implNode
    urn__nixconf__onto__implementation__lgtm["lgtm"]:::implNode

    urn__nixconf__ast__module__authelia -.->|flowsTo| urn__nixconf__ast__module__lgtm
    urn__nixconf__ast__module__authelia -.->|reads| urn__nixconf__ast__option__auth_directory
    urn__nixconf__ast__module__authelia -.->|reads| urn__nixconf__ast__option__auth_rules
    urn__nixconf__ast__module__authelia -.->|writes| urn__nixconf__ast__option__auth_directory
    urn__nixconf__ast__module__lgtm -.->|flowsTo| urn__nixconf__ast__module__authelia
    urn__nixconf__ast__module__lgtm -.->|writes| urn__nixconf__ast__option__auth_rules
    urn__nixconf__ast__option__auth_defaultPolicy -.->|typedBy| urn__nixconf__ast__type__auth_policy
    urn__nixconf__ast__option__auth_directory -.->|typedBy| urn__nixconf__ast__type__auth_directory
    urn__nixconf__ast__option__auth_directory -.->|typedBy| urn__nixconf__ast__type__auth_rule
    urn__nixconf__ast__option__auth_rules -.->|typedBy| urn__nixconf__ast__type__auth_directory
    urn__nixconf__ast__option__auth_rules -.->|typedBy| urn__nixconf__ast__type__auth_rule
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_address
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_adminGroup
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_defaultPolicy
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_directory
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_enable
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_port
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_rules
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__option__auth_subdomain
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__type__auth_directory
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__type__auth_policy
    urn__nixconf__onto__contract__auth -->|declares| urn__nixconf__ast__type__auth_rule
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__host__astrolabe -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__authelia
    urn__nixconf__onto__host__astrolabe -->|imports| urn__nixconf__onto__implementation__lgtm
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__host__x240 -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__host__x240 -->|imports| urn__nixconf__onto__implementation__lgtm
    urn__nixconf__onto__implementation__authelia -->|outputs| urn__nixconf__ast__module__authelia
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__auth
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__monitoring
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__authelia -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__authelia ==>|implements| urn__nixconf__onto__contract__auth
    urn__nixconf__onto__implementation__lgtm -->|outputs| urn__nixconf__ast__module__lgtm
    urn__nixconf__onto__implementation__lgtm -.->|consumes| urn__nixconf__onto__contract__auth
    urn__nixconf__onto__implementation__lgtm -.->|consumes| urn__nixconf__onto__contract__backup
    urn__nixconf__onto__implementation__lgtm -.->|consumes| urn__nixconf__onto__contract__persistence
    urn__nixconf__onto__implementation__lgtm -.->|consumes| urn__nixconf__onto__contract__reverse_proxy
    urn__nixconf__onto__implementation__lgtm -.->|consumes| urn__nixconf__onto__contract__secrets
    urn__nixconf__onto__implementation__lgtm ==>|implements| urn__nixconf__onto__contract__monitoring


    click urn__nixconf__ast__module__authelia href "../modules/authelia.md" "authelia"
    click urn__nixconf__ast__module__lgtm href "../modules/lgtm.md" "lgtm"
    click urn__nixconf__ast__option__auth_address href "auth.md" "auth.address"
    click urn__nixconf__ast__option__auth_adminGroup href "auth.md" "auth.adminGroup"
    click urn__nixconf__ast__option__auth_defaultPolicy href "auth.md" "auth.defaultPolicy"
    click urn__nixconf__ast__option__auth_directory href "auth.md" "auth.directory"
    click urn__nixconf__ast__option__auth_enable href "auth.md" "auth.enable"
    click urn__nixconf__ast__option__auth_port href "auth.md" "auth.port"
    click urn__nixconf__ast__option__auth_rules href "auth.md" "auth.rules"
    click urn__nixconf__ast__option__auth_subdomain href "auth.md" "auth.subdomain"
    click urn__nixconf__ast__type__auth_directory href "auth.md" "auth.directory"
    click urn__nixconf__ast__type__auth_policy href "auth.md" "auth.policy"
    click urn__nixconf__ast__type__auth_rule href "auth.md" "auth.rule"
    click urn__nixconf__onto__contract__auth href "auth.md" "auth"
    click urn__nixconf__onto__contract__backup href "backup.md" "backup"
    click urn__nixconf__onto__contract__monitoring href "monitoring.md" "monitoring"
    click urn__nixconf__onto__contract__persistence href "persistence.md" "persistence"
    click urn__nixconf__onto__contract__reverse_proxy href "reverse-proxy.md" "reverse-proxy"
    click urn__nixconf__onto__contract__secrets href "secrets.md" "secrets"
    click urn__nixconf__onto__host__astrolabe href "../hosts/astrolabe.md" "astrolabe"
    click urn__nixconf__onto__host__x240 href "../hosts/x240.md" "x240"
    click urn__nixconf__onto__implementation__authelia href "../implementations/authelia.md" "authelia"
    click urn__nixconf__onto__implementation__lgtm href "../implementations/lgtm.md" "lgtm"

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
| [`auth`](../modules/auth.md) | Declarative single sign-on (SSO), forward authentication, access control policy, and LDAP directory contract. | [More →](../modules/auth.md) |

### Library Helpers

| Symbol | Type | Description | Docs |
| :--- | :--- | :--- | :--- |
| [`mkConfig`](../lib/auth.md#mkConfig) | `auth.mkConfig :: AttrSet -> AttrSet` | Auto-derived configuration binding helper for the 'auth' contract. | [More →](../lib/auth.md#mkConfig) |
| [`mkOption`](../lib/auth.md#mkOption) | `auth.mkOption :: AttrSet -> AttrSet` | Auto-derived option constructor for the 'auth' contract. | [More →](../lib/auth.md#mkOption) |

### Custom Types

- `directory`: submodule
- `policy`: one of "bypass", "one_factor", "two_factor", "deny"
- `rule`: submodule

## Option Schema Definitions

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `auth.address` | `string` | `"127.0.0.1"` | Local bind address for the SSO authentication server. |
| `auth.adminGroup` | `string` | `"lldap_admin"` | Directory group name granted administrative privileges across integrated services. |
| `auth.defaultPolicy` | `one of "bypass", "one_factor", "two_factor", "deny"` | `"one_factor"` | Default access control policy enforced across SSO-protected virtual hosts. |
| `auth.directory` | `submodule` | `{ }` | Backing LDAP directory service configuration and administrative account settings. |
| `auth.enable` | `boolean` | `false` | Whether to enable centralized authentication, directory, and single sign-on contract. |
| `auth.port` | `16 bit unsigned integer; between 0 and 65535 (both inclusive)` | `22210` | Local TCP port on which the SSO authentication server listens. |
| `auth.rules` | `attribute set of (submodule)` | `{ }` | Attribute set of explicit access control rules evaluated before the fallback domain policy. |
| `auth.subdomain` | `string` | `"auth"` | Subdomain prefix under `reverse-proxy.domain` exposing the SSO login portal. |

## Fulfilling Implementations

Providers satisfying the `auth` contract capability:

| Implementation | Description | Definition | Docs |
| :--- | :--- | :--- | :--- |
| [`authelia`](../implementations/authelia.md) | Centralized SSO, forward authentication, 2FA, and LDAP directory implementation using Authelia and LLDAP. | [`modules/implementations/authelia/default.nix`](../../modules/implementations/authelia/default.nix) | [More →](../implementations/authelia.md) |

## Contract Consumers

Modules and instances configuring options under the `auth` contract capability:



### Implementations

<details>
<summary><code><a href="../implementations/authelia.md">authelia</a></code></summary>

**Configures options**: `auth.directory`

```nix
# modules/implementations/authelia/default.nix
...
130: message = "implementation.authelia currently requires `auth.directory.enable = true` (LLDAP backend).";
...
134: message = "auth.subdomain and auth.directory.subdomain must be distinct virtual host prefixes.";
...
138: auth.directory.adminEmail = lib.mkDefault "leonardwilsonb@gmail.com";
...
227: endpoints.authz.forward-auth.implementation = "ForwardAuth";
...
492: caddy-forward-auth = {
493: description = "Verify Caddyfile enforces forward_auth on protected services";
494: script = lib.optionalString (config.reverse-proxy.enable or false) (
495: self.lib.testing.mkInspectFile {
...
521: _unauth = machine.succeed(
...
```

</details>


<details>
<summary><code><a href="../implementations/lgtm.md">lgtm</a></code></summary>

**Configures options**: `auth.rules`

```nix
config = {
  auth.rules = ...;
};
```

</details>
