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
            direnvrcExtra = ''
              for _tmp_var in TMPDIR TMP TEMP TEMPDIR; do
                if [[ -n "''${!_tmp_var:-}" && ( "''${!_tmp_var}" == */nix-shell.* || ! -d "''${!_tmp_var}" ) ]]; then
                  unset "$_tmp_var"
                fi
              done
              unset _tmp_var
            '';
            nix-direnv.enable = true;
          };

          persistence.users = self.lib.user.forNormalUsers config (_: _: {
            data.directories = [".local/share/direnv"];
            cache.directories = [".cache/direnv"];
          });
        };
      };
    };
  };
}
