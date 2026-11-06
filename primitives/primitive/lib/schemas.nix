{
  lib,
  unwrapLib,
  ...
}: let
  /**
  Synthesizes top-level options for declared primitives, flake mirrors, and schemas.
  */
  synthesizeOptionsFn = {
    config,
    option,
  }:
    (lib.mapAttrs (
        _name: prim:
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

  synthesizeOptions = {
    docstring = ''
      Synthesizes top-level options for declared primitives, flake mirrors, and schemas.

      # Inputs

      `config`
      : Flake-parts module configuration attribute set.

      `option`
      : Option constructor suite providing default description options.

      # Type
      ```
      synthesizeOptions :: AttrSet -> AttrSet
      ```
    '';
    value = synthesizeOptionsFn;
  };

  /**
  Compiles Determinate Systems flake-schemas v1 specifications across all primitives.
  */
  buildFlakeSchemasFn = {
    config,
    inputs,
    primitives,
  }:
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

  buildFlakeSchemas = {
    docstring = ''
      Compiles Determinate Systems flake-schemas v1 specifications across all primitives.

      # Inputs

      `config`
      : Flake-parts configuration attribute set containing primitive instances.

      `inputs`
      : Pinned flake inputs providing base flake-schemas.

      `primitives`
      : Attribute set of active primitive specifications excluding the meta-primitive.

      # Type
      ```
      buildFlakeSchemas :: AttrSet -> AttrSet
      ```
    '';
    value = buildFlakeSchemasFn;
  };

  /**
  Builds a pure-Nix derivation verifying that all schema evalChecks pass across all instances.
  */
  checkFlakeSchemasFn = {
    pkgs,
    config,
    primitives,
  }: let
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

  checkFlakeSchemas = {
    docstring = ''
      Builds a pure-Nix derivation verifying that all schema evalChecks pass across all instances.

      # Inputs

      `pkgs`
      : Package set for building the check derivation.

      `config`
      : Flake configuration attribute set containing evaluated schemas.

      `primitives`
      : Attribute set of active primitive specifications.

      # Type
      ```
      checkFlakeSchemas :: AttrSet -> Package
      ```
    '';
    value = checkFlakeSchemasFn;
  };

  schemasLib = {
    docstring = ''
      Helper functions for synthesizing primitive options, compiling flake-schemas v1, and verifying evalChecks.

      # Type
      ```
      schemas :: AttrSet
      ```

      # Values
      - `synthesizeOptions args`: Generates top-level options for declared primitives.
      - `buildFlakeSchemas args`: Compiles Determinate Systems flake-schemas v1 specifications.
      - `checkFlakeSchemas args`: Evaluates and asserts that all schema evalChecks pass.
    '';
    value = {
      inherit
        synthesizeOptions
        buildFlakeSchemas
        checkFlakeSchemas
        ;
    };
  };
in {
  _module.args = {
    schemas = unwrapLib schemasLib.value;
  };

  primitive.primitive.lib = {
    schemas = schemasLib;
  };
}
