# Module: `monitoring`

Declarative metrics, logs, blackbox probing, alerting rules, and dashboard provisioning contract.

[← Back to Modules Documentation](README.md) | [← Back to Main README](../../README.md)

- **Attribute**: `flake.nixosModules.monitoring`
- **Provided by**: contract [`monitoring`](../contracts/monitoring.md)

## Declared Options

| Option Path | Type | Default | Example | Description |
| :--- | :--- | :--- | :--- | :--- |
| `monitoring.agent` | `submodule` | `{ }` | `{ ... }` | Local telemetry collector agent configuration for metrics scraping, log shipping, and remote-write buffering. |
| `monitoring.dashboards` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Attribute set of declarative Grafana dashboards provisioned automatically as code. |
| `monitoring.enable` | `boolean` | `false` | `true` | Whether to enable declarative system and service monitoring contract. |
| `monitoring.exporters` | `submodule` | `{ }` | `{ ... }` | Built-in telemetry exporter configurations (host OS, containers, blackbox probing, and custom blocks). |
| `monitoring.extraAlloyConfig` | `strings concatenated with "\n"` | `""` | `"logging { level = "info" }"` | Raw Grafana Alloy River configuration blocks appended directly to `/etc/alloy/config.alloy`. |
| `monitoring.extraGrafanaSettings` | `attribute set of anything` | `{ }` | `{ ... }` | Additional backend-specific attributes merged into `services.grafana.settings`. |
| `monitoring.extraLokiConfig` | `attribute set of anything` | `{ }` | `{ ... }` | Additional backend-specific attributes merged into `services.loki.configuration`. |
| `monitoring.extraPrometheusConfig` | `attribute set of anything` | `{ }` | `{ ... }` | Additional backend-specific attributes merged into the Prometheus server configuration. |
| `monitoring.logs` | `submodule` | `{ }` | `{ ... }` | Declarative systemd journal and file-based log ingestion sources. |
| `monitoring.probes` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Attribute set of blackbox health probes checking HTTP, TCP, or ICMP endpoint reachability. |
| `monitoring.rules` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Attribute set of alerting and recording rule groups evaluated by Prometheus or Loki. |
| `monitoring.scrapes` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Attribute set of Prometheus scrape targets collected by the local telemetry agent. |
| `monitoring.server` | `submodule` | `{ }` | `{ ... }` | Central telemetry ingestion, time-series storage, and visualization server configuration. |
| `monitoring.services` | `attribute set of (submodule)` | `{ }` | `{ ... }` | Declarative service catalog mapping logical application names to systemd units, virtual hosts, backup jobs, and storage mounts. |
| `monitoring.watchedUnits` | `list of string` | `[ ]` | `[ ... ]` | Critical systemd units (services, timers, or mounts) registered for health monitoring and journal tracking. |
