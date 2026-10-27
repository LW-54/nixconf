{
  lib,
  config,
  ...
}: let
  theme = config.internal.graph.render.mermaid.theme;

  /**
  Renders an arbitrary LPG graph or subgraph into an advanced, themed Mermaid flowchart.
  Supports dynamic clustering/subgraphs, clickable hyperlinks, and edge value annotations.
  */
  renderFlowchart = {
    graph,
    layout ? "TD",
    clusterBy ? null,
    includeTheme ? true,
    linkFn ? null,
    tooltipFn ? null,
    customNodeFormatter ? null,
    customEdgeFormatter ? null,
    title ? null,
  }: let
    nodes = builtins.attrValues graph.nodes;
    validNodeIds = builtins.attrNames graph.nodes;
    validEdges =
      lib.filter (
        e:
          builtins.elem e.source validNodeIds
          && builtins.elem e.target validNodeIds
      )
      graph.edges;

    formatNode =
      if customNodeFormatter != null
      then customNodeFormatter
      else theme.formatNode;

    formatEdge =
      if customEdgeFormatter != null
      then customEdgeFormatter
      else theme.formatEdge;

    renderNodeList = ns: lib.concatMapStringsSep "\n    " formatNode ns;
    renderEdgeList = es: lib.concatMapStringsSep "\n    " formatEdge es;

    # Cluster / Subgraph grouping
    clusterLambda =
      if clusterBy == "stratum"
      then n: n.stratum or "other"
      else if clusterBy == "kind"
      then n: n.kind or "other"
      else if builtins.isFunction clusterBy
      then clusterBy
      else null;

    body =
      if clusterLambda != null
      then let
        grouped = lib.groupBy clusterLambda nodes;
        subgraphs = map (cKey: let
          clusterNodes = grouped.${cKey};
          clusterSafeId = theme.sanitizeId "cluster_${cKey}";
        in ''
          subgraph ${clusterSafeId} ["${cKey}"]
            ${renderNodeList clusterNodes}
          end
        '') (builtins.attrNames grouped);
      in
        lib.concatStringsSep "\n  " subgraphs
        + (
          if validEdges != []
          then "\n\n  " + renderEdgeList validEdges
          else ""
        )
      else ''
        ${renderNodeList nodes}
        ${
          if validEdges != []
          then "\n    " + renderEdgeList validEdges
          else ""
        }
      '';

    # Click hyperlinks
    clickLines =
      if linkFn != null
      then let
        makeClick = n: let
          url = linkFn n;
          safeId = theme.sanitizeId n.id;
          tooltip =
            if tooltipFn != null
            then tooltipFn n
            else n.name or n.id;
        in
          if url != null && url != ""
          then "    click ${safeId} href \"${url}\" \"${theme.escapeLabel tooltip}\""
          else null;
        rawClicks = lib.filter (c: c != null) (map makeClick nodes);
      in
        if rawClicks != []
        then "\n\n" + lib.concatStringsSep "\n" rawClicks
        else ""
      else "";

    themeSection =
      if includeTheme
      then "\n\n  %% Semantic Visual Classes\n  " + lib.concatStringsSep "\n  " (lib.splitString "\n" (lib.trim theme.classDefs))
      else "";

    titleSection =
      if title != null
      then "--- title: ${title} ---\n"
      else "";
  in
    if nodes == []
    then "flowchart ${layout}\n    empty[\"Empty Graph\"]"
    else ''
      ${titleSection}flowchart ${layout}
        ${body}${clickLines}${themeSection}
    '';
in {
  internal.graph.render.mermaid.flowchart = {
    inherit renderFlowchart;
  };
}
