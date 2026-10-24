{
  lib,
  option,
  output,
  self,
  ...
}: {
  primitive.implementation = {
    schema = option.schema {
      what = "Capability implementation module";
      doc = "Concrete capability providers satisfying contract interfaces by translating abstract capability options into provider-specific NixOS services, packages, and system configurations.";
      checks = {
        validContract = inst: {
          valid = inst ? contract && (self.contract ? ${inst.contract});
          message = "Implementation targets unknown contract '${inst.contract or "unknown"}'. Declared contracts: ${lib.concatStringsSep ", " (builtins.attrNames (self.contract or {}))}";
        };
        hasModule = inst: {
          valid = inst ? module;
          message = "Implementation is missing required 'module' definition.";
        };
      };
    };

    relationships = {
      contract = "implements";
    };

    options = {
      contract = option.contract;
      module = option.module;
      packages = option.packages;
      devShells = option.devShells;
      lib = option.lib;
    };

    outputs = {
      instances,
      lib,
      ...
    }:
      lib.mkMerge [
        (output.packages instances)
        (output.devShells instances)
        (output.lib instances)
        (output.nixosModules instances)
      ];
  };
}
