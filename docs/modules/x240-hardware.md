# Module: `x240-hardware`

Hardware profile, kernel modules, and bootloader configuration for x240.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.x240-hardware`
- **Description**: Hardware profile, kernel modules, and bootloader configuration for x240.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
        self.nixosModules.x240-hardware
        self.nixosModules.x240-disk
        self.nixosModules.contracts
        self.nixosModules.x240-system
        self.nixosModules.x240-desktop
        self.nixosModules.x240-packages
      ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

*No direct top-level options declared.*
