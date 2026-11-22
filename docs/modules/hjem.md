# Module: `hjem`

Lightweight declarative home directory files and XDG environment manager.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.hjem`
- **Provided by**: implementation [`hjem`](../implementations/hjem.md)

## Importing Hosts

- [`astrolabe`](../hosts/astrolabe.md): Headless VPS Server (adje.app public edge and core services).

- [`x240`](../hosts/x240.md): ThinkPad Laptop Workstation (Desktop graphical workstation).

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `hjem.cli.package` | `package` | `pkgs.callPackage ../../cli/package.nix { }` | — | The Hjem CLI package to use. |
| `hjem.clobberByDefault` | `boolean` | `false` | — | The default override behaviour for files managed by Hjem. While `true`, existing files will be overriden with new files on rebuild. The behaviour may be modified per-user by setting {option}`hjem.users.<username>.clobberFiles` to the desired value. |
| `hjem.extraModules` | `list of module` | `[ ]` | — | Additional modules to be evaluated as a part of the users module inside {option}`config.hjem.users.<username>`. This can be used to extend each user configuration with additional options. |
| `hjem.linker` | `null or package` | `config.hjem.cli.package` | — | Package to use to link files. By default, Hjem uses its own standalone CLI linker. Setting this to `null` will use `systemd-tmpfiles`, which is only supported on Linux. Specifying a non-null package uses an external linker that is invoked with Hjem-managed manifests. |
| `hjem.linkerOptions` | `(list of (optionally newline-terminated) single-line string) or (attribute set)` | `[ ]` | — | Additional linker configuration. When using Hjem's built-in standalone linker, only `prefix` is consumed from an attribute set. ::: {.note} When using an external linker package, list values are forwarded as linker arguments and attribute-set values are forwarded as `--linker-opts <json-file>`. ::: |
| `hjem.specialArgs` | `attribute set` | `{ }` | `{ inherit inputs; }` | Additional `specialArgs` are passed to Hjem, allowing extra arguments to be passed down to to all imported modules. |
| `hjem.users` | `attribute set of (Hjem submodule for NixOS)` | `{ }` | — | Hjem-managed user configurations. |
