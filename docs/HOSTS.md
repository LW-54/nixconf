# Hosts Documentation

Master host target registry declared via `options.host` in [`primitives/host.nix`](../primitives/host.nix).

[← Back to Main README](../README.md)

## Primitive Specification

Declarative target host definitions binding concrete hardware configurations, platform architectures, active implementations, and enabled system features into bootable NixOS systems.

### Option Schema (`options.host.<name>`)

- `description` (string, required): Formal description of the target machine and role.
- `system` (string, default: `"x86_64-linux"`): Target platform architecture.
- `modules` (listOf deferredModule, default: `[]`): Top-level NixOS modules (features, implementations).
- `subModules` (attrsOf deferredModule, default: `{}`): Host configuration submodules (hardware, disk, local services).
- `packages` (raw, default: `{}`): Host-specific executable packages or generator function.
- `devShells` (raw, default: `{}`): Host-specific recovery/administrative shells or generator function.
- `lib` (attrsOf raw, default: `{}`): Host-specific library helpers exported on `flake.lib.<host>`.

### Declaration Example (`host.<name>`)

```nix
host.example-machine = {
  description = "Headless edge compute server.";
  system = "x86_64-linux";
  modules = [
    self.nixosModules.caddy
  ];
  subModules = {
    example-hardware = { ... }: { ... };
  };
};
```

## Target Hosts Catalog

| Host | Description | System | Docs |
| :--- | :--- | :--- | :--- |
| [`astrolabe`](hosts/astrolabe.md) | Headless VPS Server (adje.app public edge and core services). | `x86_64-linux` | [More →](hosts/astrolabe.md) |
| [`x240`](hosts/x240.md) | ThinkPad Laptop Workstation (Desktop graphical workstation). | `x86_64-linux` | [More →](hosts/x240.md) |
