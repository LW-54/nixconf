# Library: `monitoring`

Library helpers and constructors for the 'monitoring' contract.

[← Back to Library Documentation](README.md) | [← Back to Main README](../../README.md)

- **Library**: `flake.lib.monitoring`
- **Definition File**: [`modules/contracts/monitoring/default.nix`](../../modules/contracts/monitoring/default.nix)

<details>
<summary>Architecture Diagram (click to expand)</summary>

```mermaid
flowchart LR
  urn__nixconf__ast__function__monitoring_mkConfig["monitoring.mkConfig"]:::defaultNode
    urn__nixconf__ast__function__monitoring_mkOption["monitoring.mkOption"]:::defaultNode
    urn__nixconf__ast__symbol__monitoring_dashboard["monitoring.dashboard"]:::defaultNode
    urn__nixconf__onto__lib__monitoring["monitoring"]:::defaultNode

    urn__nixconf__onto__lib__monitoring -->|outputs| urn__nixconf__ast__function__monitoring_mkConfig
    urn__nixconf__onto__lib__monitoring -->|outputs| urn__nixconf__ast__function__monitoring_mkOption
    urn__nixconf__onto__lib__monitoring -->|outputs| urn__nixconf__ast__symbol__monitoring_dashboard


    click urn__nixconf__ast__function__monitoring_mkConfig href "monitoring.md" "monitoring.mkConfig"
    click urn__nixconf__ast__function__monitoring_mkOption href "monitoring.md" "monitoring.mkOption"
    click urn__nixconf__ast__symbol__monitoring_dashboard href "monitoring.md" "monitoring.dashboard"
    click urn__nixconf__onto__lib__monitoring href "monitoring.md" "monitoring"

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
  example = self.lib.monitoring.dashboard;
}
```

### External Usage

```nix
{
  inputs.nixconf.url = "github:LW-54/nixconf";

  outputs = { self, nixconf, ... }: {
    example = nixconf.lib.monitoring.dashboard;
  };
}
```

## Exported Symbols

<a id="dashboard"></a>
### `dashboard`

Opinionated Grafana schema v39 dashboard, layout, panel, variable, and threshold builders shared across monitoring consumers.

#### Type

```
dashboard :: AttrSet

# Values
- `ds`: Provisioned Prometheus and Loki datasource descriptor references (`prometheus`, `loki`).
- `promTarget`, `lokiTarget`: Construct Prometheus or Loki target objects (`expr`, `legend`, `instant`, `format`).
- `thresholds`: Standard threshold presets (`percent`, `percentHigh`, `percent100Ok`, `upDown`, `zeroOk`, `zeroWarn`, `latencySec`, `neutral`).
- `mappings`: Standard Grafana value mapping lists (`upDown`, `okFail`, `systemdState`, `alertState`).
- `vars`: Template variable constructors (`host`, `promQuery`, `lokiLabel`, `custom`, `textbox`).
- `mkStat`, `mkBarGauge`, `mkTimeseries`, `mkTable`, `mkSystemdUnitsTable`, `mkLogs`: Pre-styled Grafana v39 panel builders supporting multi-target lists or single-query shorthand (`expr`, `legend`, `loki`).
- `mkRow`, `mkSection`, `mkDashboard`: Responsive 24-column grid layout engine and dashboard constructor with shared crosshair tooltips and navigation links.
- `mkContainersDashboard`: Shared OCI container and systemd service cgroup overview dashboard generator.
- `mkStackHealthDashboard`: Central LGTM stack health, ingestion, alert, and scrape target dashboard generator.
- `mkServiceInspectorDashboard`: Unified per-service vertical drilldown dashboard correlating HTTP, probes, units, compute, storage, and logs.
```

#### Examples

```nix
self.lib.monitoring.dashboard.mkDashboard {
  uid = "example-overview";
  title = "Example Overview";
  variables = [(self.lib.monitoring.dashboard.vars.host {})];
  sections = [];
}
```

<a id="mkConfig"></a>
### `mkConfig`

Auto-derived configuration binding helper for the 'monitoring' contract.

#### Inputs

- `cfg`: Configuration binding parameter for the 'monitoring' contract.
- `config`: Configuration binding parameter for the 'monitoring' contract.
- `name`: Configuration binding parameter for the 'monitoring' contract.

#### Type

```
monitoring.mkConfig :: AttrSet -> AttrSet
```

#### Examples

```nix
monitoring.mkConfig { inherit config cfg; }
```

<a id="mkOption"></a>
### `mkOption`

Auto-derived option constructor for the 'monitoring' contract.

#### Inputs

- `dashboards`: Submodule option parameter for the 'monitoring' contract.
- `enable`: Submodule option parameter for the 'monitoring' contract.
- `logFiles`: Submodule option parameter for the 'monitoring' contract.
- `metrics`: Submodule option parameter for the 'monitoring' contract.
- `probe`: Submodule option parameter for the 'monitoring' contract.
- `rules`: Submodule option parameter for the 'monitoring' contract.
- `units`: Submodule option parameter for the 'monitoring' contract.

#### Type

```
monitoring.mkOption :: AttrSet -> AttrSet
```

#### Examples

```nix
monitoring.mkOption { ... }
```

<a id="types"></a>
### `types`

Custom option types declared under this library namespace:

- `agent`: submodule
- `dashboard`: submodule
- `exporters`: submodule
- `fileLog`: submodule
- `journalLogs`: submodule
- `logs`: submodule
- `probe`: submodule
- `ruleGroup`: submodule
- `ruleItem`: submodule
- `scrape`: submodule
- `server`: submodule
- `service`: submodule
