{
  lib,
  config,
  ...
}: let
  contractSubmodule = lib.types.submodule {
    options = {
      options = lib.mkOption {
        type = lib.types.raw;
        description = "NixOS option declarations for this contract.";
      };
      types = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Declarative submodules and type definitions exposed on self.lib.<name>.types.";
      };
      collection = lib.mkOption {
        type = lib.types.either lib.types.bool (lib.types.listOf lib.types.str);
        default = true;
        description = "Whether to auto-derive collection helpers directly from options, or explicit list of option names.";
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
      extraLib = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Extra helper functions and values exposed on self.lib.<name>.";
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
    coll =
      if builtins.isList c.collection && c.collection != []
      then c.collection
      else if c.collection == true
      then builtins.attrNames autoCollection
      else [];
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
            k:
              lib.mkOption {
                inherit (c.options.${k}) type;
                default = args.${k} or c.options.${k}.default;
                description = c.options.${k}.description or "${k} for this service.";
              }
          );
      };

      mkConfig = {
        config,
        cfg,
      }:
        lib.mkIf ((config.${name}.enable or false) && cfg ? ${name} && cfg.${name}.enable) {
          ${name} = lib.genAttrs coll (k: cfg.${name}.${k});
        };
    }
    else {
      mkOption = null;
      mkConfig = null;
    };
in {
  options.mkContract = lib.mkOption {
    type = lib.types.attrsOf contractSubmodule;
    default = {};
    description = "Declarative capability contracts defined directly in mkContract.";
  };

  config = {
    flake.nixosModules.contracts = {...}: {
      options = lib.mapAttrs (_: c: c.options) config.mkContract;
    };

    flake.lib =
      (lib.mapAttrs (
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
          in
            {
              inherit (c) options types;
            }
            // (lib.optionalAttrs (mkOption != null) {inherit mkOption;})
            // (lib.optionalAttrs (mkConfig != null) {inherit mkConfig;})
            // c.extraLib
        )
        config.mkContract)
      // {
        mkContract = {
          name,
          options,
          types ? {},
          collection ? true,
          mkOption ? null,
          mkConfig ? null,
          extraLib ? {},
        }: {
          mkContract.${name} = {
            inherit options types collection mkOption mkConfig extraLib;
          };
        };
      };
  };
}
