# Module: `restic`

Automated encrypted remote backups using Restic and systemd timers.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.restic`
- **Description**: Automated encrypted remote backups using Restic and systemd timers.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
          self.nixosModules.restic
          self.nixosModules.vaultwarden
          self.nixosModules.ttyd
          self.nixosModules.uchiyomi
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

*No direct top-level options declared.*
