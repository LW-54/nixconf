{
  lib,
  unwrapLib,
  ...
}: {
  primitive.lib = {
    description = "Pure reusable helper functions, data types, calculations, and configuration presets exported across the repository.";

    options = {
      symbols = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Exported library functions and values under flake.lib.<name>.<symbol>.";
      };
    };

    outputs = {
      instances,
      lib,
      ...
    }: {
      options.flake.lib = lib.mkOption {
        type = lib.types.lazyAttrsOf lib.types.raw;
        default = {};
        description = "Repository helper library functions and values.";
      };

      config.flake.lib =
        lib.mapAttrs (_: l: unwrapLib l.symbols)
        (lib.filterAttrs (_: l: l.symbols != {}) instances);
    };
  };
}
