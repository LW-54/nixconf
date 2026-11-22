{
  config,
  lib,
  ...
}: let
  helpers = config.internal.grafana;
in {
  options.internal.grafana = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Internal builder helpers for Grafana Alloy, VictoriaMetrics, VictoriaLogs, vmalert, Alertmanager, and Grafana.";
  };

  config.implementation = {
    alloy = {
      contract = "monitoring";
      description = "Telemetry collection agent implementation using Grafana Alloy for metrics scraping, log shipping, and blackbox probing.";

      module = {
        config,
        lib,
        pkgs,
        options,
        self,
        ...
      }:
        lib.mkMerge [
          (helpers.mkAlloy {inherit config lib pkgs options;})
          {
            testing.alloy = helpers.mkTesting {inherit self config lib pkgs;};
          }
        ];
    };

    grafana = {
      contract = "monitoring";
      description = "Full observability stack implementation using Grafana, VictoriaMetrics, VictoriaLogs, vmalert, Alertmanager, and Grafana Alloy.";

      module = {
        config,
        lib,
        pkgs,
        options,
        self,
        ...
      }:
        lib.mkMerge [
          {
            monitoring.server.enable = lib.mkDefault true;
          }
          (helpers.mkAlloy {inherit config lib pkgs options;})
          (helpers.mkServer {
            inherit config lib pkgs options self;
            inherit (helpers) mkDashboard;
          })
          {
            testing.grafana = helpers.mkTesting {inherit self config lib pkgs;};
          }
        ];
    };
  };
}
