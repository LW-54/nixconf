{
  config,
  lib,
  ...
}: let
  helpers = config.internal.lgtm;
in {
  options.internal.lgtm = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Internal builder helpers for Grafana Alloy, Prometheus, Loki, and Grafana.";
  };

  config.implementation.lgtm = {
    contract = "monitoring";
    description = "Observability stack implementation using Grafana Alloy, Prometheus, Loki, and Grafana.";

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
      };
      testingSuite = helpers.mkTesting {
        inherit self config lib pkgs;
      };
    in
      lib.mkMerge [
        alloyCfg
        serverCfg
        {
          testing.lgtm = testingSuite;
        }
      ];
  };
}
