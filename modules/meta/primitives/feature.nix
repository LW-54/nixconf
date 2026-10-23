{
  lib,
  config,
  ...
}: let
  featureSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      description = lib.mkOption {
        type = lib.types.str;
        description = "Formal description of this system feature.";
      };

      modules = lib.mkOption {
        type = lib.types.attrsOf lib.types.deferredModule;
        default = {};
        description = "NixOS modules exported by this feature.";
      };

      packages = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Attribute set or function ({ pkgs, ... }: { ... }) of packages provided by this feature.";
      };

      devShells = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Attribute set or function ({ pkgs, ... }: { ... }) of development shells provided by this feature.";
      };

      lib = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Library helper functions and values exported on flake.lib.<name>.";
      };

      types = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Custom types declared and exported by this feature.";
      };
    };
  });

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
  options.feature = lib.mkOption {
    type = lib.types.attrsOf featureSubmodule;
    default = {};
    description = "Reusable system configurations, applications, desktop environments, development toolchains, and services that consume contracts to integrate with the host system.";
  };

  config = {
    lib =
      lib.mapAttrs (_: feat: {
        description = feat.description;
        symbols = feat.lib;
      })
      (lib.filterAttrs (_: feat: feat.lib != {}) config.feature);

    flake.nixosModules = lib.mkMerge (lib.mapAttrsToList (
        featName: feat:
          lib.concatMapAttrs (modName: mod: {
            "${
              if modName == "default"
              then featName
              else modName
            }" =
              mod;
          })
          feat.modules
      )
      config.feature);

    perSystem = {
      pkgs,
      self',
      ...
    } @ args: {
      packages = lib.mkMerge (lib.mapAttrsToList (
          _: feat:
            if builtins.isFunction feat.packages
            then feat.packages args
            else feat.packages
        )
        config.feature);

      devShells = lib.mkMerge (lib.mapAttrsToList (
          _: feat:
            if builtins.isFunction feat.devShells
            then feat.devShells args
            else feat.devShells
        )
        config.feature);
    };
  };
}
