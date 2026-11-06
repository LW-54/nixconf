{
  config,
  lib,
  inputs,
  self,
  check,
  option,
  output,
  schemas,
  primitiveSubmodule,
  ...
}: let
  primitives = lib.filterAttrs (name: _: name != "primitive") config.primitive;
in {
  primitive.primitive = {
    description = "Meta-primitive defining how primitives are constructed, typed, and exported across the system.";

    schema = option.schema {
      what = "Primitive type specification";
      doc = "Meta-primitive defining how primitives are constructed, typed, and exported across the system.";
      checks = {
        hasSchema = check.hasAttr "schema";
        hasOptions = check.hasAttr "options";
        hasSchemas = check.hasAttr "schemas";
      };
    };

    schemas = null;

    relationships = {};

    options = (primitiveSubmodule {inherit config;}).options;

    outputs = {
      options = schemas.synthesizeOptions {inherit config option;};

      imports =
        # 1. Autonomous primitive outputs (explicitly declared per primitive via output helpers or custom logic)
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
        # 2. Flake top-level output mirrors, schemas & verification checks
        ++ [
          ({config, ...}: {
            flake =
              (lib.genAttrs
                (lib.filter (n: n != "lib") (builtins.attrNames primitives))
                (name: config.${name} or {}))
              // {
                schemas = schemas.buildFlakeSchemas {inherit config inputs primitives;};
              };

            perSystem = {pkgs, ...}: {
              checks.schemas = schemas.checkFlakeSchemas {inherit pkgs config primitives;};
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
