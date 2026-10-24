{
  lib,
  option,
  output,
  deriveContractSymbols,
  ...
}: {
  primitive.contract = {
    schema = option.schema {
      what = "Architectural capability contract";
      doc = "Pure capability interfaces defining shared option schemas, custom types, and configuration contracts decoupled from any specific service provider or backend implementation.";
      checks = {
        hasOptions = inst: {
          valid = inst ? options && builtins.isAttrs inst.options;
          message = "Contract must declare an attribute set of 'options'.";
        };
      };
    };

    relationships = {};

    options = {
      options = lib.mkOption {
        type = lib.types.raw;
        description = "NixOS option declarations for this contract.";
      };

      types = option.types;

      mkOption = lib.mkOption {
        type = lib.types.raw;
        default = null;
        description = "Feature submodule option constructor.";
      };

      mkConfig = lib.mkOption {
        type = lib.types.raw;
        default = null;
        description = "Feature configuration binding helper.";
      };

      packages = option.packages;

      devShells = option.devShells;

      lib = option.lib;
    };

    outputs = {
      instances,
      lib,
      config,
      ...
    }:
      lib.mkMerge [
        (output.packages instances)
        (output.devShells instances)
        {
          flake.nixosModules =
            (lib.mapAttrs (
                name: c: {
                  options.${name} = c.options;
                }
              )
              instances)
            // {
              contracts = {...}: {
                imports = lib.mapAttrsToList (name: _: config.flake.nixosModules.${name}) instances;
              };
            };

          lib =
            lib.mapAttrs (
              name: c: {
                description = "Library helpers and constructors for the '${name}' capability contract.";
                symbols = (deriveContractSymbols name c) // c.lib;
              }
            )
            instances;
        }
      ];
  };
}
