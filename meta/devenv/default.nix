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

      # Pin tmpdir to /tmp so impure evaluation inside an active nix-shell never bakes an
      # ephemeral /tmp/nix-shell.XXXXXX path from builtins.getEnv "TMPDIR" into the cached shellHook.
      devenv.tmpdir = "/tmp";

      # Disable devenv git-hooks manager to preserve repo's custom .githooks/pre-commit
      git-hooks.enable = false;

      # Disable container generation to avoid unnecessary nix2container / mk-shell-bin dependencies
      containers = lib.mkForce {};

      enterShell = lib.mkMerge [
        # Clean up the ephemeral NIX_BUILD_TOP directory created by nix print-dev-env before
        # devenv's top-level enterShell (order 500) unsets NIX_BUILD_TOP.
        (lib.mkOrder 100 ''
          if [[ -n "''${NIX_BUILD_TOP:-}" && "''${NIX_BUILD_TOP}" == */nix-shell.* && -d "''${NIX_BUILD_TOP}" ]]; then
            rmdir "''${NIX_BUILD_TOP}" 2>/dev/null || rm -rf "''${NIX_BUILD_TOP}"
          fi
        '')
        ''
          echo ""
          echo -e "\033[1;34m✦ nixconf devenv active\033[0m"
          echo -e "  \033[0;32m>\033[0m Run \033[1;33mmenu\033[0m (or \033[1;33mjust\033[0m) to fuzzy find commands, packages & devshells"
          echo -e "  \033[0;32m>\033[0m Run \033[1;33mjust --list\033[0m to view all recipes"
          echo ""
        ''
      ];
    };
  };
}
