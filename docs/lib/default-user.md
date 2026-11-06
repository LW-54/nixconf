# Library: `default-user`

Library helpers and constructors for the 'default-user' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.default-user`
- **Definition File**: [`modules/contracts/default-user.nix`](../../modules/contracts/default-user.nix)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

```nix
{ self, lib, pkgs, ... }: {
  example = self.lib.default-user.exampleHelper;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.default-user.exampleHelper;
  };
}
```
