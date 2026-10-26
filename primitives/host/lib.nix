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
in {
  _module.args = {
    hostLib = {
      inherit
        collectHostImportedModules
        checkContractFulfillment
        ;
    };
  };
}
