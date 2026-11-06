{self, ...}: {
  feature.direnv = {
    description = "Per-directory declarative shell environment integration via nix-direnv.";
    modules = {
      direnv = {config, ...}: {
        config = {
          programs.direnv = {
            enable = true;
            silent = false;
            loadInNixShell = true;
            direnvrcExtra = "";
            nix-direnv.enable = true;
          };

          persistence.users = self.lib.user.forNormalUsers config (_: _: {
            cache.directories = [".cache/direnv"];
          });
        };
      };
    };
  };
}
