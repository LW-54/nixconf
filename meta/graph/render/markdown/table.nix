{lib, ...}: let
  escapeCell = val: let
    s = toString (
      if val == null
      then ""
      else if builtins.isBool val
      then
        (
          if val
          then "true"
          else "false"
        )
      else val
    );
    noNewlines = builtins.replaceStrings ["\n" "\r"] [" " " "] s;
  in
    builtins.replaceStrings ["|"] ["\\|"] noNewlines;

  formatAlign = a:
    if a == "center" || a == "centre"
    then ":---:"
    else if a == "right"
    then "---:"
    else ":---";

  /**
  Renders an arbitrary markdown table from rows and column definitions.
  Args:
    headers: List of header titles [ String ]
    columns: List of extractors [ (Row -> Any) | String ]
    rows: List of data items [ Any ]
    align: Optional list of column alignments ("left" | "center" | "right")
    sortBy: Optional sorting key lambda (Row -> String)
    reverse: Optional boolean to reverse sort order
  */
  renderTable = {
    headers,
    columns,
    rows,
    align ? [],
    sortBy ? null,
    reverse ? false,
  }: let
    colFns =
      map (
        col:
          if builtins.isFunction col
          then col
          else row: row.${col} or ""
      )
      columns;

    sortedRows =
      if sortBy != null
      then let
        sorted = lib.sort (a: b: (toString (sortBy a)) < (toString (sortBy b))) rows;
      in
        if reverse
        then lib.reverseList sorted
        else sorted
      else rows;

    alignList = lib.genList (
      i:
        if i < builtins.length align
        then formatAlign (builtins.elemAt align i)
        else ":---"
    ) (builtins.length headers);

    headerLine = "| " + lib.concatStringsSep " | " headers + " |";
    sepLine = "| " + lib.concatStringsSep " | " alignList + " |";

    formatRow = row: let
      cells = map (fn: escapeCell (fn row)) colFns;
    in
      "| " + lib.concatStringsSep " | " cells + " |";

    bodyLines = map formatRow sortedRows;
  in
    if sortedRows == []
    then "*No entries to display.*"
    else lib.concatStringsSep "\n" ([headerLine sepLine] ++ bodyLines);

  /**
  Specialized table generator for graph nodes.
  */
  renderNodeTable = {
    nodes,
    columns ? ["name" "kind" "description"],
    customFormatters ? {},
    linkFn ? null,
    sortBy ? (n: n.name or n.id),
    align ? [],
  }: let
    defaultFormatters = {
      name = n:
        if linkFn != null
        then "[`${n.name or n.id}`](${linkFn n})"
        else "`${n.name or n.id}`";
      id = n: "`${n.id}`";
      kind = n: "`${n.kind}`";
      stratum = n: "`${n.stratum}`";
      description = n: (n.properties or {}).description or ((n.meta or {}).doc or "");
      file = n:
        if (n.properties or {}) ? file
        then "[`${n.properties.file}`](${n.properties.file})"
        else "—";
    };

    activeFormatters = defaultFormatters // customFormatters;

    colTitles =
      map (
        c:
          if c == "name"
          then "Name"
          else if c == "id"
          then "ID"
          else if c == "kind"
          then "Kind"
          else if c == "stratum"
          then "Stratum"
          else if c == "description"
          then "Description"
          else if c == "file"
          then "Source File"
          else c
      )
      columns;

    colFns = map (c: activeFormatters.${c} or (n: (n.properties or {}).${c} or ((n.meta or {}).${c} or ""))) columns;
  in
    renderTable {
      headers = colTitles;
      columns = colFns;
      rows = nodes;
      inherit align sortBy;
    };

  /**
  Specialized table generator for graph edges.
  */
  renderEdgeTable = {
    edges,
    graph ? null,
    columns ? ["source" "relation" "target"],
    customFormatters ? {},
    sortBy ? (e: "${e.source}-${e.relation}-${e.target}"),
    align ? [],
  }: let
    resolveLabel = id:
      if graph != null && graph.nodes ? ${id}
      then graph.nodes.${id}.label or (graph.nodes.${id}.name or id)
      else id;

    defaultFormatters = {
      source = e: "`${resolveLabel e.source}`";
      target = e: "`${resolveLabel e.target}`";
      relation = e: "**`${e.relation}`**";
      stratum = e: "`${e.stratum or "—"}`";
      resolvedValue = e:
        if (e.meta or {}) ? resolvedValue && e.meta.resolvedValue != null
        then "`${builtins.toJSON e.meta.resolvedValue}`"
        else "—";
      facet = e: (e.meta or {}).facet or "—";
    };

    activeFormatters = defaultFormatters // customFormatters;

    colTitles =
      map (
        c:
          if c == "source"
          then "Source"
          else if c == "target"
          then "Target"
          else if c == "relation"
          then "Relation"
          else if c == "stratum"
          then "Stratum"
          else if c == "resolvedValue"
          then "Resolved Value"
          else if c == "facet"
          then "Facet"
          else c
      )
      columns;

    colFns = map (c: activeFormatters.${c} or (e: (e.meta or {}).${c} or "")) columns;
  in
    renderTable {
      headers = colTitles;
      columns = colFns;
      rows = edges;
      inherit align sortBy;
    };
in {
  internal.graph.render.markdown.table = {
    inherit
      escapeCell
      renderTable
      renderNodeTable
      renderEdgeTable
      ;
  };
}
