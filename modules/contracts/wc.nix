{self, ...}: {
  flake.nixosModules.wc = self.nixosModules.uwsm;
}
