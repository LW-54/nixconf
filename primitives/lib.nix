{
  check,
  lib,
  option,
  unwrapLib,
  parser,
  ...
}: {
  primitive.lib = {
    schema = option.schema {
      what = "Exported library symbols";
      doc = "Pure reusable helper functions, data types, calculations, and configuration presets exported across the repository.";
      checks = {
        hasSymbols = check.any [
          (check.hasNonEmptyAttrs "symbols")
          (inst: builtins.isAttrs inst && inst != {})
        ];
        hasDescription = check.any [
          (check.hasString "description")
          (inst: builtins.isAttrs inst && inst != {})
        ];
        validSymbols = check.validSymbols;
      };
    };

    relationships = {};

    schemas = name: l:
      lib.mapAttrs (
        symName: rawSym: let
          hasDocAttr = builtins.isAttrs rawSym && rawSym ? docstring && rawSym.docstring != null;
          rawComment =
            if hasDocAttr
            then rawSym.docstring
            else null;
          val =
            if builtins.isAttrs rawSym && rawSym ? value
            then rawSym.value
            else rawSym;
          parsedDoc =
            if parser != null
            then parser.parseDocstring rawComment
            else null;
          isFn = builtins.isFunction val;
          isContainer = symName == "types" || symName == "options";
        in {
          what =
            if symName == "types"
            then "type-definitions"
            else if symName == "options"
            then "option-definitions"
            else if isFn
            then "function"
            else "symbol";
          shortDescription =
            if parsedDoc != null
            then parsedDoc.summary
            else if isContainer
            then "${symName} definitions for ${name}."
            else "";
          evalChecks =
            if isContainer
            then {
              isAttrs = builtins.isAttrs rawSym;
            }
            else {
              validDocstring =
                (check.validDocstring {
                  name = "${name}.${symName}";
                  inherit val parsedDoc;
                })
                == [];
            };
        }
      )
      (l.symbols or {});

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
