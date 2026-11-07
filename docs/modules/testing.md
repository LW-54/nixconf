# Module: `testing`

Declarative host verification: evaluation-time essentials, runtime VM checks, and test stand-ins for secrets.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.testing`
- **Provided by**: contract [`testing`](../contracts/testing.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `testing.checks` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Named runtime checks contributed by modules, executed by the NixOS test driver against the booted host. Every host importing a module automatically inherits its checks. |
| `testing.credentials.hashedPassword` | `string` | `"$y$j9T$wLgKY231.8j.ciV2MfEXe1$P0k5j3bCwHgnwW0Ive3w4knrgpiA4TzhCYLAnHvDZ51"` | — | Crypt(3) hash of `testing.credentials.password`, used as the stand-in for password hash secrets. |
| `testing.credentials.password` | `string` | `"test"` | — | Plain-text password that test stand-in password hashes resolve to. |
| `testing.credentials.sshHostPrivateKey` | `string` | nixpkgs snakeoil Ed25519 private key from nixos/tests/ssh-keys.nix | — | Private half of the stand-in SSH host key, used as the stand-in for host key secrets. |
| `testing.credentials.sshHostPublicKey` | `string` | nixpkgs snakeoil Ed25519 public key from nixos/tests/ssh-keys.nix | — | Public half of the stand-in SSH host key, used to verify host key provisioning. |
| `testing.credentials.sshPrivateKey` | `string` | nixpkgs snakeoil ECDSA private key from nixos/tests/ssh-keys.nix | — | Private half of the test client key, used by remote checks to log in over SSH. |
| `testing.credentials.sshPublicKey` | `string` | nixpkgs snakeoil ECDSA public key from nixos/tests/ssh-keys.nix | — | Public half of the test client key, used as the stand-in for authorized key secrets. |
| `testing.enable` | `boolean` | `false` | `true` | Whether to enable test mode; only set inside generated test variants so modules can swap real secrets and hardware for stand-ins. |
| `testing.evalChecks` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Named evaluation-time checks over the host configuration. They run in seconds without building anything (`nix flake check --no-build`), and all failures are reported together. |
| `testing.install.enable` | `boolean` | `false` | — | Whether the `install` tier (partition the real disk layout, install, boot through the real boot loader) is available for this host. Enabled automatically for Disko-managed hosts. |
| `testing.name` | `null or string` | — | `"x240"` | Flake attribute name of the host under test, injected by the test harness. |
| `testing.vm.allowedFailedUnits` | `list of string` | `[ ]` | `[ ... ]` | Shell-style unit patterns that may legitimately fail inside the isolated test network. |
| `testing.vm.cores` | `positive integer, meaning >0` | `2` | — | Number of virtual CPU cores given to the host under test. |
| `testing.vm.enable` | `boolean` | `true` | — | Whether the host can be booted in a virtualised `vm` tier test. |
| `testing.vm.memorySize` | `positive integer, meaning >0` | `2048` | — | Memory in MiB given to the virtual machine running the host under test. |
| `testing.vm.sshForwardPort` | `16 bit unsigned integer; between 0 and 65535 (both inclusive)` | `2222` | — | Host port forwarded to the guest SSH daemon when running the interactive VM. |
