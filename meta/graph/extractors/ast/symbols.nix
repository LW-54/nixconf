# Syntactic AST library symbol and docstring extractor.
{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;

  rawParseDocstring =
    if config ? primitive && config.primitive ? primitive && config.primitive.primitive ? lib && config.primitive.primitive.lib ? parser
    then config.primitive.primitive.lib.parser.value.parseDocstring
    else if config ? flake && config.flake ? lib && config.flake.lib ? core && config.flake.lib.core ? parseDocstring
    then config.flake.lib.core.parseDocstring
    else null;

  parseDocstring =
    if rawParseDocstring == null
    then (_: {})
    else if builtins.isAttrs rawParseDocstring && rawParseDocstring ? value
    then rawParseDocstring.value
    else rawParseDocstring;

  extractLibSymbolData = {}: let
    libs = config.lib or {};

    libSymbolData = lib.concatMap (ns: let
      l = libs.${ns};
      symAttrs = l.symbols or {};
      libURN = types.mkURN {
        stratum = types.strata.onto;
        kind = "lib";
        id = ns;
      };
    in
      lib.concatMap (symName: let
        rawSym = symAttrs.${symName};
        val =
          if builtins.isAttrs rawSym && rawSym ? value
          then rawSym.value
          else rawSym;
        docstring =
          if builtins.isAttrs rawSym && rawSym ? docstring
          then rawSym.docstring
          else null;
        parsedDoc =
          if parseDocstring != null && docstring != null
          then parseDocstring docstring
          else null;
        kind =
          if builtins.isFunction val
          then "function"
          else "symbol";
        fullName = "${ns}.${symName}";
        urn = types.mkURN {
          stratum = types.strata.ast;
          inherit kind;
          id = fullName;
        };
      in
        if symName == "types" || symName == "options"
        then []
        else [
          {
            node = types.mkNode {
              stratum = types.strata.ast;
              inherit kind;
              id = fullName;
              label = fullName;
              origin = {
                stratum = types.strata.onto;
                kind = "lib";
                instance = ns;
                facet = "symbols";
              };
              meta = {
                summary =
                  if parsedDoc != null
                  then parsedDoc.summary
                  else "";
                body =
                  if parsedDoc != null
                  then parsedDoc.body
                  else "";
                inputs =
                  if parsedDoc != null
                  then parsedDoc.inputs
                  else [];
                typeSignature =
                  if parsedDoc != null
                  then parsedDoc.typeSignature
                  else "";
                examples =
                  if parsedDoc != null
                  then parsedDoc.examples
                  else "";
              };
            };
            outputEdge = types.mkEdge {
              source = libURN;
              target = urn;
              relation = types.relations.OUTPUTS;
              stratum = types.strata.ast;
              meta = {facet = "symbols";};
            };
          }
        ]) (builtins.attrNames symAttrs))
    (builtins.attrNames libs);

    symbolNodes = lib.listToAttrs (map (d: lib.nameValuePair d.node.id d.node) libSymbolData);
    symbolOutputEdges = map (d: d.outputEdge) libSymbolData;
  in {
    inherit symbolNodes symbolOutputEdges;
  };
in {
  internal.graph.extractors.astSymbols = {
    inherit extractLibSymbolData parseDocstring;
  };
}
