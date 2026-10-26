# Module: `contracts`

Central contract registry importing all declared contract interfaces.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.contracts`
- **Description**: Central contract registry importing all declared contract interfaces.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
          self.nixosModules.contracts
          self.nixosModules.sops
          self.nixosModules.lw
          self.nixosModules.cgroups
          self.nixosModules.nix
          self.nixosModules.locale
          self.nixosModules.ssh
          self.nixosModules.git
        ];
```

</details>


<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
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
