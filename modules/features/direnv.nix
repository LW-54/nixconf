{self, ...}: {
  feature.direnv = {
    description = "Per-directory declarative shell environment integration via nix-direnv.";
    modules = {
      direnv = {
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

          persistence.users = lib.mapAttrs (_: _: {
            cache.directories = [".cache/direnv"];
          }) (lib.filterAttrs (_: u: u.isNormalUser or false) config.users.users);
        };
      };
    };
  };
}
