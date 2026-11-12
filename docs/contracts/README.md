# Contracts

Pure contract interfaces defining shared option schemas, custom types, and configuration contracts decoupled from any specific service provider or backend implementation.

[← Back to Main README](../../README.md)

## Specification

- **Declared as**: `contract.<name>` in any flake-parts module under `modules/contracts/`
- **Primitive definition**: [`primitives/contract/default.nix`](../../primitives/contract/default.nix)
- **Instances**: 7

## Option Schema (`contract.<name>`)

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `description` | `string` | **required** | Formal description of this primitive instance. |
| `devShells` | `raw value` | `{ }` | Development shells provided by this primitive. |
| `lib` | `attribute set of raw value` | `{ }` | Library helper functions and values exported on flake.lib.<name>. |
| `mkConfig` | `raw value` | *null* | Feature configuration binding helper. |
| `mkOption` | `raw value` | *null* | Feature submodule option constructor. |
| `options` | `raw value` | **required** | NixOS option declarations for this contract. |
| `packages` | `raw value` | `{ }` | Packages provided by this primitive. |
| `types` | `attribute set of raw value` | `{ }` | Custom types declared and exported by this primitive. |

## Declaration Example

Smallest declaration in the repository, [`modules/contracts/default-user.nix`](../../modules/contracts/default-user.nix):

```nix
{lib, ...}: {
  contract.default-user = {
    description = "Default primary user account identification, credentials, and configuration injection.";

    options = {
      enable = lib.mkEnableOption "system default user contract" // {default = true;};

      username = lib.mkOption {
        type = lib.types.str;
        example = "alice";
        description = "Username of the default user account.";
      };

      githubUsername = lib.mkOption {
        type = lib.types.str;
        example = "alice";
        description = "GitHub username of the default user.";
      };

      email = lib.mkOption {
        type = lib.types.str;
        example = "alice@example.com";
        description = "Primary email address associated with the default user.";
      };

      fullName = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        example = "Alice Smith";
        description = "Display name / GECOS description of the default user.";
      };
    };
  };
}
```

## Catalog

| Contract | Description | Implementations | Definition | Docs |
| :--- | :--- | :--- | :--- | :--- |
| [`backup`](backup.md) | Automated snapshot backup configuration, inclusion paths, exclusions, and retention rules. | [`restic`](../implementations/restic.md) | [`modules/contracts/backup.nix`](../../modules/contracts/backup.nix) | [More →](backup.md) |
| [`default-user`](default-user.md) | Default primary user account identification, credentials, and configuration injection. | [`lw`](../implementations/lw.md) | [`modules/contracts/default-user.nix`](../../modules/contracts/default-user.nix) | [More →](default-user.md) |
| [`home`](home.md) | Declarative user home dotfile tree, XDG directory specifications, and session environment. | [`hjem`](../implementations/hjem.md) | [`modules/contracts/home.nix`](../../modules/contracts/home.nix) | [More →](home.md) |
| [`persistence`](persistence.md) | Declarative state preservation across ephemeral reboots for system and user directories. | [`impermanence`](../implementations/impermanence.md) | [`modules/contracts/persistence.nix`](../../modules/contracts/persistence.nix) | [More →](persistence.md) |
| [`reverse-proxy`](reverse-proxy.md) | Declarative HTTP/TLS reverse proxy virtual host ingress and routing management. | [`caddy`](../implementations/caddy.md) | [`modules/contracts/reverse-proxy.nix`](../../modules/contracts/reverse-proxy.nix) | [More →](reverse-proxy.md) |
| [`secrets`](secrets.md) | Declarative encrypted secrets provisioning, filesystem mounting, and permission management. | [`sops`](../implementations/sops.md) | [`modules/contracts/secrets.nix`](../../modules/contracts/secrets.nix) | [More →](secrets.md) |
| [`wayland`](wayland.md) | Wayland compositor registration, session targets, and graphical environment management. | [`uwsm`](../implementations/uwsm.md) | [`modules/contracts/wayland.nix`](../../modules/contracts/wayland.nix) | [More →](wayland.md) |
