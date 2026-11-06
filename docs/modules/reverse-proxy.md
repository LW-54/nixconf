# Module: `reverse-proxy`

Declarative HTTP/TLS reverse proxy virtual host ingress and routing management.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.reverse-proxy`
- **Provided by**: contract [`reverse-proxy`](../contracts/reverse-proxy.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `reverse-proxy.domain` | `null or (Fully qualified domain name)` | — | `"adje.app"` | Base root domain name used for virtual host construction. Services providing a subdomain prefix will be exposed as `<subdomain>.<domain>`. |
| `reverse-proxy.enable` | `boolean` | `false` | `true` | Whether to enable system reverse proxy contract. |
| `reverse-proxy.hosts` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Attribute set of virtual host fully-qualified domain names (FQDN) mapped to upstream backend endpoints and proxy policies. |
