# Module: `secrets`

Capability contract interface defining 'secrets' option schemas and custom types.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.secrets`
- **Description**: Capability contract interface defining 'secrets' option schemas and custom types.

## Importing Hosts

Hosts that import this module into their system configurations:

*Not currently imported by any host.*

## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.secrets.defaultFile` | `null or absolute path` | Default YAML/JSON file containing encrypted secrets for this host. Can be overridden on a per-secret basis by consumer features. |
| `options.secrets.enable` | `boolean` | Whether to enable system secrets management contract. |
| `options.secrets.files` | `attribute set of (submodule)` | Attribute set of declarative secret items required by system services. Mapped to the active secrets provider implementation (e.g. SOPS). |

