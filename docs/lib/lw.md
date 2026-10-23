# Library Namespace: `flake.lib.lw`

Primary human user account orchestration and identity provisioning.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.lw`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.lw
  example = self.lib.lw.email;
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
    # Access exported helpers from inputs.nixconf.lib.lw
    example = nixconf.lib.lw.email;
  };
}
```

## Exported Symbols

<a id="email"></a>
### `email`

Primary email address for user account lw.





#### Type

```
email :: String
```





<a id="githubUsername"></a>
### `githubUsername`

Primary GitHub account username for user account lw.





#### Type

```
githubUsername :: String
```





<a id="username"></a>
### `username`

Primary login username for user account lw.





#### Type

```
username :: String
```




