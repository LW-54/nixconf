{
  config,
  lib,
  ...
}: let
  unwrapLib = attrs:
    lib.mapAttrs (
      _: s:
        if builtins.isAttrs s
        then
          if s ? value
          then
            if builtins.isAttrs s.value && !lib.isDerivation s.value && !lib.isOption s.value
            then unwrapLib s.value
            else s.value
          else if s ? docstring
          then builtins.removeAttrs s ["docstring"]
          else if !lib.isDerivation s && !lib.isOption s
          then unwrapLib s
          else s
        else s
    )
    attrs;

  mkDualOption = defaultDesc: optFn: let
    base = optFn defaultDesc;
    functor = {
      __functor = self: customDesc:
        optFn (
          if customDesc != null
          then customDesc
          else defaultDesc
        );
    };
  in
    base // functor;

  schemaSubmodule = {
    options = {
      version = lib.mkOption {
        type = lib.types.int;
        default = 1;
        description = "Flake schema specification version.";
      };
      doc = lib.mkOption {
        type = lib.types.str;
        description = "Markdown documentation describing this primitive flake output.";
      };
      inventory = lib.mkOption {
        type = lib.types.raw;
        description = "Function mapping the output value to an inventory tree.";
      };
    };
  };

  primitiveSubmodule = {config, ...}: {
    options = {
      schema = lib.mkOption {
        type = lib.types.submodule schemaSubmodule;
        description = "Flake schema specification (version 1) exported directly to flake.schemas.<primitive>.";
      };

      relationships = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.coercedTo lib.types.str
          (label: {inherit label;})
          (lib.types.submodule ({name, ...}: {
            options = {
              target = lib.mkOption {
                type = lib.types.enum (builtins.attrNames config.primitive);
                default = name;
                description = "Target primitive type (strictly checked against declared primitives).";
              };
              label = lib.mkOption {
                type = lib.types.enum ["implements" "consumes" "imports" "outputs"];
                description = "Nature of relationship.";
              };
            };
          }))
        );
        default = {};
        description = "Architectural relationships with other primitives.";
      };

      options = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Option declarations for concrete instances of this primitive.";
      };

      lib = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Library helper functions and option constructors provided by this primitive.";
      };

      outputs = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Autonomous output generator function mapping instances to flake outputs.";
      };
    };
  };
in {
  _module.args = {
    inherit unwrapLib mkDualOption schemaSubmodule primitiveSubmodule;
  };

  primitive.primitive.lib = {
    unwrapLib = {
      docstring = ''
        Unwraps documented symbols from an attribute set, extracting `.value` if present or stripping `.docstring` metadata.

        # Inputs

        `attrs`
        : Attribute set containing documented symbol definitions.

        # Type
        ```
        unwrapLib :: AttrSet -> AttrSet
        ```
      '';
      value = unwrapLib;
    };
  };
}
