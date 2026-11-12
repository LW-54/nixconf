{inputs, ...}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: {
    devenv.shells.default.packages = with pkgs; [
      # Interactive navigation & execution
      fzf
      just
      config.packages.menu

      # Nix utilities & diffing
      nvd
      nix-output-monitor
      alejandra
      deadnix
      statix

      # Secrets management
      sops
      age

      # Pinning & VCS
      inputs.tack.packages.${pkgs.stdenv.hostPlatform.system}.default
      git
      jq
    ];
  };
}
