{ self, inputs, ... }: {
  flake.nixosModules.bitwarden = { pkgs, lib, ... }: {
    environment.systemPackages = [ pkgs.bitwarden-desktop ];

    programs.ssh.startAgent = lib.mkForce false;
    systemd.user.services.gcr-ssh-agent.enable = lib.mkForce false;
    systemd.user.sockets.gcr-ssh-agent.enable = lib.mkForce false;
    systemd.user.services.ssh-agent.enable = lib.mkForce false;

    environment.sessionVariables = {
      SSH_AUTH_SOCK = "$HOME/.bitwarden-ssh-agent.sock";
    };
  };
}