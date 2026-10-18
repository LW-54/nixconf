{
  self,
  ...
}: let
  knownKeys = {
    master = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmdqlhZ0Pl74W0tNTu/L2iDziaIgafdo8LuTn2Ui/Cg master-key";
  };
in {
  flake.lib.ssh = {
    inherit knownKeys;
  };

  flake.nixosModules.ssh = {
    config,
    lib,
    ...
  }: let
    cfg = config.services.ssh;
  in {
    options.services.ssh = {
      enable = lib.mkEnableOption "standard SSH configuration" // {default = true;};

      listenPort = lib.mkOption {
        type = lib.types.port;
        default = 22;
        description = "Port to listen on for SSH.";
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether to automatically open SSH port in firewall.";
      };

      authorizedKeys = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [knownKeys.master];
        description = "Default SSH authorized public keys for administrative access.";
      };

      authorizeForUsers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = ["root" "lw"];
        description = "List of user accounts that should receive the authorizedKeys.";
      };
    };

    config = lib.mkIf cfg.enable {
      services.openssh = {
        enable = true;
        ports = [cfg.listenPort];
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
        };
      };

      networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [cfg.listenPort];

      programs.ssh.knownHosts = {
        "github.com" = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
      };

      # Allow referencing public key by name via SOPS secret
      sops.secrets."ssh/master-pubkey" = {
        sopsFile = ../../secrets/ssh/master.yaml;
        key = "publicKey";
      };

      users.users = lib.genAttrs cfg.authorizeForUsers (_: {
        openssh.authorizedKeys.keys = cfg.authorizedKeys;
      });

      persistence.files = lib.mkIf (config.persistence ? enable && config.persistence.enable) [
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
        "/etc/ssh/ssh_host_rsa_key"
        "/etc/ssh/ssh_host_rsa_key.pub"
      ];
    };
  };

  perSystem = {
    pkgs,
    self',
    ...
  }: {
    devShells.master-ssh = self.lib.bitwarden.mkShell {
      inherit pkgs;
      bw = self'.packages.bw;
      shellHook = ''
        umask 077
        master_ssh_key="$(mktemp "''${TMPDIR:-/tmp}/master-ssh.XXXXXX")"
        chmod 600 "''${master_ssh_key}"
        trap 'rm -f "''${master_ssh_key}"' EXIT

        ${self.lib.bitwarden.mkValue {
          itemId = "master-key";
          jqFilter = ".sshKey.privateKey // .notes";
        }} > "''${master_ssh_key}"

        export SSH_AUTH_SOCK=""
        export GIT_SSH_COMMAND="ssh -o IdentitiesOnly=yes -i ''${master_ssh_key}"
        ssh-add "''${master_ssh_key}" 2>/dev/null || true
        printf 'Master SSH key loaded into session from Bitwarden.\n'
      '';
    };
  };
}
