{self, ...}: {
  flake.nixosModules.secrets = self.nixosModules.sops;
}
