{...}: {
  nixos = {
    environment.etc."aky/harmonia-dev.json".text = builtins.toJSON {
      trustTier = "workstation-only";
      prodTrusted = false;
    };
  };
}
