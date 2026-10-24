# Library Namespace: `flake.lib.primitive`

Primitives framework helper functions, option constructors, and utilities.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.primitive`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.primitive
  example = self.lib.primitive.option;
}
```

### External Usage

When consuming this flake as an input in another `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixconf.url = "github:LW-54/nixconf";
  };

  outputs = { self, nixpkgs, nixconf, ... }: {
    # Access exported helpers from inputs.nixconf.lib.primitive
    example = nixconf.lib.primitive.option;
  };
}
```

## Exported Symbols

<a id="option"></a>
### `option`

Pre-configured option constructors for primitive definitions with automatic descriptions and functor override support.





#### Type

```
option :: AttrSet
```





<a id="output"></a>
### `output`

Pre-configured output generator helpers for aggregating flake outputs.





#### Type

```
output :: AttrSet
```





<a id="unwrapLib"></a>
### `unwrapLib`

Unwraps documented symbols from an attribute set, extracting `.value` if present or stripping `.docstring` metadata.



#### Inputs

- `attrs`: Attribute set containing documented symbol definitions.


#### Type

```
unwrapLib :: AttrSet -> AttrSet
```




