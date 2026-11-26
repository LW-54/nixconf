{...}: {
  nixos = {
    environment.etc."aky/niks3.json".text = builtins.toJSON {
      listen = "127.0.0.1:5751";
      oidcIssuer = "https://token.actions.githubusercontent.com";
      readPath = "direct-r2-cdn";
    };
  };
}
