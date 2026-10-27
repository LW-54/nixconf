# Module: `direnv`

Per-directory declarative shell environment integration via nix-direnv.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.direnv`
- **Description**: Per-directory declarative shell environment integration via nix-direnv.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
          self.nixosModules.direnv
          self.nixosModules.wifi-eduroam
          self.nixosModules.git
          self.nixosModules.tack
          self.nixosModules.bw
          self.nixosModules.ssh
          self.nixosModules.cgroups
          self.nixosModules.docker
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

*No direct top-level options declared.*
