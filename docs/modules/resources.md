# Module: `resources`

Contract interface defining 'resources' option schemas and custom types.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.resources`
- **Description**: Contract interface defining 'resources' option schemas and custom types.

## Importing Hosts

Hosts that import this module into their system configurations:

*Not currently imported by any host.*

## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.resources.defaultSlices.enable` | `boolean` | Whether to automatically declare standard hierarchical resource slices (`system.slice`, `production.slice`, `services.slice`, and `background.slice`). |
| `options.resources.enable` | `boolean` | Whether to enable system resource allocation contract. |
| `options.resources.services` | `attribute set of (submodule)` | Attribute set of per-service resource policies and constraints mapped directly to individual systemd service unit configurations. |
| `options.resources.slices` | `attribute set of (submodule)` | Attribute set of hierarchical systemd slice definitions mapping directly to Linux cgroups v2 resource controllers (CPU, memory, IO, and task counts). |
