# Module: `backup`

Declarative multi-provider backup contract separating per-provider schedules/retention, host vs shared repository scopes, per-service units, and boot-time most-recent auto-restore.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.backup`
- **Provided by**: contract [`backup`](../contracts/backup.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `backup.destinations` | `attribute set of (submodule)` | `{ }` | `{ b2-shared.enable = true; gdrive-host.retention.daily = 60; }` | Named backup destinations parameterized by backing storage slice, `host`/`shared` scope, priority, schedule, and per-tier retention. |
| `backup.enable` | `boolean` | `false` | `true` | Whether to enable declarative backup configuration. |
| `backup.exclude` | `list of string` | `[ ]` | `[ ... ]` | Global exclusion patterns applied across backup units. |
| `backup.paths` | `list of string` | `[ ]` | `[ ... ]` | Host-level filesystem paths included in synthetic `system` backups when not claimed by any declared `backup.units` entry. |
| `backup.units` | `attribute set of (submodule)` | `{ }` | `{ vaultwarden = { scope = "shared"; paths = ["/var/lib/vaultwarden"]; destinationOverrides.b2-shared.enable = true; }; }` | Logical backup units with independent paths, scopes, destination overrides, and boot-time most-recent auto-restore configuration. |
