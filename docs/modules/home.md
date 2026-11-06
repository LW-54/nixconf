# Module: `home`

Declarative user home dotfile tree, XDG directory specifications, and session environment.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.home`
- **Provided by**: contract [`home`](../contracts/home.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `home.enable` | `boolean` | `false` | `true` | Whether to enable declarative user home dotfile and environment contract. |
| `home.shared` | `submodule` | `{ }` | `{ ... }` | Shared dotfile tree and environment configurations applied across all managed users. |
| `home.users` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Per-user dotfile tree and environment configurations mapped to active backend interpreters (e.g. Hjem). |
