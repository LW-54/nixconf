# Module: `git`

Git version control system, global/per-user configuration, and Bitwarden SSH key agent shell.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.git`
- **Provided by**: feature [`git`](../features/git.md)

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).

- [`x240`](../hosts/x240.md): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `git.enable` | `boolean` | `true` | `true` | Whether to enable Git version control. |
| `git.prebuildGithubSsh` | `boolean` | `true` | `true` | Whether to enable prebuilding the GitHub SSH development shell. |
| `git.settings` | `attribute set of anything` | `{ }` | — | Global Git configuration settings. |
| `git.users` | `attribute set of (submodule)` | `{ }` | — | Per-user Git configuration overrides. |
