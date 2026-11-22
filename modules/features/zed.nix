{self, ...}: let
  defaultSettings = {
    agent = {
      tool_permissions.default = "allow";
    };
    agent_servers.AGY = {
      type = "custom";
      command = "agy";
      args = ["acp" "--dangerously-skip-permissions"];
      default_config_options = {
        thought_level = "medium";
        model = "gemini-4-neon";
      };
    };
    icon_theme = "Zed (Default)";
    ui_font_size = 16;
    buffer_font_size = 15;
    theme = {
      mode = "dark";
      light = "One Light";
      dark = "One Dark";
    };
    ssh_connections = [
      {
        host = "adje.app";
        username = self.lib.lw.username;
        projects = [
          {paths = ["/home/${self.lib.lw.username}/nixconf"];}
        ];
      }
    ];
  };

  mkWrappedZed = {
    pkgs,
    extraPackages ? [],
  }:
    (pkgs.symlinkJoin {
      name = "zed-${pkgs.zed-editor.version}";
      paths = [pkgs.zed-editor];
      nativeBuildInputs = [pkgs.makeWrapper];
      postBuild =
        if extraPackages != []
        then ''
          wrapProgram "$out/bin/zeditor" \
            --prefix PATH : "${pkgs.lib.makeBinPath extraPackages}"
        ''
        else "";
    })
    // {
      meta =
        (builtins.removeAttrs (pkgs.zed-editor.meta or {}) ["outputsToInstall"])
        // {
          helpCommand = "zeditor --help";
          homepage = "https://zed.dev";
        };
    };
in {
  feature.zed = {
    description = "Zed editor environment, declarative settings/keymaps, SSH remote presets, and wrapped CLI/LSP toolchain.";

    modules.zed = {
      config,
      lib,
      pkgs,
      ...
    }: let
      cfg = config.zed;
    in {
      options.zed = {
        enable = lib.mkEnableOption "Zed editor" // {default = true;};

        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = {};
          description = "Global declarative Zed `settings.json` configuration merged over defaults.";
        };

        keymap = lib.mkOption {
          type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
          default = [];
          description = "Global declarative Zed `keymap.json` entries.";
        };

        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
          description = "Additional packages (LSPs, formatters, agent CLIs) added to Zed's wrapped `PATH`.";
        };

        users = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule {
            options = {
              enable = lib.mkOption {
                type = lib.types.nullOr lib.types.bool;
                default = null;
                description = "Whether Zed configuration is enabled for this user.";
              };

              settings = lib.mkOption {
                type = lib.types.attrsOf lib.types.anything;
                default = {};
                description = "User-specific Zed `settings.json` overrides.";
              };

              keymap = lib.mkOption {
                type = lib.types.listOf (lib.types.attrsOf lib.types.anything);
                default = [];
                description = "User-specific Zed `keymap.json` entries appended to global keymaps.";
              };
            };
          });
          default = {};
          description = "Per-user Zed configuration overrides.";
        };
      };

      config = lib.mkIf cfg.enable {
        zed.settings = lib.mapAttrs (_: lib.mkDefault) defaultSettings;

        environment.systemPackages = [
          (mkWrappedZed {
            inherit pkgs;
            extraPackages =
              [pkgs.nixd pkgs.alejandra]
              ++ lib.optional (self.packages.${pkgs.stdenv.hostPlatform.system} ? agy) self.packages.${pkgs.stdenv.hostPlatform.system}.agy
              ++ cfg.extraPackages;
          })
        ];

        home.shared.xdg.config =
          {
            "zed/settings.json" = {
              generator = builtins.toJSON;
              value = cfg.settings;
            };
          }
          // lib.optionalAttrs (cfg.keymap != []) {
            "zed/keymap.json" = {
              generator = builtins.toJSON;
              value = cfg.keymap;
            };
          };

        home.users = lib.mapAttrs (_: uCfg:
          lib.mkIf (uCfg.enable != false) {
            xdg.config =
              {
                "zed/settings.json" = {
                  generator = builtins.toJSON;
                  value = lib.recursiveUpdate cfg.settings uCfg.settings;
                };
              }
              // lib.optionalAttrs (cfg.keymap != [] || uCfg.keymap != []) {
                "zed/keymap.json" = {
                  generator = builtins.toJSON;
                  value = cfg.keymap ++ uCfg.keymap;
                };
              };
          })
        cfg.users;

        persistence.users = self.lib.user.forNormalUsers config (_: _: {
          data.directories = [".config/zed" ".local/share/zed"];
        });
      };
    };

    packages = {
      pkgs,
      self',
      ...
    }: {
      zed = mkWrappedZed {
        inherit pkgs;
        extraPackages =
          [pkgs.nixd pkgs.alejandra]
          ++ pkgs.lib.optional (self'.packages ? agy) self'.packages.agy;
      };
    };
  };
}
