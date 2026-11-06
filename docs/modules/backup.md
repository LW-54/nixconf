# Module: `backup`

Automated snapshot backup configuration, inclusion paths, exclusions, and retention rules.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.backup`
- **Provided by**: contract [`backup`](../contracts/backup.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `backup.enable` | `boolean` | `false` | `true` | Whether to enable system backup automation contract. |
| `backup.exclude` | `list of string` | `[ ]` | `[ ... ]` | List of glob patterns, file paths, or directories to explicitly exclude from backup snapshots (e.g. cache directories, transient sockets). |
| `backup.paths` | `list of absolute path` | `[ ]` | `[ ... ]` | List of absolute filesystem directory or file paths to include in the backup snapshot. Aggregated across all active service modules via `mkConfig`. |
| `backup.pruneOpts` | `list of string` | `[ ... ]` | — | Command-line argument rules passed to the backup backend pruning command to enforce snapshot retention and prevent unbounded remote storage usage. |
| `backup.timerConfig` | `attribute set of anything` | `{ ... }` | — | Systemd timer specification governing when automated backup snapshots run. Defaults to executing daily at 04:00 with persistence enabled. |
