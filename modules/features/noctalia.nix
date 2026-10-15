{self, inputs, ...}: {
  flake.nixosModules.noctalia = {
    config,
    lib,
    ...
  }: {
    config = {
      hjem.extraModules = [
        inputs.noctalia.hjemModules.default
        ({...}: {
          programs.noctalia = {
            enable = true;
            systemd.enable = true;
          };
        })
      ];

      persistence.users = self.lib.mkUserPersistence {
        inherit lib config;
        data.directories = [".config/noctalia"];
      };
    };
  };
}