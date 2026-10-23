# Library Namespace: `flake.lib.user`

Normal user account helper functions and querying utilities.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.user`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.user
  example = self.lib.user.forNormalUsers;
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
    # Access exported helpers from inputs.nixconf.lib.user
    example = nixconf.lib.user.forNormalUsers;
  };
}
```

## Exported Symbols

<a id="forNormalUsers"></a>
### `forNormalUsers`

Maps an attribute set generation function across all normal users.



#### Inputs

- `config`: Evaluated NixOS system configuration.
- `f`: Function `(userName -> userAttrs -> AttrSet)`.


#### Type

```
forNormalUsers :: Config -> (String -> AttrSet -> AttrSet) -> AttrSet
```


#### Examples

```nix
forNormalUsers config (userName: user: {
  data.directories = [".config/example"];
})
```



<a id="normalUserNames"></a>
### `normalUserNames`

Returns list of usernames for all normal users on the system.



#### Inputs

- `config`: Evaluated NixOS system configuration.


#### Type

```
normalUserNames :: Config -> [String]
```


#### Examples

```nix
normalUserNames config
```



<a id="normalUsers"></a>
### `normalUsers`

Filters `config.users.users` down to normal human user accounts (`isNormalUser = true`).



#### Inputs

- `config`: Evaluated NixOS system configuration.


#### Type

```
normalUsers :: Config -> AttrSet
```


#### Examples

```nix
normalUsers config
```


