{
  inputs,
  self,
  ...
}: let
  cores = 4;
  keyboardLayout = "fr";
in {
  flake.nixosConfigurations.x240 = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.x240];
  };

  flake.nixosModules.x240 = {...}: {
    imports = [
      self.nixosModules.x240-hardware
      self.nixosModules.x240-disk
      self.nixosModules.x240-system
      self.nixosModules.x240-desktop
      self.nixosModules.x240-packages
    ];
  };

  flake.nixosModules.x240-packages = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      curl
      wl-clipboard
      alejandra
      btop
      jq
    ];
  };

  flake.nixosModules.x240-system-features = {...}: {
    imports = [
      self.nixosModules.direnv
      self.nixosModules.wifi-eduroam
      self.nixosModules.git
      self.nixosModules.tack
      self.nixosModules.bw
      self.nixosModules.ssh
    ];
  };

  flake.nixosModules.x240-system = {
    config,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.contracts
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

  flake.nixosModules.x240-desktop-features = {...}: {
    imports = [
      self.nixosModules.dolphin
      self.nixosModules.foot
      self.nixosModules.vivaldi
      self.nixosModules.vscode
    ];
  };

  flake.nixosModules.x240-desktop = {...}: {
    imports = [
      self.nixosModules.fonts
      self.nixosModules.labwc
      self.nixosModules.noctalia
      self.nixosModules.audio
      self.nixosModules.cursor
      self.nixosModules.greetd
      self.nixosModules.x240-desktop-features
    ];

    config.services.xserver.xkb = {
      layout = keyboardLayout;
      variant = "";
    };
  };

  flake.nixosModules.x240-disk = {...}: {
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

  flake.nixosModules.x240-hardware = {
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
}
