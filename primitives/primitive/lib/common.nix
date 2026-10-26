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

      schemas = lib.mkOption {
        type = lib.types.raw;
        default = null;
        description = "Per-instance schema inventory children generator mapping instances to Determinate Systems flake.schemas v1 specifications and evalChecks.";
      };

      relationships = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.coercedTo lib.types.str
          (relation: {inherit relation;})
          (lib.types.submodule ({
            name,
            config,
            ...
          }: {
            options = {
              target = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Target primitive kind (e.g. 'contract').";
              };
              relation = lib.mkOption {
                type = lib.types.str;
                default = "implements";
                description = "Computer science relationship verb.";
              };
              attribute = lib.mkOption {
                type = lib.types.str;
                default = name;
                description = "Instance attribute key storing the target identifier.";
              };
              resolve = lib.mkOption {
                type = lib.types.raw;
                default = inst: inst.${config.attribute} or null;
                description = "Function extracting the target identifier from an instance.";
              };
              description = lib.mkOption {
                type = lib.types.str;
                default = "";
                description = "Documentation for this architectural relationship.";
              };
            };
          }))
        );
        default = {};
        description = "Explicit architectural relationships between primitive instances (e.g. implementation implements contract).";
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
