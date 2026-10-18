{self, ...}: {
  flake.nixosModules.contracts = {
    imports = [
      self.nixosModules.users
      self.nixosModules.persistence
      self.nixosModules.secrets
      self.nixosModules.wc
      self.nixosModules.reverse-proxy
      self.nixosModules.backup
    ];
  };
}
