# Module: `default-user`

Default primary user account identification, credentials, and configuration injection.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.default-user`
- **Provided by**: contract [`default-user`](../contracts/default-user.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `default-user.email` | `string` | — | `"alice@example.com"` | Primary email address associated with the default user. |
| `default-user.enable` | `boolean` | `true` | `true` | Whether to enable system default user contract. |
| `default-user.fullName` | `null or string` | — | `"Alice Smith"` | Display name / GECOS description of the default user. |
| `default-user.githubUsername` | `string` | — | `"alice"` | GitHub username of the default user. |
| `default-user.username` | `string` | — | `"alice"` | Username of the default user account. |
