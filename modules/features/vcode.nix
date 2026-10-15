{self, ...}: {
  flake.nixosModules.vscode = {
    config,
    lib,
    ...
  }: let
    cfg = config.vscode;
  in {
    imports = [
      (self.lib.mkUserFeature {
        inherit lib;
        name = "vscode";
        description = "Visual Studio Code";
        package = pkgs: pkgs.vscode;
      })
    ];

    config.persistence.users = self.lib.mkUserPersistence {
      inherit lib config;
      userEnabled = userName:
        self.lib.resolveUserOption {
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
