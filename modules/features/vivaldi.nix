{
  config,
  self,
  ...
}: let
  flakeLib = config.flake.lib;
in {
  flake.nixosModules.vivaldi = {
    config,
    lib,
    ...
  }: let
    cfg = config.vivaldi;
  in {
    imports = [
      (flakeLib.users.mkUserFeature {
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

    config.persistence.users = flakeLib.users.mkUserPersistence {
      inherit lib config;
      userEnabled = userName:
        flakeLib.users.resolveUserOption {
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
