{
  self,
  inputs,
  ...
}: {
  flake.nixosConfigurations.x240 = inputs.nixpkgs.lib.nixosSystem {
    modules = [self.nixosModules.x240Config];
  };

  flake.nixosModules.x240Config = {lib, ...}: {
    imports = [
      self.nixosModules.x240Hardware
      self.nixosModules.x240Boot
      self.nixosModules.x240Storage
      self.nixosModules.impermanence
      self.nixosModules.x240System
    ];
  };

  flake.nixosModules.x240System = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      self.nixosModules.x240Desktop
      self.nixosModules.x240Resources

      self.nixosModules.contracts

      self.nixosModules.nix
      self.nixosModules.sops-tools
      self.nixosModules.direnv
      self.nixosModules.locale
      self.nixosModules.wifi-eduroam
      self.nixosModules.fonts

      self.nixosModules.labwc
      self.nixosModules.uwsm
      self.nixosModules.noctalia
      self.nixosModules.noctalia-greeter
      self.nixosModules.keyring
      self.nixosModules.tack
      self.nixosModules.dolphin
      self.nixosModules.foot

      self.nixosModules.git
      self.nixosModules.vscode
      self.nixosModules.vivaldi
      self.nixosModules.bitwarden-desktop
      self.nixosModules.bw
    ];

    networking.hostName = "x240";
    networking.networkmanager.enable = true;
    services.displayManager.defaultSession = "labwc-uwsm";

    environment.systemPackages = with pkgs; [
      curl
      wl-clipboard
      alejandra
    ];

    system.configurationRevision = self.rev or self.dirtyRev or "unknown";
    system.stateVersion = "25.11";
  };
}
