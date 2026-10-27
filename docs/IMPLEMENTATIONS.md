# Implementations Documentation

Concrete capability providers declared via `options.implementation` in [`primitives/implementation.nix`](../primitives/implementation.nix).

[← Back to Main README](../README.md)

## Primitive Specification

Concrete capability providers satisfying contract interfaces by translating abstract capability options into provider-specific NixOS services, packages, and system configurations.

### Option Schema (`options.implementation.<name>`)

- `contract` (string, required): Name of the contract this module implements.
- `description` (string, required): Formal description of how this provider satisfies the contract.
- `module` (deferredModule, required): NixOS module implementing the contract.
- `packages` (raw, default: `{}`): Implementation package declarations or generator function.
- `devShells` (raw, default: `{}`): Implementation development shells or generator function.
- `lib` (attrsOf raw, default: `{}`): Exported library helpers and identity definitions on `flake.lib.<name>`.

### Declaration Example (`implementation.<name>`)

```nix
implementation.example-provider = {
  contract = "reverse-proxy";
  description = "Reverse proxy capability provider using example backend.";
  module = { ... }: { ... };
};
```

## Implementations Catalog

*No entries to display.*
