{
  lib,
  config,
  ...
}: let
  types = config.internal.graph.core.types;
  algebra = config.internal.graph.core.algebra;
  container = config.internal.graph.core.container;

  /**
  Quotient Functor Pi_arch: Projects the fine-grained CPG into the macro Architectural Graph.
  Contracts operational modules into their defining features/implementations/hosts,
  and maps operational imports and writes into macro architectural relationships.
  */
  toArchitectureLPGFn = {cpg}: let
    # 1. Map fine-grained CPG node to its macro architectural container
    resolveMacroURN = node:
      if node.stratum == types.strata.onto
      then node.id
      else if node.stratum == types.strata.eval && node.kind == "configuration"
      then
        types.mkURN {
          stratum = types.strata.onto;
          kind = "host";
          id = node.name;
        }
      else if node.stratum == types.strata.ast && node.kind == "module"
      then let
        prodPrim = node.origin.producerPrimitive or (node.origin.primitive or null);
        prodInst = node.origin.producerInstance or (node.origin.instance or null);
      in
        if prodPrim != null && prodInst != null && prodPrim != "workspace"
        then
          types.mkURN {
            stratum = types.strata.onto;
            kind = prodPrim;
            id = prodInst;
          }
        else node.id
      else node.id;

    # 2. Extract macro nodes: all ontological instances + contract options/types if desired
    macroOntoNodes = lib.filterAttrs (_: n: n.stratum == types.strata.onto && n.kind != "primitive") cpg.nodes;

    # 3. Derive macro IMPORTS edges: Host -> Feature / Implementation
    cfgImportEdges = lib.filter (e: e.relation == types.relations.IMPORTS) cpg.edges;
    macroImportEdges = lib.concatMap (e: let
      srcNode = cpg.nodes.${e.source} or null;
      tgtNode = cpg.nodes.${e.target} or null;
      macroSrc =
        if srcNode != null
        then resolveMacroURN srcNode
        else e.source;
      macroTgt =
        if tgtNode != null
        then resolveMacroURN tgtNode
        else e.target;
    in
      if macroSrc != macroTgt && macroOntoNodes ? ${macroSrc} && macroOntoNodes ? ${macroTgt}
      then [
        (types.mkEdge {
          source = macroSrc;
          target = macroTgt;
          relation = "IMPORTS";
          stratum = types.strata.onto;
          meta = {
            host = srcNode.name or "unknown";
            importedModule = tgtNode.name or "unknown";
          };
        })
      ]
      else [])
    cfgImportEdges;

    # 4. Derive macro CONSUMES edges: Feature/Host -> Contract (via option writes)
    writesEdges = lib.filter (e: e.relation == types.relations.WRITES) cpg.edges;
    macroConsumesEdges = lib.concatMap (e: let
      srcNode = cpg.nodes.${e.source} or null;
      macroSrc =
        if srcNode != null
        then resolveMacroURN srcNode
        else e.source;
      optNode = cpg.nodes.${e.target} or null;
      cName = optNode.meta.contract or null;
      cURN =
        if cName != null
        then
          types.mkURN {
            stratum = types.strata.onto;
            kind = "contract";
            id = cName;
          }
        else null;
    in
      if cURN != null && macroSrc != cURN && macroOntoNodes ? ${macroSrc} && macroOntoNodes ? ${cURN}
      then [
        (types.mkEdge {
          source = macroSrc;
          target = cURN;
          relation = "CONSUMES";
          stratum = types.strata.onto;
          qualifier = optNode.name or null;
          meta = {
            optionWritten = optNode.name or "unknown";
          };
        })
      ]
      else [])
    writesEdges;

    # 5. Macro IMPLEMENTS edges
    implEdges = map (e:
      types.mkEdge {
        source = e.source;
        target = e.target;
        relation = "IMPLEMENTS";
        stratum = types.strata.onto;
        meta = e.meta;
      }) (lib.filter (e: e.relation == types.relations.IMPLEMENTS) cpg.edges);

    allMacroNodes = macroOntoNodes;
    allMacroEdges = container.dedupEdges (macroImportEdges ++ macroConsumesEdges ++ implEdges);
  in
    container.mkGraph {
      nodes = allMacroNodes;
      edges = allMacroEdges;
      meta = {
        projection = "ArchitectureLPG";
        version = 1;
      };
    };
in {
  internal.graph.projections.architecture = {
    toArchitectureLPG = toArchitectureLPGFn;
  };
}
