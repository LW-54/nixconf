_: let
  defaultSettings = {
    agentMode = "auto";
    # agy's built-in Linux sandbox (exebox/sbox) constructs a pivot_root mount namespace
    # without mounting /nix, preventing any NixOS binary from executing inside it.
    # Kernel-level filesystem and privilege isolation is enforced declaratively via
    # systemd hardening on agy-remote-control.service instead.
    enableTerminalSandbox = false;
  };

  defaultRules = {
    autonomy = ''
      ## Autonomy & Decision Making
      - Act autonomously on implementation details: directly perform file edits, formatting, refactoring, test execution, and diagnostic/build commands without asking for confirmation first.
      - Do not ask for permission before running routine commands or applying straightforward code changes.
      - Pause and ask for user input (using `ask_question` or an implementation plan) ONLY for:
        - Architecture and high-level design decisions with meaningful trade-offs.
        - Ambiguous product or behavioral requirements where multiple interpretations exist.
        - Destructive or irreversible actions (e.g., deleting untracked data, force-pushing, dropping state).
    '';

    gitCommits = ''
      ## Git Commit Messages
      - Always format commit messages as `<type>: <description>` (e.g., `feat: ...`, `fix: ...`, `refactor: ...`, `docs: ...`, `chore: ...`, `revert: ...`).
      - NEVER use parenthetical scopes like `type(scope): ...` in commit messages.
      - Keep the commit subject line concise, lowercase after `<type>: `, and without a trailing period.
    '';
  };

  renderRules = lib: rules:
    "# Global Agent Rules\n\n"
    + lib.concatStringsSep "\n\n" (map lib.trim (lib.filter (s: lib.trim s != "") (builtins.attrValues rules)))
    + "\n";
in {
  internal.antigravity.configModule = {
    config,
    lib,
    ...
  }: let
    cfg = config.agy.config;
  in {
    key = "nixconf:agy-config";

    options.agy.config = {
      enable = lib.mkEnableOption "declarative Antigravity CLI settings, rules, and MCP configuration" // {default = true;};

      settings = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Declarative `~/.gemini/antigravity-cli/settings.json` attributes merged over defaults.";
      };

      rules = lib.mkOption {
        type = lib.types.attrsOf lib.types.lines;
        default = {};
        description = "Declarative named Markdown sections rendered into global `GEMINI.md` rules.";
      };

      mcpServers = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = {};
        description = "Declarative MCP server definitions serialized to `~/.gemini/config/mcp_config.json` when non-empty.";
      };

      users = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            enable = lib.mkOption {
              type = lib.types.nullOr lib.types.bool;
              default = null;
              description = "Whether Antigravity configuration is enabled for this user.";
            };

            settings = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = {};
              description = "User-specific `settings.json` overrides.";
            };

            rules = lib.mkOption {
              type = lib.types.attrsOf lib.types.lines;
              default = {};
              description = "User-specific global rule section overrides/additions.";
            };
          };
        });
        default = {};
        description = "Per-user Antigravity configuration overrides.";
      };
    };

    config = lib.mkIf cfg.enable {
      agy.config = {
        settings = lib.mapAttrs (_: lib.mkDefault) defaultSettings;
        rules = lib.mapAttrs (_: lib.mkDefault) defaultRules;
      };

      home.shared.files =
        {
          ".gemini/GEMINI.md".text = renderRules lib cfg.rules;
          ".gemini/config/GEMINI.md".text = renderRules lib cfg.rules;
        }
        // lib.optionalAttrs (cfg.settings != {}) {
          ".gemini/antigravity-cli/settings.json" = {
            generator = builtins.toJSON;
            value = cfg.settings;
          };
        }
        // lib.optionalAttrs (cfg.mcpServers != {}) {
          ".gemini/config/mcp_config.json" = {
            generator = builtins.toJSON;
            value = {inherit (cfg) mcpServers;};
          };
        };

      home.users = lib.mapAttrs (_: uCfg:
        lib.mkIf (uCfg.enable != false) {
          files =
            lib.optionalAttrs (uCfg.rules != {}) {
              ".gemini/GEMINI.md".text = renderRules lib (cfg.rules // uCfg.rules);
              ".gemini/config/GEMINI.md".text = renderRules lib (cfg.rules // uCfg.rules);
            }
            // lib.optionalAttrs (uCfg.settings != {}) {
              ".gemini/antigravity-cli/settings.json" = {
                generator = builtins.toJSON;
                value = lib.recursiveUpdate cfg.settings uCfg.settings;
              };
            };
        })
      cfg.users;
    };
  };
}
