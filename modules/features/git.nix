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
  flake.nixosModules.git = {
    config,
    lib,
    pkgs,
    options,
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

    config = lib.mkIf cfg.enable {
      git.settings = lib.mapAttrs (_: lib.mkDefault) defaultSettings;
      environment.systemPackages = [pkgs.git];
      system.extraDependencies = lib.optional cfg.prebuildGithubSsh self.devShells.${pkgs.system}.github-ssh;

      home.shared.xdg.config."git/config" = {
        generator = lib.generators.toINI {};
        value = cfg.settings;
      };

      home.users = lib.mapAttrs (userName: uCfg:
        lib.mkIf (uCfg.enable != false) {
          xdg.config."git/config" = {
            generator = lib.generators.toINI {};
            value = lib.recursiveUpdate cfg.settings uCfg.settings;
          };
        })
      cfg.users;

      # Configure Git settings for the default user if active
      git.users = lib.mkIf (config.default-user.enable or false) {
        ${config.default-user.username}.settings.user = {
          name = config.default-user.githubUsername;
          email = config.default-user.email;
        };
      };
    };
  };

  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.git = inputs.wrapper-modules.wrappers.git.wrap {
      inherit pkgs;
      settings =
        defaultSettings
        // {
          user = {
            name = self.lib.lw.githubUsername;
            email = self.lib.lw.email;
          };
        };
    };

    devShells.github-ssh = self.lib.bitwarden.mkShell {
      inherit pkgs;
      bw = self'.packages.bw;
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
  };
}
