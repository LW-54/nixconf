# Library: `disko`

Declarative disk partitioning and filesystem layouts via Disko.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.disko`
- **Definition File**: [`modules/features/disko.nix`](../../modules/features/disko.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__disko_mkLayout["disko.mkLayout"]:::defaultNode
    urn__nixconf__onto__lib__disko["disko"]:::defaultNode

    urn__nixconf__onto__lib__disko -->|outputs| urn__nixconf__ast__function__disko_mkLayout


    click urn__nixconf__ast__function__disko_mkLayout href "disko.md" "disko.mkLayout"
    click urn__nixconf__onto__lib__disko href "disko.md" "disko"

  %% Semantic Visual Classes
  classDef hostNode fill:#1e293b,stroke:#38bdf8,stroke-width:2px,color:#f8fafc;
  classDef contractNode fill:#1e1b4b,stroke:#818cf8,stroke-width:2px,color:#f8fafc;
  classDef implNode fill:#0f172a,stroke:#34d399,stroke-width:2px,color:#f8fafc;
  classDef featureNode fill:#134e4a,stroke:#2dd4bf,stroke-width:2px,color:#f8fafc;
  classDef optNode fill:#422006,stroke:#facc15,stroke-width:1px,color:#fefce8;
  classDef typeNode fill:#3b0764,stroke:#c084fc,stroke-width:1px,color:#faf5ff;
  classDef pkgNode fill:#4c0519,stroke:#fb7185,stroke-width:1px,color:#fff1f2;
  classDef devShellNode fill:#451a03,stroke:#fb923c,stroke-width:1px,color:#fff7ed;
  classDef drvNode fill:#18181b,stroke:#a1a1aa,stroke-width:1px,color:#f4f4f5;
  classDef defaultNode fill:#1e293b,stroke:#64748b,stroke-width:1px,color:#f8fafc;
```

</details>

## Usage

This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

### Internal Usage

```nix
{ self, lib, pkgs, ... }: {
  example = self.lib.disko.mkLayout;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.disko.mkLayout;
  };
}
```

## Exported Symbols

<a id="mkLayout"></a>
### `mkLayout`

Constructs a standard Disko disk configuration with EFI system partition, BIOS boot partition, LVM volume group, Btrfs subvolumes, and ephemeral tmpfs root.

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
