{inputs, ...}: {
  flake.nixosModules.tack = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.tack.packages.${pkgs.system}.default
    ];
  };
}
