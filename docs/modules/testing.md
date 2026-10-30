# Module: `testing`

Contract interface defining 'testing' option schemas and custom types.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.testing`
- **Description**: Contract interface defining 'testing' option schemas and custom types.

## Importing Hosts

Hosts that import this module into their system configurations:

*Not currently imported by any host.*

## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.testing.checks` | `attribute set of (submodule)` | Named runtime checks contributed by modules, executed by the NixOS test driver against the booted host. Every host importing a module automatically inherits its checks. |
| `options.testing.credentials.hashedPassword` | `string` | Crypt(3) hash of `testing.credentials.password`, used as the stand-in for password hash secrets. |
| `options.testing.credentials.password` | `string` | Plain-text password that test stand-in password hashes resolve to. |
| `options.testing.credentials.sshHostPrivateKey` | `string` | Private half of the stand-in SSH host key, used as the stand-in for host key secrets. |
| `options.testing.credentials.sshHostPublicKey` | `string` | Public half of the stand-in SSH host key, used to verify host key provisioning. |
| `options.testing.credentials.sshPrivateKey` | `string` | Private half of the test client key, used by remote checks to log in over SSH. |
| `options.testing.credentials.sshPublicKey` | `string` | Public half of the test client key, used as the stand-in for authorized key secrets. |
| `options.testing.enable` | `boolean` | Whether to enable test mode; only set inside generated test variants so modules can swap real secrets and hardware for stand-ins. |
| `options.testing.evalChecks` | `attribute set of (submodule)` | Named evaluation-time checks over the host configuration. They run in seconds without building anything (`nix flake check --no-build`), and all failures are reported together. |
| `options.testing.install.enable` | `boolean` | Whether the `install` tier (partition the real disk layout, install, boot through the real boot loader) is available for this host. Enabled automatically for Disko-managed hosts. |
| `options.testing.name` | `null or string` | Flake attribute name of the host under test, injected by the test harness. |
| `options.testing.vm.allowedFailedUnits` | `list of string` | Shell-style unit patterns that may legitimately fail inside the isolated test network. |
| `options.testing.vm.cores` | `positive integer, meaning >0` | Number of virtual CPU cores given to the host under test. |
| `options.testing.vm.enable` | `boolean` | Whether the host can be booted in a virtualised `vm` tier test. |
| `options.testing.vm.memorySize` | `positive integer, meaning >0` | Memory in MiB given to the virtual machine running the host under test. |
| `options.testing.vm.sshForwardPort` | `16 bit unsigned integer; between 0 and 65535 (both inclusive)` | Host port forwarded to the guest SSH daemon when running the interactive VM. |
