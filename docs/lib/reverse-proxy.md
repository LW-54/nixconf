# Library Namespace: `flake.lib.reverse-proxy`

Library helpers and constructors for the 'reverse-proxy' contract.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.reverse-proxy`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.reverse-proxy
  example = self.lib.reverse-proxy.mkConfig;
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
    # Access exported helpers from inputs.nixconf.lib.reverse-proxy
    example = nixconf.lib.reverse-proxy.mkConfig;
  };
}
```

## Exported Symbols

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'reverse-proxy' contract.



#### Inputs

- `cfg`: Configuration binding parameter for the 'reverse-proxy' contract.
- `config`: Configuration binding parameter for the 'reverse-proxy' contract.


#### Type

```
reverse-proxy.mkConfig :: AttrSet -> AttrSet
```


#### Examples

```nix
reverse-proxy.mkConfig { inherit config cfg; }
```



<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'reverse-proxy' contract.



#### Inputs

- `address`: Submodule option parameter for the 'reverse-proxy' contract.
- `basicAuth`: Submodule option parameter for the 'reverse-proxy' contract.
- `port`: Submodule option parameter for the 'reverse-proxy' contract.
- `subdomain`: Submodule option parameter for the 'reverse-proxy' contract.


#### Type

```
reverse-proxy.mkOption :: AttrSet -> AttrSet
```


#### Examples

```nix
reverse-proxy.mkOption { ... }
```


