{
  inputs,
  self,
  ...
}: let
  globalRules = ''
    # Global Agent Rules

    ## Git Commit Messages
    - Always format commit messages as `<type>: <description>` (e.g., `feat: ...`, `fix: ...`, `refactor: ...`, `docs: ...`, `chore: ...`, `revert: ...`).
    - NEVER use parenthetical scopes like `type(scope): ...` in commit messages.
    - Keep the commit subject line concise, lowercase after `<type>: `, and without a trailing period.
  '';

  mkModule = {
    name,
    prettyName,
    extraConfig ? (_: {}),
  }: {
    config,
    lib,
    pkgs,
    ...
  }: {
    options.${name}.enable = lib.mkEnableOption prettyName // {default = true;};

    config = lib.mkIf config.${name}.enable (lib.mkMerge [
      {
        environment.systemPackages = [self.packages.${pkgs.stdenv.hostPlatform.system}.${name}];
        home.shared.files = {
          ".gemini/GEMINI.md".text = globalRules;
          ".gemini/config/GEMINI.md".text = globalRules;
        };
        persistence.users = self.lib.user.forNormalUsers config (_: _: {
          data.directories = [
            ".gemini"
          ];
        });
      }
      (extraConfig {inherit config lib pkgs;})
    ]);
  };
in {
  feature.antigravity = {
    description = "Google Antigravity IDE, agentic workflow tools, and CLI runtime.";
    modules = {
      antigravity = mkModule {
        name = "antigravity";
        prettyName = "Antigravity";
      };

      antigravity-ide = mkModule {
        name = "antigravity-ide";
        prettyName = "Antigravity IDE";
        extraConfig = {config, ...}: {
          persistence.users = self.lib.user.forNormalUsers config (_: _: {
            data.directories = [
              ".antigravity-ide"
            ];
          });
        };
      };

      antigravity-cli = mkModule {
        name = "antigravity-cli";
        prettyName = "Antigravity CLI";
      };
    };

    packages = {pkgs, ...}: let
      upstream = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system};
      wrap = pkg: helpCommand:
        pkg
        // {
          meta =
            (pkg.meta or {})
            // {
              inherit helpCommand;
              homepage = "https://github.com/jacopone/antigravity-nix";
            };
        };
    in {
      antigravity = wrap upstream.default "antigravity --help";
      antigravity-ide = wrap upstream.google-antigravity-ide "antigravity-ide --help";
      antigravity-cli = wrap upstream.google-antigravity-cli "antigravity --help";
    };

    devShells = {
      pkgs,
      self',
      ...
    }: {
      gemini = self.lib.bitwarden.mkShell {
        inherit pkgs;
        bw = self'.packages.bw;
        packages = [pkgs.age pkgs.git pkgs.sops self'.packages.antigravity-cli];
        meta = {
          description = "Development shell with the Antigravity CLI and SOPS-encrypted GEMINI_API_KEY.";
          usage = ''
            Development shell with the Antigravity CLI and a SOPS-backed `GEMINI_API_KEY`.

            Unlocks the master SOPS age key via Bitwarden (item `c2352759-f5e3-40af-a797-89bd86e230d2`) if `SOPS_AGE_KEY` is not already set, decrypts `api_key` from `secrets/admin/gemini.yaml`, and exports `GEMINI_API_KEY` and `GOOGLE_API_KEY`.
          '';
        };
        shellHook = ''
          if [[ -z "''${GEMINI_API_KEY:-}" ]]; then
            repo_root="''${DEVENV_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
            sops_file="$repo_root/secrets/admin/gemini.yaml"
            if [[ ! -f "$sops_file" && -f "${self}/secrets/admin/gemini.yaml" ]]; then
              sops_file="${self}/secrets/admin/gemini.yaml"
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
