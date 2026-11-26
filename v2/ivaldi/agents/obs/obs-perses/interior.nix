{
  bound,
  lib,
  ...
}: {
  nixos = {
    environment.etc."aky/obs-perses.json".text = builtins.toJSON {
      ui = "perses-0.54";
      metricsApi = bound."obs:metrics-api".url;
      tracesApi = bound."obs:traces-api".url;
      probes = lib.sort builtins.lessThan (lib.attrNames bound."panel-probes");
      stateVolumes = lib.sort builtins.lessThan (lib.attrNames bound."panel-state");
    };
  };
}
