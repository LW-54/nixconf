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

    run = pkgs.writeShellApplication {
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
