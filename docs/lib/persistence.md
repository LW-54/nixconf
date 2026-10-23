# Library Namespace: `flake.lib.persistence`

Library helpers and constructors for the 'persistence' capability contract.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.persistence`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.persistence
  example = self.lib.persistence.entries;
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
    # Access exported helpers from inputs.nixconf.lib.persistence
    example = nixconf.lib.persistence.entries;
  };
}
```

## Exported Symbols

<a id="entries"></a>
### `entries`

List of directory or file paths to persist, either strings or custom bind-mount attribute sets.





#### Type

```
entries :: Type
```





<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'persistence' capability contract.



#### Inputs

- `cfg`: Configuration binding parameter for the 'persistence' contract.
- `config`: Configuration binding parameter for the 'persistence' contract.


#### Type

```
persistence.mkConfig :: AttrSet -> AttrSet
```


#### Examples

```nix
persistence.mkConfig { inherit config cfg; }
```



<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'persistence' capability contract.



#### Inputs

- `args`: Service-specific options to include.


#### Type

```
persistence.mkOption :: AttrSet -> AttrSet
```


#### Examples

```nix
persistence.mkOption { ... }
```


