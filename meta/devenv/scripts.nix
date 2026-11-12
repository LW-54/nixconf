{
  perSystem = {...}: {
    devenv.shells.default.scripts = {
      ide.exec = ''
        if command -v antigravity-ide >/dev/null 2>&1; then
          exec antigravity-ide "''${@:-.}"
        else
          echo "antigravity-ide not found in PATH; running via 'nix run .#antigravity-ide'..."
          exec nix run "$DEVENV_ROOT#antigravity-ide" -- "''${@:-.}"
        fi
      '';
    };
  };
}
