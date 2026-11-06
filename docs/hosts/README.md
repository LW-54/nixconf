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

## Declaration Example

Smallest declaration in the repository, [`modules/hosts/astrolabe.nix`](../../modules/hosts/astrolabe.nix):

<details>
<summary><code>modules/hosts/astrolabe.nix</code></summary>

```nix
{self, ...}: {
  host.astrolabe = {
    description = "Headless VPS Server (adje.app public edge and core services).";
    configuration = {
      imports = [
        self.nixosModules.astrolabe-hardware
        self.nixosModules.astrolabe-disk
        self.nixosModules.contracts
        self.nixosModules.astrolabe-system
        self.nixosModules.astrolabe-services
        self.nixosModules.astrolabe-packages
      ];
    };
    subModules = {
      astrolabe-packages = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          nano
          rsync
          btop
        ];
      };

      astrolabe-services = {...}: {
        imports = [
          self.nixosModules.caddy
          self.nixosModules.restic
          self.nixosModules.vaultwarden
          self.nixosModules.ttyd
          self.nixosModules.uchiyomi
        ];

        config = {
          reverse-proxy.domain = "adje.app";
          services.resticBackup.repository = "s3:https://s3.eu-central-003.backblazeb2.com/cyclostyle-docker";
          persistence.directories = [
            "/var/lib/containers"
          ];
        };
      };

      astrolabe-system = {
        imports = [
          self.nixosModules.sops
          self.nixosModules.lw
          self.nixosModules.nix
          self.nixosModules.locale
          self.nixosModules.ssh
          self.nixosModules.git
        ];

        config = {
          networking.hostName = "astrolabe";
          system.configurationRevision = self.rev or self.dirtyRev or "unknown";
          system.stateVersion = "25.11";
        };
      };

      astrolabe-disk = {...}: {
        imports = [
          self.nixosModules.disko
          self.nixosModules.impermanence
        ];

        config =
          self.lib.disko.mkLayout {
            device = "/dev/sda";
            espSize = "512M";
            biosBootSize = "1M";
          }
          // {
            zramSwap.enable = true;
          };
      };

      astrolabe-hardware = {
        modulesPath,
        lib,
        ...
      }: {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          (modulesPath + "/profiles/qemu-guest.nix")
        ];

        config = {
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
          boot.loader.grub = {
            enable = true;
            efiSupport = true;
            efiInstallAsRemovable = true;
            device = "/dev/sda";
          };
        };
      };
    };
  };
}
```

</details>

## Catalog

| Host | Description | System | Definition | Docs |
| :--- | :--- | :--- | :--- | :--- |
| [`astrolabe`](astrolabe.md) | Headless VPS Server (adje.app public edge and core services). | `x86_64-linux` | [`modules/hosts/astrolabe.nix`](../../modules/hosts/astrolabe.nix) | [More →](astrolabe.md) |
| [`x240`](x240.md) | ThinkPad Laptop Workstation (Desktop graphical workstation). | `x86_64-linux` | [`modules/hosts/x240.nix`](../../modules/hosts/x240.nix) | [More →](x240.md) |
