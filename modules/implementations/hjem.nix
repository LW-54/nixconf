{inputs, ...}: {
  /**
  Declarative per-user dotfile, XDG environment, and user systemd service management via Hjem.
  */
  implementation.hjem = {
    contract = "home";
    description = "Lightweight declarative home directory files and XDG environment manager.";
    module = {
      config,
      lib,
      ...
    }: let
      homeCfg = config.home;

      mapFiles = files:
        lib.mapAttrs (_: file:
          lib.filterAttrs (_: value: value != null) (
            builtins.removeAttrs file ["assertions" "force"]
            // lib.optionalAttrs file.force {clobber = true;}
          ))
        files;

      mapHome = _: home: {
        enable = home.enable;
        packages = homeCfg.shared.packages ++ home.packages;
        files = mapFiles (homeCfg.shared.files // home.files);
        xdg = {
          cache.files = mapFiles (homeCfg.shared.xdg.cache // home.xdg.cache);
          config.files = mapFiles (homeCfg.shared.xdg.config // home.xdg.config);
          data.files = mapFiles (homeCfg.shared.xdg.data // home.xdg.data);
          state.files = mapFiles (homeCfg.shared.xdg.state // home.xdg.state);
        };
        environment.sessionVariables = homeCfg.shared.sessionVariables // home.sessionVariables;
        systemd.services = homeCfg.shared.systemd.services // home.systemd.services;
      };
    in {
      imports = [
        inputs.hjem.nixosModules.default
      ];

      hjem.clobberByDefault = true;
      hjem.users = lib.mapAttrs mapHome homeCfg.users;
    };
  };
}
