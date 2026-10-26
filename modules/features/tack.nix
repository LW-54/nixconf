{inputs, ...}: {
  feature.tack = {
    description = "Flake input pinning and lockfile orchestration tool.";
    modules = {
      tack = {pkgs, ...}: {
        environment.systemPackages = [
          inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
      };
    };
  };
}
