# Library Namespace: `flake.lib.wayland`

Library helpers and constructors for the 'wayland' capability contract.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.wayland`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.wayland
  example = self.lib.wayland.mkConfig;
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
    # Access exported helpers from inputs.nixconf.lib.wayland
    example = nixconf.lib.wayland.mkConfig;
  };
}
```

## Exported Symbols

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'wayland' capability contract.



#### Inputs

- `cfg`: Configuration binding parameter for the 'wayland' contract.
- `config`: Configuration binding parameter for the 'wayland' contract.


#### Type

```
wayland.mkConfig :: AttrSet -> AttrSet
```


#### Examples

```nix
wayland.mkConfig { inherit config cfg; }
```



<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'wayland' capability contract.



#### Inputs

- `name`: Submodule option parameter for the 'wayland' contract.


#### Type

```
wayland.mkOption :: AttrSet -> AttrSet
```


#### Examples

```nix
wayland.mkOption { ... }
```


