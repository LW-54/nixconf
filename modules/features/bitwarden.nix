{self, ...}: {
  flake.nixosModules.bitwarden = {
    config,
    lib,
    ...
  }: let
    cfg = config.bitwarden;
    bitwardenEnabledFor = userName:
      self.lib.resolveUserOption {
        inherit lib userName;
        global = cfg.enable;
        users = cfg.users;
        path = ["enable"];
      };
    sshAgentEnabledFor = userName:
      self.lib.resolveUserOption {
        inherit lib userName;
        global = cfg.sshAgent.enable;
        users = cfg.users;
        path = ["sshAgent" "enable"];
      };
    anyHjemUserWithBitwardenSshAgent =
      lib.any
      (userName:
        bitwardenEnabledFor userName
        && sshAgentEnabledFor userName)
      (lib.attrNames config.hjem.users);
  in {
    imports = [
      (self.lib.mkUserFeature {
        inherit lib;
        name = "bitwarden";
        description = "Bitwarden Desktop";
        package = pkgs: pkgs.bitwarden-desktop;

        featureOptions.sshAgent.enable =
          lib.mkEnableOption "the Bitwarden SSH agent"
          // {
            default = false;
          };

        userOptions.sshAgent.enable = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "Whether this user's SSH agent uses Bitwarden, overriding bitwarden.sshAgent.enable.";
        };

        userModule = {
          cfg,
          user,
          name,
          lib,
          ...
        }: let
          sshAgentOverride = lib.attrByPath ["sshAgent" "enable"] null user;
          sshAgentEnabled =
            if sshAgentOverride == null
            then cfg.sshAgent.enable
            else sshAgentOverride;
          sshAgentSocket = "${config.users.users.${name}.home}/.bitwarden-ssh-agent.sock";
        in {
          environment.sessionVariables = lib.mkIf sshAgentEnabled {
            SSH_AUTH_SOCK = sshAgentSocket;
          };

          files.".config/environment.d/99-bitwarden-ssh-agent.conf" = lib.mkIf sshAgentEnabled {
            text = "SSH_AUTH_SOCK=${sshAgentSocket}\n";
          };
        };
      })
    ];

    config.programs.ssh.startAgent =
      lib.mkIf anyHjemUserWithBitwardenSshAgent (lib.mkForce false);
    config.services.gnome.gcr-ssh-agent.enable =
      lib.mkIf anyHjemUserWithBitwardenSshAgent (lib.mkForce false);
    config.systemd.user.services.gcr-ssh-agent.enable =
      lib.mkIf anyHjemUserWithBitwardenSshAgent (lib.mkForce false);
    config.systemd.user.sockets.gcr-ssh-agent.enable =
      lib.mkIf anyHjemUserWithBitwardenSshAgent (lib.mkForce false);

    config.persistence.users = self.lib.mkUserPersistence {
      inherit lib config;
      userEnabled = userName:
        self.lib.resolveUserOption {
          inherit lib;
          global = cfg.enable;
          users = cfg.users;
          inherit userName;
        };
      data.directories = [".config/Bitwarden"];
      cache.directories = [".cache/com.bitwarden.desktop"];
    };
  };
}
