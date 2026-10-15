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
      self.nixosModules.direnv
      self.nixosModules.locale
      self.nixosModules.wifi-eduroam
      self.nixosModules.fonts

      self.nixosModules.labwc
      self.nixosModules.noctalia
      self.nixosModules.noctalia-greeter
      self.nixosModules.tack
      self.nixosModules.cosmic
      self.nixosModules.dolphin
      self.nixosModules.foot

      self.nixosModules.git
      self.nixosModules.vscode
      self.nixosModules.vivaldi
      self.nixosModules.bitwarden
    ];

    networking.hostName = "x240";
    networking.networkmanager.enable = true;

    environment.systemPackages = with pkgs; [
      curl
      wl-clipboard
    ];

    bitwarden.users.${config.users.defaultUser.name}.sshAgent.enable = true;

    system.configurationRevision = self.rev or self.dirtyRev or "unknown";
    system.stateVersion = "25.11";
  };
}
