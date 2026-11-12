{
  self,
  lib,
  ...
}: {
  perSystem = {
    pkgs,
    config,
    ...
  }: let
    runnerSystem = "x86_64-linux";
    hostTests = config.legacyPackages.hostTests or {};
    hostsWithVm = builtins.attrNames (lib.filterAttrs (_: t: t ? vm) hostTests);
  in {
    workflow.host-tests = self.lib.fromYAML pkgs ''
      name: Host Verification & VM Tests

      on:
        push:
          branches:
            - main
            - "feat/**"
        workflow_dispatch:
          inputs:
            tier:
              description: "Test tier to execute"
              required: true
              default: "all"
              type: choice
              options:
                - all
                - static
                - vm
                - install
            host:
              description: "Host to test"
              required: true
              default: "all"
              type: choice
              options: ${builtins.toJSON (["all"] ++ hostsWithVm)}

      concurrency:
        group: ''${{ github.workflow }}-''${{ github.ref }}
        cancel-in-progress: true

      permissions:
        contents: write

      jobs:
        vm-tests:
          name: VM Runtime Tests (''${{ matrix.host }})
          runs-on: ubuntu-latest
          strategy:
            fail-fast: false
            matrix:
              host: ${builtins.toJSON hostsWithVm}
          steps:
            - name: Checkout repository
              uses: actions/checkout@v4
            - name: Enable KVM permissions
              run: |
                echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules
                sudo udevadm control --reload-rules
                sudo udevadm trigger --name-match=kvm
                [ -e /dev/kvm ] && sudo chmod 666 /dev/kvm || true
            - name: Install Nix
              uses: cachix/install-nix-action@v31
              with:
                extra_nix_config: |
                  system-features = nixos-test benchmark big-parallel kvm
            - name: Setup Cachix
              uses: cachix/cachix-action@v17
              with:
                name: lw-54
                authToken: ''${{ secrets.CACHIX_AUTH_TOKEN }}
            - name: Run VM test
              run: nix build -L '.#legacyPackages.${runnerSystem}.hostTests.''${{ matrix.host }}.vm'
    '';
  };
}
