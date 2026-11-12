{self, ...}: {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    runnerSystem = "x86_64-linux";
    targets = builtins.attrNames (self.lib.collectBuildables runnerSystem);
  in {
    legacyPackages.ciBuildables = self.lib.collectBuildables system;

    workflow.build = self.lib.fromYAML pkgs ''
      name: CI & Binary Cache Push

      on:
        push:
          branches: [main]
        pull_request:
          branches: [main]
        workflow_dispatch: {}

      concurrency:
        group: ''${{ github.workflow }}-''${{ github.ref }}
        cancel-in-progress: true

      jobs:
        check:
          name: Flake Checks
          runs-on: ubuntu-latest
          steps:
            - name: Checkout repository
              uses: actions/checkout@v4
            - name: Install Nix
              uses: cachix/install-nix-action@v31
            - name: Setup Cachix
              uses: cachix/cachix-action@v17
              with:
                name: lw-54
                authToken: ''${{ secrets.CACHIX_AUTH_TOKEN }}
            - name: Run flake check
              run: nix flake check

        build:
          name: Build & Cache (''${{ matrix.target }})
          needs: [check]
          runs-on: ubuntu-latest
          strategy:
            fail-fast: false
            matrix:
              target: ${builtins.toJSON targets}
          steps:
            - name: Checkout repository
              uses: actions/checkout@v4
            - name: Install Nix
              uses: cachix/install-nix-action@v31
            - name: Setup Cachix
              uses: cachix/cachix-action@v17
              with:
                name: lw-54
                authToken: ''${{ secrets.CACHIX_AUTH_TOKEN }}
            - name: Build derivation
              run: nix build -L '.#legacyPackages.${runnerSystem}.ciBuildables."''${{ matrix.target }}"'
    '';
  };
}
