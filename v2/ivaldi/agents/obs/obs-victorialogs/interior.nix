{...}: {
  nixos = {
    environment.etc."aky/obs-victorialogs.json".text = builtins.toJSON {
      listen = "127.0.0.1:9428";
      retentionDays = 365;
      builtInWebUi = true;
    };
  };
}
