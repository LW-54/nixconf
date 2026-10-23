# Module: `astrolabe`

Unified NixOS system configuration root module for host 'astrolabe'.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.astrolabe`
- **Description**: Unified NixOS system configuration root module for host 'astrolabe'.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
  self.nixosModules.astrolabe-hardware
  self.nixosModules.astrolabe-disk
  self.nixosModules.astrolabe-system
  self.nixosModules.astrolabe-services
  self.nixosModules.astrolabe-packages
];
```

</details>


## Declared Options

NixOS options declared directly by this module:

*No direct top-level options declared.*
