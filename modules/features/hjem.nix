{inputs, ...}: {
  flake.nixosModules.hjem = {
    config,
    lib,
    ...
  }: let
    mapFiles = files:
      lib.mapAttrs (_: file:
        lib.filterAttrs (_: value: value != null) (
          builtins.removeAttrs file ["assertions" "force"]
          // lib.optionalAttrs file.force {clobber = true;}
        ))
      files;
    mapHome = _: home: {
      enable = home.enable;
      packages = home.packages;
      files = mapFiles home.files;
      xdg = {
        cache.files = mapFiles home.xdg.cache;
        config.files = mapFiles home.xdg.config;
        data.files = mapFiles home.xdg.data;
        state.files = mapFiles home.xdg.state;
      };
      environment.sessionVariables = home.environment.sessionVariables;
      systemd.services = home.systemd.services;
    };
  in {
    imports = [inputs.hjem.nixosModules.default];
    config = {
      hjem.clobberByDefault = true;
      hjem.users = lib.mapAttrs mapHome config.users.home;
    };
  };
}
