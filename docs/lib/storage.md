# Library: `storage`

Library helpers and constructors for the 'storage' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.storage`
- **Definition File**: [`modules/contracts/storage/default.nix`](../../modules/contracts/storage/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__storage_evalDriverSettings["storage.evalDriverSettings"]:::defaultNode
    urn__nixconf__ast__function__storage_mkConfig["storage.mkConfig"]:::defaultNode
    urn__nixconf__ast__function__storage_mkOption["storage.mkOption"]:::defaultNode
    urn__nixconf__ast__function__storage_resolveHostStorage["storage.resolveHostStorage"]:::defaultNode
    urn__nixconf__ast__function__storage_resolveSlice["storage.resolveSlice"]:::defaultNode
    urn__nixconf__onto__lib__storage["storage"]:::defaultNode

    urn__nixconf__onto__lib__storage -->|outputs| urn__nixconf__ast__function__storage_evalDriverSettings
    urn__nixconf__onto__lib__storage -->|outputs| urn__nixconf__ast__function__storage_mkConfig
    urn__nixconf__onto__lib__storage -->|outputs| urn__nixconf__ast__function__storage_mkOption
    urn__nixconf__onto__lib__storage -->|outputs| urn__nixconf__ast__function__storage_resolveHostStorage
    urn__nixconf__onto__lib__storage -->|outputs| urn__nixconf__ast__function__storage_resolveSlice


    click urn__nixconf__ast__function__storage_evalDriverSettings href "storage.md" "storage.evalDriverSettings"
    click urn__nixconf__ast__function__storage_mkConfig href "storage.md" "storage.mkConfig"
    click urn__nixconf__ast__function__storage_mkOption href "storage.md" "storage.mkOption"
    click urn__nixconf__ast__function__storage_resolveHostStorage href "storage.md" "storage.resolveHostStorage"
    click urn__nixconf__ast__function__storage_resolveSlice href "storage.md" "storage.resolveSlice"
    click urn__nixconf__onto__lib__storage href "storage.md" "storage"

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
  example = self.lib.storage.evalDriverSettings;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.storage.evalDriverSettings;
  };
}
```

## Exported Symbols

<a id="evalDriverSettings"></a>
### `evalDriverSettings`

Evaluates a storage provider instance's `settings` attribute set against its driver's `settingsModule`, returning typed settings and defaults.

#### Inputs

- `driver`: Driver definition attribute set from `storage.drivers`.
- `providerName`: Provider instance name used for error attribution.
- `providerCfg`: Provider instance configuration from `storage.providers`.

#### Type

```
evalDriverSettings :: { driver :: Driver, providerName :: String, providerCfg :: Provider } -> AttrSet
```

#### Examples

```nix
self.lib.storage.evalDriverSettings {
  driver = config.storage.drivers.hetzner-box;
  providerName = "hbox";
  providerCfg = config.storage.providers.hbox;
}
```

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'storage' contract.

#### Inputs

- `cfg`: Configuration binding parameter for the 'storage' contract.
- `config`: Configuration binding parameter for the 'storage' contract.
- `name`: Configuration binding parameter for the 'storage' contract.

#### Type

```
storage.mkConfig :: AttrSet -> AttrSet
```

#### Examples

```nix
storage.mkConfig { inherit config cfg; }
```

<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'storage' contract.

#### Inputs

- `automount`: Submodule option parameter for the 'storage' contract.
- `enable`: Submodule option parameter for the 'storage' contract.
- `gid`: Submodule option parameter for the 'storage' contract.
- `mountPoint`: Submodule option parameter for the 'storage' contract.
- `protocol`: Submodule option parameter for the 'storage' contract.
- `readOnly`: Submodule option parameter for the 'storage' contract.
- `slice`: Submodule option parameter for the 'storage' contract.
- `uid`: Submodule option parameter for the 'storage' contract.
- `umask`: Submodule option parameter for the 'storage' contract.
- `vfsCacheMode`: Submodule option parameter for the 'storage' contract.

#### Type

```
storage.mkOption :: AttrSet -> AttrSet
```

#### Examples

```nix
storage.mkOption { ... }
```

<a id="resolveHostStorage"></a>
### `resolveHostStorage`

Resolves all providers, slices, mounts, deduplicated SOPS secrets, and reconciler payloads for a single host configuration.

#### Inputs

- `storageCfg`: Evaluated `config.storage` attribute set for the target host.
- `hostName`: Name of the NixOS host being evaluated.
- `placeholders`: Optional function `(store -> key -> string)` emitting runtime SOPS placeholders.

#### Type

```
resolveHostStorage :: { storageCfg :: AttrSet, hostName :: String, placeholders? :: (String -> String -> String) } -> AttrSet
```

#### Examples

```nix
self.lib.storage.resolveHostStorage {
  storageCfg = config.storage;
  hostName = "astrolabe";
}
```

<a id="resolveSlice"></a>
### `resolveSlice`

Recursively resolves a logical slice (`direct`, `crypt`, or `union` across `shared` or `per-host` scope) for a given host into SOPS secret requirements, rclone remote definitions, protocol endpoints, and provider reconciliation items.

#### Inputs

- `storageCfg`: Evaluated `config.storage` attribute set.
- `sliceName`: Name of the slice declared in `storage.slices`.
- `hostName`: Host name used when resolving `per-host` slice paths and secret stores.
- `placeholders`: Optional function `(store -> key -> string)` emitting runtime SOPS placeholders (defaults to `<sops:store:key>`).
- `visited`: Internal accumulator of visited slice names used to detect reference cycles.

#### Type

```
resolveSlice :: { storageCfg :: AttrSet, sliceName :: String, hostName :: String, placeholders? :: (String -> String -> String), visited? :: [String] } -> AttrSet
```

#### Examples

```nix
self.lib.storage.resolveSlice {
  storageCfg = config.storage;
  sliceName = "hbox-backup-host";
  hostName = "astrolabe";
}
```

<a id="types"></a>
### `types`

Custom option types declared under this library namespace:

- `driver`: submodule
- `mount`: submodule
- `provider`: submodule
- `slice`: submodule
