# Implementations Documentation

Concrete capability providers declared via `options.implementation` in [`primitives/implementation.nix`](../primitives/implementation.nix).

[← Back to Main README](../README.md)

## Primitive Specification

Concrete capability providers satisfying contract interfaces by translating abstract capability options into provider-specific NixOS services, packages, and system configurations.

### Option Schema (`options.implementation.<name>`)

- `contract` (string, required): Name of the capability contract this module implements.
- `description` (string, required): Formal description of how this provider satisfies the contract.
- `module` (deferredModule, required): NixOS module implementing the contract capability.
- `packages` (raw, default: `{}`): Implementation package declarations or generator function.
- `devShells` (raw, default: `{}`): Implementation development shells or generator function.
- `lib` (attrsOf raw, default: `{}`): Exported library helpers and identity definitions on `flake.lib.<name>`.

### Declaration Example (`implementation.<name>`)

```nix
implementation.example-provider = {
  contract = "reverse-proxy";
  description = "Reverse proxy capability provider using example backend.";
  module = { ... }: { ... };
};
```

## Implementations Catalog

| Implementation | Description | Contract Satisfied | Docs |
| :--- | :--- | :--- | :--- |
| [`caddy`](implementations/caddy.md) | Automated TLS virtual host reverse proxy implementation using Caddy. | [`reverse-proxy`](contracts/reverse-proxy.md) | [More →](implementations/caddy.md) |
| [`cgroups`](implementations/cgroups.md) | Systemd control groups slice hierarchy and resource quotas implementation. | [`resources`](contracts/resources.md) | [More →](implementations/cgroups.md) |
| [`hjem`](implementations/hjem.md) | Lightweight declarative home directory files and XDG environment manager. | [`home`](contracts/home.md) | [More →](implementations/hjem.md) |
| [`impermanence`](implementations/impermanence.md) | Ephemeral root filesystem with persistent state bind-mounts via Impermanence. | [`persistence`](contracts/persistence.md) | [More →](implementations/impermanence.md) |
| [`lw`](implementations/lw.md) | Primary human user account orchestration and identity provisioning. | [`default-user`](contracts/default-user.md) | [More →](implementations/lw.md) |
| [`restic`](implementations/restic.md) | Automated encrypted remote backups using Restic and systemd timers. | [`backup`](contracts/backup.md) | [More →](implementations/restic.md) |
| [`sops`](implementations/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [`secrets`](contracts/secrets.md) | [More →](implementations/sops.md) |
| [`uwsm`](implementations/uwsm.md) | Universal Wayland Session Manager integration for desktop environments. | [`wayland`](contracts/wayland.md) | [More →](implementations/uwsm.md) |
