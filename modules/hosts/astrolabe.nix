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

      astrolabe-services = {...}: {
        imports = [
          self.nixosModules.caddy
          self.nixosModules.restic
          self.nixosModules.vaultwarden
          self.nixosModules.ttyd
        ];

        config = {
          reverse-proxy.domain = "adje.app";
          services.resticBackup.repository = "s3:https://s3.eu-central-003.backblazeb2.com/cyclostyle-docker";
        };
      };

      astrolabe-system = {
        imports = [
          self.nixosModules.contracts
          self.nixosModules.sops
          self.nixosModules.lw
          self.nixosModules.cgroups
          self.nixosModules.nix
          self.nixosModules.locale
          self.nixosModules.ssh
          self.nixosModules.git
        ];

        config = {
          networking.hostName = "astrolabe";
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
