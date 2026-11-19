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
  };
}
