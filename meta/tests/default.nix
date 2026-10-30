{
  config,
  lib,
  inputs,
  ...
}: let
  testingLib = config.flake.lib.testing;
  testingModule = config.flake.nixosModules.nixos-test;
  hostNames = builtins.attrNames (config.host or {});

  hostSystem = name: config.flake.nixosConfigurations.${name}.config.nixpkgs.hostPlatform.system;

  /*
  Test tiers derived for every host, cheapest first:
    eval        seconds, no build: full system evaluation + `testing.evalChecks`
    inspect     seconds, builds artifacts: verifies /etc, users, PAM, units in a pure sandbox (no KVM needed)
    vm          minutes, KVM: boots the host's real system closure in QEMU with stand-in
                secrets and runs `testing.checks` (storage is virtualised)
    install     slow, KVM: partitions the real Disko layout, installs, boots through the
                real boot loader, then runs the install-tier checks
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
    };

    # The real host plus the testing implementation (stand-ins, no virtualisation):
    # basis for evaluation checks, the install tier, and the interactive VM.
    variant = nixos.extendModules {modules = [testingModule harnessModule];};
    vcfg = variant.config;
    cfg = vcfg.testing;

    failures = testingLib.failedEvalChecks cfg.evalChecks;
    # Forces evaluation of the complete real system (including all NixOS assertions)
    # without making the check depend on building it.
    toplevelDrv = builtins.unsafeDiscardStringContext nixos.config.system.build.toplevel.drvPath;

    eval =
      if failures != []
      then
        throw ''
          host '${name}' failed ${toString (builtins.length failures)} evaluation check(s):
          ${lib.concatMapStringsSep "\n" (f: "  - ${f.name}: ${f.message}") failures}
          Fix the configuration, or opt out per host with `testing.evalChecks.<name>.enable = false;`.''
      else
        pkgs.runCommand "nixconf-eval-${name}" {
          meta.description = "Evaluation tier for host ${name}: system evaluates and essential checks hold.";
        } ''
          echo ${lib.escapeShellArg toplevelDrv} > $out
        '';

    loginUsers = ["root"] ++ builtins.attrNames (lib.filterAttrs (_: u: u.isNormalUser) vcfg.users.users);
    sshd = vcfg.services.openssh;

    inspect =
      pkgs.runCommand "nixconf-inspect-${name}" {
        meta.description = "Artifact inspection tier for host ${name}: validates /etc and system artifacts without KVM.";
      } ''
        etc="${nixos.config.system.build.etc}/etc"
        echo "Validating system artifacts for ${name} at $etc..."

        # 1. Verify filesystem table and shells exist
        if [ ! -e "$etc/fstab" ]; then
          echo "Error: /etc/fstab was not generated!" >&2
          exit 1
        fi
        if [ ! -e "$etc/shells" ]; then
          echo "Error: /etc/shells was not generated!" >&2
          exit 1
        fi

        # 2. Verify PAM directory and login configuration exist
        if [ ! -d "$etc/pam.d" ]; then
          echo "Error: /etc/pam.d was not generated!" >&2
          exit 1
        fi
        if [ ! -e "$etc/pam.d/login" ]; then
          echo "Error: /etc/pam.d/login was not generated!" >&2
          exit 1
        fi

        # 3. Verify sudoers configuration exists
        if [ ! -e "$etc/sudoers" ]; then
          echo "Error: /etc/sudoers was not generated!" >&2
          exit 1
        fi

        # 4. Verify SSH configuration if enabled
        ${lib.optionalString sshd.enable ''
          if [ ! -d "$etc/ssh" ] || [ ! -e "$etc/ssh/sshd_config" ]; then
            echo "Error: sshd_config was not generated!" >&2
            exit 1
          fi
          if [ ! -e "$etc/pam.d/sshd" ]; then
            echo "Error: /etc/pam.d/sshd was not generated!" >&2
            exit 1
          fi
        ''}

        # 5. Verify systemd directory exists
        if [ ! -d "$etc/systemd/system" ]; then
          echo "Error: /etc/systemd/system was not generated!" >&2
          exit 1
        fi

        mkdir -p $out
        echo "Passed artifact inspection for host ${name}" > $out/success
        echo ${lib.escapeShellArg toplevelDrv} >> $out/toplevel
      '';

    vmChecks = testingLib.selectChecks {
      inherit (cfg) checks;
      tier = "vm";
    };
    needsClient = lib.any (c: c.remote) vmChecks;

    vm = inputs.nixpkgs.lib.nixos.runTest {
      name = "nixconf-${name}";
      hostPkgs = pkgs;
      # Same modules and specialArgs as `nixosConfigurations.${name}`; nodes keep
      # instantiating nixpkgs from the host's own `nixpkgs.*` options.
      node.specialArgs = systemArgs.specialArgs;
      nodes =
        {
          machine.imports = systemArgs.modules ++ [testingModule harnessModule];
        }
        // lib.optionalAttrs needsClient {
          client = {
            virtualisation.memorySize = 512;
            documentation.enable = false;
          };
        };
      testScript = {nodes, ...}: ''
        start_all()

        ${testingLib.mkTestScript {
          inherit (nodes.machine.testing) checks;
          tier = "vm";
          label = name;
        }}
      '';
    };

    run = pkgs.writeShellApplication {
      name = "run-${name}-test-vm";
      runtimeInputs = [pkgs.coreutils];
      meta.description = "Interactive VM of host ${name} booted with stand-in secrets.";
      text = ''
        state="''${XDG_RUNTIME_DIR:-/tmp}"
        export NIX_DISK_IMAGE="''${NIX_DISK_IMAGE:-$state/nixconf-${name}-test.qcow2}"
        key="$state/nixconf-test-ssh-key"
        install -m 0600 ${pkgs.writeText "nixconf-test-ssh-key" cfg.credentials.sshPrivateKey} "$key"
        cat >&2 <<EOF
        ${name}: interactive test VM with stand-in secrets (no real secret is decrypted)
          console login : ${lib.concatStringsSep ", " loginUsers} / password '${cfg.credentials.password}'
        ${lib.optionalString (sshd.enable && vcfg.virtualisation.vmVariant.virtualisation.forwardPorts != []) "  ssh           : ssh -p ${toString cfg.vm.sshForwardPort} -i $key -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@localhost\n"}  disk image    : $NIX_DISK_IMAGE (delete it to start fresh)
        EOF
        exec ${vcfg.system.build.vm}/bin/run-${vcfg.networking.hostName}-vm "$@"
      '';
    };
  in
    {
      inherit eval inspect run variant;
      checks = {
        eval = builtins.attrNames cfg.evalChecks;
        inspect = ["passwd" "shadow" "pam" "users" "systemd"];
        vm = map (c: c.name) vmChecks;
        install = map (c: c.name) (testingLib.selectChecks {
          inherit (cfg) checks;
          tier = "install";
        });
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

    cli = pkgs.writeShellApplication {
      name = "nixconf-test";
      runtimeInputs = [pkgs.coreutils];
      excludeShellChecks = ["SC2016"];
      meta.description = "Runs host test tiers (eval, inspect, vm, install) and interactive test VMs.";
      text = ''
        flake="''${NIXCONF_FLAKE:-.}"
        attr="legacyPackages.${system}.hostTests"
        declare -A available=(
          [eval]=${lib.escapeShellArg (toString names)}
          [inspect]=${lib.escapeShellArg (toString (hostsWith "inspect"))}
          [vm]=${lib.escapeShellArg (toString (hostsWith "vm"))}
          [install]=${lib.escapeShellArg (toString (hostsWith "install"))}
          [interactive]=${lib.escapeShellArg (toString (hostsWith "interactive"))}
          [run]=${lib.escapeShellArg (toString names)}
        )

        usage() {
          cat <<'EOF'
        Usage: nix run .#test -- [TIER] [HOST...]

        Tiers (default: eval):
          eval         Evaluate every host and its essential checks; seconds, builds no system.
          inspect      Validate built system artifacts (/etc, users, PAM, units) without KVM.
          vm           Boot hosts in QEMU with stand-in secrets and run their checks (needs KVM).
          install      Partition the Disko layout, install, reboot via the real boot loader (needs KVM, slow).
          interactive  Open the VM test driver REPL for one host.
          run          Boot one host as an interactive VM with stand-in secrets.
          list         Show hosts, available tiers and their checks.

        Without HOST arguments every host providing the tier is tested.
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
            nix eval --raw "$flake#$attr" --apply '
              tests: builtins.concatStringsSep "\n" (map (h: let t = tests.''${h}; in
                h + ": tiers [" + builtins.concatStringsSep " " (builtins.filter (n: t ? ''${n}) ["eval" "inspect" "vm" "install" "interactive" "run"]) + "]\n"
                + builtins.concatStringsSep "\n" (map (k: "  " + k + ": " + builtins.concatStringsSep ", " t.checks.''${k}) (builtins.attrNames t.checks))
              ) (builtins.attrNames tests)) + "\n"'
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
                *" $host "*) targets+=("$flake#$attr.$host.$tier") ;;
                *) echo "Host '$host' does not provide the '$tier' tier (available: ''${available[$tier]:-none})." >&2; exit 1 ;;
              esac
            done
            echo "==> $tier: ''${hosts[*]}" >&2
            nix build --no-link --print-build-logs "''${targets[@]}"
            echo "==> $tier passed: ''${hosts[*]}" >&2
            ;;
          interactive|run)
            if [ "$#" -lt 1 ]; then
              echo "Usage: nix run .#test -- $tier HOST [ARGS...]" >&2
              exit 1
            fi
            host="$1"
            shift
            case " ''${available[$tier]} " in
              *" $host "*) ;;
              *) echo "Host '$host' does not provide the '$tier' tier." >&2; exit 1 ;;
            esac
            warn_kvm
            exec nix run "$flake#$attr.$host.$tier" -- "$@"
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
