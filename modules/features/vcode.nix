{ self, ... }:
{
  flake.nixosModules.vscode = { lib, ... }:
    let
      settings = self.lib.mkOptionWithUserOverride {
        inherit lib;
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        userDefault = { };
        merge = lib.recursiveUpdate;
        description = "Visual Studio Code settings";
      };
    in
    {
      imports = [ (self.lib.mkUserFeature {
      inherit lib;
      name = "vscode";
      description = "Visual Studio Code";
      package = pkgs: pkgs.vscode;

      featureOptions.settings = settings.global;
      userOptions.settings = settings.user;

      userModule = { cfg, user, lib, ... }:
        {
          xdg.config.files."Code/User/settings.json" = {
            generator = lib.generators.toJSON { };
            value = lib.recursiveUpdate cfg.settings (user.settings or { });
          };
        };
      }) ];
    };
}
