{
  bound,
  lib,
  ...
}: {
  nixos = {
    environment.etc."aky/obs-parquet-archiver.json".text = builtins.toJSON {
      metricsApi = bound."obs:metrics-api".url;
      logsApi = bound."obs:logs-api".url;
      destinations = lib.attrNames bound."archive:parquet";
      memoryMaxMib = 512;
      zstdLevel = 9;
      preRedactionEnabled = true;
    };
  };
}
