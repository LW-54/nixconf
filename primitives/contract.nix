{
  lib,
  option,
  ...
}: let
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
in {
  primitive.contract = {
    description = "Pure capability interfaces defining shared option schemas, custom types, and configuration contracts decoupled from any specific service provider or backend implementation.";

    options = {
      options = lib.mkOption {
        type = lib.types.raw;
        description = "NixOS option declarations for this contract.";
      };

      types = option.types;

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

      packages = option.packages;

      devShells = option.devShells;

      lib = option.lib;
    };

    outputs = {
      instances,
      lib,
      config,
      ...
    }: {
      flake.nixosModules =
        (lib.mapAttrs (
            name: c: {
              options.${name} = c.options;
            }
          )
          instances)
        // {
          contracts = {...}: {
            imports = lib.mapAttrsToList (name: _: config.flake.nixosModules.${name}) instances;
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
        instances;
    };
  };
}
