{
  lib,
  unwrapLib,
  ...
}: let
  mkPerSystemCollector = attrName: instances: {
    perSystem = {
      pkgs,
      self',
      ...
    } @ args: {
      ${attrName} = lib.mkMerge (
        lib.mapAttrsToList (
          _: inst:
            if inst ? ${attrName}
            then
              if builtins.isFunction inst.${attrName}
              then inst.${attrName} args
              else inst.${attrName}
            else {}
        )
        instances
      );
    };
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
        value = mkPerSystemCollector "packages";
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
        value = mkPerSystemCollector "devShells";
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

      nixosModules = {
        docstring = ''
          Helper registering primitive instance NixOS modules under `flake.nixosModules`.
          Supports single modules (`inst.module`), module collections (`inst.modules`),
          and host configurations (`inst.configuration` / `inst.subModules`),
          mapping 'default' submodule keys to the instance name.

          # Inputs

          `instances`
          : Attribute set of primitive instances declared under `config.<primitive>`.

          # Type
          ```
          nixosModules :: AttrSet -> AttrSet
          ```
        '';
        value = instances: {
          flake.nixosModules =
            lib.concatMapAttrs (
              name: inst:
                (lib.optionalAttrs (inst ? module) {
                  ${name} = inst.module;
                })
                // (lib.optionalAttrs (inst ? configuration) {
                  ${name} = inst.configuration;
                })
                // (inst.subModules or {})
                // (lib.optionalAttrs (inst ? modules) (
                  lib.mapAttrs' (
                    modName: mod:
                      lib.nameValuePair (
                        if modName == "default"
                        then name
                        else modName
                      )
                      mod
                  )
                  inst.modules
                ))
            )
            instances;
        };
      };

      schemas = {
        docstring = ''
          Helper generating Determinate Systems `flake.schemas` v1 declarations for primitive instances.

          # Inputs

          `kind`
          : Primitive kind string (e.g. "contract", "feature", "host", "implementation", "lib").

          `instances`
          : Attribute set of primitive instances declared under `config.<primitive>`.

          `children`
          : Function `(name: instance: { ... })` returning an attribute set of schema inventory children.

          # Type
          ```
          schemas :: AttrSet -> AttrSet
          ```
        '';
        value = {
          kind,
          instances,
          children ? (_: _: {}),
        }: {
          flake.schemas =
            lib.mapAttrs' (
              name: inst:
                lib.nameValuePair "${kind}/${name}" {
                  version = 1;
                  doc = inst.description or "${kind} instance '${name}'.";
                  inventory = _: {
                    children = children name inst;
                  };
                }
            )
            instances;
        };
      };

      childOutputs = {
        docstring = ''
          Helper creating schema inventory children for instance `packages` and `devShells`.

          # Inputs

          `name`
          : Name of the primitive instance.

          `inst`
          : Instance attribute set.

          # Type
          ```
          childOutputs :: String -> AttrSet -> AttrSet
          ```
        '';
        value = name: inst:
          (lib.optionalAttrs (inst.packages or null != null) {
            packages = {
              what = "Exported packages";
              shortDescription = "Packages declared by '${name}'.";
              evalChecks = {
                isValid = builtins.isAttrs inst.packages || builtins.isFunction inst.packages;
              };
            };
          })
          // (lib.optionalAttrs (inst.devShells or null != null) {
            devShells = {
              what = "Exported devShells";
              shortDescription = "DevShells declared by '${name}'.";
              evalChecks = {
                isValid = builtins.isAttrs inst.devShells || builtins.isFunction inst.devShells;
              };
            };
          });
      };

      standard = {
        docstring = ''
          Standard output generator merging packages, devShells, lib, and nixosModules for primitive instances.

          # Inputs

          `instances`
          : Attribute set of primitive instances declared under `config.<primitive>`.

          # Type
          ```
          standard :: AttrSet -> AttrSet
          ```
        '';
        value = instances:
          lib.mkMerge [
            (output.value.packages.value instances)
            (output.value.devShells.value instances)
            (output.value.lib.value instances)
            (output.value.nixosModules.value instances)
          ];
      };
    };
  };
in {
  _module.args = {
    output = unwrapLib output.value;
  };

  primitive.primitive.lib = {
    inherit output;
  };
}
