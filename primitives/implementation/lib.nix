{lib, ...}: let
  /**
  Wraps a raw implementation module function or attribute set with contract enablement
  and conditional gating.
  */
  wrapImplementationModule = {
    name,
    contract,
    userModule,
    contractModule ? null,
  }: {
    config,
    lib,
    ...
  } @ args: let
    evaluated =
      if builtins.isFunction userModule
      then let
        res = builtins.tryEval (userModule args);
      in
        if res.success
        then res.value
        else userModule (builtins.intersectAttrs (builtins.functionArgs userModule) args)
      else if builtins.isPath userModule
      then let
        imported = import userModule;
      in
        if builtins.isFunction imported
        then imported args
        else imported
      else userModule;

    hasExplicitConfig = evaluated ? config;
    innerConfig =
      if hasExplicitConfig
      then evaluated.config
      else builtins.removeAttrs evaluated ["options" "imports" "_file" "key"];

    extractedImports = evaluated.imports or [];
    extractedOptions = evaluated.options or {};

    contractImport = lib.optional (contractModule != null) contractModule;
  in {
    _file = "implementation:${name}";
    key = "implementation-${name}";
    imports = contractImport ++ extractedImports;
    options = extractedOptions;
    config = lib.mkMerge [
      {
        ${contract}.enable = lib.mkDefault true;
      }
      (lib.mkIf (config.${contract}.enable or false) innerConfig)
    ];
  };
in {
  _module.args = {
    implementationLib = {
      inherit wrapImplementationModule;
    };
  };
}
