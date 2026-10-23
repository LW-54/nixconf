# Module: `persistence`

Capability contract interface defining 'persistence' option schemas and custom types.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.persistence`
- **Description**: Capability contract interface defining 'persistence' option schemas and custom types.

## Importing Hosts

Hosts that import this module into their system configurations:

*Not currently imported by any host.*

## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.persistence.directories` | `list of (string or attribute set of anything)` | List of directory paths to persist across reboots, as absolute system paths under `/persist/system`. Can be string paths or attribute sets defining custom ownership and bind-mount modes. |
| `options.persistence.enable` | `boolean` | Whether to enable declarative filesystem persistence contract mapped to impermanence. |
| `options.persistence.files` | `list of (string or attribute set of anything)` | List of individual file paths to persist across reboots, as absolute system paths under `/persist/system`. Can be string paths or attribute sets defining custom ownership and bind-mount modes. |
| `options.persistence.users` | `attribute set of (submodule)` | Per-user persistence declarations keyed by username. `data` and `cache` root names are repository conventions, not upstream impermanence requirements. |

