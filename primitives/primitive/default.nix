{
  config,
  lib,
  inputs,
  self,
  check,
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
        hasSchema = check.hasAttr "schema";
        hasOptions = check.hasAttr "options";
        hasSchemas = check.hasAttr "schemas";
      };
    };

    schemas = null;

    relationships = {};

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
                  // (lib.mapAttrs (_: prim: prim.schema) config.primitive)
                  // (lib.concatMapAttrs (
                      primKind: prim:
                        if prim.schemas != null
                        then
                          lib.mapAttrs' (
                            instName: inst:
                              lib.nameValuePair "${primKind}/${instName}" {
                                version = 1;
                                doc = inst.description or "${primKind} instance '${instName}'.";
                                inventory = _: {
                                  children = let
                                    f = prim.schemas;
                                    fArgs = builtins.functionArgs f;
                                  in
                                    if fArgs == {}
                                    then f instName inst
                                    else
                                      f {
                                        name = instName;
                                        instance = inst;
                                        inherit config lib;
                                      };
                                };
                              }
                          ) (config.${primKind} or {})
                        else {}
                    )
                    primitives);
              };

            perSystem = {pkgs, ...}: {
              checks.schemas = let
                primPrefixes = map (p: "${p}/") (builtins.attrNames primitives);
                isInstanceSchema = name: lib.any (p: lib.hasPrefix p name) primPrefixes;
                failedChecks = lib.concatLists (lib.mapAttrsToList (
                  schemaName: schema: let
                    inv =
                      if builtins.isFunction (schema.inventory or null)
                      then schema.inventory {}
                      else {children = {};};
                  in
                    lib.concatLists (lib.mapAttrsToList (
                      childName: child:
                        lib.mapAttrsToList (
                          chkName: valid:
                            if !valid
                            then "[schema-check-failed] ${schemaName}.${childName}.${chkName}"
                            else null
                        ) (child.evalChecks or {})
                    ) (inv.children or {}))
                ) (lib.filterAttrs (n: _: isInstanceSchema n) config.flake.schemas));
                cleanFailed = lib.filter (x: x != null) failedChecks;
              in
                if cleanFailed != []
                then builtins.throw (lib.concatStringsSep "\n" cleanFailed)
                else pkgs.runCommand "check-primitive-schemas" {} "touch $out";
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
