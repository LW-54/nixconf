# Lightweight pure-Nix default development shell (replaces devenv to eliminate ~4s flake eval
# overhead and impure PWD/TMPDIR hacks while preserving direnv + nix-direnv caching).
{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devShells.default = pkgs.mkShellNoCC {
      name = "nixconf-devshell";

      packages = with pkgs; [
        # Interactive navigation & execution
        fzf
        just
        config.packages.menu
        config.packages.prof

        # Nix utilities, caching & diffing
        attic-client
        nvd
        nix-diff
        nix-eval-jobs
        nix-fast-build
        nix-output-monitor
        alejandra
        deadnix
        statix

        # Secrets management
        sops
        age

        # Pinning & VCS
        inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.default
        gh
        git
        jq
      ];

      shellHook = ''
        export DEVENV_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
        echo ""
        echo -e "\033[1;34m✦ nixconf devshell active\033[0m"
        echo -e "  \033[0;32m>\033[0m Run \033[1;33mmenu\033[0m (or \033[1;33mjust\033[0m) to fuzzy find commands, packages & devshells"
        echo -e "  \033[0;32m>\033[0m Run \033[1;33mjust --list\033[0m to view all recipes"
        echo ""
      '';

      meta.description = "Main development shell with just, fzf, menu, nixprof, attic-client, and Nix linters.";
    };
  };
}
