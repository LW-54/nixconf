{ self, inputs, ... }: {
  flake.nixosConfigurations.x240 = inputs.nixpkgs.lib.nixosSystem {
    modules = [ self.nixosModules.x240Config ];
  };

  flake.nixosModules.x240Config = { pkgs, config, ... }: {
    imports = [
      self.nixosModules.x240Hardware
      self.nixosModules.x240Boot
      self.nixosModules.x240Desktop
      self.nixosModules.x240Resources

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

    networking.hostName = "x240";
    networking.networkmanager.enable = true;

    environment.systemPackages = with pkgs; [ curl ];

    bitwarden.users.${config.users.defaultUser.name}.sshAgent.enable = true;

    system.stateVersion = "25.11"; 
    
  };
}




