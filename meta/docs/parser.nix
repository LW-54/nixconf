{config, ...}: let
  symbols = config.primitive.primitive.lib.parser.value;
in {
  lib.docsParser = {
    description = "Pure-Nix RFC 145 docstring parser utilities for functions and library symbols.";
    inherit symbols;
  };
}
