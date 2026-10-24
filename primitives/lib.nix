{
  lib,
  option,
  unwrapLib,
  ...
}: {
  primitive.lib = {
    schema = option.schema {
      what = "Exported library symbols";
      doc = "Pure reusable helper functions, data types, calculations, and configuration presets exported across the repository.";
      checks = {
        hasSymbols = inst: {
          valid = (inst ? symbols && (inst.symbols or {}) != {}) || (builtins.isAttrs inst && inst != {});
          message = "Library definition must export symbols.";
        };
        hasDescription = inst: {
          valid = (inst.description or "") != "" || (builtins.isAttrs inst && inst != {});
          message = "Library module must have symbols or description.";
        };
      };
    };

    relationships = {};

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
      flake.lib =
        lib.mapAttrs (_: l: unwrapLib l.symbols)
        (lib.filterAttrs (_: l: l.symbols != {}) instances);
    };
  };
}
