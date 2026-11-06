# Module: `locale`

System internationalization, time zone, and language locale configuration.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.locale`
- **Provided by**: feature [`locale`](../features/locale.md)

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).

- [`x240`](../hosts/x240.md): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `locale.defaultLocale` | `string` | `"en_US.UTF-8"` | — | System default locale and the default user locale. |
| `locale.enable` | `boolean` | `true` | `true` | Whether to enable locale configuration. |
| `locale.extraLocaleSettings` | `attribute set of string` | `{ ... }` | — | Additional system locale settings and user defaults. |
| `locale.timeZone` | `string` | `"Europe/Paris"` | — | System time zone. |
