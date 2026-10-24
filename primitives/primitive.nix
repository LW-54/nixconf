{
  config,
  lib,
  inputs,
  self,
  ...
}: let
  unwrapLib = attrs:
    lib.mapAttrs (
      _: s:
        if builtins.isAttrs s && s ? value
        then s.value
        else if builtins.isAttrs s && s ? docstring
        then builtins.removeAttrs s ["docstring"]
        else s
    )
    attrs;

  # Dual functor helper: allows using `option.modules` directly or calling `option.modules "custom"`
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

  primitiveSubmodule = {
    options = {
      description = lib.mkOption {
        type = lib.types.str;
        description = "Formal description of this primitive class.";
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
  options = {
    primitive = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule primitiveSubmodule);
      default = {};
      description = "Declared primitives in the repository.";
    };
    primitives = lib.mkOption {
      type = lib.types.raw;
      description = "Synthesized Pass 2 primitives module.";
    };
  };

  config = {
    _module.args = {
      option = unwrapLib config.primitive.primitive.lib.option.value;
      output = unwrapLib config.primitive.primitive.lib.output.value;
      unwrapLib = unwrapLib;
    };

    primitive.primitive = {
      description = "Meta-primitive defining how primitives are constructed, typed, and exported across the system.";
      options = primitiveSubmodule.options;

      lib = {
        option = {
          docstring = ''
            Pre-configured option constructors for primitive definitions with automatic descriptions and functor override support.

            # Type
            ```
            option :: AttrSet
            ```
          '';
          value = {
            description = {
              docstring = ''
                Pre-configured option constructor for formal primitive instance descriptions.

                # Inputs

                `customDesc`
                : Optional custom description overriding the default.

                # Type
                ```
                description :: (String -> Option) | Option
                ```
              '';
              value = mkDualOption "Formal description of this primitive instance." (
                desc:
                  lib.mkOption {
                    type = lib.types.str;
                    description = desc;
                  }
              );
            };

            module = {
              docstring = ''
                Pre-configured option constructor for a single deferred NixOS module.

                # Inputs

                `customDesc`
                : Optional custom description overriding the default.

                # Type
                ```
                module :: (String -> Option) | Option
                ```
              '';
              value = mkDualOption "NixOS module implementing the capability." (
                desc:
                  lib.mkOption {
                    type = lib.types.deferredModule;
                    description = desc;
                  }
              );
            };

            modules = {
              docstring = ''
                Pre-configured option constructor for an attribute set of deferred NixOS modules.

                # Inputs

                `customDesc`
                : Optional custom description overriding the default.

                # Type
                ```
                modules :: (String -> Option) | Option
                ```
              '';
              value = mkDualOption "NixOS modules exported by this primitive." (
                desc:
                  lib.mkOption {
                    type = lib.types.attrsOf lib.types.deferredModule;
                    default = {};
                    description = desc;
                  }
              );
            };

            moduleList = {
              docstring = ''
                Pre-configured option constructor for a list of deferred NixOS modules.

                # Inputs

                `customDesc`
                : Optional custom description overriding the default.

                # Type
                ```
                moduleList :: (String -> Option) | Option
                ```
              '';
              value = mkDualOption "List of NixOS modules enabled for this host." (
                desc:
                  lib.mkOption {
                    type = lib.types.listOf lib.types.deferredModule;
                    default = [];
                    description = desc;
                  }
              );
            };

            packages = {
              docstring = ''
                Pre-configured option constructor for primitive package outputs.

                # Inputs

                `customDesc`
                : Optional custom description overriding the default.

                # Type
                ```
                packages :: (String -> Option) | Option
                ```
              '';
              value = mkDualOption "Packages provided by this primitive." (
                desc:
                  lib.mkOption {
                    type = lib.types.raw;
                    default = {};
                    description = desc;
                  }
              );
            };

            devShells = {
              docstring = ''
                Pre-configured option constructor for primitive development shell outputs.

                # Inputs

                `customDesc`
                : Optional custom description overriding the default.

                # Type
                ```
                devShells :: (String -> Option) | Option
                ```
              '';
              value = mkDualOption "Development shells provided by this primitive." (
                desc:
                  lib.mkOption {
                    type = lib.types.raw;
                    default = {};
                    description = desc;
                  }
              );
            };

            lib = {
              docstring = ''
                Pre-configured option constructor for exported helper functions on `flake.lib.<name>`.

                # Inputs

                `customDesc`
                : Optional custom description overriding the default.

                # Type
                ```
                lib :: (String -> Option) | Option
                ```
              '';
              value = mkDualOption "Library helper functions and values exported on flake.lib.<name>." (
                desc:
                  lib.mkOption {
                    type = lib.types.attrsOf lib.types.raw;
                    default = {};
                    description = desc;
                  }
              );
            };

            types = {
              docstring = ''
                Pre-configured option constructor for custom types declared and exported by a primitive.

                # Inputs

                `customDesc`
                : Optional custom description overriding the default.

                # Type
                ```
                types :: (String -> Option) | Option
                ```
              '';
              value = mkDualOption "Custom types declared and exported by this primitive." (
                desc:
                  lib.mkOption {
                    type = lib.types.attrsOf lib.types.raw;
                    default = {};
                    description = desc;
                  }
              );
            };

            contract = {
              docstring = ''
                Pre-configured option constructor specifying the target capability contract implemented by an implementation provider.

                # Inputs

                `customDesc`
                : Optional custom description overriding the default.

                # Type
                ```
                contract :: (String -> Option) | Option
                ```
              '';
              value = mkDualOption "Name of the capability contract this module implements." (
                desc:
                  lib.mkOption {
                    type = lib.types.str;
                    description = desc;
                  }
              );
            };
          };
        };

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

        output = {
          docstring = ''
            Pre-configured output generator helpers for aggregating flake outputs.

            # Type
            ```
            output :: AttrSet
            ```
          '';
          value = {
            packages = {
              docstring = ''
                Helper generating `perSystem.packages` from primitive instances.

                # Inputs

                `instances`
                : Attribute set of primitive instances declared under `config.<primitive>`.

                # Type
                ```
                packages :: AttrSet -> AttrSet
                ```
              '';
              value = instances: {
                perSystem = {
                  pkgs,
                  self',
                  ...
                } @ args: {
                  packages = lib.mkMerge (
                    lib.mapAttrsToList (
                      _: inst:
                        if inst ? packages
                        then
                          (
                            if builtins.isFunction inst.packages
                            then inst.packages args
                            else inst.packages
                          )
                        else {}
                    )
                    instances
                  );
                };
              };
            };

            devShells = {
              docstring = ''
                Helper generating `perSystem.devShells` from primitive instances.

                # Inputs

                `instances`
                : Attribute set of primitive instances declared under `config.<primitive>`.

                # Type
                ```
                devShells :: AttrSet -> AttrSet
                ```
              '';
              value = instances: {
                perSystem = {
                  pkgs,
                  self',
                  ...
                } @ args: {
                  devShells = lib.mkMerge (
                    lib.mapAttrsToList (
                      _: inst:
                        if inst ? devShells
                        then
                          (
                            if builtins.isFunction inst.devShells
                            then inst.devShells args
                            else inst.devShells
                          )
                        else {}
                    )
                    instances
                  );
                };
              };
            };

            lib = {
              docstring = ''
                Helper registering exported primitive helper functions under `config.lib.<name>`.

                # Inputs

                `instances`
                : Attribute set of primitive instances declared under `config.<primitive>`.

                # Type
                ```
                lib :: AttrSet -> AttrSet
                ```
              '';
              value = instances: {
                lib = lib.mapAttrs (_: inst: {
                  inherit (inst) description;
                  symbols = inst.lib or {};
                }) (lib.filterAttrs (_: inst: (inst.lib or {}) != {}) instances);
              };
            };
          };
        };
      };

      outputs = let
        output = unwrapLib config.primitive.primitive.lib.output.value;
        optionDesc = (unwrapLib config.primitive.primitive.lib.option.value).description;
      in {
        options =
          (lib.mapAttrs (
              name: prim:
                lib.mkOption {
                  type = lib.types.attrsOf (lib.types.submodule {
                    options =
                      {
                        description = optionDesc;
                      }
                      // prim.options;
                  });
                  default = {};
                  description = prim.description;
                }
            )
            config.primitive)
          // {
            primitive = lib.mkOption {
              type = lib.types.attrsOf lib.types.raw;
              default = config.primitive;
              description = "Evaluated primitives specifications and schemas.";
            };
          };

        imports =
          # 1. Automatic aggregation of standard outputs (packages, devShells, lib) based on primitive schema
          (lib.concatMap (
            name: let
              prim = config.primitive.${name};
            in
              if name == "primitive"
              then []
              else
                (lib.optional (prim.options ? packages) ({config, ...}: output.packages (config.${name} or {})))
                ++ (lib.optional (prim.options ? devShells) ({config, ...}: output.devShells (config.${name} or {})))
                ++ (lib.optional (prim.options ? lib && name != "contract") ({config, ...}: output.lib (config.${name} or {})))
          ) (builtins.attrNames config.primitive))
          # 2. Primitive-specific outputs
          ++ (lib.mapAttrsToList (
              name: prim:
                if name != "primitive" && builtins.isFunction (prim.outputs or null)
                then
                  {config, ...}:
                    prim.outputs {
                      instances = config.${name} or {};
                      inherit config lib inputs self;
                    }
                else {}
            )
            config.primitive)
          ++ [
            {
              lib.primitive = {
                description = "Primitives framework helper functions, option constructors, and utilities.";
                symbols = config.primitive.primitive.lib;
              };
            }
          ];
      };
    };

    primitives = config.primitive.primitive.outputs;
  };
}
