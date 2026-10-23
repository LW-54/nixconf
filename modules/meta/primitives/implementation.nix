{
  lib,
  config,
  ...
}: let
  implSubmodule = lib.types.submodule {
    options = {
      contract = lib.mkOption {
        type = lib.types.str;
        description = "Name of the capability contract this module implements.";
      };
      description = lib.mkOption {
        type = lib.types.str;
        description = "Formal description of how this provider satisfies the contract capability.";
      };
      module = lib.mkOption {
        type = lib.types.deferredModule;
        description = "NixOS module implementing the contract capability.";
      };
      packages = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Implementation package declarations or generator function.";
      };
      devShells = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Implementation development shells or generator function.";
      };
      lib = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Exported library helpers and identity definitions on flake.lib.<name>.";
      };
    };
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
  options.implementation = lib.mkOption {
    type = lib.types.attrsOf implSubmodule;
    default = {};
    description = "Concrete capability providers satisfying contract interfaces by translating abstract capability options into provider-specific NixOS services, packages, and system configurations.";
  };

  config = {
    lib =
      lib.mapAttrs (_: impl: {
        description = impl.description;
        symbols = impl.lib;
      })
      (lib.filterAttrs (_: impl: impl.lib != {}) config.implementation);

    flake.nixosModules = lib.mapAttrs (_: impl: impl.module) config.implementation;

    perSystem = {
      pkgs,
      self',
      ...
    } @ args: {
      packages = lib.mkMerge (lib.mapAttrsToList (
          _: impl:
            if builtins.isFunction impl.packages
            then impl.packages args
            else impl.packages
        )
        config.implementation);

      devShells = lib.mkMerge (lib.mapAttrsToList (
          _: impl:
            if builtins.isFunction impl.devShells
            then impl.devShells args
            else impl.devShells
        )
        config.implementation);
    };
  };
}
