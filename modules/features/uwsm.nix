{...}: {
  flake.nixosModules.uwsm = {...}: {
    config.programs.uwsm.enable = true;
  };
}
