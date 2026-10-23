{...}: {
  /**
  Systemd-integrated Wayland graphical session management and compositor launching via UWSM.
  */
  implementation.uwsm = {
    contract = "wayland";
    description = "Universal Wayland Session Manager integration for desktop environments.";
    module = {
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
  };
}
