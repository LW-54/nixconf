# Module: `reverse-proxy`

Contract interface defining 'reverse-proxy' option schemas and custom types.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.reverse-proxy`
- **Description**: Contract interface defining 'reverse-proxy' option schemas and custom types.

## Importing Hosts

Hosts that import this module into their system configurations:

*Not currently imported by any host.*

## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.reverse-proxy.domain` | `null or (Fully qualified domain name)` | Base root domain name used for virtual host construction. Services providing a subdomain prefix will be exposed as `<subdomain>.<domain>`. |
| `options.reverse-proxy.enable` | `boolean` | Whether to enable system reverse proxy contract. |
| `options.reverse-proxy.hosts` | `attribute set of (submodule)` | Attribute set of virtual host fully-qualified domain names (FQDN) mapped to upstream backend endpoints and proxy policies. |
