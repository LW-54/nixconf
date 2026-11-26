{...}: {
  nixos = {
    environment.etc."aky/obs-victoriametrics.json".text = builtins.toJSON {
      listen = "127.0.0.1:8428";
      retentionMonths = 36;
      maxDiskUsagePct = 80;
    };
  };
}
