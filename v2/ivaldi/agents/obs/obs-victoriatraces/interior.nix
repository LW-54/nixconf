{...}: {
  nixos = {
    environment.etc."aky/obs-victoriatraces.json".text = builtins.toJSON {
      listen = "127.0.0.1:10428";
      retentionDays = 90;
    };
  };
}
