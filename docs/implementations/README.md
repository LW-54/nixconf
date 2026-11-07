# Implementations

Concrete capability providers satisfying contract interfaces by translating abstract capability options into provider-specific NixOS services, packages, and system configurations.

[← Back to Main README](../../README.md)

## Specification

- **Declared as**: `implementation.<name>` in any flake-parts module under `modules/implementations/`
- **Primitive definition**: [`primitives/implementation/default.nix`](../../primitives/implementation/default.nix)
- **Instances**: 8

## Option Schema (`implementation.<name>`)

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `contract` | `string` | **required** | Name of the contract this module implements. |
| `description` | `string` | **required** | Formal description of this primitive instance. |
| `devShells` | `raw value` | `{ }` | Development shells provided by this primitive. |
| `lib` | `attribute set of raw value` | `{ }` | Library helper functions and values exported on flake.lib.<name>. |
| `module` | `module` | **required** | NixOS module implementing the capability. |
| `packages` | `raw value` | `{ }` | Packages provided by this primitive. |

## Declaration Example

Smallest declaration in the repository, [`modules/implementations/uwsm.nix`](../../modules/implementations/uwsm.nix):

```nix
{...}: {
  /**
  Systemd-integrated Wayland graphical session management and compositor launching via UWSM.
  */
  implementation.uwsm = {
    contract = "wayland";
    description = "Universal Wayland Session Manager integration for desktop environments.";
    module = {
      config,
      lib,
      ...
    }: {
      programs.uwsm = {
        enable = true;
        waylandCompositors =
          lib.mapAttrs (_: c: {
            inherit (c) prettyName comment binPath;
          })
          config.wayland.compositors;
      };
    };
  };
}
```

## Catalog

| Implementation | Contract | Description | Definition | Docs |
| :--- | :--- | :--- | :--- | :--- |
| [`caddy`](caddy.md) | [`reverse-proxy`](../contracts/reverse-proxy.md) | Automated TLS virtual host reverse proxy implementation using Caddy. | [`modules/implementations/caddy.nix`](../../modules/implementations/caddy.nix) | [More →](caddy.md) |
| [`hjem`](hjem.md) | [`home`](../contracts/home.md) | Lightweight declarative home directory files and XDG environment manager. | [`modules/implementations/hjem.nix`](../../modules/implementations/hjem.nix) | [More →](hjem.md) |
| [`impermanence`](impermanence.md) | [`persistence`](../contracts/persistence.md) | Ephemeral root filesystem with persistent state bind-mounts via Impermanence. | [`modules/implementations/impermanence.nix`](../../modules/implementations/impermanence.nix) | [More →](impermanence.md) |
| [`lw`](lw.md) | [`default-user`](../contracts/default-user.md) | Primary human user account orchestration and identity provisioning. | [`modules/implementations/lw.nix`](../../modules/implementations/lw.nix) | [More →](lw.md) |
| [`nixos-test`](nixos-test.md) | [`testing`](../contracts/testing.md) | Host verification through the NixOS test driver: built-in essentials, QEMU VM sizing, and Disko install tests. | [`modules/implementations/nixos-test.nix`](../../modules/implementations/nixos-test.nix) | [More →](nixos-test.md) |
| [`restic`](restic.md) | [`backup`](../contracts/backup.md) | Automated encrypted remote backups using Restic and systemd timers. | [`modules/implementations/restic.nix`](../../modules/implementations/restic.nix) | [More →](restic.md) |
| [`sops`](sops.md) | [`secrets`](../contracts/secrets.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [`modules/implementations/sops.nix`](../../modules/implementations/sops.nix) | [More →](sops.md) |
| [`uwsm`](uwsm.md) | [`wayland`](../contracts/wayland.md) | Universal Wayland Session Manager integration for desktop environments. | [`modules/implementations/uwsm.nix`](../../modules/implementations/uwsm.nix) | [More →](uwsm.md) |
