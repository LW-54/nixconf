{
  self,
  inputs,
  ...
}: let
  defaultSettings = {
    pull.rebase = true;
    fetch.prune = true;
    push.autoSetupRemote = true;
    rerere.enabled = true;
  };
in {
  feature.git = {
    description = "Git version control system, global/per-user configuration, and Bitwarden GitHub SSH/CLI shells.";

    modules = {
      git = {
        config,
        lib,
        pkgs,
        ...
      }: let
        cfg = config.git;
      in {
        options.git = {
          enable = lib.mkEnableOption "Git version control" // {default = true;};
          settings = lib.mkOption {
            type = lib.types.attrsOf lib.types.anything;
            default = {};
            description = "Global Git configuration settings.";
          };
          users = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule {
              options = {
                enable = lib.mkOption {
                  type = lib.types.nullOr lib.types.bool;
                  default = null;
                  description = "Whether Git configuration is enabled for this user.";
                };
                settings = lib.mkOption {
                  type = lib.types.attrsOf lib.types.anything;
                  default = {};
                  description = "User-specific Git configuration settings overriding global defaults.";
                };
              };
            });
            default = {};
            description = "Per-user Git configuration overrides.";
          };
          prebuildGithubSsh = lib.mkEnableOption "prebuilding the GitHub SSH development shell" // {default = true;};
        };

        config = lib.mkIf cfg.enable (lib.mkMerge [
          {
            git.settings = lib.mapAttrs (_: lib.mkDefault) defaultSettings;
            environment.systemPackages = [pkgs.git];
            system.extraDependencies = lib.optional cfg.prebuildGithubSsh self.devShells.${pkgs.stdenv.hostPlatform.system}.github-ssh;

            home.shared.xdg.config."git/config" = {
              generator = lib.generators.toINI {};
              value = cfg.settings;
            };

            home.users = lib.mapAttrs (_: uCfg:
              lib.mkIf (uCfg.enable != false) {
                xdg.config."git/config" = {
                  generator = lib.generators.toINI {};
                  value = lib.recursiveUpdate cfg.settings uCfg.settings;
                };
              })
            cfg.users;
          }
          (lib.mkIf config.default-user.enable {
            git.users.${config.default-user.username}.settings.user = {
              name = config.default-user.githubUsername;
              email = config.default-user.email;
            };
          })
        ]);
      };
    };

    packages = {pkgs, ...}: {
      git =
        (inputs.wrapper-modules.wrappers.git.wrap {
          inherit pkgs;
          settings =
            defaultSettings
            // {
              user = {
                name = self.lib.lw.githubUsername;
                email = self.lib.lw.email;
              };
            };
        })
        // {
          meta = {
            helpCommand = "git --help";
            homepage = "https://git-scm.com/doc";
          };
        };
    };

    devShells = {
      pkgs,
      self',
      ...
    }: {
      github-ssh = self.lib.bitwarden.mkShell {
        inherit pkgs;
        bw = self'.packages.bw;
        meta = {
          description = "Development shell configured with Bitwarden-authenticated GitHub SSH deploy keys.";
          usage = ''
            Development shell configured with Bitwarden-authenticated GitHub deploy keys.

            Loads the GitHub deploy key from Bitwarden item `334fd4e6-1911-4017-9232-9463e6b70e21` into a secure temporary file in `$TMPDIR` (mode `0600`) and exports `GIT_SSH_COMMAND` to use it with `IdentitiesOnly=yes`. The temporary key file is automatically removed on shell exit via `trap`.
          '';
        };
        shellHook = ''
          umask 077
          github_ssh_key="$(mktemp "''${TMPDIR:-/tmp}/github-ssh.XXXXXX")"
          chmod 600 "''${github_ssh_key}"
          trap 'rm -f "''${github_ssh_key}"' EXIT

          ${self.lib.bitwarden.mkValue {
            itemId = "334fd4e6-1911-4017-9232-9463e6b70e21";
            jqFilter = ".sshKey.privateKey | select(type == \"string\" and length > 0)";
          }} > "''${github_ssh_key}"

          export GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes -i ''${github_ssh_key}"
        '';
      };

      github-cli = self.lib.bitwarden.mkShell {
        inherit pkgs;
        bw = self'.packages.bw;
        packages = [pkgs.age pkgs.git pkgs.gh pkgs.sops];
        meta = {
          description = "Development shell configured with GitHub CLI (gh) and SOPS-encrypted GH_TOKEN.";
          usage = ''
            Development shell configured with the GitHub CLI (`gh`) and a SOPS-backed `GH_TOKEN`.

            Unlocks the master SOPS age key via Bitwarden (item `c2352759-f5e3-40af-a797-89bd86e230d2`) if `SOPS_AGE_KEY` is not already set, decrypts `token` from `secrets/admin/github.yaml`, and exports `GH_TOKEN`.
          '';
        };
        shellHook = ''
          if [[ -z "''${GH_TOKEN:-}" ]]; then
            repo_root="''${DEVENV_ROOT:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
            sops_file="$repo_root/secrets/admin/github.yaml"
            if [[ ! -f "$sops_file" && -f "${self}/secrets/admin/github.yaml" ]]; then
              sops_file="${self}/secrets/admin/github.yaml"
            fi
            if [[ ! -f "$sops_file" ]]; then
              printf 'Missing GitHub token SOPS file: %s\n' "$sops_file" >&2
              exit 1
            fi
            if [[ -z "''${SOPS_AGE_KEY:-}" ]]; then
              ${self.lib.bitwarden.mkValue {
            itemId = "c2352759-f5e3-40af-a797-89bd86e230d2";
            variable = "SOPS_AGE_KEY";
            jqFilter = ".notes | select(type == \"string\" and length > 0)";
          }}
            fi
            GH_TOKEN="$(SOPS_AGE_KEY="$SOPS_AGE_KEY" sops -d --extract '["token"]' "$sops_file")" || exit 1
            export GH_TOKEN
          fi
        '';
      };
    };
  };
}
