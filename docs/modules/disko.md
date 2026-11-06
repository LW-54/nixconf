# Module: `disko`

Declarative disk partitioning and filesystem layouts via Disko.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.disko`
- **Provided by**: feature [`disko`](../features/disko.md)

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).

- [`x240`](../hosts/x240.md): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `disko.checkScripts` | `boolean` | `false` | — | Whether to run shellcheck on script outputs |
| `disko.devices` | `submodule` | `{ }` | — | The devices to set up |
| `disko.enableConfig` | `boolean` | `true` | — | configure nixos with the specified devices should be true if the system is booted with those devices should be false on an installer image etc. |
| `disko.imageBuilder.copyNixStore` | `boolean` | `true` | — | whether to copy the nix store into the disk images we just created |
| `disko.imageBuilder.copyNixStoreThreads` | `positive integer, meaning >0, or value "auto" (singular enum)` | `"auto"` | `4` | Number of parallel threads to use when copying the nix store. Set to "auto" (the default) to automatically determine based on CPU cores, capped at 8. Higher values may hurt performance on some systems due to virtiofsd file descriptor limits. |
| `disko.imageBuilder.enableBinfmt` | `boolean` | `false` | — | enable emulation of foreign architecture binaries in the builder. Makes it possible to build disk images for a foreign architecture in a VM with native performance. Required for the bootloader installation step, which chroots into the target environment. |
| `disko.imageBuilder.extraConfig` | `unspecified value` | `{ }` | — | Extra NixOS config for your test. Can be used to specify a different luks key for tests. A dummy key is in /tmp/secret.key |
| `disko.imageBuilder.extraDependencies` | `list of package` | `[ ]` | — | list of extra packages to make available in the make-disk-image.nix VM builder, an example might be f2fs-tools |
| `disko.imageBuilder.extraPostVM` | `strings concatenated with "\n"` | `":"` | `${pkgs.zstd}/bin/zstd --compress $out/*raw rm $out/*raw` | extra shell code to execute once the disk image(s) have been successfully created and moved to $out |
| `disko.imageBuilder.extraRootModules` | `list of string` | `[ ]` | `[ ... ]` | extra kernel modules to pass to the vmTools.runCommand invocation in the make-disk-image.nix builder |
| `disko.imageBuilder.imageFormat` | `one of "raw", "qcow2"` | `"raw"` | — | QEMU image format to use for the disk images |
| `disko.imageBuilder.kernelPackages` | `attribute set` | `config.boot.kernelPackages` | `pkgs.linuxPackages_testing` | the kernel used when building disk images via make-disk-image.nix. Useful when the config's kernel won't boot in the image-builder. |
| `disko.imageBuilder.name` | `string` | `"${config.networking.hostName}-disko-images"` | — | name for the disk images |
| `disko.imageBuilder.pkgs` | `attribute set` | `pkgs` | `pkgs` | the pkgs instance used when building disk images via make-disk-image.nix. Useful when the config's kernel won't boot in the image-builder. |
| `disko.imageBuilder.qemu` | `null or string` | — | `${pkgs.qemu_kvm}/bin/qemu-system-aarch64` | the qemu emulator string used when building disk images via make-disk-image.nix. Useful when using binfmt on your build host, and wanting to build disk images for a foreign architecture |
| `disko.imageBuilder.useVirtualDevices` | `boolean` | `true` | — | Replace device names with ones usable in VMs. Ex: `/dev/vda`. Disable this if the disk image is for use on real hardware. |
| `disko.memSize` | `signed integer` | `1024` | — | size of the memory passed to runInLinuxVM, in megabytes |
| `disko.rootMountPoint` | `string` | `"/mnt"` | — | Where the device tree should be mounted by the mountScript |
| `disko.testMode` | `boolean` | `false` | — | this is true if the system is being run in test mode. like a vm test or an interactive vm |
| `disko.tests.bootCommands` | `strings concatenated with "\n"` | `""` | — | NixOS test script commands to run after the machine has started. Can be used to enter an interactive password. |
| `disko.tests.efi` | `boolean` | `"config.boot.loader.systemd-boot.enable \|\| config.boot.loader.grub.efiSupport"` | — | Whether efi is enabled for the `system.build.installTest`. We try to automatically detect efi based on the configured bootloader. |
| `disko.tests.enableOCR` | `boolean` | `false` | — | Sets the enableOCR option in the NixOS VM test driver. |
| `disko.tests.extraChecks` | `strings concatenated with "\n"` | `""` | `"machine.succeed("test -e /var/secrets/my.secret")"` | extra checks to run in the `system.build.installTest`. |
| `disko.tests.extraConfig` | `unspecified value` | `{ }` | — | Extra NixOS config for your test. Can be used to specify a different luks key for tests. A dummy key is in /tmp/secret.key |
