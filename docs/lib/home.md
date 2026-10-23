# Library Namespace: `flake.lib.home`

Library helpers and constructors for the 'home' capability contract.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.home`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.home
  example = self.lib.home.mkConfig;
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
    # Access exported helpers from inputs.nixconf.lib.home
    example = nixconf.lib.home.mkConfig;
  };
}
```

## Exported Symbols

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'home' capability contract.



#### Inputs

- `config`: Configuration binding parameter for the 'home' contract.
- `homeConfig`: Configuration binding parameter for the 'home' contract.
- `lib`: Configuration binding parameter for the 'home' contract.


#### Type

```
home.mkConfig :: AttrSet -> AttrSet
```


#### Examples

```nix
home.mkConfig { inherit config cfg; }
```



<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'home' capability contract.



#### Inputs

- `defaultEnable`: Submodule option parameter for the 'home' contract.
- `description`: Submodule option parameter for the 'home' contract.
- `lib`: Submodule option parameter for the 'home' contract.
- `name`: Submodule option parameter for the 'home' contract.
- `userOptions`: Submodule option parameter for the 'home' contract.


#### Type

```
home.mkOption :: AttrSet -> AttrSet
```


#### Examples

```nix
home.mkOption { ... }
```


