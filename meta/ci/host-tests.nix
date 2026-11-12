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
    ciLib = self.lib.ci or self.lib;
    hostTests = config.legacyPackages.hostTests or {};
    hostsWithVm = builtins.attrNames (lib.filterAttrs (_: t: t ? vm) hostTests);
    matrixInclude =
      map (h: {
        host = h;
        hasInstall = hostTests.${h} ? install;
      })
      hostsWithVm;
  in {
    workflow.host-tests = ciLib.fromYAML pkgs ''
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
              default: "vm"
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
        host-tests:
          name: Host Tests (''${{ matrix.host }})
          runs-on: ubuntu-latest
          strategy:
            fail-fast: false
            matrix:
              include: ${builtins.toJSON matrixInclude}
          steps:
            - name: Checkout repository
              uses: actions/checkout@v4

            - name: Enable KVM permissions
              if: |
                (github.event_name != 'workflow_dispatch' || github.event.inputs.host == 'all' || github.event.inputs.host == matrix.host) &&
                (github.event_name != 'workflow_dispatch' || github.event.inputs.tier != 'static')
              run: |
                echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules
                sudo udevadm control --reload-rules
                sudo udevadm trigger --name-match=kvm
                [ -e /dev/kvm ] && sudo chmod 666 /dev/kvm || true

            - name: Install Nix
              if: |
                github.event_name != 'workflow_dispatch' || github.event.inputs.host == 'all' || github.event.inputs.host == matrix.host
              uses: cachix/install-nix-action@v31
              with:
                extra_nix_config: |
                  system-features = nixos-test benchmark big-parallel kvm

            - name: Setup Cachix
              if: |
                github.event_name != 'workflow_dispatch' || github.event.inputs.host == 'all' || github.event.inputs.host == matrix.host
              uses: cachix/cachix-action@v17
              with:
                name: lw-54
                authToken: ''${{ secrets.CACHIX_AUTH_TOKEN }}

            - name: Static Verification (eval & inspect)
              if: |
                (github.event_name != 'workflow_dispatch' || github.event.inputs.host == 'all' || github.event.inputs.host == matrix.host) &&
                (github.event_name == 'workflow_dispatch' && (github.event.inputs.tier == 'all' || github.event.inputs.tier == 'static'))
              run: |
                nix run .#test -- eval "''${{ matrix.host }}"
                nix run .#test -- inspect "''${{ matrix.host }}"

            - name: VM Runtime Tests (vm)
              if: |
                (github.event_name != 'workflow_dispatch' || github.event.inputs.host == 'all' || github.event.inputs.host == matrix.host) &&
                (github.event_name != 'workflow_dispatch' || github.event.inputs.tier == 'all' || github.event.inputs.tier == 'vm')
              run: |
                nix run .#test -- vm "''${{ matrix.host }}"

            - name: Install & Storage Lifecycle Tests (install)
              if: |
                matrix.hasInstall &&
                (github.event_name != 'workflow_dispatch' || github.event.inputs.host == 'all' || github.event.inputs.host == matrix.host) &&
                (github.event_name == 'workflow_dispatch' && (github.event.inputs.tier == 'all' || github.event.inputs.tier == 'install'))
              run: |
                nix run .#test -- install "''${{ matrix.host }}"
    '';
  };
}
