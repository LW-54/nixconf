{
  config,
  lib,
  ...
}: let
  helpers = config.internal.victoria;
in {
  options.internal.victoria = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Internal builder helpers for Grafana Alloy, VictoriaMetrics, VictoriaLogs, vmalert, Alertmanager, and Grafana.";
  };

  config.implementation.victoria = {
    contract = "monitoring";
    description = "Observability stack implementation using Grafana Alloy, VictoriaMetrics, VictoriaLogs, vmalert, Alertmanager, and Grafana.";

    module = {
      config,
      lib,
      pkgs,
      options,
      self,
      ...
    }: let
      alloyCfg = helpers.mkAlloy {
        inherit config lib pkgs options;
      };
      serverCfg = helpers.mkServer {
        inherit config lib pkgs options self;
        inherit (helpers) mkDashboard;
      };
      testingSuite = helpers.mkTesting {
        inherit self config lib pkgs;
      };
    in
      lib.mkMerge [
        alloyCfg
        serverCfg
        {
          testing.victoria = testingSuite;
        }
      ];
  };
}
