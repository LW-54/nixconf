{self, ...}: let
  cores = 4;
  keyboardLayout = "fr";
in {
  host.x240 = {
    description = "ThinkPad Laptop Workstation (Desktop graphical workstation).";
    configuration = {
      imports = [
        self.nixosModules.x240-hardware
        self.nixosModules.x240-disk
        self.nixosModules.x240-system
        self.nixosModules.x240-desktop
        self.nixosModules.x240-packages
      ];
    };
    subModules = {
      x240-packages = {pkgs, ...}: {
        environment.systemPackages = with pkgs; [
          curl
          wl-clipboard
          alejandra
          btop
          jq
        ];
      };

      x240-system-features = {...}: {
        imports = [
          self.nixosModules.direnv
          self.nixosModules.wifi-eduroam
          self.nixosModules.git
          self.nixosModules.tack
          self.nixosModules.bw
          self.nixosModules.ssh
          self.nixosModules.cgroups
        ];
      };

      x240-system = {
        config,
        lib,
        ...
      }: {
        imports = [
          self.nixosModules.contracts
          self.nixosModules.sops
          self.nixosModules.lw
          self.nixosModules.hjem
          self.nixosModules.nix
          self.nixosModules.locale
          self.nixosModules.x240-system-features
        ];

        config = {
          console.keyMap = keyboardLayout;
          networking.hostName = "x240";
          networking.networkmanager.enable = true;
          nix.settings = {
            build-cores = cores - 1;
            cores = cores - 1;
          };
          system.configurationRevision = self.rev or self.dirtyRev or "unknown";
          system.stateVersion = "25.11";
        };
      };

      x240-desktop-features = {...}: {
        imports = [
          self.nixosModules.dolphin
          self.nixosModules.foot
          self.nixosModules.vivaldi
          self.nixosModules.vscode
          self.nixosModules.antigravity-ide
        ];
      };

      x240-desktop = {...}: {
        imports = [
          self.nixosModules.uwsm
          self.nixosModules.fonts
          self.nixosModules.labwc
          self.nixosModules.noctalia
          self.nixosModules.audio
          self.nixosModules.cursor
          self.nixosModules.greetd
          self.nixosModules.x240-desktop-features
        ];

        config = {
          wayland.enable = true;
          environment.sessionVariables = {
            XKB_DEFAULT_LAYOUT = keyboardLayout;
            XKB_DEFAULT_VARIANT = "";
          };
        };
      };

      x240-disk = {...}: {
        imports = [
          self.nixosModules.disko
          self.nixosModules.impermanence
        ];

        config =
          self.lib.disko.mkLayout {
            device = "/dev/disk/by-id/ata-Samsung_SSD_850_EVO_500GB_S21JNSAG400208P";
            swapSize = "16G";
            swapResume = true;
          }
          // {
            zramSwap.enable = true;
          };
      };

      x240-hardware = {
        config,
        lib,
        modulesPath,
        ...
      }: {
        imports = [(modulesPath + "/installer/scan/not-detected.nix")];

        config = {
          boot.initrd.availableKernelModules = [
            "xhci_pci"
            "ehci_pci"
            "ahci"
            "usb_storage"
            "sd_mod"
            "rtsx_pci_sdmmc"
          ];
          boot.initrd.kernelModules = [];
          boot.kernelModules = [];
          boot.extraModulePackages = [];
          boot.loader.grub = {
            enable = true;
            useOSProber = true;
          };
          hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
          nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
        };
      };
    };
  };
}
