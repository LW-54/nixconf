{ self, inputs, ... }: {
  flake.nixosConfigurations.x240 = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.x240Config ];
  };

  flake.nixosModules.x240Config = { pkgs, config, ... }: {
    imports = [
      self.nixosModules.x240Hardware

      self.nixosModules.contracts
      
      self.nixosModules.nix
      self.nixosModules.direnv
      self.nixosModules.locale
      self.nixosModules.wifi-eduroam

      self.nixosModules.cosmic
      
      self.nixosModules.git
      self.nixosModules.vscode
      self.nixosModules.helium
      self.nixosModules.bitwarden
    ];

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.useOSProber = true;
    
    networking.hostName = "x240";
    networking.networkmanager.enable = true;

    environment.systemPackages = with pkgs; [
          curl
    ];

    bitwarden.users.${config.users.defaultUser.name}.sshAgent.enable = true;

    nix.settings = { # Fixed to 3 for x240 (4 cores - 1).
      build-cores = 3;
      cores = 3;
      trusted-users = [ config.users.defaultUser.name ];
    };

    console.keyMap = "fr";
    services.xserver.xkb = { layout = "fr"; variant = ""; };

    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    system.stateVersion = "25.11"; 
    
  };
}




