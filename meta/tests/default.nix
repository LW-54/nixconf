{
  config,
  lib,
  inputs,
  ...
}: let
  testingLib = config.flake.lib.testing;
  testingModule = config.flake.nixosModules.testing;
  hostNames = builtins.attrNames (config.host or {});

  hostSystem = name: config.flake.nixosConfigurations.${name}.config.nixpkgs.hostPlatform.system;

  /*
  Test tiers derived for every host, cheapest first:
    eval        seconds, no build: full system evaluation + all namespaced `evalChecks`
    inspect     seconds, builds artifacts: verifies /etc and system artifacts in a pure sandbox (no KVM needed)
    vm          minutes, KVM: boots host in QEMU with stand-in secrets and runs all `vmChecks`
    install     slow, KVM: Disko layout, nixos-install, bootloader, runs all `vmChecks` + `installChecks`
    interactive the `vm` test driver as a Python REPL (`start_all()`, `machine.shell_interact()`)
    run         plain interactive VM of the host with stand-in secrets
  */
  mkHostTests = {
    pkgs,
    name,
  }: let
    nixos = config.flake.nixosConfigurations.${name};
    systemArgs = config.flake.lib.host.systemArgs.${name};

    harnessModule = {
      testing.name = name;
      testing.enable = true;
    };

    variant = nixos.extendModules {modules = [harnessModule];};
    vcfg = variant.config;
    cfg = vcfg.testing;

    failures = testingLib.failedEvalChecks cfg;
    toplevelDrv = builtins.unsafeDiscardStringContext nixos.config.system.build.toplevel.drvPath;

    eval =
      if failures != []
      then
        throw ''
          host '${name}' failed ${toString (builtins.length failures)} evaluation check(s):
          ${lib.concatMapStringsSep "\n" (f: "  - ${f.name}: ${f.message}") failures}
          Fix the configuration, or opt out per host with `testing.<namespace>.evalChecks.<name>.enable = false;`.''
      else
        pkgs.runCommand "nixconf-eval-${name}" {
          meta.description = "Evaluation tier for host ${name}: system evaluates and essential checks hold.";
        } ''
          echo ${lib.escapeShellArg toplevelDrv} > $out
        '';

    loginUsers = ["root"] ++ builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser) vcfg.users.users);
    sshd = vcfg.services.openssh;
    inspectScript = testingLib.mkInspectScript cfg;

    inspect =
      pkgs.runCommand "nixconf-inspect-${name}" {
        meta.description = "Artifact inspection tier for host ${name}: validates /etc and system artifacts without KVM.";
      } ''
        etc="${nixos.config.system.build.etc}/etc"
        echo "Validating system artifacts for ${name} at $etc..."

        ${inspectScript}

        mkdir -p $out
        echo "Passed artifact inspection for host ${name}" > $out/success
        echo ${lib.escapeShellArg toplevelDrv} >> $out/toplevel
      '';

    vm = inputs.nixpkgs.lib.nixos.runTest {
      name = "nixconf-${name}";
      hostPkgs = pkgs;
      node.specialArgs = systemArgs.specialArgs;
      nodes.machine.imports = systemArgs.modules ++ [harnessModule];
      testScript = {nodes, ...}: ''
        start_all()

        ${testingLib.mkVmScript {
          inherit (nodes.machine.config) testing;
          label = name;
        }}
      '';
    };

    snakeoil = import "${inputs.nixpkgs}/nixos/tests/ssh-keys.nix" {
      inherit lib;
      writeText = _: text: text;
    };

    run = pkgs.writeShellApplication {
      name = "run-${name}-test-vm";
      runtimeInputs = [pkgs.coreutils];
      meta.description = "Interactive VM of host ${name} booted with stand-in secrets.";
      text = ''
        state="''${XDG_RUNTIME_DIR:-/tmp}"
        export NIX_DISK_IMAGE="''${NIX_DISK_IMAGE:-$state/nixconf-${name}-test.qcow2}"
        key="$state/nixconf-test-ssh-key"
        install -m 0600 ${pkgs.writeText "nixconf-test-ssh-key" snakeoil.snakeOilPrivateKey} "$key"
        cat >&2 <<EOF
        ${name}: interactive test VM with stand-in secrets (no real secret is decrypted)
          console login : ${lib.concatStringsSep ", " loginUsers} / password 'test'
        ${lib.optionalString (sshd.enable && vcfg.virtualisation.vmVariant.virtualisation.forwardPorts != []) "  ssh           : ssh -p ${toString cfg.vm.sshForwardPort} -i $key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost\n"}  disk image    : $NIX_DISK_IMAGE (delete it to start fresh)
        EOF
        exec ${vcfg.system.build.vm}/bin/run-${vcfg.networking.hostName}-vm "$@"
      '';
    };
  in
    {
      inherit eval inspect run variant;
      checks = {
        eval = map (c: c.name) (testingLib.collectChecks "evalChecks" cfg);
        inspect = map (c: c.qualifiedName) (testingLib.collectChecks "inspectChecks" cfg);
        vm = map (c: c.qualifiedName) (testingLib.collectChecks "vmChecks" cfg);
        install = map (c: c.qualifiedName) ((testingLib.collectChecks "vmChecks" cfg) ++ (testingLib.collectChecks "installChecks" cfg));
      };
    }
    // lib.optionalAttrs cfg.vm.enable {
      inherit vm;
      interactive = vm.driverInteractive;
    }
    // lib.optionalAttrs (cfg.install.enable && vcfg.system.build ? installTest) {
      install = vcfg.system.build.installTest;
    };
