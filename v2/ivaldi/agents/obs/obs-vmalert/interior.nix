{
  bound,
  lib,
  ...
}: {
  nixos = {
    environment.etc."aky/obs-vmalert.json".text = builtins.toJSON {
      metricsApi = bound."obs:metrics-api".url;
      logsApi = bound."obs:logs-api".url;
      notifySink = bound."notify:sink".url;
      sloProbes = lib.sort builtins.lessThan (lib.attrNames bound."slo-probes");
    };
  };
}
