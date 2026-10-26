# Module: `vaultwarden`

Self-hosted Bitwarden compatible password manager server.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.vaultwarden`
- **Description**: Self-hosted Bitwarden compatible password manager server.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
          self.nixosModules.vaultwarden
          self.nixosModules.ttyd
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

*No direct top-level options declared.*
