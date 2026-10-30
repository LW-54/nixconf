{lib, ...}: let
  # Derives collection contract helpers (mkOption, mkConfig) and synthesizes documented symbols
  deriveContractSymbols = name: c: let
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

    derivedCollection =
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
        }: let
          targetCfg = cfg.${name} or cfg;
        in
          lib.mkIf (targetCfg.enable or false) {
            ${name} = lib.genAttrs coll (optName: targetCfg.${optName} or []);
          };
      }
      else {
        mkOption = null;
        mkConfig = null;
      };

    mkOption =
      if c.mkOption != null
      then c.mkOption
      else derivedCollection.mkOption;

    mkConfig =
      if c.mkConfig != null
      then c.mkConfig
      else derivedCollection.mkConfig;

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
  in
    (lib.optionalAttrs (c.types != {}) {inherit (c) types;})
    // (lib.optionalAttrs (mkOption != null) {
      mkOption = {
        docstring = ''
          Auto-derived option constructor for the '${name}' contract.

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
          Auto-derived configuration binding helper for the '${name}' contract.

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
  _module.args = {
    inherit deriveContractSymbols;
    contractLib = {
      inherit deriveContractSymbols;
    };
  };
}
