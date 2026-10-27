# Module: `home`

Contract interface defining 'home' option schemas and custom types.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.home`
- **Description**: Contract interface defining 'home' option schemas and custom types.

## Importing Hosts

Hosts that import this module into their system configurations:

*Not currently imported by any host.*

## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.home.enable` | `boolean` | Whether to enable declarative user home dotfile and environment contract. |
| `options.home.shared` | `submodule` | Shared dotfile tree and environment configurations applied across all managed users. |
| `options.home.users` | `attribute set of (submodule)` | Per-user dotfile tree and environment configurations mapped to active backend interpreters (e.g. Hjem). |
