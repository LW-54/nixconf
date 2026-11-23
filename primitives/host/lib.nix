{
  lib,
  config,
  ...
}: let
  /**
  Builds dummy arguments for safely unrolling module lambdas in pure evaluation.
  */
  mkDummyArgs = {
    lib,
    self ? (config.flake or {}),
    inputs ? (config.flake.inputs or {}),
  }: {
    inherit lib;
    pkgs = {};
    config = {};
    options = {};
    modulesPath = "";
    inherit self inputs;
  };

  /**
  Safely evaluates a module if it is a function, catching any evaluation errors.
  */
  safeCallModule = {
    dummyArgs,
    m,
  }:
    if builtins.isFunction m
    then let
      fArgs = builtins.functionArgs m;
      args =
        if fArgs == {}
        then dummyArgs
        else lib.mapAttrs (argName: _: dummyArgs.${argName} or {}) fArgs;
      res = builtins.tryEval (m args);
    in
      if res.success
      then res.value
      else {}
    else m;

  /**
  Recursively expands a module's imports list to collect all nested module files.
  */
  expandModule = {
    dummyArgs,
    m,
  }: let
    unwrapped = safeCallModule {
      inherit dummyArgs;
      inherit m;
    };
  in
    if builtins.isAttrs unwrapped
    then
      (
        if unwrapped ? _file
        then [unwrapped._file]
        else []
      )
      ++ (
        if unwrapped ? imports
        then
          builtins.concatMap (importItem:
            expandModule {
              inherit dummyArgs;
              m = importItem;
            })
          unwrapped.imports
        else []
      )
    else [];

  /**
  Collects all NixOS module names imported across a host's configuration and subModules.
  Accepts either a host attribute set directly (`h`) or `{ host, self, inputs }`.
  */
  collectHostImportedModules = arg: let
    host =
      if builtins.isAttrs arg && arg ? host
      then arg.host
      else arg;
    self =
      if builtins.isAttrs arg && arg ? self
      then arg.self
      else (config.flake or {});
    inputs =
      if builtins.isAttrs arg && arg ? inputs
      then arg.inputs
      else (config.flake.inputs or {});
    dummyArgs = mkDummyArgs {
      inherit lib self inputs;
    };
    rawFiles =
      (expandModule {
        inherit dummyArgs;
        m = host.configuration or {};
      })
      ++ (builtins.concatMap (subDef:
        expandModule {
          inherit dummyArgs;
          m = subDef;
        }) (builtins.attrValues (host.subModules or {})));

    extractModuleName = f: let
      s = builtins.unsafeDiscardStringContext (toString f);
    in
      if lib.hasInfix "#nixosModules." s
      then lib.last (lib.splitString "#nixosModules." s)
      else if lib.hasInfix "flake.nixosModules." s
      then lib.last (lib.splitString "flake.nixosModules." s)
      else null;
  in
    lib.unique (lib.filter (n: n != null) (map extractModuleName rawFiles));

  /**
  Generates contract fulfillment and conflict prevention evalChecks for a host.
  */
  checkContractFulfillment = {
    name,
    host,
    config,
  }: let
    hCfg = config.flake.nixosConfigurations.${name} or null;
    allContracts = config.contract or {};
    allImpls = config.implementation or {};
    importedModuleNames = collectHostImportedModules host;
  in
    lib.mapAttrs' (cName: _: let
      isEnabled = (hCfg != null) && (hCfg.config.${cName}.enable or false == true);
      implsForContract = lib.filterAttrs (_: impl: (impl.contract or "") == cName) allImpls;
      activeImpls = lib.filter (iName: builtins.elem iName importedModuleNames) (builtins.attrNames implsForContract);
      hasImpl = builtins.length activeImpls > 0;
      noConflict = builtins.length activeImpls <= 1;
    in
      lib.nameValuePair "contract-${cName}" {
        what = "Contract fulfillment on host";
        shortDescription = "Contract '${cName}' fulfillment check for host '${name}'.";
        evalChecks = {
          fulfilledIfEnabled = (!isEnabled) || hasImpl;
          noConflictingImplementations = (!isEnabled) || noConflict;
        };
      })
    allContracts;

  /**
  Builds the progressive test tiers (eval, inspect, vm, install, interactive, run) for a host configuration.
  */
  mkHostTests = {
    pkgs,
    name,
    config,
    inputs,
  }: let
    nixos = config.flake.nixosConfigurations.${name};
    systemArgs = config.flake.lib.host.systemArgs.${name};
    testingLib = config.flake.lib.testing;

    harnessModule = {
      testing.name = name;
      testing.enable = true;
    };

    # Use the base host config directly for eval & inspect tiers so we never force a
    # second full NixOS evaluation (`variant = nixos.extendModules`) during `nix flake check`.
    evalCfg = nixos.config.testing;

    variant = nixos.extendModules {modules = [harnessModule];};
    vcfg = variant.config;
    cfg = vcfg.testing;

    failures = testingLib.failedEvalChecks evalCfg;
    nixosAssertionFailures = map (a: a.message) (lib.filter (a: !a.assertion) nixos.config.assertions);

    assertEval =
      if failures != []
      then
        throw ''
          host '${name}' failed ${toString (builtins.length failures)} evaluation check(s):
          ${lib.concatMapStringsSep "\n" (f: "  - ${f.name}: ${f.message}") failures}
          Fix the configuration, or opt out per host with `testing.<namespace>.evalChecks.<name>.enable = false;`.''
      else if nixosAssertionFailures != []
      then
        throw ''
          host '${name}' failed ${toString (builtins.length nixosAssertionFailures)} NixOS assertion(s):
          ${lib.concatMapStringsSep "\n" (m: "  - ${m}") nixosAssertionFailures}''
      else true;

    evalCheckNames = map (c: c.qualifiedName) (testingLib.collectChecks "evalChecks" evalCfg);

    eval = assert assertEval;
      pkgs.runCommandLocal "nixconf-eval-${name}" {
        meta.description = "Evaluation tier for host ${name}: system assertions and essential evalChecks hold without instantiating toplevel derivations.";
      } ''
        printf '%s\n' ${lib.escapeShellArgs (["host=${name}"] ++ evalCheckNames)} > $out
      '';

    inspectScript = testingLib.mkInspectScript evalCfg;

    inspect = assert assertEval;
      pkgs.runCommand "nixconf-inspect-${name}" {
        meta.description = "Artifact inspection tier for host ${name}: validates /etc and system-path artifacts without KVM.";
      } ''
        etc="${nixos.config.system.build.etc}/etc"
        sw="${nixos.config.system.path}"
        echo "Validating system artifacts for ${name} at $etc..."

        ${inspectScript}

        mkdir -p $out
        echo "Passed artifact inspection for host ${name}" > $out/success
      '';

    inspectNamespaces = lib.unique (map (c: c.namespace) (testingLib.collectChecks "inspectChecks" evalCfg));
    inspectByNamespace = lib.genAttrs inspectNamespaces (ns:
      assert assertEval;
        pkgs.runCommand "nixconf-inspect-${name}-${ns}" {
          meta.description = "Targeted artifact inspection tier (${ns}) for host ${name}.";
        } ''
          etc="${nixos.config.system.build.etc}/etc"
          sw="${nixos.config.system.path}"
          echo "Validating ${ns} artifacts for ${name} at $etc..."

          ${testingLib.mkFilteredInspectScript {
            testing = evalCfg;
            namespace = ns;
          }}

          mkdir -p $out
          echo "Passed ${ns} inspection for host ${name}" > $out/success
        '');

    vmNamespaces = lib.unique (map (c: c.namespace) (testingLib.collectChecks "vmChecks" evalCfg));
    vmByNamespace = lib.genAttrs vmNamespaces (ns:
      assert assertEval;
        inputs.nixpkgs.lib.nixos.runTest {
          name = "nixconf-${name}-${ns}";
          hostPkgs = pkgs;
          node.pkgsReadOnly = false;
          node.specialArgs = systemArgs.specialArgs;
          nodes.machine.imports = systemArgs.modules ++ [harnessModule];
          testScript = {nodes, ...}: ''
            start_all()

            ${testingLib.mkVmScript {
              inherit (nodes.machine.config) testing;
              label = "${name}/${ns}";
              namespaces = [ns];
            }}
          '';
        });

    vm = assert assertEval;
      inputs.nixpkgs.lib.nixos.runTest {
        name = "nixconf-${name}";
        hostPkgs = pkgs;
        node.pkgsReadOnly = false;
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

    run = assert assertEval;
      pkgs.writeShellApplication {
        name = "run-${name}-test-vm";
        runtimeInputs = [pkgs.coreutils];
        meta.description = "Interactive VM of host ${name} booted with stand-in secrets.";
        text = ''
          state="''${XDG_RUNTIME_DIR:-/tmp}"
          export NIX_DISK_IMAGE="''${NIX_DISK_IMAGE:-$state/nixconf-${name}-test.qcow2}"
          ${cfg.interactiveInit}
          cat >&2 <<EOF
          ${name}: interactive test VM with stand-in secrets (no real secret is decrypted)
          ${lib.concatStringsSep "\n" cfg.interactiveNotes}
            disk image    : $NIX_DISK_IMAGE (delete it to start fresh)
          EOF
          exec ${vcfg.system.build.vm}/bin/run-${vcfg.networking.hostName}-vm "$@"
        '';
      };
  in
    {
      inherit eval inspect inspectByNamespace run variant;
      checks = {
        eval = map (c: c.name) (testingLib.collectChecks "evalChecks" evalCfg);
        inspect = map (c: c.qualifiedName) (testingLib.collectChecks "inspectChecks" evalCfg);
        vm = map (c: c.qualifiedName) (testingLib.collectChecks "vmChecks" evalCfg);
        install = map (c: c.qualifiedName) ((testingLib.collectChecks "vmChecks" evalCfg) ++ (testingLib.collectChecks "installChecks" evalCfg));
      };
    }
    // lib.optionalAttrs evalCfg.vm.enable {
      inherit vm vmByNamespace;
      interactive = vm.driverInteractive;
    }
    // lib.optionalAttrs (evalCfg.install.enable && nixos.config.system.build ? installTest) {
      install = assert assertEval; vcfg.system.build.installTest;
    };
in {
  _module.args = {
    hostLib = {
      inherit
        collectHostImportedModules
        checkContractFulfillment
        mkHostTests
        ;
    };
  };
}
