{ self, inputs, ... }: {
  flake.nixosModules.obsidian = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.obsidian
    ];
  };

  perSystem = { pkgs, self', ... }: {
    # Build the plugin bundle (main.js, manifest.json, styles.css)
    packages.mdbase-obsidian-plugin = pkgs.buildNpmPackage {
      pname = "mdbase-obsidian";
      version = "0-unstable";
      src = inputs.mdbase-obsidian;

      # First build fails and prints the real hash — paste it back in here.
      npmDepsHash = "sha256-uNjAJgblwmzVZ0Hzz7IYPjqnhmWgPLBQ4LU2Nu/1IKc=";
      npmBuildScript = "build";

      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp main.js manifest.json styles.css $out/
        runHook postInstall
      '';
    };

    # Obsidian itself, wrapped so the plugin gets synced into every known vault on every launch
    packages.obsidian = inputs.wrappers.lib.wrapPackage {
      inherit pkgs;
      package = pkgs.obsidian;
      runtimeInputs = [ pkgs.jq ];
      preHook = ''
        plugin_src="${self'.packages.mdbase-obsidian-plugin}"
        config_file="$HOME/.config/obsidian/obsidian.json"
        if [ -f "$config_file" ]; then
          jq -r '.vaults[].path // empty' "$config_file" 2>/dev/null | while read -r vault_path; do
            [ -d "$vault_path" ] || continue
            dest="$vault_path/.obsidian/plugins/mdbase-obsidian"
            mkdir -p "$dest"
            for f in main.js manifest.json styles.css; do
              ln -sfn "$plugin_src/$f" "$dest/$f"
            done
          done
        fi
      '';
    };
  };
}