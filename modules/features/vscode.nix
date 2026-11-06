{self, ...}: {
  feature.vscode = {
    description = "Visual Studio Code editor environment and persistence.";
    modules = {
      vscode = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.vscode;
      in {
        options.vscode.enable = lib.mkEnableOption "Visual Studio Code" // {default = true;};

        config = lib.mkIf cfg.enable {
          environment.systemPackages = [pkgs.vscode];

          persistence.users = self.lib.user.forNormalUsers config (_: _: {
            data.directories = [".config/Code" ".vscode"];
          });
        };
      };
    };
  };
}
