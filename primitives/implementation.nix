{
  check,
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
        hasModule = check.hasAttr "module";
        validSymbols = check.validSymbols;
      };
    };

    relationships = {
      contract = {
        relation = "implements";
        description = "Implementation fulfills contract interface.";
      };
    };

    schemas = {
      name,
      instance,
      config,
      ...
    }:
      {
        contract = {
          what = "Target contract";
          shortDescription = "Implements contract '${instance.contract or "unknown"}'.";
          evalChecks = {
            validContract = instance ? contract && (config.contract ? ${instance.contract});
            hasModule = instance ? module;
          };
        };
      }
      // (output.childOutputs name instance);

    options = {
      contract = option.contract;
      module = option.module;
      packages = option.packages;
      devShells = option.devShells;
      lib = option.lib;
    };

    outputs = {instances, ...}: output.standard instances;
  };
}
