# Module: `caddy`

Automated TLS virtual host reverse proxy implementation using Caddy.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.caddy`
- **Description**: Automated TLS virtual host reverse proxy implementation using Caddy.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
          self.nixosModules.caddy
          self.nixosModules.restic
          self.nixosModules.vaultwarden
          self.nixosModules.ttyd
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

*No direct top-level options declared.*
