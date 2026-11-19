# Module: `auth`

Declarative single sign-on (SSO), forward authentication, access control policy, and LDAP directory contract.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.auth`
- **Provided by**: contract [`auth`](../contracts/auth.md)

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `auth.address` | `string` | `"127.0.0.1"` | `"127.0.0.1"` | Local bind address for the SSO authentication server. |
| `auth.adminGroup` | `string` | `"lldap_admin"` | `"lldap_admin"` | Directory group name granted administrative privileges across integrated services. |
| `auth.defaultPolicy` | `one of "bypass", "one_factor", "two_factor", "deny"` | `"one_factor"` | `"two_factor"` | Default access control policy enforced across SSO-protected virtual hosts. |
| `auth.directory` | `submodule` | `{ }` | `{ ... }` | Backing LDAP directory service configuration and administrative account settings. |
| `auth.enable` | `boolean` | `false` | `true` | Whether to enable centralized authentication, directory, and single sign-on contract. |
| `auth.port` | `16 bit unsigned integer; between 0 and 65535 (both inclusive)` | `22210` | `9091` | Local TCP port on which the SSO authentication server listens. |
| `auth.rules` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Attribute set of explicit access control rules evaluated before the fallback domain policy. |
| `auth.subdomain` | `string` | `"auth"` | `"auth"` | Subdomain prefix under `reverse-proxy.domain` exposing the SSO login portal. |
