# Module: `default-user`

Contract interface defining 'default-user' option schemas and custom types.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.default-user`
- **Description**: Contract interface defining 'default-user' option schemas and custom types.

## Importing Hosts

Hosts that import this module into their system configurations:

*Not currently imported by any host.*

## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.default-user.email` | `string` | Primary email address associated with the default user. |
| `options.default-user.enable` | `boolean` | Whether to enable system default user contract. |
| `options.default-user.fullName` | `null or string` | Display name / GECOS description of the default user. |
| `options.default-user.githubUsername` | `string` | GitHub username of the default user. |
| `options.default-user.modules` | `list of module` | Arbitrary NixOS configuration modules contributed by other features for the default user, evaluated and merged into the system when enabled. |
| `options.default-user.username` | `string` | Username of the default user account. |
