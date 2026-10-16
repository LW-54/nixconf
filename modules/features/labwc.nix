{self, ...}: {
  flake.nixosModules.labwc = {
    config,
    lib,
    ...
  }: {
    imports = [
      (self.lib.mkHjemUserProjection {
        inherit lib;
        name = "labwc";
        description = "Labwc";
        userOptions = {
          rc = lib.mkOption {
            type = lib.types.nullOr lib.types.lines;
            default = null;
            description = "Labwc rc.xml content for this user.";
          };

          autostart = lib.mkOption {
            type = lib.types.nullOr lib.types.lines;
            default = null;
            description = "Labwc autostart content for this user.";
          };
        };

        userEnabled = _: config.programs.labwc.enable;

        userModule = {user, ...}: let
          rc = user.rc or null;
          autostart = user.autostart or null;
        in {
          files =
            (lib.optionalAttrs (rc != null) {
              ".config/labwc/rc.xml".text = rc;
            })
            // (lib.optionalAttrs (autostart != null) {
              ".config/labwc/autostart".text = autostart;
            });
        };
      })
    ];

    programs.labwc.enable = true;

    persistence.users = self.lib.mkUserPersistence {
      inherit lib config;
      data.directories = [".config/labwc"];
    };
  };
}
