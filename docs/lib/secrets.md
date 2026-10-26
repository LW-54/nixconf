# Library Namespace: `flake.lib.secrets`

Library helpers and constructors for the 'secrets' contract.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.secrets`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.secrets
  example = self.lib.secrets.mkConfig;
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
    # Access exported helpers from inputs.nixconf.lib.secrets
    example = nixconf.lib.secrets.mkConfig;
  };
}
```

## Exported Symbols

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'secrets' contract.



#### Inputs

- `cfg`: Configuration binding parameter for the 'secrets' contract.
- `config`: Configuration binding parameter for the 'secrets' contract.
- `secrets`: Configuration binding parameter for the 'secrets' contract.


#### Type

```
secrets.mkConfig :: AttrSet -> AttrSet
```


#### Examples

```nix
secrets.mkConfig { inherit config cfg; }
```



<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'secrets' contract.



#### Inputs

- `secrets`: Submodule option parameter for the 'secrets' contract.


#### Type

```
secrets.mkOption :: AttrSet -> AttrSet
```


#### Examples

```nix
secrets.mkOption { ... }
```


