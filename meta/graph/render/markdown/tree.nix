{lib, ...}: let
  /**
  Renders a DAG or tree structure into an indented markdown bullet list.
  */
  renderMarkdownBullets = {
    graph,
    roots,
    relation ? null,
    formatNode ? (n: "`${n.name or n.id}`"),
    maxDepth ? 10,
  }: let
    walk = nodeId: depth: visited: let
      node =
        graph.nodes.${
          nodeId
        } or {
          id = nodeId;
          name = nodeId;
        };
      indent = lib.concatStrings (lib.genList (_: "  ") depth);
      line = "${indent}- ${formatNode node}";
      outEdges =
        if depth >= maxDepth || builtins.elem nodeId visited
        then []
        else
          lib.filter (
            e:
              e.source
              == nodeId
              && (relation == null || e.relation == relation)
          )
          graph.edges;
      childLines =
        builtins.concatMap (
          e: walk e.target (depth + 1) (visited ++ [nodeId])
        )
        outEdges;
    in
      [line] ++ childLines;

    rootIds = map (r:
      if builtins.isAttrs r
      then r.id
      else r)
    roots;
    allLines = builtins.concatMap (rId: walk rId 0 []) rootIds;
  in
    if allLines == []
    then "*Empty tree.*"
    else lib.concatStringsSep "\n" allLines;

  /**
  Renders a DAG or tree structure into formatted ASCII tree lines (├──, └──, │).
  */
  renderAsciiTree = {
    graph,
    roots,
    relation ? null,
    formatNode ? (n: n.name or n.id),
    maxDepth ? 10,
  }: let
    walk = nodeId: prefix: isLast: depth: visited: let
      node =
        graph.nodes.${
          nodeId
        } or {
          id = nodeId;
          name = nodeId;
        };
      nodeText = formatNode node;
      connector =
        if depth == 0
        then ""
        else if isLast
        then "└── "
        else "├── ";
      currentLine = "${prefix}${connector}${nodeText}";
      childPrefix =
        if depth == 0
        then ""
        else if isLast
        then "${prefix}    "
        else "${prefix}│   ";

      outEdges =
        if depth >= maxDepth || builtins.elem nodeId visited
        then []
        else
          lib.filter (
            e:
              e.source
              == nodeId
              && (relation == null || e.relation == relation)
          )
          graph.edges;
      numChildren = builtins.length outEdges;
      indexedChildren =
        lib.imap0 (i: e: {
          target = e.target;
          isLastChild = (i + 1) == numChildren;
        })
        outEdges;

      childLines =
        builtins.concatMap (
          c: walk c.target childPrefix c.isLastChild (depth + 1) (visited ++ [nodeId])
        )
        indexedChildren;
    in
      [currentLine] ++ childLines;

    rootIds = map (r:
      if builtins.isAttrs r
      then r.id
      else r)
    roots;
    numRoots = builtins.length rootIds;
    indexedRoots =
      lib.imap0 (i: rId: {
        id = rId;
        isLastRoot = (i + 1) == numRoots;
      })
      rootIds;

    allLines =
      builtins.concatMap (
        r: walk r.id "" r.isLastRoot 0 []
      )
      indexedRoots;
  in
    if allLines == []
    then "Empty tree."
    else lib.concatStringsSep "\n" allLines;

  /**
  Unified tree renderer supporting both markdown bullets and ASCII blocks.
  */
  renderTree = {
    graph,
    roots,
    relation ? null,
    style ? "markdown", # "markdown" | "ascii"
    format ? null, # Alias for style
    formatNode ? null,
    maxDepth ? 10,
  }: let
    activeStyle =
      if format != null
      then format
      else style;
  in
    if activeStyle == "ascii"
    then let
      fn =
        if formatNode != null
        then formatNode
        else n: n.name or n.id;
      ascii = renderAsciiTree {
        inherit
          graph
          roots
          relation
          maxDepth
          ;
        formatNode = fn;
      };
    in ''
      ```text
      ${ascii}
      ```
    ''
    else let
      fn =
        if formatNode != null
        then formatNode
        else n: "`${n.name or n.id}`";
    in
      renderMarkdownBullets {
        inherit
          graph
          roots
          relation
          maxDepth
          ;
        formatNode = fn;
      };
in {
  internal.graph.render.markdown.tree = {
    inherit
      renderMarkdownBullets
      renderAsciiTree
      renderTree
      ;
  };
}
