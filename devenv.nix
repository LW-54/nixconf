{
  pkgs,
  lib,
  inputs,
  ...
}: let
  devenvRootFileContent =
    if inputs ? devenv-root
    then builtins.readFile inputs.devenv-root.outPath
    else "";
in {
  # If direnv provided devenv-root, use it; otherwise fallback to ./. so pure checks pass standalone
  devenv.root = lib.mkIf (devenvRootFileContent == "") (builtins.toString ./.);

  packages = with pkgs; [
    # Interactive navigation & execution
    fzf
    just

    # Nix utilities & diffing
    nvd
    nix-output-monitor
    alejandra
    deadnix
    statix

    # Secrets management
    sops
    age

    # Pinning & VCS
    inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.default
    git
    jq
  ];

  # Disable devenv git-hooks manager to preserve repo's custom .githooks/pre-commit
  git-hooks.enable = false;

  # Disable container generation to avoid unnecessary nix2container / mk-shell-bin dependencies
  containers = lib.mkForce {};

  # Scripts exposed directly in the devenv PATH
  scripts = {
    menu.exec = ''
      bash "$DEVENV_ROOT/scripts/menu.sh" "$@"
    '';

    ide.exec = ''
      if command -v antigravity-ide >/dev/null 2>&1; then
        exec antigravity-ide "''${@:-.}"
      else
        echo "antigravity-ide not found in PATH; running via 'nix run .#antigravity-ide'..."
        exec nix run "$DEVENV_ROOT#antigravity-ide" -- "''${@:-.}"
      fi
    '';
  };

  enterShell = ''
    echo ""
    echo -e "\033[1;34m✦ nixconf devenv active\033[0m"
    echo -e "  \033[0;32m>\033[0m Run \033[1;33mmenu\033[0m (or \033[1;33mjust --choose\033[0m) to fuzzy find commands, packages & devshells"
    echo -e "  \033[0;32m>\033[0m Run \033[1;33mide\033[0m to open repository in Antigravity IDE"
    echo -e "  \033[0;32m>\033[0m Run \033[1;33mjust --list\033[0m to view all recipes"
    echo ""
  '';
}
