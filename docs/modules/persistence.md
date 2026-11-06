# Module: `persistence`

Declarative state preservation across ephemeral reboots for system and user directories.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.persistence`
- **Provided by**: contract [`persistence`](../contracts/persistence.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `persistence.directories` | `list of (string or attribute set of anything)` | `[ ]` | `[ ... ]` | List of directory paths to persist across reboots, as absolute system paths under `/persist/system`. Can be string paths or attribute sets defining custom ownership and bind-mount modes. |
| `persistence.enable` | `boolean` | `true` | `true` | Whether to enable declarative filesystem persistence contract mapped to impermanence. |
| `persistence.files` | `list of (string or attribute set of anything)` | `[ ]` | `[ ... ]` | List of individual file paths to persist across reboots, as absolute system paths under `/persist/system`. Can be string paths or attribute sets defining custom ownership and bind-mount modes. |
| `persistence.users` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Per-user persistence declarations keyed by username. `data` and `cache` root names are repository conventions, not upstream impermanence requirements. |
