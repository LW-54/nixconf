# Module: `sops`

Declarative encrypted secrets provisioning using SOPS and age keys.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.sops`
- **Provided by**: implementation [`sops`](../implementations/sops.md)

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).

- [`x240`](../hosts/x240.md): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `sops.age.generateKey` | `boolean` | `false` | — | Whether or not to generate the age key. If this option is set to false, the key must already be present at the specified location. |
| `sops.age.keyFile` | `null or path not in the Nix store` | — | `"/var/lib/sops-nix/key.txt"` | Path to age key file used for sops decryption. |
| `sops.age.plugins` | `list of package` | `[ ]` | — | List of plugins to use for sops decryption. |
| `sops.age.sshKeyPaths` | `list of absolute path` | The ed25519 keys from {option}`config.services.openssh.hostKeys` | — | Paths to ssh keys added as age keys during sops description. |
| `sops.defaultSopsFile` | `absolute path` | — | — | Default sops file used for all secrets. |
| `sops.defaultSopsFormat` | `string` | `"yaml"` | — | Default sops format used for all secrets. |
| `sops.defaultSopsKey` | `null or string` | — | — | Default key used to lookup in all secrets. This option is ignored if format is binary. "" means whole file. |
| `sops.environment` | `attribute set of (string or absolute path)` | `{ }` | — | Environment variables to set before calling sops-install-secrets. The values are placed in single quotes and not escaped any further to allow usage of command substitutions for more flexibility. To properly quote strings with quotes use lib.escapeShellArg. This will be evaluated twice when using secrets that use neededForUsers but in a subshell each time so the environment variables don't collide. |
| `sops.gnupg.home` | `null or string` | — | `"/root/.gnupg"` | Path to gnupg database directory containing the key for decrypting the sops file. |
| `sops.gnupg.package` | `package` | `pkgs.gnupg` | — | The gnupg package to use for sops operations. |
| `sops.gnupg.sshKeyPaths` | `list of absolute path` | The rsa keys from {option}`config.services.openssh.hostKeys` | — | Path to ssh keys added as GPG keys during sops description. This option must be explicitly unset if <literal>config.sops.gnupg.home</literal> is set. |
| `sops.gnupgHome` | `null or string` | — | — | Alias of {option}`sops.gnupg.home`. |
| `sops.keepGenerations` | `unsigned integer, meaning >=0` | `1` | — | Number of secrets generations to keep. Setting this to 0 disables pruning. |
| `sops.log` | `list of (one of "keyImport", "secretChanges")` | `[ ... ]` | — | What to log |
| `sops.package` | `package` | `(pkgs.callPackage ../.. {}).sops-install-secrets` | — | sops-install-secrets package to use. |
| `sops.placeholder` | `attribute set of (value that can be coerced to string)` | `{ }` | — |  |
| `sops.prebuildAdminShell` | `boolean` | `true` | `true` | Whether to enable prebuilding the SOPS admin development shell. |
| `sops.prebuildHostShell` | `boolean` | `true` | `true` | Whether to enable prebuilding the SOPS host development shell. |
| `sops.secrets` | `attribute set of (submodule)` | `{ }` | — | Path where the latest secrets are mounted to. |
| `sops.sshKeyPaths` | `list of absolute path` | — | — | Alias of {option}`sops.gnupg.sshKeyPaths`. |
| `sops.templates` | `attribute set of (submodule)` | `{ }` | — | Templates for secret files |
| `sops.useSystemdActivation` | `boolean` | `(options.systemd ? sysusers && config.systemd.sysusers.enable) \|\| (options.services ? userborn && config.services.userborn.enable)` | — | Use a systemd unit to install secrets, instead of deploying them using an activation script. This option is automatically enabled when systemd-sysusers or userborn are used to manage users and groups. It can also be useful to specify additional dependencies to be satisfied before secrets are installed, such as required mountpoints for SOPS key files. |
| `sops.useTmpfs` | `boolean` | `false` | — | Use tmpfs in place of ramfs for secrets storage. *WARNING* On Linux kernels earlier than 6.4, enabling this option has the potential to write secrets to disk unencrypted if the tmpfs volume is written to swap. Do not use unless absolutely necessary. When using a swap file or device, consider enabling swap encryption by setting the `randomEncryption.enable` option ``` swapDevices = [{ device = "/dev/sdXY"; randomEncryption.enable = true; }]; ``` |
| `sops.validateSopsFiles` | `boolean` | `true` | — | Check all sops files at evaluation time. This requires sops files to be added to the nix store. |
| `sops.validationPackage` | `package` | `config.sops.package` | — | sops-install-secrets package to use when validating configuration. Defaults to sops.package if building natively, and a native version of sops-install-secrets if cross compiling. |
