{lib, ...}: let
  sanitizeId = s: builtins.replaceStrings [":" "." "-" "/" "@"] ["_" "_" "_" "_" "_"] s;

  formatNode = node: let
    safeId = sanitizeId node.id;
    label = builtins.replaceStrings ["\""] ["'"] (node.label or node.name or node.id);
  in
    if node.kind == "host" || node.kind == "configuration"
    then "${safeId}([\"${label}\"])"
    else if node.kind == "contract"
    then "${safeId}{{\"${label}\"}}"
    else if node.kind == "implementation"
    then "${safeId}[\"${label}\"]"
    else if node.kind == "feature"
    then "${safeId}(\"${label}\")"
    else if node.kind == "option"
    then "${safeId}[/\"${label}\"/]"
    else if node.kind == "type"
    then "${safeId}[[\"${label}\"]]"
    else if node.kind == "package"
    then "${safeId}[(\"${label}\")]"
    else if node.kind == "devShell"
    then "${safeId}>\"${label}\"]"
    else "${safeId}[\"${label}\"]";

  formatEdge = edge: let
    src = sanitizeId edge.source;
    tgt = sanitizeId edge.target;
    rel = edge.relation;
  in
    if rel == "implements" || rel == "IMPLEMENTS"
    then "${src} == \"implements\" ==> ${tgt}"
    else if rel == "consumes" || rel == "CONSUMES"
    then "${src} -. \"consumes\" .-> ${tgt}"
    else if rel == "flowsTo" || rel == "FLOWS_TO"
    then "${src} -. \"flowsTo\" .-> ${tgt}"
    else if rel == "writes" || rel == "WRITES"
    then "${src} -. \"writes\" .-> ${tgt}"
    else if rel == "reads" || rel == "READS"
    then "${src} -. \"reads\" .-> ${tgt}"
    else if rel == "imports" || rel == "IMPORTS"
    then "${src} -->|\"imports\"| ${tgt}"
    else "${src} -->|\"${rel}\"| ${tgt}";

  toMermaid = {
    layout ? "TD",
    groupByStratum ? false,
  }: graph: let
    nodes = builtins.attrValues graph.nodes;
    validNodeIds = builtins.attrNames graph.nodes;
    validEdges = lib.filter (e: builtins.elem e.source validNodeIds && builtins.elem e.target validNodeIds) graph.edges;

    renderNodes = ns: lib.concatMapStringsSep "\n    " formatNode ns;
    renderEdges = es: lib.concatMapStringsSep "\n    " formatEdge es;

    body =
      if groupByStratum
      then let
        grouped = lib.groupBy (n: n.stratum or "other") nodes;
        subgraphs = map (strat: ''
          subgraph ${strat} ["${strat}"]
            ${renderNodes grouped.${strat}}
          end
        '') (builtins.attrNames grouped);
      in
        lib.concatStringsSep "\n  " subgraphs
        + "\n  "
        + renderEdges validEdges
      else ''
        ${renderNodes nodes}
        ${renderEdges validEdges}
      '';
  in ''
    flowchart ${layout}
      ${body}
  '';
in {
  internal.graph.serializers.mermaid = {
    inherit
      sanitizeId
      formatNode
      formatEdge
      toMermaid
      ;
  };
}
