# Hosts

Declarative target host definitions binding concrete hardware configurations, platform architectures, active implementations, and enabled system features into bootable NixOS systems.

[← Back to Main README](../../README.md)

## Specification

- **Declared as**: `host.<name>` in any flake-parts module under `modules/hosts/`
- **Primitive definition**: [`primitives/host/default.nix`](../../primitives/host/default.nix)
- **Instances**: 2

## Option Schema (`host.<name>`)

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `configuration` | `module` | `{ }` | Host NixOS configuration module defining system settings, imports, and services. |
| `description` | `string` | **required** | Formal description of this primitive instance. |
| `devShells` | `raw value` | `{ }` | Development shells provided by this primitive. |
| `lib` | `attribute set of raw value` | `{ }` | Library helper functions and values exported on flake.lib.<name>. |
| `packages` | `raw value` | `{ }` | Packages provided by this primitive. |
| `specialArgs` | `attribute set of raw value` | `{ }` | Additional special arguments forwarded to nixpkgs.lib.nixosSystem. |
| `subModules` | `attribute set of module` | `{ }` | Host configuration submodules partitioning hardware, disks, and local system services. |
| `system` | `string` | `"x86_64-linux"` | Target Nix platform architecture for this host. |

## Declaration Example

Smallest declaration in the repository, [`modules/hosts/x240/default.nix`](../../modules/hosts/x240/default.nix):

```nix
{self, ...}: {
  host.x240 = {
    description = "ThinkPad Laptop Workstation (Desktop graphical workstation).";
    configuration = {
      imports = [
        self.nixosModules.x240-hardware
        self.nixosModules.x240-disk
        self.nixosModules.x240-system
        self.nixosModules.x240-desktop
        self.nixosModules.x240-resources
      ];
    };
  };
}
```

## Catalog

| Host | Description | System | Definition | Docs |
| :--- | :--- | :--- | :--- | :--- |
| [`astrolabe`](astrolabe.md) | Headless VPS Server (adje.app public edge and core services). | `x86_64-linux` | [`modules/hosts/astrolabe/default.nix`](../../modules/hosts/astrolabe/default.nix) | [More →](astrolabe.md) |
| [`x240`](x240.md) | ThinkPad Laptop Workstation (Desktop graphical workstation). | `x86_64-linux` | [`modules/hosts/x240/default.nix`](../../modules/hosts/x240/default.nix) | [More →](x240.md) |
