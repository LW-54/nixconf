{self, ...}: {
  flake.nixosModules.ssh = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.ssh;
    hostKeySecretPath = ../../secrets/hosts/${config.networking.hostName}/ssh.yaml;
    hasHostKeySecret = builtins.pathExists hostKeySecretPath;
    publicKeysFile = ../../secrets/ssh/public.yaml;
    publicKeys =
      if builtins.pathExists publicKeysFile
      then let
        lines = lib.splitString "\n" (builtins.readFile publicKeysFile);
        getKey = line: let
          m = builtins.match "^([a-zA-Z0-9_.-]+):.*" line;
        in
          if m != null && builtins.head m != "sops"
          then builtins.head m
          else null;
      in
        lib.unique (builtins.filter (x: x != null) (map getKey lines))
      else ["master"];
  in {
    options.services.ssh = {
      enable = lib.mkEnableOption "standard SSH configuration" // {default = true;};

      prebuildMasterSsh = lib.mkEnableOption "prebuilding the master SSH development shell" // {default = true;};

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
        default = [];
        description = "Additional SSH authorized public keys for administrative access.";
      };

      authorizeForUsers = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = null;
        apply = users:
          if users == null
          then ["root"] ++ lib.optional (config.users ? account && config.users.account ? lw) "lw"
          else users;
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

      # Expose public keys in SOPS
      sops.secrets =
        lib.listToAttrs (map (name: {
            name = "ssh/public/${name}";
            value = {
              sopsFile = ../../secrets/ssh/public.yaml;
              key = name;
              mode = "0444";
            };
          })
          publicKeys)
        // lib.optionalAttrs hasHostKeySecret {
          "ssh/host-key" = {
            sopsFile = hostKeySecretPath;
            key = "ed25519";
            mode = "0600";
          };
        };

      # Provision host SSH key from SOPS if missing or different
      systemd.services.provision-ssh-host-key = lib.mkIf hasHostKeySecret {
        description = "Provision SSH host key from SOPS if missing or different";
        wantedBy = ["sshd.service"];
        before = ["sshd.service"];
        after = ["sops-nix.service"];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
        };
        script = ''
          if [ ! -s /etc/ssh/ssh_host_ed25519_key ] || ! ${pkgs.diffutils}/bin/cmp -s /etc/ssh/ssh_host_ed25519_key ${config.sops.secrets."ssh/host-key".path}; then
            mkdir -p /etc/ssh
            install -m 600 ${config.sops.secrets."ssh/host-key".path} /etc/ssh/ssh_host_ed25519_key
            ${pkgs.openssh}/bin/ssh-keygen -y -f /etc/ssh/ssh_host_ed25519_key > /etc/ssh/ssh_host_ed25519_key.pub
            chmod 644 /etc/ssh/ssh_host_ed25519_key.pub
            if [ -d /persist/system ]; then
              mkdir -p /persist/system/etc/ssh
              cp -p /etc/ssh/ssh_host_ed25519_key /persist/system/etc/ssh/ssh_host_ed25519_key
              cp -p /etc/ssh/ssh_host_ed25519_key.pub /persist/system/etc/ssh/ssh_host_ed25519_key.pub
            fi
          fi
        '';
      };

      system.extraDependencies = lib.optional cfg.prebuildMasterSsh self.devShells.${pkgs.system}.master-ssh;

      services.openssh.extraConfig = lib.optionalString (cfg.authorizeForUsers != []) ''
        Match User ${lib.concatStringsSep "," cfg.authorizeForUsers}
            AuthorizedKeysFile /etc/ssh/authorized_keys.d/%u ${config.sops.secrets."ssh/public/master".path}
      '';

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

        ssh-add "''${master_ssh_key}" 2>/dev/null || true
      '';
    };
  };
}
