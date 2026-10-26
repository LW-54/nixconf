# Library Namespace: `flake.lib.backup`

Library helpers and constructors for the 'backup' contract.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.backup`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.backup
  example = self.lib.backup.mkConfig;
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
    # Access exported helpers from inputs.nixconf.lib.backup
    example = nixconf.lib.backup.mkConfig;
  };
}
```

## Exported Symbols

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'backup' contract.



#### Inputs

- `cfg`: Configuration binding parameter for the 'backup' contract.
- `config`: Configuration binding parameter for the 'backup' contract.


#### Type

```
backup.mkConfig :: AttrSet -> AttrSet
```


#### Examples

```nix
backup.mkConfig { inherit config cfg; }
```



<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'backup' contract.



#### Inputs

- `args`: Service-specific options to include.


#### Type

```
backup.mkOption :: AttrSet -> AttrSet
```


#### Examples

```nix
backup.mkOption { ... }
```



<a id="defaultPruneOpts"></a>
### `defaultPruneOpts`

Default snapshot retention rules passed to the restic prune command.
Preserves 7 daily, 4 weekly, and 12 monthly snapshots.





#### Type

```
defaultPruneOpts :: [String]
```





<a id="defaultTimerConfig"></a>
### `defaultTimerConfig`

Default systemd timer configuration for automated backup operations.
Executes daily at 04:00 with persistent timer catch-up.





#### Type

```
defaultTimerConfig :: AttrSet
```




