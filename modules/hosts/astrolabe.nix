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
    _module.args = {
      inherit domain;
    };

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
      self.nixosModules.sops
      self.nixosModules.persistence
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
        directories = [
          "/var/lib/vaultwarden"
          "/var/lib/caddy"
        ];
        files = [
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ];
      };

      # Users
      security.sudo.wheelNeedsPassword = false;

      users.users.root.openssh.authorizedKeys.keys = ["${sshKey} master-key"];

      users.users.lw = {
        isNormalUser = true;
        description = "Leonard Wilson";
        extraGroups = ["wheel"];
        openssh.authorizedKeys.keys = ["${sshKey} master-key"];
      };

      services.openssh = {
        enable = true;
        settings.PasswordAuthentication = false;
      };

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

      programs.nix-ld.enable = true;

      environment.systemPackages = with pkgs; [
        git
        nano
        ttyd
        rsync
        btop
      ];

      networking.firewall.allowedTCPPorts = [22 80 443];

      # Backblaze B2 Restic Backup
      services.restic.backups.s3-main = {
        repository = "s3:https://s3.eu-central-003.backblazeb2.com/cyclostyle-docker";
        environmentFile = config.sops.secrets."restic/env".path;
        passwordFile = config.sops.secrets."restic/password".path;
        paths = ["/var/lib/vaultwarden"];
        pruneOpts = [
          "--keep-daily 7"
          "--keep-weekly 4"
          "--keep-monthly 12"
        ];
        initialize = true;
        timerConfig = {
          OnCalendar = "04:00";
          Persistent = true;
        };
      };

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

      # ttyd
      systemd.services.ttyd-web = {
        description = "ttyd Web Terminal";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        serviceConfig = {
          User = "lw";
          WorkingDirectory = "/home/lw";
          ExecStart = "${pkgs.ttyd}/bin/ttyd -i 127.0.0.1 -p 7681 -W ${pkgs.bashInteractive}/bin/bash";
          Restart = "always";
        };
      };

      # Caddy
      services.caddy = {
        enable = true;
        virtualHosts = {
          "ttyd.${domain}" = {
            extraConfig = ''
              basicauth / {
                admin $2a$14$vYmK17NeNy4sdgvOm6SAheSigD5Lnus70w8aJfQgLBceSG0hlVrPK
              }
              reverse_proxy localhost:7681
            '';
          };
        };
      };
    };
  };

  flake.nixosModules.astrolabe-services = {...}: {
    imports = [
      self.nixosModules.astrolabe-service-vaultwarden
    ];
  };

  flake.nixosModules.astrolabe-service-vaultwarden = {domain, ...}: {
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://vaultwarden.${domain}";
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        WEB_VAULT_ENABLED = true;
      };
    };

    services.caddy.virtualHosts."vaultwarden.${domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:8222
      '';
    };
  };

  flake.nixosModules.astrolabe-service-jellyfin = {domain, ...}: {
    sops.secrets."zurg_config" = {};

    services.caddy.virtualHosts."jellyfin.${domain}" = {
      extraConfig = "reverse_proxy 127.0.0.1:8096";
    };

    # Generate the official smart webhook script on the host
    environment.etc."zurg_webhook.sh" = {
      mode = "0755";
      text = ''
        #!/bin/sh
        # Formats Zurg's changed folder names into a JSON payload for cli_debrid
        PATHS=""
        for arg in "$@"; do
          PATHS="$PATHS\"$arg\","
        done
        PATHS=''${PATHS%,} # Remove trailing comma

        curl -s -X POST "https://clidebrid.adje.app/api/webhook/rclone" \
          -H "Content-Type: application/json" \
          -d "{\"data\": [$PATHS]}"
      '';
    };

    systemd.tmpfiles.rules = [
      "d /opt/docker-data/media 0777 root root -"
      "d /opt/docker-data/media/zurg 0777 root root -"
      "d /opt/docker-data/media/symlinks 0777 root root -"
    ];

    services.restic.backups.s3-main.exclude = [
      "/opt/docker-data/jellyfin/jellyfin-cache"
      "/opt/docker-data/jellyfin/jellyfin-config/metadata"
      "/opt/docker-data/media/zurg"
    ];
  };

  flake.nixosModules.astrolabe-service-seerr = {domain, ...}: {
    networking.firewall.allowedTCPPorts = [5055 5000];

    systemd.tmpfiles.rules = [
      "d /opt/docker-data/seerr/config 0755 1000 1000 -"
      "Z /opt/docker-data/seerr/config - 1000 1000 -"
      "d /opt/docker-data/seerr/cli_debrid 0777 root root -"
      "Z /opt/docker-data/seerr/cli_debrid - root root -"
    ];

    services.caddy.virtualHosts = {
      "seerr.${domain}" = {extraConfig = "reverse_proxy 127.0.0.1:5055";};
      "clidebrid.${domain}" = {extraConfig = "reverse_proxy 127.0.0.1:5000";};
    };
  };

  flake.nixosModules.astrolabe-service-obsidian-livesync = {
    config,
    pkgs,
    domain,
    ...
  }: {
    sops.secrets."couchdb_env" = {
      owner = "lw";
    };

    systemd.tmpfiles.rules = [
      "d /opt/docker-data/obsidian-livesync/data 0755 5984 5984 - -"
      "d /opt/docker-data/obsidian-livesync/etc 0755 5984 5984 - -"
    ];

    systemd.services.init-couchdb = {
      description = "Initialize CouchDB system databases for Obsidian Live Sync";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target" "sops-nix.service"];
      wants = ["network-online.target" "sops-nix.service"];

      serviceConfig = {
        Type = "oneshot";
        EnvironmentFile = config.sops.secrets."couchdb_env".path;
        RemainAfterExit = true;
      };

      path = [pkgs.curl pkgs.jq];

      script = ''
        HOST="http://localhost:5984"

        echo "Waiting for CouchDB to be ready on $HOST..."
        for i in {1..24}; do
          if curl -s "$HOST/" > /dev/null; then
            echo "CouchDB is up!"
            break
          fi
          sleep 5
        done

        AUTH="$COUCHDB_USER:$COUCHDB_PASSWORD"

        create_db() {
          local db_name=$1
          echo "Checking/Creating database: $db_name"
          curl -s -X PUT "$HOST/$db_name" -u "$AUTH"
        }

        create_db "_users"
        create_db "_replicator"
        create_db "_global_changes"

        echo "CouchDB initialization complete."
      '';
    };

    services.caddy.virtualHosts."sync.${domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:5984
      '';
    };
  };

  flake.nixosModules.astrolabe-service-obsidian-livesync-cli = {
    config,
    pkgs,
    ...
  }: {
    systemd.tmpfiles.rules = [
      "d /opt/docker-data/obsidian-livesync-cli/data 0755 1000 100 - -"
      "d /home/lw/obsidian/Memex 0755 1000 100 - -"
    ];

    systemd.services.obsidian-livesync-cli = {
      description = "Obsidian LiveSync CLI Daemon";
      wantedBy = ["multi-user.target"];
      after = ["docker.service" "sops-nix.service"];
      wants = ["docker.service" "sops-nix.service"];

      serviceConfig = {
        Type = "simple";
        User = "root";
        Restart = "always";
        RestartSec = 10;
        EnvironmentFile = config.sops.secrets."couchdb_env".path;
      };

      path = [pkgs.docker-compose pkgs.coreutils];

      script = ''
        SETTINGS="/opt/docker-data/obsidian-livesync-cli/data/settings.json"
        mkdir -p /opt/docker-data/obsidian-livesync-cli/data
        cat <<EOF > $SETTINGS
        {
          "couchDB_URI": "http://127.0.0.1:5984",
          "couchDB_USER": "$COUCHDB_USER",
          "couchDB_PASSWORD": "$COUCHDB_PASSWORD",
          "couchDB_DBNAME": "livesync",
          "liveSync": true,
          "syncOnSave": true,
          "syncOnStart": true,
          "encrypt": false,
          "usePluginSync": false,
          "isConfigured": true
        }
        EOF

        cd /home/lw/astrolabe/services/obsidian-livesync-cli
        exec docker-compose -f docker-compose.yml up
      '';
    };
  };

  flake.nixosModules.astrolabe-service-obsidian-web = {
    domain,
    pkgs,
    ...
  }: {
    systemd.tmpfiles.rules = [
      "d /opt/docker-data/obsidian-web/config 0755 1000 100 - -"
      "d /home/lw/obsidian 0755 1000 100 - -"
    ];

    services.caddy.virtualHosts."obsidian.${domain}" = {
      extraConfig = ''
        basicauth / {
          admin $2a$14$vYmK17NeNy4sdgvOm6SAheSigD5Lnus70w8aJfQgLBceSG0hlVrPK
        }
        reverse_proxy 127.0.0.1:7211
      '';
    };

    systemd.services.obsidian-permission-watchdog = {
      description = "Dynamic geometric-backoff permission repair for Obsidian vault";
      wantedBy = ["multi-user.target"];
      after = ["docker.service"];

      serviceConfig = {
        Type = "simple";
        User = "root";
        Restart = "always";
        RestartSec = "10";
      };

      path = [pkgs.findutils pkgs.coreutils];

      script = ''
        VAULT="/home/lw/obsidian"
        DELAY=60
        MAX_DELAY=14400

        mkdir -p $VAULT

        while true; do
          BAD_FILES=$(find $VAULT \( ! -uid 1000 -o ! -gid 100 \) -print -quit)

          if [ -n "$BAD_FILES" ]; then
            echo "Permission mismatch detected. Running full repair..."
            chown -R 1000:100 $VAULT
            find $VAULT -type d -exec chmod 2775 {} +
            find $VAULT -type f -exec chmod 664 {} +
            echo "Repair complete. Resetting delay to 1 minute."
            DELAY=60
          else
            DELAY=$(( DELAY * 2 ))
            if [ $DELAY -gt $MAX_DELAY ]; then
              DELAY=$MAX_DELAY
            fi
          fi

          sleep $DELAY
        done
      '';
    };
  };

  flake.nixosModules.astrolabe-service-syncthing = {
    domain,
    pkgs,
    ...
  }: let
    syncthingData = "/opt/docker-data/syncthing";
  in {
    systemd.tmpfiles.rules = [
      "d ${syncthingData} 0755 1000 100 - -"
    ];

    systemd.services.syncthing = {
      description = "Syncthing container for Obsidian vault syncing";
      wantedBy = ["multi-user.target"];
      after = ["docker.service"];
      wants = ["docker.service"];

      serviceConfig = {
        Type = "simple";
        User = "root";
        Restart = "always";
        RestartSec = 10;
      };

      path = [pkgs.docker-compose pkgs.coreutils];

      script = ''
        mkdir -p "${syncthingData}"
        chown 1000:100 "${syncthingData}"
        cd /home/lw/astrolabe/services/syncthing
        exec docker-compose -f docker-compose.yml up
      '';
    };

    services.caddy.virtualHosts."syncthing.${domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:8384
      '';
    };
  };

  flake.nixosModules.astrolabe-service-copyparty = {
    config,
    domain,
    ...
  }: {
    sops.secrets."copyparty_users" = {
      owner = "lw";
    };

    systemd.tmpfiles.rules = [
      "d /opt/docker-data/copyparty/config 0755 1000 100 - -"
    ];

    systemd.services.init-copyparty-config = {
      description = "Generate Copyparty config from SOPS secret";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target" "sops-nix.service"];
      wants = ["network-online.target" "sops-nix.service"];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };

      script = ''
        CONF="/opt/docker-data/copyparty/config/copyparty.conf"
        mkdir -p /opt/docker-data/copyparty/config

        echo "[global]" > $CONF
        echo "rproxy: -1" >> $CONF
        echo "xff-src: lan" >> $CONF
        echo "e2dsa" >> $CONF
        echo "e2ts" >> $CONF
        echo "" >> $CONF

        echo "[accounts]" >> $CONF
        cat ${config.sops.secrets."copyparty_users".path} >> $CONF
        echo "" >> $CONF

        echo "[/]" >> $CONF
        echo "/home/lw" >> $CONF
        echo "accs:" >> $CONF
        echo "  A: admin" >> $CONF

        chown 1000:100 $CONF
        chmod 600 $CONF
      '';
    };

    services.caddy.virtualHosts."copyparty.${domain}" = {
      extraConfig = ''
        reverse_proxy 127.0.0.1:3923
      '';
    };
  };

  flake.nixosModules.astrolabe-service-suwayomi = {domain, ...}: {
    systemd.tmpfiles.rules = [
      "d /opt/docker-data/suwayomi 0777 root root -"
    ];

    services.caddy.virtualHosts."suwayomi.${domain}" = {
      extraConfig = "reverse_proxy 127.0.0.1:8085";
    };

    services.restic.backups.s3-main.exclude = [
      "/opt/docker-data/suwayomi/downloads"
    ];
  };

  flake.nixosModules.astrolabe-service-flaresolverr = {...}: {
    # No Caddy or extra firewall ports needed for FlareSolverr
    # since it stays inside the private Docker network.
  };
}
