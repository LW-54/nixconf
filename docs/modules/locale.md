# Module: `locale`

System internationalization, time zone, and language locale configuration.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.locale`
- **Description**: System internationalization, time zone, and language locale configuration.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
          self.nixosModules.locale
          self.nixosModules.ssh
          self.nixosModules.git
        ];
```

</details>


<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
          self.nixosModules.locale
          self.nixosModules.x240-system-features
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.locale.defaultLocale` | `string` | System default locale and the default user locale. |
| `options.locale.enable` | `boolean` | Whether to enable locale configuration. |
| `options.locale.extraLocaleSettings` | `attribute set of string` | Additional system locale settings and user defaults. |
| `options.locale.timeZone` | `string` | System time zone. |
