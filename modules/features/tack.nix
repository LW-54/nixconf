{inputs, ...}: {
  flake.nixosModules.tack = {pkgs, ...}: {
    environment.systemPackages = [
      inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
