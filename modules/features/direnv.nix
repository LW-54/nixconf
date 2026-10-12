{ ... }:
{
  flake.nixosModules.direnv = { config, lib, ... }:
    {
      config = {
        programs.direnv = {
          enable = true;
          silent = false;
          loadInNixShell = true;
          direnvrcExtra = "";
          nix-direnv.enable = true;
        };

        persistence.users = lib.mapAttrs (_: _: {
          cache.directories = [ ".cache/direnv" ];
        }) config.users.users;
      };
    };
}
