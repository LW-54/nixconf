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
      Opinionated Grafana schema v39 dashboard, layout, panel, variable, annotation, and threshold builders shared across monitoring consumers.

      # Type
      ```
      dashboard :: AttrSet
      ```

      # Values
      - `ds`: Provisioned metrics and logs datasource descriptor references (`metrics`, `prometheus`, `logs`).
      - `promTarget`, `logsTarget`: Construct metrics (`PromQL`/`MetricsQL`) or logs (`LogsQL`) target objects (`expr`, `legend`, `queryType`).
      - `thresholds`, `mappings`: Standard threshold presets and Grafana value mappings.
      - `links`: Click-to-drilldown Grafana data links (`toTaskManager`, `toTimeMachine`, `toHostHardware`, `toService`, `toUnitLogs`, `toCapacityAnalytics`, `toTrendsExplorer`, `toMetricWorkbench`, `toStorageAtlas`).
      - `vars`: Template variable constructors (`host`, `promQuery`, `logsField`, `custom`, `textbox`).
      - `statToggleExpr`, `statBandOverrides`, `systemdOpsParsePipe`: Statistical envelope toggles, overlay styling, and systemd accounting LogsQL parser.
      - `mkStat`, `mkRatioStat`, `mkBarGauge`, `mkTimeseries`, `mkTable`, `mkStorageTable`, `mkSystemdUnitsTable`, `mkLogs`, `mkText`, `mkEcharts`, `mkStorageTreemap`, `mkMemoryHeatmapTreemap`: Pre-styled Grafana v39 panel and interactive ECharts treemap builders.
      - `mkRow`, `mkSection`, `mkDashboard`: Responsive 24-column grid layout engine with automatic host event annotations (`Reboots`, `NixOS Deployments`, `OOM Kills`, `Unit Failures`) and top navigation bar.
      - `mkFleetOverviewDashboard`, `mkTaskManagerDashboard`, `mkTimeMachineDashboard`, `mkTrendsExplorerDashboard`, `mkMetricWorkbenchDashboard`, `mkStorageAtlasDashboard`, `mkLogsExplorerDashboard`, `mkHostHardwareDashboard`, `mkCapacityAnalyticsDashboard`, `mkServicesCatalogDashboard`, `mkServiceInspectorDashboard`, `mkContainersDashboard`: Core infrastructure, statistical capacity, trend exploration, custom metric workbench, storage treemap atlas, and investigation dashboards.

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
