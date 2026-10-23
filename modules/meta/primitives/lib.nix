{
  lib,
  config,
  ...
}: let
  libSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      description = lib.mkOption {
        type = lib.types.str;
        description = "Formal description of this library namespace and its capabilities.";
      };

      symbols = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Exported library functions and values under flake.lib.<name>.<symbol>.";
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
  options.flake.lib = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
    description = "Repository helper library functions and values.";
  };

  options.lib = lib.mkOption {
    type = lib.types.attrsOf libSubmodule;
    default = {};
    description = "Pure reusable helper functions, data types, calculations, and configuration presets exported across the repository.";
  };

  config = {
    flake.lib =
      lib.mapAttrs (_: l: unwrapLib l.symbols)
      (lib.filterAttrs (_: l: l.symbols != {}) config.lib);
  };
}
