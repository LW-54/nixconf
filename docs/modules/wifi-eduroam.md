# Module: `wifi-eduroam`

Eduroam WPA2-Enterprise 802.1X wireless networking integration via NetworkManager.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.wifi-eduroam`
- **Description**: Eduroam WPA2-Enterprise 802.1X wireless networking integration via NetworkManager.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
          self.nixosModules.wifi-eduroam
          self.nixosModules.git
          self.nixosModules.tack
          self.nixosModules.bw
          self.nixosModules.ssh
          self.nixosModules.docker
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

*No direct top-level options declared.*
