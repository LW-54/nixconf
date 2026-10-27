{lib, ...}: let
  /**
  Renders a 2D cross-tabulation / adjacency markdown table from two sets of entities and a relationship matcher.
  Args:
    rows: List of row entities [ Node | AttrSet ]
    cols: List of column entities [ Node | AttrSet ]
    graph: Optional LPG graph to match edges
    relation: Optional relation name filter (e.g., "CONSUMES", "IMPORTS", "implements")
    rowHeader: Column title for the row index (default: "Entity")
    rowLabel: Function extracting display title for a row item (default: r.name or r.id)
    colLabel: Function extracting display title for a col item (default: c.name or c.id)
    cellFn: Custom renderer { row, col, edges, matched }: String -> Cell content
  */
  renderMatrix = {
    rows,
    cols,
    graph ? null,
    relation ? null,
    rowHeader ? "Entity",
    rowLabel ? (r: r.name or r.id),
    colLabel ? (c: c.name or c.id),
    cellFn ? null,
  }: let
    defaultCellFn = {
      matched,
      edges,
      ...
    }:
      if matched
      then "✓"
      else "·";

    actualCellFn =
      if cellFn != null
      then cellFn
      else defaultCellFn;

    edgeIndex =
      if graph != null
      then
        lib.groupBy (
          e: "${e.source}__${e.target}"
        ) (
          if relation != null
          then lib.filter (e: e.relation == relation) graph.edges
          else graph.edges
        )
      else {};

    colHeaders = map colLabel cols;
    headerLine = "| " + lib.concatStringsSep " | " ([rowHeader] ++ colHeaders) + " |";
    sepLine = "| :--- | " + lib.concatStringsSep " | " (map (_: ":---:") colHeaders) + " |";

    formatRow = r: let
      rTitle = rowLabel r;
      rId = r.id or r.name;
      cells =
        map (
          c: let
            cId = c.id or c.name;
            key = "${rId}__${cId}";
            matchingEdges = edgeIndex.${key} or [];
            matched = matchingEdges != [];
          in
            actualCellFn {
              row = r;
              col = c;
              edges = matchingEdges;
              inherit matched;
            }
        )
        cols;
    in
      "| " + lib.concatStringsSep " | " ([rTitle] ++ cells) + " |";

    bodyLines = map formatRow rows;
  in
    if rows == [] || cols == []
    then "*Empty matrix.*"
    else lib.concatStringsSep "\n" ([headerLine sepLine] ++ bodyLines);
in {
  internal.graph.render.markdown.matrix = {
    inherit renderMatrix;
  };
}
