{self, ...}: {
  flake.nixosModules.vivaldi = {
    config,
    lib,
    ...
  }: let
    cfg = config.vivaldi;
  in {
    imports = [
      (self.lib.users.mkUserFeature {
        inherit lib;
        name = "vivaldi";
        description = "Vivaldi Browser";
        package = pkgs:
          pkgs.vivaldi.override {
            proprietaryCodecs = true;
            enableWidevine = true;
          };
      })
    ];

    config.persistence.users = self.lib.users.mkUserPersistence {
      inherit lib config;
      userEnabled = userName:
        self.lib.users.resolveUserOption {
          inherit lib;
          global = cfg.enable;
          users = cfg.users;
          inherit userName;
        };
      data.directories = [".config/vivaldi"];
      cache.directories = [".cache/vivaldi"];
    };
  };
}
