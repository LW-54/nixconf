{self, ...}: {
  flake.nixosModules.vscode = {
    config,
    lib,
    ...
  }: let
    cfg = config.vscode;
  in {
    imports = [
      (self.lib.users.mkUserFeature {
        inherit lib;
        name = "vscode";
        description = "Visual Studio Code";
        package = pkgs: pkgs.vscode;
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
      data = {
        directories = [".config/Code" ".vscode"];
      };
    };
  };
}
