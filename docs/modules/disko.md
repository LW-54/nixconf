# Module: `disko`

Declarative disk partitioning and filesystem layouts via Disko.

[← Back to Modules Documentation](../MODULES.md) | [← Back to Main README](../../README.md)

## Metadata

- **Module Attribute**: `flake.nixosModules.disko`
- **Description**: Declarative disk partitioning and filesystem layouts via Disko.

## Importing Hosts

Hosts that import this module into their system configurations:

<details>
<summary><code><a href="../hosts/astrolabe.md">astrolabe</a></code></summary>

```nix
          self.nixosModules.disko
          self.nixosModules.impermanence
        ];
```

</details>


<details>
<summary><code><a href="../hosts/x240.md">x240</a></code></summary>

```nix
          self.nixosModules.disko
          self.nixosModules.impermanence
        ];
```

</details>


## Declared Options

NixOS options declared directly by this module:

| Option Path | Type | Description |
| :--- | :--- | :--- |
| `options.disko.checkScripts` | `boolean` | Whether to run shellcheck on script outputs |
| `options.disko.devices` | `submodule` | The devices to set up |
| `options.disko.enableConfig` | `boolean` | configure nixos with the specified devices should be true if the system is booted with those devices should be false on an installer image etc. |
| `options.disko.imageBuilder.copyNixStore` | `boolean` | whether to copy the nix store into the disk images we just created |
| `options.disko.imageBuilder.copyNixStoreThreads` | `positive integer, meaning >0, or value "auto" (singular enum)` | Number of parallel threads to use when copying the nix store. Set to "auto" (the default) to automatically determine based on CPU cores, capped at 8. Higher values may hurt performance on some systems due to virtiofsd file descriptor limits. |
| `options.disko.imageBuilder.enableBinfmt` | `boolean` | enable emulation of foreign architecture binaries in the builder. Makes it possible to build disk images for a foreign architecture in a VM with native performance. Required for the bootloader installation step, which chroots into the target environment. |
| `options.disko.imageBuilder.extraConfig` | `unspecified value` | Extra NixOS config for your test. Can be used to specify a different luks key for tests. A dummy key is in /tmp/secret.key |
| `options.disko.imageBuilder.extraDependencies` | `list of package` | list of extra packages to make available in the make-disk-image.nix VM builder, an example might be f2fs-tools |
| `options.disko.imageBuilder.extraPostVM` | `strings concatenated with "\n"` | extra shell code to execute once the disk image(s) have been successfully created and moved to $out |
| `options.disko.imageBuilder.extraRootModules` | `list of string` | extra kernel modules to pass to the vmTools.runCommand invocation in the make-disk-image.nix builder |
| `options.disko.imageBuilder.imageFormat` | `one of "raw", "qcow2"` | QEMU image format to use for the disk images |
| `options.disko.imageBuilder.kernelPackages` | `attribute set` | the kernel used when building disk images via make-disk-image.nix. Useful when the config's kernel won't boot in the image-builder. |
| `options.disko.imageBuilder.name` | `string` | name for the disk images |
| `options.disko.imageBuilder.pkgs` | `attribute set` | the pkgs instance used when building disk images via make-disk-image.nix. Useful when the config's kernel won't boot in the image-builder. |
| `options.disko.imageBuilder.qemu` | `null or string` | the qemu emulator string used when building disk images via make-disk-image.nix. Useful when using binfmt on your build host, and wanting to build disk images for a foreign architecture |
| `options.disko.memSize` | `signed integer` | size of the memory passed to runInLinuxVM, in megabytes |
| `options.disko.rootMountPoint` | `string` | Where the device tree should be mounted by the mountScript |
| `options.disko.testMode` | `boolean` | this is true if the system is being run in test mode. like a vm test or an interactive vm |
| `options.disko.tests.bootCommands` | `strings concatenated with "\n"` | NixOS test script commands to run after the machine has started. Can be used to enter an interactive password. |
| `options.disko.tests.efi` | `boolean` | Whether efi is enabled for the `system.build.installTest`. We try to automatically detect efi based on the configured bootloader. |
| `options.disko.tests.enableOCR` | `boolean` | Sets the enableOCR option in the NixOS VM test driver. |
| `options.disko.tests.extraChecks` | `strings concatenated with "\n"` | extra checks to run in the `system.build.installTest`. |
| `options.disko.tests.extraConfig` | `unspecified value` | Extra NixOS config for your test. Can be used to specify a different luks key for tests. A dummy key is in /tmp/secret.key |
