{
  inputs,
  self,
  ...
}: {
  internal.antigravity = {
    packages = {pkgs, ...}: let
      upstream = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system};
      wrapMeta = pkg: helpCommand:
        pkg
        // {
          meta =
            (pkg.meta or {})
            // {
              inherit helpCommand;
              homepage = "https://github.com/jacopone/antigravity-nix";
            };
        };
      agy = wrapMeta upstream.google-antigravity-cli "agy --help";
      agy-api =
        (pkgs.symlinkJoin {
          name = "agy-api-${agy.version or "0"}";
          paths = [agy];
          nativeBuildInputs = [pkgs.makeWrapper];
          postBuild = ''
            wrapProgram "$out/bin/agy" \
              --add-flags '--settings {"modelProvider":"gemini"}'
            ln -s "$out/bin/agy" "$out/bin/agy-api"
          '';
        })
        // {
          meta =
            (builtins.removeAttrs (agy.meta or {}) ["outputsToInstall"])
            // {
              mainProgram = "agy-api";
              helpCommand = "agy-api --help";
            };
        };
    in {
      inherit agy agy-api;
      antigravity = wrapMeta upstream.default "antigravity --help";
      antigravity-ide = wrapMeta upstream.google-antigravity-ide "antigravity-ide --help";
    };

    devShells = {
      pkgs,
      self',
      ...
    }: {
      gemini-api = self.lib.bitwarden.mkShell {
        inherit pkgs;
        bw = self'.packages.bw;
        packages = [pkgs.age pkgs.sops self'.packages.agy-api];
        meta = {
          description = "Development shell exporting SOPS-encrypted GEMINI_API_KEY with API-key-wrapped agy-api.";
          usage = ''
            Development shell exporting `GEMINI_API_KEY` / `GOOGLE_API_KEY` from SOPS (`secrets/admin/gemini.yaml`) and providing `agy-api` (configured with `modelProvider = "gemini"`).

            Unlocks the master SOPS age key via Bitwarden (item `c2352759-f5e3-40af-a797-89bd86e230d2`) if `SOPS_AGE_KEY` is not already set.
          '';
        };
        shellHook = ''
          if [[ -z "''${GEMINI_API_KEY:-}" ]]; then
            repo_root="''${DEVENV_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
            sops_file="$repo_root/secrets/admin/gemini.yaml"
            if [[ ! -f "$sops_file" && -f "${../../../secrets/admin/gemini.yaml}" ]]; then
              sops_file="${../../../secrets/admin/gemini.yaml}"
            fi
            if [[ ! -f "$sops_file" ]]; then
              printf 'Missing Gemini SOPS file: %s\n' "$sops_file" >&2
              exit 1
            fi
            if [[ -z "''${SOPS_AGE_KEY:-}" ]]; then
              ${self.lib.bitwarden.mkValue {
            itemId = "c2352759-f5e3-40af-a797-89bd86e230d2";
            variable = "SOPS_AGE_KEY";
            jqFilter = ".notes | select(type == \"string\" and length > 0)";
          }}
            fi
            GEMINI_API_KEY="$(SOPS_AGE_KEY="$SOPS_AGE_KEY" sops -d --extract '["api_key"]' "$sops_file")" || exit 1
            export GEMINI_API_KEY GOOGLE_API_KEY="$GEMINI_API_KEY"
          fi
        '';
      };
    };
  };
}
