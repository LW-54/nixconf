{
  config,
  self,
  ...
}: let
  flakeLib = config.flake.lib;
in {
  flake.nixosModules.vscode = {
    config,
    lib,
    ...
  }: let
    cfg = config.vscode;
  in {
    imports = [
      (flakeLib.users.mkUserFeature {
        inherit lib;
        name = "vscode";
        description = "Visual Studio Code";
        package = pkgs: pkgs.vscode;
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
      data = {
        directories = [".config/Code" ".vscode"];
      };
    };
  };
}
