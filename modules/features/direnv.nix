{
  config,
  self,
  ...
}: let
  flakeLib = config.flake.lib;
in {
  flake.nixosModules.direnv = {
    config,
    lib,
    ...
  }: {
    config = {
      programs.direnv = {
        enable = true;
        silent = false;
        loadInNixShell = true;
        direnvrcExtra = "";
        nix-direnv.enable = true;
      };

      persistence.users = flakeLib.users.mkUserPersistence {
        inherit lib config;
        cache.directories = [".cache/direnv"];
      };
    };
  };
}
