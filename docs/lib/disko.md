# Library Namespace: `flake.lib.disko`

Declarative disk partitioning and filesystem layouts via Disko.

[← Back to Library Documentation](../LIB.md) | [← Back to Main README](../../README.md)

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

Within repository modules, NixOS configurations, or packages, access functions directly through `self.lib.disko`:

```nix
{ self, lib, pkgs, ... }: {
  # Access helpers directly from self.lib.disko
  example = self.lib.disko.mkLayout;
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
    # Access exported helpers from inputs.nixconf.lib.disko
    example = nixconf.lib.disko.mkLayout;
  };
}
```

## Exported Symbols

<a id="mkLayout"></a>
### `mkLayout`

Constructs a standard Disko disk configuration with EFI system partition, BIOS boot partition, and Btrfs subvolumes (@, @nix, @persist, @swap).



#### Inputs

- `device`: Primary disk block device path (e.g., "/dev/nvme0n1", "/dev/sda").
- `espSize`: Size of EFI system partition (default: "1G").
- `biosBootSize`: Size of BIOS boot partition for MBR compatibility (default: "1M").
- `swapSize`: Size of swap partition or subvolume, or null if swap is disabled (default: null).
- `swapResume`: Whether to enable resume offset configuration for swap hibernation (default: false).
- `persistSize`: Size allocated to persistent data subvolume (default: "100%").
- `filesystem`: Root filesystem type (currently must be "btrfs").


#### Type

```
mkLayout :: AttrSet -> AttrSet
```


#### Examples

```nix
disko.mkLayout {
  device = "/dev/nvme0n1";
  swapSize = "8G";
}
```


