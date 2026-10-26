{
  check,
  lib,
  option,
  output,
  ...
}: {
  primitive.feature = {
    schema = option.schema {
      what = "System feature module set";
      doc = "Reusable system configurations, applications, desktop environments, development toolchains, and services that consume contracts to integrate with the host system.";
      checks = {
        hasOutputs = check.any [
          (check.hasNonEmptyAttrs "modules")
          (check.hasNonEmptyAttrs "packages")
          (check.hasNonEmptyAttrs "devShells")
          (check.hasNonEmptyAttrs "lib")
        ];
        validSymbols = check.validSymbols;
        validMeta = check.validMeta;
      };
    };

    relationships = {};

    schemas = name: feat:
      (lib.mapAttrs (
        modName: modDef: {
          what = "NixOS module";
          shortDescription = "Feature submodule '${modName}'.";
          evalChecks.isValidModule = builtins.isFunction modDef || builtins.isAttrs modDef || builtins.isPath modDef;
        }
      ) (feat.modules or {}))
      // (output.childOutputs name feat);

    options = {
      modules = option.modules;
      packages = option.packages;
      devShells = option.devShells;
      lib = option.lib;
      types = option.types;
    };

    outputs = {instances, ...}: output.standard instances;
  };
}
