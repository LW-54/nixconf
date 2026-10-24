{
  config,
  lib,
  inputs,
  self,
  option,
  output,
  primitiveSubmodule,
  ...
}: {
  primitive.primitive = {
    schema = option.schema {
      what = "Primitive type specification";
      doc = "Meta-primitive defining how primitives are constructed, typed, and exported across the system.";
      checks = {
        hasSchema = inst: {
          valid = inst ? schema;
          message = "Primitive must declare a flake schema specification.";
        };
        hasOptions = inst: {
          valid = inst ? options;
          message = "Primitive must declare instance options.";
        };
      };
    };

    relationships = {
      primitive = "outputs";
    };

    options = primitiveSubmodule.options;

    outputs = let
      primitives = lib.filterAttrs (name: _: name != "primitive") config.primitive;
    in {
      options =
        (lib.mapAttrs (
            name: prim:
              lib.mkOption {
                type = lib.types.attrsOf (lib.types.submodule {
                  options =
                    {
                      description = option.description;
                    }
                    // prim.options;
                });
                default = {};
                description = prim.schema.doc;
              }
          )
          config.primitive)
        // {
          primitive = lib.mkOption {
            type = lib.types.attrsOf lib.types.raw;
            default = config.primitive;
            description = "Evaluated primitives specifications and schemas.";
          };

          flake =
            (lib.genAttrs (builtins.attrNames config.primitive) (name:
              lib.mkOption {
                type = lib.types.lazyAttrsOf lib.types.raw;
                default = {};
                description = "Flake top-level output for ${name} primitive instances.";
              }))
            // {
              schemas = lib.mkOption {
                type = lib.types.lazyAttrsOf lib.types.raw;
                default = {};
                description = "Determinate Systems flake-schemas v1 specifications for flake outputs.";
              };
            };
        };

      imports =
        # 1. Primitive outputs (explicitly declared per primitive via output helpers or custom logic)
        (lib.mapAttrsToList (
            name: prim:
              if builtins.isFunction (prim.outputs or null)
              then
                {config, ...}:
                  prim.outputs {
                    instances = config.${name} or {};
                    inherit config lib inputs self output;
                  }
              else {}
          )
          primitives)
        # 2. Flake top-level output mirrors & Flake Schemas v1 export
        ++ [
          ({config, ...}: {
            flake =
              (lib.genAttrs
                (lib.filter (n: n != "lib") (builtins.attrNames primitives))
                (name: config.${name} or {}))
              // {
                schemas =
                  (inputs.flake-schemas.schemas or {})
                  // (lib.mapAttrs (_: prim: prim.schema) config.primitive);
              };

            lib.primitive = {
              description = "Primitives framework helper functions, option constructors, and utilities.";
              symbols = config.primitive.primitive.lib;
            };
          })
        ];
    };
  };
}
