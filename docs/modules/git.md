# Module: `git`

Git version control system, global/per-user configuration, and Bitwarden SSH key agent shell.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.git`
- **Description**: Git version control system, global/per-user configuration, and Bitwarden SSH key agent shell.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
          self.nixosModules.git
        ];
```

</details>


<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
          self.nixosModules.git
          self.nixosModules.tack
          self.nixosModules.bw
          self.nixosModules.ssh
          self.nixosModules.cgroups
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.git.enable` | `boolean` | Whether to enable Git version control. |
| `options.git.prebuildGithubSsh` | `boolean` | Whether to enable prebuilding the GitHub SSH development shell. |
| `options.git.settings` | `attribute set of anything` | Global Git configuration settings. |
| `options.git.users` | `attribute set of (submodule)` | Per-user Git configuration overrides. |
