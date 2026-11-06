# Module: `secrets`

Declarative encrypted secrets provisioning, filesystem mounting, and permission management.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.secrets`
- **Provided by**: contract [`secrets`](../contracts/secrets.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `secrets.defaultFile` | `null or absolute path` | — | `./secrets/secrets.yaml` | Default YAML/JSON file containing encrypted secrets for this host. Can be overridden on a per-secret basis by consumer features. |
| `secrets.enable` | `boolean` | `true` | `true` | Whether to enable system secrets management contract. |
| `secrets.files` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Attribute set of declarative secret items required by system services. Mapped to the active secrets provider implementation (e.g. SOPS). |
