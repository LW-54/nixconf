# Module: `micro`

Modern and intuitive terminal-based text editor with wrapped declarative configuration.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.micro`
- **Provided by**: feature [`micro`](../features/micro.md)

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).

- [`x240`](../hosts/x240.md): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `micro.bindings` | `attribute set of anything` | `{ }` | — | Declarative `bindings.json` keybinding overrides baked into the wrapped `micro` configuration directory. |
| `micro.defaultEditor` | `boolean` | `true` | — | Whether to set `micro` as the system-wide default `EDITOR` and `VISUAL`. |
| `micro.enable` | `boolean` | `true` | `true` | Whether to enable Micro terminal text editor. |
| `micro.settings` | `attribute set of anything` | `{ ... }` | — | Declarative `settings.json` attributes baked into the wrapped `micro` configuration directory. |
