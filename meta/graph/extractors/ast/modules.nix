# Syntactic AST module node and OUTPUTS edge extractor.
{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  source = config.internal.graph.extractors.source;
  inherit (source) instanceSourceText referenceConfiguration;

  # Generative provenance mapping: flake.nixosModules attribute -> producing primitive instance.
  moduleProducerMap = let
    kinds = builtins.attrNames (lib.filterAttrs (n: _: n != "primitive" && n != "lib") (config.primitive or {}));
    entry = kind: instance: facet: {
      primitive = kind;
      inherit instance facet;
    };
    forInstance = kind: iName: iDef:
      lib.optionalAttrs (iDef ? configuration) {${iName} = entry kind iName "configuration";}
      // lib.mapAttrs (_: _: entry kind iName "subModules") (iDef.subModules or {})
      // lib.optionalAttrs (iDef ? module) {${iName} = entry kind iName "module";}
      // lib.mapAttrs' (mKey: _:
        lib.nameValuePair (
          if mKey == "default"
          then iName
          else mKey
        ) (entry kind iName "modules"))
      (iDef.modules or {});
  in
    lib.foldl' (acc: kind: acc // lib.concatMapAttrs (forInstance kind) (config.${kind} or {})) {} kinds;

  /*
  Describes an exported NixOS module without hardcoded prose. Resolution order:
  1. `docs.modules.<name>` declared on the producing primitive instance,
  2. `docs.modules.<name>` declared on any primitive (modules synthesized by primitive outputs),
  3. the description of a primitive instance carrying the same name as the module,
  4. a generic sentence naming the producing instance.
  */
  describeModule = {
    name,
    producer ? moduleProducerMap.${name} or null,
  }: let
    primitives = lib.filterAttrs (n: _: n != "primitive") (config.primitive or {});
    producerInst =
      if producer != null && primitives ? ${producer.primitive or ""}
      then (config.${producer.primitive} or {}).${producer.instance} or null
      else null;
    fromProducer =
      if producerInst != null
      then producerInst.docs.modules.${name} or null
      else null;
    fromPrimitives = lib.findFirst (d: d != null) null (lib.mapAttrsToList (_: p: p.docs.modules.${name} or null) (config.primitive or {}));
    sameName = lib.findFirst (d: d != null) null (lib.mapAttrsToList (kind: _: ((config.${kind} or {}).${name} or {}).description or null) primitives);
  in
    if fromProducer != null
    then fromProducer
    else if fromPrimitives != null
    then fromPrimitives
    else if sameName != null
    then sameName
    else if producerInst != null
    then "NixOS module exported by ${producer.primitive} '${producer.instance}'."
    else "Exported NixOS module '${name}'.";

  extractModuleData = {}: let
    hosts = config.host or {};
    flakeModules = config.flake.nixosModules or {};
    moduleNames = builtins.attrNames flakeModules;

    moduleData =
      map (mName: let
        producer =
          moduleProducerMap.${
            mName
          } or {
            primitive = "workspace";
            instance = "nixosModules";
            facet = mName;
          };
        urn = types.mkURN {
          stratum = types.strata.ast;
          kind = "module";
          id = mName;
        };
        resolveModuleDesc = name:
          describeModule {
            inherit name producer;
          };

        importingHosts = lib.filter (
          hName: let
            hostContent = instanceSourceText "host" hName;
          in
            lib.hasInfix "nixosModules.${mName}" hostContent
            || builtins.elem (config.flake.nixosModules.${mName} or null) ((hosts.${hName} or {}).modules or [])
        ) (builtins.attrNames hosts);

        hostConfigurations = lib.genAttrs importingHosts (hName: let
          hostContent = instanceSourceText "host" hName;
          lines = lib.splitString "\n" hostContent;
          countChars = char: s: builtins.length (lib.filter (c: c == char) (lib.stringToCharacters s));
          isMatch = line: lib.hasInfix "${mName}." line || lib.hasInfix "self.nixosModules.${mName}" line;
          matchingIndices = lib.filter (i: isMatch (builtins.elemAt lines i)) (lib.range 0 (builtins.length lines - 1));
          extractBlockFrom = startIdx: let
            rem = lib.sublist startIdx (builtins.length lines - startIdx) lines;
            folder = acc: line:
              if acc.done
              then acc
              else let
                opens = (countChars "{" line) + (countChars "(" line);
                closes = (countChars "}" line) + (countChars ")" line);
                newDepth = acc.depth + opens - closes;
                hasSemi = lib.hasSuffix ";" (lib.removeSuffix " " line);
                done = (acc.depth > 0 && newDepth <= 0) || (acc.depth == 0 && opens > 0 && opens == closes) || (acc.depth == 0 && hasSemi);
              in {
                depth = newDepth;
                lines = acc.lines ++ [line];
                done = done;
              };
            res =
              lib.foldl' folder {
                depth = 0;
                lines = [];
                done = false;
              }
              rem;
          in
            lib.concatStringsSep "\n" res.lines;
        in
          if matchingIndices == []
          then ""
          else extractBlockFrom (builtins.head matchingIndices));

        findModuleOptions = name: let
          findInTree = path: attrs:
            lib.concatMap (k: let
              v = attrs.${k};
              currPath =
                if path == ""
                then k
                else "${path}.${k}";
            in
              if builtins.isAttrs v && (v ? type || (v ? _type && v._type == "option"))
              then [
                {
                  path = currPath;
                  type = v.type.description or (v.type.name or "anything");
                  description = v.description or "";
                  default =
                    if v ? defaultText
                    then v.defaultText
                    else if v ? default
                    then v.default
                    else null;
                  example =
                    if v ? exampleText
                    then v.exampleText
                    else if v ? example
                    then v.example
                    else null;
                }
              ]
              else if builtins.isAttrs v
              then findInTree currPath v
              else []) (builtins.attrNames attrs);
          referenceOptions = referenceConfiguration.options or {};
          matchingTree = referenceOptions.${name} or null;
        in
          if matchingTree != null && builtins.isAttrs matchingTree
          then findInTree name matchingTree
          else [];

        node = types.mkNode {
          stratum = types.strata.ast;
          kind = "module";
          id = mName;
          label = "nixosModule/${mName}";
          origin = producer;
          meta = {
            producerPrimitive = producer.primitive;
            producerInstance = producer.instance;
            description = resolveModuleDesc mName;
            inherit importingHosts hostConfigurations;
            options = findModuleOptions mName;
          };
        };
        outputEdge =
          if producer.primitive != "workspace"
          then [
            (types.mkEdge {
              source = types.mkURN {
                stratum = types.strata.onto;
                kind = producer.primitive;
                id = producer.instance;
              };
              target = urn;
              relation = types.relations.OUTPUTS;
              stratum = types.strata.ast;
              meta = {facet = producer.facet;};
            })
          ]
          else [];
      in {
        inherit node outputEdge;
      })
      moduleNames;

    moduleNodes = lib.listToAttrs (map (d: lib.nameValuePair d.node.id d.node) moduleData);
    moduleOutputEdges = lib.concatMap (d: d.outputEdge) moduleData;
  in {
    inherit moduleNodes moduleOutputEdges moduleProducerMap;
  };
in {
  internal.graph.extractors.astModules = {
    inherit extractModuleData moduleProducerMap describeModule;
  };
}
