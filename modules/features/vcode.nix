{self, ...}: {
  flake.nixosModules.vscode = {
    config,
    lib,
    ...
  }: let
    cfg = config.vscode;
  in {
    imports = [
      (self.lib.users.mkFeature {
        inherit lib;
        name = "vscode";
        description = "Visual Studio Code";
        package = pkgs: pkgs.vscode;
      })
    ];

    config.persistence.users = self.lib.users.mkPersistence {
      inherit lib config;
      global = cfg.enable;
      userOverrides = cfg.users;
      data = {
        directories = [".config/Code" ".vscode"];
      };
    };
  };
}
