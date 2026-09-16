{ self, inputs, ... }: {
  flake.nixosConfigurations.x240 = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.x240Config ];
  };

  flake.nixosModules.x240Config = { pkgs, lib, ... }: {
    imports = [
      self.nixosModules.x240Hardware
      
      self.nixosModules.nix
      self.nixosModules.user

      self.nixosModules.gnome
      self.nixosModules.cosmic
      
      self.nixosModules.git
      self.nixosModules.vscode
      self.nixosModules.helium
      self.nixosModules.bitwarden
      self.nixosModules.obsidian
      self.nixosModules.mdbase-connect
    ];

    boot.loader.grub.enable = true;
    boot.loader.grub.device = "/dev/sda";
    boot.loader.grub.useOSProber = true;
    
    networking.hostName = "x240";
    networking.networkmanager.enable = true;

    time.timeZone = "Europe/Paris";
    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
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

    environment.systemPackages = with pkgs; [
      yt-dlp
      ffmpeg
      curl
    ];

    system.stateVersion = "25.11"; 
  };
}
