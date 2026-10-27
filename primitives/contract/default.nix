{
  lib,
  check,
  option,
  output,
  contractLib,
  ...
}: {
  primitive.contract = {
    schema = option.schema {
      what = "Architectural contract";
      doc = "Pure contract interfaces defining shared option schemas, custom types, and configuration contracts decoupled from any specific service provider or backend implementation.";
      checks = {
        hasOptions = check.hasAttrs "options";
        validOptions = check.validOptions;
      };
    };

    relationships = {};

    schemas = name: c:
      (lib.mapAttrs (
        optPath: opt: {
          what = "NixOS option";
          shortDescription = opt.description or "";
          evalChecks.validOption =
            (check.validOption {
              path = optPath;
              option = opt;
              isContract = true;
            })
            == [];
        }
      ) (check.flattenOptions name c.options))
      // (lib.mapAttrs (
        typeName: typeDef: {
          what = "custom-type";
          shortDescription = typeDef.description or "Type definition ${typeName}.";
          evalChecks.hasDescription = (typeDef.description or "") != "";
        }
      ) (c.types or {}));

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
                  _file = "contract:${name}";
                  key = "contract-${name}";
                  options.${name} = c.options;
                }
              )
              instances)
            // {
              contracts = {...}: {
                _file = "contracts";
                key = "contracts";
                imports = lib.mapAttrsToList (name: _: config.flake.nixosModules.${name}) instances;
              };
            };

          lib =
            lib.mapAttrs (
              name: c: {
                description = "Library helpers and constructors for the '${name}' contract.";
                symbols = (contractLib.deriveContractSymbols name c) // c.lib;
              }
            )
            instances;
        }
      ];
  };
}
