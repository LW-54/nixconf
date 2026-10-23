# Module: `astrolabe-services`

Daemon services, reverse-proxy ingress, and automated backups for astrolabe.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.astrolabe-services`
- **Description**: Daemon services, reverse-proxy ingress, and automated backups for astrolabe.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
  self.nixosModules.astrolabe-services
  self.nixosModules.astrolabe-packages
];
```

</details>


## Declared Options

NixOS options declared directly by this module:

*No direct top-level options declared.*
