{lib, ...}: let
  sanitizeId = s: builtins.replaceStrings [":" "." "-" "/" "@"] ["_" "_" "_" "_" "_"] s;

  formatNode = node: let
    safeId = sanitizeId node.id;
    label = builtins.replaceStrings ["\""] ["'"] (node.label or node.name or node.id);
    shape =
      if node.kind == "host" || node.kind == "configuration"
      then "stadium"
      else if node.kind == "contract"
      then "hexagon"
      else if node.kind == "implementation"
      then "box"
      else if node.kind == "feature"
      then "ellipse"
      else if node.kind == "option"
      then "parallelogram"
      else if node.kind == "package"
      then "cylinder"
      else "box";
  in "\"${safeId}\" [label=\"${label}\" shape=\"${shape}\"];";

  formatEdge = edge: let
    src = sanitizeId edge.source;
    tgt = sanitizeId edge.target;
    rel = edge.relation;
    style =
      if rel == "writes" || rel == "reads" || rel == "flowsTo" || rel == "consumes" || rel == "CONSUMES"
      then "dashed"
      else if rel == "implements" || rel == "IMPLEMENTS"
      then "bold"
      else "solid";
  in "\"${src}\" -> \"${tgt}\" [label=\"${rel}\" style=\"${style}\"];";

  toDot = graph: let
    nodes = builtins.attrValues graph.nodes;
    validNodeIds = builtins.attrNames graph.nodes;
    validEdges = lib.filter (e: builtins.elem e.source validNodeIds && builtins.elem e.target validNodeIds) graph.edges;

    nodeLines = lib.concatMapStringsSep "\n  " formatNode nodes;
    edgeLines = lib.concatMapStringsSep "\n  " formatEdge validEdges;
  in ''
    digraph G {
      rankdir="LR";
      node [fontname="Helvetica" fontsize="10"];
      edge [fontname="Helvetica" fontsize="9"];

      ${nodeLines}

      ${edgeLines}
    }
  '';
in {
  internal.graph.serializers.dot = {
    inherit
      toDot
      ;
  };
}
