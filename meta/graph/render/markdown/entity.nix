{
  lib,
  config,
  ...
}: let
  tableLib = config.internal.graph.render.markdown.table;

  /**
  Renders a comprehensive entity sheet (inspection report) for a single graph node.
  Args:
    node: Node attribute set
    graph: Entire LPG graph containing the node
    includeNeighborhoodDiagram: Boolean to include a Mermaid diagram of the 1-hop neighborhood (default: true)
    mermaidRenderer: Optional function to render a Mermaid diagram from a subgraph
  */
  renderEntity = {
    node,
    graph,
    includeNeighborhoodDiagram ? true,
    mermaidRenderer ? null,
  }: let
    name = node.name or node.id;
    kind = node.kind or "entity";
    stratum = node.stratum or "unknown";
    desc = (node.properties or {}).description or ((node.meta or {}).doc or "");
    file = (node.properties or {}).file or null;

    inEdges = lib.filter (e: e.target == node.id) graph.edges;
    outEdges = lib.filter (e: e.source == node.id) graph.edges;

    metaRows =
      [
        {
          key = "Identifier";
          val = "`${node.id}`";
        }
        {
          key = "Kind";
          val = "`${kind}`";
        }
        {
          key = "Stratum";
          val = "`${stratum}`";
        }
      ]
      ++ (lib.optional (file != null) {
        key = "Source File";
        val = "[`${file}`](${file})";
      })
      ++ (lib.mapAttrsToList (k: v: {
        key = k;
        val =
          if builtins.isString v
          then v
          else "`${builtins.toJSON v}`";
      }) (builtins.removeAttrs (node.meta or {}) ["doc"]));

    metaTable = tableLib.renderTable {
      headers = [
        "Attribute"
        "Value"
      ];
      columns = [
        "key"
        "val"
      ];
      rows = metaRows;
      align = [
        "left"
        "left"
      ];
    };

    inTable = tableLib.renderEdgeTable {
      edges = inEdges;
      inherit graph;
      columns = [
        "source"
        "relation"
        "stratum"
        "resolvedValue"
      ];
    };

    outTable = tableLib.renderEdgeTable {
      edges = outEdges;
      inherit graph;
      columns = [
        "relation"
        "target"
        "stratum"
        "resolvedValue"
      ];
    };

    defaultMermaidRenderer = g: config.internal.graph.render.mermaid.flowchart.renderFlowchart {graph = g;};
    activeMermaidRenderer =
      if mermaidRenderer != null
      then mermaidRenderer
      else defaultMermaidRenderer;

    diagramSection =
      if includeNeighborhoodDiagram && activeMermaidRenderer != null
      then let
        neighborNodeIds = lib.unique (
          [node.id]
          ++ (map (e: e.source) inEdges)
          ++ (map (e: e.target) outEdges)
        );
        subgraphNodes = lib.filterAttrs (id: _: builtins.elem id neighborNodeIds) graph.nodes;
        subgraphEdges =
          lib.filter (
            e:
              builtins.elem e.source neighborNodeIds
              && builtins.elem e.target neighborNodeIds
          )
          graph.edges;
        neighborhoodGraph = {
          nodes = subgraphNodes;
          edges = subgraphEdges;
        };
        diagram = activeMermaidRenderer neighborhoodGraph;
      in ''
        ### Neighborhood Diagram

        ```mermaid
        ${diagram}
        ```
      ''
      else "";
  in ''
    ## ${kind}: `${name}`

    ${
      if desc != ""
      then desc + "\n"
      else ""
    }
    ### Metadata

    ${metaTable}

    ### Outgoing Relationships (${toString (builtins.length outEdges)})

    ${outTable}

    ### Incoming Relationships (${toString (builtins.length inEdges)})

    ${inTable}

    ${diagramSection}
  '';
in {
  internal.graph.render.markdown.entity = {
    inherit renderEntity;
  };
}
