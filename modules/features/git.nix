{ self, ... }:
{
  flake.nixosModules.git = { lib, ... }:
    let
      settings = self.lib.mkOptionWithUserOverride {
        inherit lib;
        type = lib.types.attrsOf lib.types.anything;
        default = {
          user.name = "LW-54";
          user.email = "leonardwilsonb@gmail.com";
          pull.rebase = true;
          fetch.prune = true;
          push.autoSetupRemote = true;
          rerere.enabled = true;
        };
        userDefault = { };
        merge = lib.recursiveUpdate;
        description = "Git settings";
      };
    in
    {
      imports = [ (self.lib.mkUserFeature {
      inherit lib;
      name = "git";
      description = "Git";
      package = pkgs: pkgs.git;

      featureOptions.settings = settings.global;
      userOptions.settings = settings.user;

      userModule = { cfg, user, lib, ... }:
        {
          xdg.config.files."git/config" = {
            generator = lib.generators.toINI { };
            value = lib.recursiveUpdate cfg.settings (user.settings or { });
          };
        };
      }) ];
    };
}
