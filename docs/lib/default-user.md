# Library Namespace: `flake.lib.default-user`

Library helpers and constructors for the 'default-user' contract.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.default-user`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.default-user
  example = self.lib.default-user.forDefaultUser;
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
    # Access exported helpers from inputs.nixconf.lib.default-user
    example = nixconf.lib.default-user.forDefaultUser;
  };
}
```

## Exported Symbols

<a id="forDefaultUser"></a>
### `forDefaultUser`

Conditionally evaluates a user configuration function with the configured default username if default-user is enabled.



#### Inputs

- `config`: The evaluated NixOS system configuration.
- `f`: Function receiving the default username string and returning an attribute set.


#### Type

```
forDefaultUser :: Config -> (String -> AttrSet) -> AttrSet
```


#### Examples

```nix
forDefaultUser config (user: {
  users.users.${user}.extraGroups = [ "wheel" ];
})
```



<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'default-user' contract.



#### Inputs

- `cfg`: Configuration binding parameter for the 'default-user' contract.
- `config`: Configuration binding parameter for the 'default-user' contract.


#### Type

```
default-user.mkConfig :: AttrSet -> AttrSet
```


#### Examples

```nix
default-user.mkConfig { inherit config cfg; }
```



<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'default-user' contract.



#### Inputs

- `args`: Service-specific options to include.


#### Type

```
default-user.mkOption :: AttrSet -> AttrSet
```


#### Examples

```nix
default-user.mkOption { ... }
```


