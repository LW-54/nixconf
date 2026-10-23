# Module: `ssh`

OpenSSH server daemon hardening, authorized key distribution, and master SSH key agent shell.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.ssh`
- **Description**: OpenSSH server daemon hardening, authorized key distribution, and master SSH key agent shell.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
  self.nixosModules.ssh
  self.nixosModules.git
];
```

</details>


<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
  self.nixosModules.ssh
  self.nixosModules.cgroups
];
```

</details>


## Declared Options

NixOS options declared directly by this module:

*No direct top-level options declared.*
