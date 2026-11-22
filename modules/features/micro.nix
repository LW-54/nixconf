_: let
  defaultSettings = {
    autoindent = true;
    clipboard = "terminal";
    colorscheme = "default";
    mkparents = true;
    softwrap = true;
    tabsize = 2;
    tabstospaces = true;
  };

  mkWrappedMicro = {
    pkgs,
    settings ? defaultSettings,
    bindings ? {},
  }: let
    configDir = pkgs.runCommand "micro-config" {} ''
      mkdir -p "$out"
      cat > "$out/settings.json" <<'EOF'
      ${builtins.toJSON settings}
      EOF
      ${
        if bindings != {}
        then ''
          cat > "$out/bindings.json" <<'EOF'
          ${builtins.toJSON bindings}
          EOF
        ''
        else ""
      }
    '';
  in
    (pkgs.symlinkJoin {
      name = "micro-${pkgs.micro.version}";
      paths = [pkgs.micro];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild = ''
        wrapProgram "$out/bin/micro" \
          --set-default MICRO_CONFIG_HOME "${configDir}"
      '';
    })
    // {
      meta =
        (builtins.removeAttrs (pkgs.micro.meta or {}) ["outputsToInstall"])
        // {
          helpCommand = "micro --help";
          homepage = "https://micro-editor.github.io";
        };
    };
in {
  feature.micro = {
    description = "Modern and intuitive terminal-based text editor with wrapped declarative configuration.";

    modules = {
      micro = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.micro;
        wrappedMicro = mkWrappedMicro {
          inherit pkgs;
          inherit (cfg) settings bindings;
        };
      in {
        options.micro = {
          enable = lib.mkEnableOption "Micro terminal text editor" // {default = true;};

          defaultEditor = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Whether to set `micro` as the system-wide default `EDITOR` and `VISUAL`.";
          };

          settings = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = defaultSettings;
            description = "Declarative `settings.json` attributes baked into the wrapped `micro` configuration directory.";
          };

          bindings = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = {};
            description = "Declarative `bindings.json` keybinding overrides baked into the wrapped `micro` configuration directory.";
          };
        };

        config = lib.mkIf cfg.enable {
          environment.systemPackages = [wrappedMicro];

          environment.variables = lib.mkIf cfg.defaultEditor {
            EDITOR = "micro";
            VISUAL = "micro";
          };
        };
      };
    };

    packages = {pkgs, ...}: {
      micro = mkWrappedMicro {inherit pkgs;};
    };
  };
}
