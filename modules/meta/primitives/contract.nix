{
  lib,
  config,
  ...
}: let
  contractSubmodule = lib.types.submodule {
    options = {
      description = lib.mkOption {
        type = lib.types.str;
        description = "Formal description of this capability contract.";
      };
      options = lib.mkOption {
        type = lib.types.raw;
        description = "NixOS option declarations for this contract.";
      };
      types = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Declarative submodules and type definitions exposed on self.lib.<name>.types.";
      };
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
      packages = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Contract-specific package declarations or generator function.";
      };
      devShells = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Contract-specific development shells or generator function.";
      };
      lib = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Helper functions and values exposed on self.lib.<name>.";
      };
    };
  };

  # Helper to derive mkOption and mkConfig directly from options for collection contracts
  deriveCollectionHelpers = name: c: let
    autoCollection =
      lib.filterAttrs (
        _: opt:
          opt ? type
          && (opt.type.name or "") == "listOf"
          && opt ? default
          && builtins.isList opt.default
          && opt.default == []
      )
      c.options;
    coll = builtins.attrNames autoCollection;
  in
    if coll != []
    then {
      mkOption = args: {
        ${name} =
          {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = true;
              description = "Whether to include this service's paths in ${name}.";
            };
          }
          // lib.genAttrs coll (
            optName:
              lib.mkOption {
                type = c.options.${optName}.type;
                default = args.${optName} or c.options.${optName}.default or [];
                description = c.options.${optName}.description or "${optName} for this service.";
              }
          );
      };

      mkConfig = {
        config,
        cfg ? config.${name},
      }:
        lib.mkIf (cfg.enable or false) {
          ${name} = lib.genAttrs coll (optName: cfg.${optName} or []);
        };
    }
    else {
      mkOption = null;
      mkConfig = null;
    };

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
in {
  options.contract = lib.mkOption {
    type = lib.types.attrsOf contractSubmodule;
    default = {};
    description = "Pure capability interfaces defining shared option schemas, custom types, and configuration contracts decoupled from any specific service provider or backend implementation.";
  };

  config = {
    flake.nixosModules =
      (lib.mapAttrs (
          name: c: {
            options.${name} = c.options;
          }
        )
        config.contract)
      // {
        contracts = {...}: {
          imports = lib.mapAttrsToList (name: _: config.flake.nixosModules.${name}) config.contract;
        };
      };

    lib =
      lib.mapAttrs (
        name: c: let
          derived = deriveCollectionHelpers name c;
          mkOption =
            if c.mkOption != null
            then c.mkOption
            else derived.mkOption;
          mkConfig =
            if c.mkConfig != null
            then c.mkConfig
            else derived.mkConfig;
          mkOptionArgs =
            if builtins.isFunction mkOption
            then builtins.attrNames (builtins.functionArgs mkOption)
            else [];
          mkConfigArgs =
            if builtins.isFunction mkConfig
            then builtins.attrNames (builtins.functionArgs mkConfig)
            else [];

          mkOptionInputs =
            if mkOptionArgs != []
            then lib.concatMapStringsSep "\n\n" (a: "`${a}`\n: Submodule option parameter for the '${name}' contract.") mkOptionArgs
            else "`args`\n: Service-specific options to include.";

          mkConfigInputs =
            if mkConfigArgs != []
            then lib.concatMapStringsSep "\n\n" (a: "`${a}`\n: Configuration binding parameter for the '${name}' contract.") mkConfigArgs
            else "`args`\n: Host configuration and consumer configuration.";

          autoSymbols =
            (lib.optionalAttrs (c.types != {}) {inherit (c) types;})
            // (lib.optionalAttrs (mkOption != null) {
              mkOption = {
                docstring = ''
                  Auto-derived option constructor for the '${name}' capability contract.

                  # Inputs

                  ${mkOptionInputs}

                  # Type

                  ```
                  ${name}.mkOption :: AttrSet -> AttrSet
                  ```

                  # Examples
                  ```nix
                  ${name}.mkOption { ... }
                  ```
                '';
                value = mkOption;
              };
            })
            // (lib.optionalAttrs (mkConfig != null) {
              mkConfig = {
                docstring = ''
                  Auto-derived configuration binding helper for the '${name}' capability contract.

                  # Inputs

                  ${mkConfigInputs}

                  # Type

                  ```
                  ${name}.mkConfig :: AttrSet -> AttrSet
                  ```

                  # Examples
                  ```nix
                  ${name}.mkConfig { inherit config cfg; }
                  ```
                '';
                value = mkConfig;
              };
            });
        in {
          description = "Library helpers and constructors for the '${name}' capability contract.";
          symbols = autoSymbols // c.lib;
        }
      )
      config.contract;

    perSystem = {
      pkgs,
      self',
      ...
    } @ args: {
      packages = lib.mkMerge (lib.mapAttrsToList (
          _: c:
            if builtins.isFunction c.packages
            then c.packages args
            else c.packages
        )
        config.contract);

      devShells = lib.mkMerge (lib.mapAttrsToList (
          _: c:
            if builtins.isFunction c.devShells
            then c.devShells args
            else c.devShells
        )
        config.contract);
    };
  };
}
