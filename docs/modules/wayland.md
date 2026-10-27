# Module: `wayland`

Contract interface defining 'wayland' option schemas and custom types.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.wayland`
- **Description**: Contract interface defining 'wayland' option schemas and custom types.

## Importing Hosts

Hosts that import this module into their system configurations:

*Not currently imported by any host.*

## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.wayland.compositors` | `attribute set of (submodule)` | Declarative Wayland compositor registrations managed by the session manager. |
| `options.wayland.enable` | `boolean` | Whether to enable system-level Wayland session orchestration. When enabled, Wayland compositor backends (such as UWSM) will configure systemd graphical session targets, environment variables, and startup units. |