in {
  perSystem = {
    pkgs,
    system,
    ...
  }: let
    names = lib.filter (name: hostSystem name == system) hostNames;
    tests = lib.genAttrs names (name: mkHostTests {inherit pkgs name;});
    hostsWith = tier: lib.filter (name: tests.${name} ? ${tier}) names;

    scenarios = lib.mapAttrs (sName: s:
      inputs.nixpkgs.lib.nixos.runTest {
        name = "nixconf-scenario-${sName}";
        hostPkgs = pkgs;
        nodes = s.nodes;
        testScript = s.testScript;
      }) (lib.filterAttrs (_: s: s.enable) (config.test.scenarios or {}));
    scenarioNames = builtins.attrNames scenarios;

    cli = pkgs.writeShellApplication {
      name = "nixconf-test";
      runtimeInputs = [pkgs.coreutils];
      excludeShellChecks = ["SC2016"];
      meta.description = "Runs test tiers (eval, inspect, vm, install), multi-node scenarios, and interactive test VMs.";
      text = ''
        flake="''${NIXCONF_FLAKE:-.}"
        hostAttr="legacyPackages.${system}.hostTests"
        scenAttr="legacyPackages.${system}.scenarios"
        declare -A available=(
          [eval]=${lib.escapeShellArg (toString names)}
          [inspect]=${lib.escapeShellArg (toString (hostsWith "inspect"))}
          [vm]=${lib.escapeShellArg (toString (hostsWith "vm"))}
          [install]=${lib.escapeShellArg (toString (hostsWith "install"))}
          [interactive]=${lib.escapeShellArg (toString ((hostsWith "interactive") ++ scenarioNames))}
          [run]=${lib.escapeShellArg (toString names)}
          [scenario]=${lib.escapeShellArg (toString scenarioNames)}
        )

        usage() {
          cat <<'EOF'
        Usage: nix run .#test -- [TIER|scenario] [TARGET...]

        Tiers (default: eval):
          eval         Evaluate every host and its essential checks; seconds, builds no system.
          inspect      Validate built system artifacts (/etc, users, PAM, units) without KVM.
          vm           Boot hosts in QEMU with stand-in secrets and run their vmChecks (needs KVM).
          install      Partition Disko, install, reboot, run vmChecks + installChecks (needs KVM, slow).
          scenario     Run arbitrary multi-node virtual network scenarios.
          interactive  Open test driver REPL for one host or scenario.
          run          Boot one host as an interactive VM with stand-in secrets.
          list         Show hosts, scenarios, available tiers and their checks.

        Without TARGET arguments every host or scenario providing the tier is tested.
        Set NIXCONF_FLAKE to test another checkout (default: current directory).
        EOF
        }

        warn_kvm() {
          if [ ! -w /dev/kvm ]; then
            echo "warning: /dev/kvm is not accessible; VM tiers need a builder with system-features 'kvm nixos-test'." >&2
          fi
        }

        tier="''${1:-eval}"
        [ "$#" -gt 0 ] && shift

        case "$tier" in
          -h|--help|help)
            usage
            ;;
          list)
            echo "==> Host Tests:"
            nix eval --raw "$flake#$hostAttr" --apply '
              tests: builtins.concatStringsSep "\n" (map (h: let t = tests.''${h}; in
                h + ": tiers [" + builtins.concatStringsSep " " (builtins.filter (n: t ? ''${n}) ["eval" "inspect" "vm" "install" "interactive" "run"]) + "]\n"
                + builtins.concatStringsSep "\n" (map (k: "  " + k + ": " + builtins.concatStringsSep ", " t.checks.''${k}) (builtins.attrNames t.checks))
              ) (builtins.attrNames tests)) + "\n"'
            ${lib.optionalString (scenarioNames != []) ''
          echo "==> Scenarios: ${toString scenarioNames}"
        ''}
            ;;
          eval|inspect|vm|install)
            read -r -a hosts <<< "''${available[$tier]}"
            [ "$#" -gt 0 ] && hosts=("$@")
            if [ "''${#hosts[@]}" -eq 0 ]; then
              echo "No host provides the '$tier' tier." >&2
              exit 1
            fi
            case "$tier" in
              vm|install) warn_kvm ;;
              *) ;;
            esac
            targets=()
            for host in "''${hosts[@]}"; do
              case " ''${available[$tier]} " in
                *" $host "*) targets+=("$flake#$hostAttr.$host.$tier") ;;
                *) echo "Host '$host' does not provide the '$tier' tier (available: ''${available[$tier]:-none})." >&2; exit 1 ;;
              esac
            done
            echo "==> $tier: ''${hosts[*]}" >&2
            nix build --no-link --print-build-logs "''${targets[@]}"
            echo "==> $tier passed: ''${hosts[*]}" >&2
            ;;
          scenario)
            read -r -a scens <<< "''${available[scenario]}"
            [ "$#" -gt 0 ] && scens=("$@")
            if [ "''${#scens[@]}" -eq 0 ]; then
              echo "No multi-node scenario tests are declared." >&2
              exit 1
            fi
            warn_kvm
            targets=()
            for sc in "''${scens[@]}"; do
              case " ''${available[scenario]} " in
                *" $sc "*) targets+=("$flake#$scenAttr.$sc") ;;
                *) echo "Scenario '$sc' is not defined (available: ''${available[scenario]:-none})." >&2; exit 1 ;;
              esac
            done
            echo "==> scenario: ''${scens[*]}" >&2
            nix build --no-link --print-build-logs "''${targets[@]}"
            echo "==> scenario passed: ''${scens[*]}" >&2
            ;;
          interactive)
            if [ "$#" -lt 1 ]; then
              echo "Usage: nix run .#test -- interactive TARGET [ARGS...]" >&2
              exit 1
            fi
            target="$1"
            shift
            warn_kvm
            case " ''${available[interactive]} " in
              *" $target "*)
                case " ''${available[vm]} " in
                  *" $target "*) exec nix run "$flake#$hostAttr.$target.interactive" -- "$@" ;;
                  *) exec nix run "$flake#$scenAttr.$target.driverInteractive" -- "$@" ;;
                esac
                ;;
              *)
                echo "Target '$target' is neither an interactive host nor a scenario." >&2
                exit 1
                ;;
            esac
            ;;
          run)
            if [ "$#" -lt 1 ]; then
              echo "Usage: nix run .#test -- run HOST [ARGS...]" >&2
              exit 1
            fi
            host="$1"
            shift
            case " ''${available[run]} " in
              *" $host "*) ;;
              *) echo "Host '$host' does not provide the 'run' tier." >&2; exit 1 ;;
            esac
            warn_kvm
            exec nix run "$flake#$hostAttr.$host.run" -- "$@"
            ;;
          *)
            echo "Unknown tier: $tier" >&2
            usage >&2
            exit 1
            ;;
        esac
      '';
    };
  in {
    legacyPackages.hostTests = tests;
    legacyPackages.scenarios = scenarios;

    checks =
      lib.concatMapAttrs (name: t: {
        "eval-${name}" = t.eval;
        "inspect-${name}" = t.inspect;
      })
      tests;

    packages.test = cli;

    apps.test = {
      type = "app";
      program = lib.getExe cli;
      meta.description = cli.meta.description;
    };
  };
}
