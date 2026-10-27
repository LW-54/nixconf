# Module: `bw`

System service module exported by the 'bitwarden' feature.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.bw`
- **Description**: System service module exported by the 'bitwarden' feature.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
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
