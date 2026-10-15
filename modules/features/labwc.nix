{self, ...}: {
  flake.nixosModules.labwc = {
    config,
    lib,
    ...
  }: {
    programs.labwc.enable = true;

    persistence.users = self.lib.mkUserPersistence {
      inherit lib config;
      data.directories = [".config/labwc"];
    };
  };
}