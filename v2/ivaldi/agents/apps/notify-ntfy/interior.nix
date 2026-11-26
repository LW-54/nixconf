{...}: {
  nixos = {
    environment.etc."aky/notify-ntfy.json".text = builtins.toJSON {
      listen = "127.0.0.1:2586";
    };
  };
}
