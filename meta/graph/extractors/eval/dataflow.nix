# Operational fixpoint dataflow channel extractor (WRITES, READS, FLOWS_TO).
{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  astExtractor = config.internal.graph.extractors.ast;

  cleanSourcePath = p: let
    s = builtins.unsafeDiscardStringContext (toString p);
    afterSource = lib.last (lib.splitString "-source/" s);
    afterRepo =
      if lib.hasInfix "nixconf/" afterSource
      then lib.last (lib.splitString "nixconf/" afterSource)
      else afterSource;
  in
    lib.removePrefix "/nix/store/" afterRepo;

  parseViaOption = s:
    if lib.hasInfix ", via option " s
    then let
      parts = lib.splitString ", via option " s;
      filePath = builtins.elemAt parts 0;
      via = builtins.elemAt parts 1;
      tokens = lib.splitString "." via;
      primKind = builtins.elemAt tokens 0;
      instName =
        if builtins.length tokens > 1
        then builtins.elemAt tokens 1
        else null;
      facet =
        if builtins.length tokens > 2
        then lib.concatStringsSep "." (lib.drop 2 tokens)
        else null;
    in {
      file = cleanSourcePath filePath;
      inherit via primKind instName facet;
    }
    else {
      file = cleanSourcePath s;
      via = null;
      primKind = null;
      instName = null;
      facet = null;
    };

  extractScalarValue = val: let
    try = builtins.tryEval val;
  in
    if !try.success
    then "<eval-error>"
    else let
      v = try.value;
    in
      if v == null
      then null
      else if builtins.isBool v || builtins.isInt v || builtins.isFloat v
      then v
      else if builtins.isString v
      then builtins.substring 0 200 (builtins.unsafeDiscardStringContext v)
      else if builtins.isList v
      then
        if builtins.length v <= 20
        then
          map (
            elem: let
              elemTry = builtins.tryEval elem;
            in
              if !elemTry.success
              then "<eval-error>"
              else if builtins.isAttrs elemTry.value || builtins.isFunction elemTry.value
              then "<${builtins.typeOf elemTry.value}>"
              else extractScalarValue elemTry.value
          )
          v
        else "<list[${toString (builtins.length v)}]>"
      else "<${builtins.typeOf v}>";

  extractHostDataFlow = {
    hName,
    nixosConfigs ? config.flake.nixosConfigurations or {},
    activeContractImplementersByHost,
    contractNames ? builtins.attrNames (config.contract or {}),
    flakeModules ? config.flake.nixosModules or {},
  }: let
    hCfg = nixosConfigs.${hName} or null;
    activeImplsForHost = activeContractImplementersByHost.${hName} or {};
  in
    if hCfg == null
    then []
    else
      lib.concatMap (cName: let
        matchingTree = hCfg.options.${cName} or null;
        contractOpts =
          if matchingTree != null && builtins.isAttrs matchingTree
          then astExtractor.flattenOptionsTree cName matchingTree
          else [];
        activeImplName = activeImplsForHost.${cName} or null;
        consumerModuleURN =
          if activeImplName != null
          then
            types.mkURN {
              stratum = types.strata.ast;
              kind = "module";
              id = activeImplName;
            }
          else null;
      in
        lib.concatMap ({
          path,
          option,
        }: let
          optURN = types.mkURN {
            stratum = types.strata.ast;
            kind = "option";
            id = path;
          };
          defs = option.definitionsWithLocations or [];
          resolvedVal = let
            pathList = lib.splitString "." path;
            valTry = builtins.tryEval (lib.attrByPath pathList null hCfg.config);
          in
            if valTry.success
            then extractScalarValue valTry.value
            else "<unevaluated>";
        in
          lib.concatMap (def: let
            parsed = parseViaOption def.file;

            subModCandidate =
              if parsed.facet != null && lib.hasPrefix "modules." parsed.facet
              then lib.removePrefix "modules." parsed.facet
              else if parsed.facet != null && lib.hasPrefix "subModules." parsed.facet
              then lib.removePrefix "subModules." parsed.facet
              else parsed.instName;

            writerModuleURN =
              if subModCandidate != null && flakeModules ? ${subModCandidate}
              then
                types.mkURN {
                  stratum = types.strata.ast;
                  kind = "module";
                  id = subModCandidate;
                }
              else if parsed.primKind != null && parsed.instName != null && config.${parsed.primKind} ? ${parsed.instName}
              then
                types.mkURN {
                  stratum = types.strata.onto;
                  kind = parsed.primKind;
                  id = parsed.instName;
                }
              else null;
          in
            if writerModuleURN == null
            then []
            else let
              writesEdge = types.mkEdge {
                source = writerModuleURN;
                target = optURN;
                relation = types.relations.WRITES;
                stratum = types.strata.eval;
                qualifier = hName;
                meta = {
                  host = hName;
                  path = path;
                  file = parsed.file;
                  valueType = builtins.typeOf (def.value or null);
                  resolvedValue = resolvedVal;
                };
              };

              readsEdge =
                if consumerModuleURN != null
                then [
                  (types.mkEdge {
                    source = consumerModuleURN;
                    target = optURN;
                    relation = types.relations.READS;
                    stratum = types.strata.eval;
                    qualifier = hName;
                    meta = {
                      host = hName;
                      path = path;
                    };
                  })
                ]
                else [];

              flowsToEdge =
                if consumerModuleURN != null && writerModuleURN != consumerModuleURN
                then [
                  (types.mkEdge {
                    source = writerModuleURN;
                    target = consumerModuleURN;
                    relation = types.relations.FLOWS_TO;
                    stratum = types.strata.eval;
                    qualifier = "${hName}:${builtins.replaceStrings ["."] ["-"] path}";
                    meta = {
                      host = hName;
                      viaOption = path;
                      resolvedValue = resolvedVal;
                    };
                  })
                ]
                else [];
            in
              [writesEdge] ++ readsEdge ++ flowsToEdge)
          defs)
        contractOpts)
      contractNames;
in {
  internal.graph.extractors.evalDataflow = {
    inherit extractHostDataFlow cleanSourcePath parseViaOption extractScalarValue;
  };
}
