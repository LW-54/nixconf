# Library Namespace: `flake.lib.resources`

Library helpers and constructors for the 'resources' capability contract.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.resources`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.resources
  example = self.lib.resources.defaultSlices;
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
    # Access exported helpers from inputs.nixconf.lib.resources
    example = nixconf.lib.resources.defaultSlices;
  };
}
```

## Exported Symbols

<a id="defaultSlices"></a>
### `defaultSlices`

Default systemd slice hierarchy configurations and resource budget definitions.





#### Type

```
defaultSlices :: AttrSet
```





<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'resources' capability contract.



#### Inputs

- `cfg`: Configuration binding parameter for the 'resources' contract.
- `config`: Configuration binding parameter for the 'resources' contract.
- `serviceName`: Configuration binding parameter for the 'resources' contract.


#### Type

```
resources.mkConfig :: AttrSet -> AttrSet
```


#### Examples

```nix
resources.mkConfig { inherit config cfg; }
```



<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'resources' capability contract.



#### Inputs

- `battery`: Submodule option parameter for the 'resources' contract.
- `cpu`: Submodule option parameter for the 'resources' contract.
- `io`: Submodule option parameter for the 'resources' contract.
- `memory`: Submodule option parameter for the 'resources' contract.
- `profile`: Submodule option parameter for the 'resources' contract.
- `slice`: Submodule option parameter for the 'resources' contract.
- `tasksMax`: Submodule option parameter for the 'resources' contract.


#### Type

```
resources.mkOption :: AttrSet -> AttrSet
```


#### Examples

```nix
resources.mkOption { ... }
```



<a id="profiles"></a>
### `profiles`

Predefined systemd cgroup resource allocation profile archetypes (critical, standard, background, batch).





#### Type

```
profiles :: AttrSet
```




