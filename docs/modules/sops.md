# Module: `sops`

Declarative encrypted secrets provisioning using SOPS and age keys.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.sops`
- **Description**: Declarative encrypted secrets provisioning using SOPS and age keys.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
          self.nixosModules.sops
          self.nixosModules.lw
          self.nixosModules.cgroups
          self.nixosModules.nix
          self.nixosModules.locale
          self.nixosModules.ssh
          self.nixosModules.git
        ];
```

</details>


<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
          self.nixosModules.sops
          self.nixosModules.lw
          self.nixosModules.hjem
          self.nixosModules.nix
          self.nixosModules.locale
          self.nixosModules.x240-system-features
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.sops.age.generateKey` | `boolean` | Whether or not to generate the age key. If this option is set to false, the key must already be present at the specified location. |
| `options.sops.age.keyFile` | `null or path not in the Nix store` | Path to age key file used for sops decryption. |
| `options.sops.age.plugins` | `list of package` | List of plugins to use for sops decryption. |
| `options.sops.age.sshKeyPaths` | `list of absolute path` | Paths to ssh keys added as age keys during sops description. |
| `options.sops.defaultSopsFile` | `absolute path` | Default sops file used for all secrets. |
| `options.sops.defaultSopsFormat` | `string` | Default sops format used for all secrets. |
| `options.sops.defaultSopsKey` | `null or string` | Default key used to lookup in all secrets. This option is ignored if format is binary. "" means whole file. |
| `options.sops.environment` | `attribute set of (string or absolute path)` | Environment variables to set before calling sops-install-secrets.  The values are placed in single quotes and not escaped any further to allow usage of command substitutions for more flexibility. To properly quote strings with quotes use lib.escapeShellArg.  This will be evaluated twice when using secrets that use neededForUsers but in a subshell each time so the environment variables don't collide. |
| `options.sops.gnupg.home` | `null or string` | Path to gnupg database directory containing the key for decrypting the sops file. |
| `options.sops.gnupg.package` | `package` | The gnupg package to use for sops operations. |
| `options.sops.gnupg.sshKeyPaths` | `list of absolute path` | Path to ssh keys added as GPG keys during sops description. This option must be explicitly unset if <literal>config.sops.gnupg.home</literal> is set. |
| `options.sops.gnupgHome` | `null or string` | Alias of {option}`sops.gnupg.home`. |
| `options.sops.keepGenerations` | `unsigned integer, meaning >=0` | Number of secrets generations to keep. Setting this to 0 disables pruning. |
| `options.sops.log` | `list of (one of "keyImport", "secretChanges")` | What to log |
| `options.sops.package` | `package` | sops-install-secrets package to use. |
| `options.sops.placeholder` | `attribute set of (value that can be coerced to string)` |  |
| `options.sops.prebuildAdminShell` | `boolean` | Whether to enable prebuilding the SOPS admin development shell. |
| `options.sops.prebuildHostShell` | `boolean` | Whether to enable prebuilding the SOPS host development shell. |
| `options.sops.secrets` | `attribute set of (submodule)` | Path where the latest secrets are mounted to. |
| `options.sops.sshKeyPaths` | `list of absolute path` | Alias of {option}`sops.gnupg.sshKeyPaths`. |
| `options.sops.templates` | `attribute set of (submodule)` | Templates for secret files |
| `options.sops.useSystemdActivation` | `boolean` | Use a systemd unit to install secrets, instead of deploying them using an activation script.  This option is automatically enabled when systemd-sysusers or userborn are used to manage users and groups. It can also be useful to specify additional dependencies to be satisfied before secrets are installed, such as required mountpoints for SOPS key files. |
| `options.sops.useTmpfs` | `boolean` | Use tmpfs in place of ramfs for secrets storage.  *WARNING* On Linux kernels earlier than 6.4, enabling this option has the potential to write secrets to disk unencrypted if the tmpfs volume is written to swap. Do not use unless absolutely necessary.  When using a swap file or device, consider enabling swap encryption by setting the `randomEncryption.enable` option  ``` swapDevices = [{   device = "/dev/sdXY";   randomEncryption.enable = true; }]; ``` |
| `options.sops.validateSopsFiles` | `boolean` | Check all sops files at evaluation time. This requires sops files to be added to the nix store. |
| `options.sops.validationPackage` | `package` | sops-install-secrets package to use when validating configuration.  Defaults to sops.package if building natively, and a native version of sops-install-secrets if cross compiling. |

