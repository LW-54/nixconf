{
  config,
  lib,
  ...
}: {
  options.internal.monitoring.dashboard = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Internal Grafana dashboard helper sub-modules assembled into `contract.monitoring.lib.dashboard`.";
  };

  config.contract.monitoring.lib.dashboard = {
    docstring = ''
      Opinionated Grafana schema v39 dashboard, layout, panel, variable, and threshold builders shared across monitoring consumers.

      # Type
      ```
      dashboard :: AttrSet
      ```

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

      # Examples
      ```nix
      self.lib.monitoring.dashboard.mkDashboard {
        uid = "example-overview";
        title = "Example Overview";
        variables = [(self.lib.monitoring.dashboard.vars.host {})];
        sections = [];
      }
      ```
    '';
    value = config.internal.monitoring.dashboard;
  };
}
