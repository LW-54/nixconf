{
  lib,
  unwrapLib,
  mkDualOption,
  ...
}: let
  option = {
    docstring = ''
      Pre-configured option constructors for primitive definitions with automatic descriptions and functor override support.

      # Type
      ```
      option :: AttrSet
      ```
    '';
    value = {
      schema = {
        docstring = ''
          Pre-configured constructor for Determinate Systems Flake Schema v1 specifications with evaluation checks.

          # Inputs

          `doc`
          : Formal markdown documentation string describing this output family.

          `what`
          : Human-readable classification noun describing concrete instances (e.g. "NixOS host configuration").

          `checks`
          : Optional attribute set of validation check functions: `name -> (instance -> bool | { valid = bool; message = str; })`.

          # Type
          ```
          schema :: AttrSet -> AttrSet
          ```
        '';
        value = {
          doc,
          what,
          checks ? {},
        }: {
          version = 1;
          inherit doc;
          inventory = instances: {
            children =
              lib.mapAttrs (name: inst: let
                allChecks =
                  {
                    hasDescription = i: {
                      valid = (i.description or (i.schema.doc or "")) != "";
                      message = "${what} '${name}' is missing a required formal description.";
                    };
                  }
                  // (lib.mapAttrs (_: chk:
                    if builtins.isFunction chk
                    then chk
                    else _: chk)
                  checks);

                evaluatedChecks = lib.mapAttrs (chkName: checkFn: let
                  res = checkFn inst;
                in
                  if builtins.isAttrs res && res ? valid
                  then ({todos = [];} // res)
                  else {
                    valid = res;
                    message = "${what} '${name}' failed check '${chkName}'.";
                    todos = [];
                  })
                allChecks;
              in {
                inherit what;
                shortDescription = inst.description or (inst.schema.doc or "");
                evalChecks = lib.mapAttrs (_: c: c.valid) evaluatedChecks;
                checkDetails = evaluatedChecks;
              })
              instances;
          };
        };
      };

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
          Pre-configured option constructor specifying the target contract implemented by an implementation provider.

          # Inputs

          `customDesc`
          : Optional custom description overriding the default.

          # Type
          ```
          contract :: (String -> Option) | Option
          ```
        '';
        value = mkDualOption "Name of the contract this module implements." (
          desc:
            lib.mkOption {
              type = lib.types.str;
              description = desc;
            }
        );
      };
    };
  };
in {
  _module.args = {
    option = unwrapLib option.value;
  };

  primitive.primitive.lib = {
    inherit option;
  };
}
