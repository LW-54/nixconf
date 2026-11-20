# Library: `resources`

Library helpers and constructors for the 'resources' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.resources`
- **Definition File**: [`modules/contracts/resources/default.nix`](../../modules/contracts/resources/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__resources_mkConfig["resources.mkConfig"]:::defaultNode
    urn__nixconf__ast__function__resources_mkOption["resources.mkOption"]:::defaultNode
    urn__nixconf__ast__function__resources_sliceName["resources.sliceName"]:::defaultNode
    urn__nixconf__ast__function__resources_toBytes["resources.toBytes"]:::defaultNode
    urn__nixconf__ast__symbol__resources_profiles["resources.profiles"]:::defaultNode
    urn__nixconf__onto__lib__resources["resources"]:::defaultNode

    urn__nixconf__onto__lib__resources -->|outputs| urn__nixconf__ast__function__resources_mkConfig
    urn__nixconf__onto__lib__resources -->|outputs| urn__nixconf__ast__function__resources_mkOption
    urn__nixconf__onto__lib__resources -->|outputs| urn__nixconf__ast__function__resources_sliceName
    urn__nixconf__onto__lib__resources -->|outputs| urn__nixconf__ast__function__resources_toBytes
    urn__nixconf__onto__lib__resources -->|outputs| urn__nixconf__ast__symbol__resources_profiles


    click urn__nixconf__ast__function__resources_mkConfig href "resources.md" "resources.mkConfig"
    click urn__nixconf__ast__function__resources_mkOption href "resources.md" "resources.mkOption"
    click urn__nixconf__ast__function__resources_sliceName href "resources.md" "resources.sliceName"
    click urn__nixconf__ast__function__resources_toBytes href "resources.md" "resources.toBytes"
    click urn__nixconf__ast__symbol__resources_profiles href "resources.md" "resources.profiles"
    click urn__nixconf__onto__lib__resources href "resources.md" "resources"

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
  example = self.lib.resources.mkConfig;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.resources.mkConfig;
  };
}
```

## Exported Symbols

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'resources' contract.

#### Inputs

- `cfg`: Configuration binding parameter for the 'resources' contract.
- `config`: Configuration binding parameter for the 'resources' contract.
- `units`: Configuration binding parameter for the 'resources' contract.

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

Auto-derived option constructor for the 'resources' contract.

#### Inputs

- `cpu`: Submodule option parameter for the 'resources' contract.
- `deferOnBattery`: Submodule option parameter for the 'resources' contract.
- `enable`: Submodule option parameter for the 'resources' contract.
- `io`: Submodule option parameter for the 'resources' contract.
- `memory`: Submodule option parameter for the 'resources' contract.
- `oom`: Submodule option parameter for the 'resources' contract.
- `tasksMax`: Submodule option parameter for the 'resources' contract.
- `tier`: Submodule option parameter for the 'resources' contract.
- `units`: Submodule option parameter for the 'resources' contract.

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

Built-in host workload resource tier profiles (`server` and `workstation`) mapped to systemd slices.

#### Type

```
profiles :: AttrSet
```

<a id="sliceName"></a>
### `sliceName`

Normalize a resource tier name into its canonical systemd `.slice` unit name.

#### Inputs

- `tier`: Workload tier name (with or without `.slice` suffix).

#### Type

```
sliceName :: String -> String
```

#### Examples

```nix
resources.sliceName "critical" # => "critical.slice"
```

<a id="toBytes"></a>
### `toBytes`

Convert an integer or byte-size string (`B`, `K`, `M`, `G`, `T`, `P`) into an exact integer byte count.

#### Inputs

- `x`: Non-negative integer bytes or size string such as `"512M"` or `"1.5G"`.

#### Type

```
toBytes :: (Int | String) -> Int
```

#### Examples

```nix
resources.toBytes "512M" # => 536870912
```

<a id="types"></a>
### `types`

Custom option types declared under this library namespace:

- `byteSize`: Byte size as an integer or systemd size string with `B`, `K`, `M`, `G`, `T`, or `P` suffix (e.g. `512M`, `2G`).
- `cgroupWeight`: Cgroups v2 relative scheduling weight integer strictly between `1` and `10000`.
- `cpuQuota`: Systemd `CPUQuota=` percentage string (e.g. `50%`, `150%`).
- `disk`: System-wide local disk headroom and garbage-collection threshold submodule.
- `onBattery`: Power-policy override submodule defining reduced CPU and I/O limits applied to a tier while on battery.
- `oom`: Host-wide `systemd-oomd` configuration submodule.
- `oomPreference`: Systemd `ManagedOOMPreference` policy (`none`, `avoid`, or `omit`).
- `oomScore`: Linux kernel `OOMScoreAdjust` integer strictly between `-1000` and `1000`.
- `percentage`: Percentage string strictly between `0%` and `100%`.
- `power`: Host power-aware resource throttling policy submodule.
- `profile`: Host workload profile preset (`server` or `workstation`).
- `resourceSize`: Cgroup memory limit as an integer, size string (`B`/`K`/`M`/`G`/`T`/`P`), percentage (`%`), or `infinity`.
- `storageBudget`: Remote storage capacity budget and periodic telemetry submodule keyed by `storage.slices` name.
- `tier`: Workload resource tier submodule mapping directly to a top-level systemd `.slice` unit.
- `unit`: Per-systemd-unit resource policy submodule binding a unit to a tier with optional overrides.
- `volume`: Dedicated local disk quota, preallocated loopback volume, or space reservation submodule.
