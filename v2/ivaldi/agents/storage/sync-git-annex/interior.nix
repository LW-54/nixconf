{...}: {
  nixos = {
    environment.etc."aky/git-annex.json".text = builtins.toJSON {
      idleRamMib = 0;
      calmMonotonic = true;
    };
  };
}
