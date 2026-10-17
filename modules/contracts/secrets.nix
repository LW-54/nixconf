{self, ...}: {
  flake.nixosModules.secrets = {imports = [self.nixosModules.sops-nix];};
}
