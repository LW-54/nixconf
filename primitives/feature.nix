{
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
        hasCapability = inst: {
          valid =
            (inst.modules or {})
            != {}
            || (inst.packages or {}) != {}
            || (inst.devShells or {}) != {}
            || (inst.lib or {}) != {};
          message = "Feature must export at least one module, package, devShell, or library helper.";
        };
      };
    };

    relationships = {
      contract = "consumes";
    };

    options = {
      modules = option.modules;
      packages = option.packages;
      devShells = option.devShells;
      lib = option.lib;
      types = option.types;
    };

    outputs = {instances, ...}:
      lib.mkMerge [
        (output.packages instances)
        (output.devShells instances)
        (output.lib instances)
        (output.nixosModules instances)
      ];
  };
}
