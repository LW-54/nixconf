# Module: `storage`

Declarative multi-provider storage contract separating open driver definitions, logical providers, host/shared slices, and mount requests.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.storage`
- **Provided by**: contract [`storage`](../contracts/storage.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `storage.activeSlices` | `list of string` | `[ ]` | `[ ... ]` | Additional non-mounted slices required on this host (such as direct `restic` backup targets). |
| `storage.driftCheck.enable` | `boolean` | `false` | — | Whether to enable periodic drift verification for declared storage providers and SOPS secret stores. |
| `storage.driftCheck.onCalendar` | `string` | `"daily"` | — | Systemd OnCalendar expression controlling periodic storage drift checks. |
| `storage.drivers` | `attribute set of (submodule)` | `{ hetzner-box = ...; gdrive = ...; b2 = ...; s3 = ...; }` | `{ garage = { description = "..."; settingsModule = ...; resolveSlice = ...; }; }` | Open registry of storage driver modules implementing `settingsModule` and `resolveSlice` (pre-seeded with built-in drivers). |
| `storage.enable` | `boolean` | `false` | `true` | Whether to enable declarative multi-provider storage management. |
| `storage.mounts` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Declarative POSIX mount requests consumed by storage implementations (`implementation.rclone`). |
| `storage.providers` | `attribute set of (submodule)` | `{ hbox = ...; gdrive = ...; b2 = ...; }` | `{ hbox-archive = { driver = "hetzner-box"; settings.boxId = "u999999"; }; }` | Named storage provider instances parameterized by an open `driver` and isolated per-instance SOPS secret store. |
| `storage.slices` | `attribute set of (submodule)` | `{ uchiyomi = ...; hbox-backup-host = ...; hbox-backup-shared = ...; gdrive = ...; gdrive-backup-host = ...; gdrive-backup-shared = ...; b2 = ...; b2-backup-host = ...; b2-backup-shared = ...; }` | `{ shared-docs = { kind = "direct"; scope = "shared"; provider = "hbox"; path = "docs"; }; }` | Logical storage slices across direct providers, rclone crypt layers, and union tiers, with `shared` or `per-host` scoping. |
