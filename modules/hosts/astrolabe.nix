{
  inputs,
  self,
  ...
}: let
  domain = "adje.app";
  sshKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOmdqlhZ0Pl74W0tNTu/L2iDziaIgafdo8LuTn2Ui/Cg";
in {
  flake.nixosConfigurations.astrolabe = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.astrolabe];
  };

  flake.nixosModules.astrolabe = {...}: {
    imports = [
      self.nixosModules.astrolabe-hardware
      self.nixosModules.astrolabe-disk
      self.nixosModules.astrolabe-system
      self.nixosModules.astrolabe-services
    ];
  };

  flake.nixosModules.astrolabe-hardware = {
    modulesPath,
    lib,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    config = {
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      boot.loader.grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        device = "/dev/sda";
      };
    };
  };

  flake.nixosModules.astrolabe-disk = {...}: {
    imports = [
      self.nixosModules.disko
      self.nixosModules.impermanence
    ];

    config =
      self.lib.disko.mkLayout {
        device = "/dev/sda";
        espSize = "512M";
        biosBootSize = "1M";
      }
      // {
        zramSwap.enable = true;
      };
  };

  flake.nixosModules.astrolabe-system = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.nixosModules.contracts
      self.nixosModules.nix
      self.nixosModules.locale
    ];

    config = {
      networking.hostName = "astrolabe";
      system.stateVersion = "25.11";

      # SOPS configuration for Astrolabe
      sops.defaultSopsFile = ../../secrets/hosts/astrolabe/secrets.yaml;
      sops.defaultSopsFormat = "yaml";
      sops.age.keyFile = "/persist/sops-nix/key.txt";

      sops.secrets."restic/env" = {};
      sops.secrets."restic/password" = {};
      sops.secrets."github_ssh_key" = {
        owner = "lw";
        path = "/home/lw/.ssh/id_ed25519";
        mode = "0400";
      };

      persistence = {
        enable = true;
        files = [
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
      };

      # Users
      security.sudo.wheelNeedsPassword = false;
      users.defaultPasswordHash = false;

      users.users.root.openssh.authorizedKeys.keys = ["${sshKey} master-key"];
      users.account.lw = {
        isNormalUser = true;
        description = "Leonard Wilson";
        extraGroups = ["wheel"];
        openssh.authorizedKeys.keys = ["${sshKey} master-key"];
      };

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
      };

      networking.firewall.allowedTCPPorts = [22];

      # Nix settings for server
      nix.cachixWatchStore = false;

      programs.ssh.knownHosts = {
        "github.com" = {
          publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        };
      };

      programs.git = {
        enable = true;
        config = {
          init.defaultBranch = "main";
          pull.rebase = false;
          user.name = "LW-54";
          user.email = "leonardwilsonb@gmail.com";
        };
      };

      environment.systemPackages = with pkgs; [
        git
        nano
        rsync
        btop
      ];

      # Git repo sync for nixconf repo
      systemd.services.clone-nixconf-repo = {
        description = "Clone nixconf Config Repository on First Boot";
        wantedBy = ["multi-user.target"];
        wants = ["network-online.target" "sops-nix.service"];
        after = ["network-online.target" "sops-nix.service"];
        path = [pkgs.git pkgs.openssh];
        serviceConfig = {
          Type = "oneshot";
          User = "lw";
          WorkingDirectory = "/home/lw";
          RemainAfterExit = true;
        };
        script = ''
          for i in {1..10}; do
            if [ -f "/home/lw/.ssh/id_ed25519" ]; then break; fi
            sleep 1
          done

          if [ ! -d "/home/lw/nixconf" ]; then
            export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"
            git clone git@github.com:LW-54/nixconf.git /home/lw/nixconf
          fi
        '';
      };
    };
  };

  flake.nixosModules.astrolabe-services = {config, ...}: {
    imports = [
      self.nixosModules.caddy
      self.nixosModules.restic
      self.nixosModules.vaultwarden
      self.nixosModules.ttyd
    ];

    config = {
      # Reverse Proxy
      services.reverseProxy = {
        enable = true;
        domain = domain;
      };

      # Backup automation
      backup.enable = true;
      services.resticBackup = {
        repository = "s3:https://s3.eu-central-003.backblazeb2.com/cyclostyle-docker";
        environmentFile = config.sops.secrets."restic/env".path;
        passwordFile = config.sops.secrets."restic/password".path;
      };

      # Service toggles
      services.vaultwarden-server.enable = true;
      services.ttyd-web.enable = true;
    };
  };
}
