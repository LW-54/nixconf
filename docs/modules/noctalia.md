# Module: `noctalia`

Noctalia shell environment, status bar, app launcher, and wallpaper manager.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.noctalia`
- **Description**: Noctalia shell environment, status bar, app launcher, and wallpaper manager.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
          self.nixosModules.noctalia
          self.nixosModules.audio
          self.nixosModules.cursor
          self.nixosModules.greetd
          self.nixosModules.x240-desktop-features
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

*No direct top-level options declared.*
