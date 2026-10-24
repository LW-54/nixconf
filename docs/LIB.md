# Library Documentation

Pure reusable helper functions, data types, calculations, and presets declared via `options.lib` in [`primitives/lib.nix`](../primitives/lib.nix).

[← Back to Main README](../README.md)

## Primitive Specification

Pure reusable helper functions, data types, calculations, and configuration presets exported across the repository.

### Option Schema (`options.lib.<name>`)

- `description` (string, required): Formal description of this library namespace and its capabilities.
- `symbols` (attrsOf raw, default: `{}`): Exported library functions and values under `flake.lib.<name>.<symbol>`. Can be declared either as raw values or as attribute sets containing an RFC 145 docstring (`{ docstring = "..."; value = ...; }`).

### Declaration Example (`lib.<name>`)

```nix
lib.math = {
  description = "Mathematical utility functions and numeric helpers.";
  symbols = {
    add = {
      docstring = ''
        Adds two integers.

        # Inputs

        - `a`: First integer
        - `b`: Second integer

        # Type

        ```
        Int -> Int -> Int
        ```
      '';
      value = a: b: a + b;
    };
  };
};
```

## Library Namespaces Catalog

| Library Namespace | Description | Exported Functions / Symbols | Docs |
| :--- | :--- | :--- | :--- |
| [`flake.lib.backup`](lib/backup.md) | Library helpers and constructors for the 'backup' capability contract. | [`defaultPruneOpts`](lib/backup.md#defaultPruneOpts), [`defaultTimerConfig`](lib/backup.md#defaultTimerConfig), [`mkConfig`](lib/backup.md#mkConfig), [`mkOption`](lib/backup.md#mkOption) | [More →](lib/backup.md) |
| [`flake.lib.bitwarden`](lib/bitwarden.md) | Bitwarden password manager CLI wrapper, desktop application, and vault retrieval helpers. | [`mkShell`](lib/bitwarden.md#mkShell), [`mkValue`](lib/bitwarden.md#mkValue) | [More →](lib/bitwarden.md) |
| [`flake.lib.default-user`](lib/default-user.md) | Library helpers and constructors for the 'default-user' capability contract. | [`forDefaultUser`](lib/default-user.md#forDefaultUser), [`mkConfig`](lib/default-user.md#mkConfig), [`mkOption`](lib/default-user.md#mkOption) | [More →](lib/default-user.md) |
| [`flake.lib.disko`](lib/disko.md) | Declarative disk partitioning and filesystem layouts via Disko. | [`mkLayout`](lib/disko.md#mkLayout) | [More →](lib/disko.md) |
| [`flake.lib.home`](lib/home.md) | Library helpers and constructors for the 'home' capability contract. | [`mkConfig`](lib/home.md#mkConfig), [`mkOption`](lib/home.md#mkOption) | [More →](lib/home.md) |
| [`flake.lib.lw`](lib/lw.md) | Primary human user account orchestration and identity provisioning. | [`email`](lib/lw.md#email), [`githubUsername`](lib/lw.md#githubUsername), [`username`](lib/lw.md#username) | [More →](lib/lw.md) |
| [`flake.lib.persistence`](lib/persistence.md) | Library helpers and constructors for the 'persistence' capability contract. | [`entries`](lib/persistence.md#entries), [`mkConfig`](lib/persistence.md#mkConfig), [`mkOption`](lib/persistence.md#mkOption) | [More →](lib/persistence.md) |
| [`flake.lib.primitive`](lib/primitive.md) | Primitives framework helper functions, option constructors, and utilities. | [`option`](lib/primitive.md#option), [`output`](lib/primitive.md#output), [`unwrapLib`](lib/primitive.md#unwrapLib) | [More →](lib/primitive.md) |
| [`flake.lib.resources`](lib/resources.md) | Library helpers and constructors for the 'resources' capability contract. | [`defaultSlices`](lib/resources.md#defaultSlices), [`mkConfig`](lib/resources.md#mkConfig), [`mkOption`](lib/resources.md#mkOption), [`profiles`](lib/resources.md#profiles) | [More →](lib/resources.md) |
| [`flake.lib.reverse-proxy`](lib/reverse-proxy.md) | Library helpers and constructors for the 'reverse-proxy' capability contract. | [`mkConfig`](lib/reverse-proxy.md#mkConfig), [`mkOption`](lib/reverse-proxy.md#mkOption) | [More →](lib/reverse-proxy.md) |
| [`flake.lib.secrets`](lib/secrets.md) | Library helpers and constructors for the 'secrets' capability contract. | [`mkConfig`](lib/secrets.md#mkConfig), [`mkOption`](lib/secrets.md#mkOption) | [More →](lib/secrets.md) |
| [`flake.lib.sops`](lib/sops.md) | Declarative encrypted secrets provisioning using SOPS and age keys. | [`mkHostShell`](lib/sops.md#mkHostShell) | [More →](lib/sops.md) |
| [`flake.lib.user`](lib/user.md) | Normal user account helper functions and querying utilities. | [`forNormalUsers`](lib/user.md#forNormalUsers), [`normalUserNames`](lib/user.md#normalUserNames), [`normalUsers`](lib/user.md#normalUsers) | [More →](lib/user.md) |
| [`flake.lib.wayland`](lib/wayland.md) | Library helpers and constructors for the 'wayland' capability contract. | [`mkConfig`](lib/wayland.md#mkConfig), [`mkOption`](lib/wayland.md#mkOption) | [More →](lib/wayland.md) |
