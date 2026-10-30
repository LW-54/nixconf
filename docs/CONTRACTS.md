# Contracts Documentation

Pure abstract interfaces declared via `options.contract` in [`primitives/contract/default.nix`](../primitives/contract/default.nix).

[← Back to Main README](../README.md)

## Primitive Specification

Pure contract interfaces defining shared option schemas, custom types, and configuration contracts decoupled from any specific service provider or backend implementation.

### Option Schema (`options.contract.<name>`)

- `description` (string, required): Formal description of the contract.
- `options` (raw, required): NixOS option declarations defined for this contract.
- `types` (attrsOf raw, default: `{}`): Custom submodule types exposed on `self.lib.<name>.types`.
- `mkOption` (raw, default: `null`): Submodule option constructor for features.
- `mkConfig` (raw, default: `null`): Configuration binding helper.
- `packages` (raw, default: `{}`): Contract packages or generator function.
- `devShells` (raw, default: `{}`): Contract development shells or generator function.
- `lib` (attrsOf raw, default: `{}`): Extra library helpers and symbols exported on `flake.lib.<name>`.

### Declaration Example (`contract.<name>`)

```nix
contract.example = {
  description = "Abstract contract interface.";
  options = {
    enable = lib.mkEnableOption "example contract";
  };
};
```

## Contracts Catalog

| Contract | Description | Implementations | Docs |
| :--- | :--- | :--- | :--- |
| [`backup`](contracts/backup.md) | Automated snapshot backup configuration, inclusion paths, exclusions, and retention rules. | [`restic`](implementations/restic.md) | [More →](contracts/backup.md) |
| [`default-user`](contracts/default-user.md) | Default primary user account identification, credentials, and configuration injection. | [`lw`](implementations/lw.md) | [More →](contracts/default-user.md) |
| [`home`](contracts/home.md) | Declarative user home dotfile tree, XDG directory specifications, and session environment. | [`hjem`](implementations/hjem.md) | [More →](contracts/home.md) |
| [`persistence`](contracts/persistence.md) | Declarative state preservation across ephemeral reboots for system and user directories. | [`impermanence`](implementations/impermanence.md) | [More →](contracts/persistence.md) |
| [`reverse-proxy`](contracts/reverse-proxy.md) | Declarative HTTP/TLS reverse proxy virtual host ingress and routing management. | [`caddy`](implementations/caddy.md) | [More →](contracts/reverse-proxy.md) |
| [`secrets`](contracts/secrets.md) | Declarative encrypted secrets provisioning, filesystem mounting, and permission management. | [`sops`](implementations/sops.md) | [More →](contracts/secrets.md) |
| [`wayland`](contracts/wayland.md) | Wayland compositor registration, session targets, and graphical environment management. | [`uwsm`](implementations/uwsm.md) | [More →](contracts/wayland.md) |
