{self, ...}: {
  host.astrolabe = {
    description = "Headless VPS Server (adje.app public edge and core services).";
    configuration = {
      imports = [
        self.nixosModules.astrolabe-hardware
        self.nixosModules.astrolabe-disk
        self.nixosModules.astrolabe-system
        self.nixosModules.astrolabe-services
        self.nixosModules.astrolabe-packages
      ];
    };
    subModules = {
      astrolabe-packages = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          nano
          rsync
          btop
        ];
      };

      astrolabe-services = {config, ...}: {
        imports = [
          self.nixosModules.caddy
          self.nixosModules.authelia
          self.nixosModules.lgtm
          self.nixosModules.restic
          self.nixosModules.snapshot
          self.nixosModules.vaultwarden
          self.nixosModules.ttyd
          self.nixosModules.uchiyomi
          self.nixosModules.copyparty
        ];

        config = {
          reverse-proxy.domain = "adje.app";
          monitoring = {
            server.enable = true;
            scrapes = {
              prometheus.port = config.monitoring.server.prometheus.port;
              loki.port = config.monitoring.server.loki.port;
              grafana.port = config.monitoring.server.grafana.port;
            };
            dashboards.lgtm-health = {
              title = "Monitoring Stack Health";
              folder = "Infrastructure";
              json = self.lib.monitoring.dashboard.mkStackHealthDashboard {};
            };
          };
          persistence.directories = [
            "/var/lib/containers"
          ];
          testing.vm.allowedFailedUnits = [
            "docker-*.service"
          ];
        };
      };

      astrolabe-system = {
        imports = [
          self.nixosModules.sops
          self.nixosModules.rclone
          self.nixosModules.lw
          self.nixosModules.nix
          self.nixosModules.locale
          self.nixosModules.ssh
          self.nixosModules.git
        ];

        config = {
          networking.hostName = "astrolabe";
          system.configurationRevision = self.rev or self.dirtyRev or "unknown";
          system.stateVersion = "25.11";
        };
      };

      astrolabe-disk = {...}: {
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

      astrolabe-hardware = {
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
    };
  };
}
