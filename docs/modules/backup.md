# Module: `backup`

Contract interface defining 'backup' option schemas and custom types.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.backup`
- **Description**: Contract interface defining 'backup' option schemas and custom types.

## Importing Hosts

Hosts that import this module into their system configurations:

*Not currently imported by any host.*

## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.backup.enable` | `boolean` | Whether to enable system backup automation contract. |
| `options.backup.exclude` | `list of string` | List of glob patterns, file paths, or directories to explicitly exclude from backup snapshots (e.g. cache directories, transient sockets). |
| `options.backup.paths` | `list of absolute path` | List of absolute filesystem directory or file paths to include in the backup snapshot. Aggregated across all active service modules via `mkConfig`. |
| `options.backup.pruneOpts` | `list of string` | Command-line argument rules passed to the backup backend pruning command to enforce snapshot retention and prevent unbounded remote storage usage. |
| `options.backup.timerConfig` | `attribute set of anything` | Systemd timer specification governing when automated backup snapshots run. Defaults to executing daily at 04:00 with persistence enabled. |
