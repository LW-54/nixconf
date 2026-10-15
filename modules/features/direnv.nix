{self, ...}: {
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

      persistence.users = self.lib.mkUserPersistence {
        inherit lib config;
        cache.directories = [".cache/direnv"];
      };
    };
  };
}
