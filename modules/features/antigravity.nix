{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.antigravity = {lib, ...}: {
    imports = [
      (self.lib.users.mkFeature {
        inherit lib;
        name = "antigravity";
        description = "Antigravity";
        package = pkgs: self.packages.${pkgs.system}.antigravity;
      })
    ];
  };

  flake.nixosModules.antigravity-ide = {lib, ...}: {
    imports = [
      (self.lib.users.mkFeature {
        inherit lib;
        name = "antigravity-ide";
        description = "Antigravity IDE";
        package = pkgs: self.packages.${pkgs.system}.antigravity-ide;
      })
    ];
  };

  flake.nixosModules.antigravity-cli = {lib, ...}: {
    imports = [
      (self.lib.users.mkFeature {
        inherit lib;
        name = "antigravity-cli";
        description = "Antigravity CLI";
        package = pkgs: self.packages.${pkgs.system}.antigravity-cli;
      })
    ];
  };

  perSystem = {pkgs, ...}: {
    packages = {
      antigravity = inputs.antigravity-nix.packages.${pkgs.system}.default;
      antigravity-ide = inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-ide;
      antigravity-cli = inputs.antigravity-nix.packages.${pkgs.system}.google-antigravity-cli;
    };
  };
}
