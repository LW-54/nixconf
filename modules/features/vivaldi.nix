{self, ...}: {
  flake.nixosModules.vivaldi = {
    config,
    lib,
    ...
  }: let
    cfg = config.vivaldi;
  in {
    imports = [
      (self.lib.users.mkFeature {
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

    config.persistence.users = self.lib.users.mkPersistence {
      inherit lib config;
      global = cfg.enable;
      userOverrides = cfg.users;
      data.directories = [".config/vivaldi"];
      cache.directories = [".cache/vivaldi"];
    };
  };
}
