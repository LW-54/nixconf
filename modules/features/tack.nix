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

  # Parallel usage section injected into the tack feature page
  docs.sections."features/tack".usage = {
    order = 80;
    content = ''
      ## Usage

      Inputs are pinned in `.tack/pins.toml` and locked in `.tack/pins.lock.json`; `flake.nix` imports them through `import ./.tack`,
      decoupling external inputs from repository code while keeping updates deterministic.

      ```bash
      # Update all pinned inputs
      tack update

      # Update a specific pinned input
      tack update nixpkgs

      # Add a new input pin
      tack add github:owner/repo

      # Remove an input pin
      tack rm repo
      ```
    '';
  };
}
