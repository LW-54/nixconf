{...}: {
  flake.nixosModules.uwsm = {
    config,
    lib,
    ...
  }: {
    config = lib.mkIf (config.wayland.enable or false) {
      programs.uwsm = {
        enable = true;
        waylandCompositors =
          lib.mapAttrs (_: c: {
            inherit (c) prettyName comment binPath;
          })
          config.wayland.compositors;
      };
    };
  };
}
