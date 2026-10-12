{ self, ... }:

{
  flake.nixosModules.contracts = {
    imports = [
      self.nixosModules.users
      self.nixosModules.persistence
      self.nixosModules.secrets
    ];
  };
}