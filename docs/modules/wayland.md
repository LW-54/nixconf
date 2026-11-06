# Module: `wayland`

Wayland compositor registration, session targets, and graphical environment management.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.wayland`
- **Provided by**: contract [`wayland`](../contracts/wayland.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `wayland.compositors` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Declarative Wayland compositor registrations managed by the session manager. |
| `wayland.enable` | `boolean` | `false` | `true` | Whether to enable system-level Wayland session orchestration. When enabled, Wayland compositor backends (such as UWSM) will configure systemd graphical session targets, environment variables, and startup units. |
