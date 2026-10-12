{ self, ... }:
{
  flake.nixosModules.bitwarden = { lib, ... }:
    {
      imports = [ (self.lib.mkUserFeature {
        inherit lib;
        name = "bitwarden";
        description = "Bitwarden Desktop";
        package = pkgs: pkgs.bitwarden-desktop;

        featureOptions.sshAgent.enable = lib.mkEnableOption "the Bitwarden SSH agent" // {
          default = false;
        };

        userOptions.sshAgent.enable = lib.mkOption {
          type = lib.types.nullOr lib.types.bool;
          default = null;
          description = "Whether this user's SSH agent uses Bitwarden, overriding bitwarden.sshAgent.enable.";
        };

        userModule = { cfg, user, lib, ... }:
          let
            sshAgentOverride = lib.attrByPath [ "sshAgent" "enable" ] null user;
            sshAgentEnabled =
              if sshAgentOverride == null then cfg.sshAgent.enable else sshAgentOverride;
          in
          {
            environment.sessionVariables = lib.mkIf sshAgentEnabled {
              BITWARDEN_SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
              SSH_AUTH_SOCK = "$BITWARDEN_SSH_AUTH_SOCK";
            };
          };
      }) ];
    };
}
