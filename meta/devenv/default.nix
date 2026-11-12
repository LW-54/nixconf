{inputs, ...}: {
  imports = [
    inputs.devenv.flakeModule
  ];

  perSystem = {lib, ...}: let
    resolvedRoot =
      if (builtins.getEnv "PWD") != ""
      then builtins.getEnv "PWD"
      else builtins.toString ../..;
  in {
    devenv.shells.default = {
      # In interactive/impure shells (direnv/nix develop), use the working directory;
      # in pure mode (flake check), fallback to repo root closure so pure checks pass standalone.
      devenv.root = resolvedRoot;

      # Disable devenv git-hooks manager to preserve repo's custom .githooks/pre-commit
      git-hooks.enable = false;

      # Disable container generation to avoid unnecessary nix2container / mk-shell-bin dependencies
      containers = lib.mkForce {};

      enterShell = ''
        echo ""
        echo -e "\033[1;34m✦ nixconf devenv active\033[0m"
        echo -e "  \033[0;32m>\033[0m Run \033[1;33mmenu\033[0m (or \033[1;33mjust --choose\033[0m) to fuzzy find commands, packages & devshells"
        echo -e "  \033[0;32m>\033[0m Run \033[1;33mide\033[0m to open repository in Antigravity IDE"
        echo -e "  \033[0;32m>\033[0m Run \033[1;33mjust --list\033[0m to view all recipes"
        echo ""
      '';
    };
  };
}
