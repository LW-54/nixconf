{lib, ...}: let
  /**
  Serializes a graph into standard JSON Graph Format (JGF v2).
  */
  toJSONGraph = graph: {
    graph = {
      id = "nixconf-cpg";
      type = graph.format or "SemanticCPG";
      metadata = graph.meta or {};
      nodes =
        lib.mapAttrs (id: node: {
          inherit (node) label;
          metadata = {
            inherit (node) stratum kind;
            name = node.name or id;
            origin = node.origin or {};
            properties = node.meta or {};
          };
        })
        graph.nodes;
      edges =
        map (e: {
          inherit (e) id source target;
          relation = e.relation;
          metadata = {
            stratum = e.stratum or "ast";
            properties = e.meta or {};
          };
        })
        graph.edges;
    };
  };

  /**
  Serializes a graph into Cytoscape.js JSON format.
  */
  toCytoscape = graph: {
    elements = {
      nodes = map (node: {
        data = {
          inherit (node) id label;
          name = node.name or node.id;
          stratum = node.stratum or "unknown";
          kind = node.kind or "unknown";
          properties = node.meta or {};
        };
      }) (builtins.attrValues graph.nodes);
      edges =
        map (e: {
          data = {
            inherit (e) id source target;
            relation = e.relation;
            stratum = e.stratum or "ast";
            properties = e.meta or {};
          };
        })
        graph.edges;
    };
  };
in {
  internal.graph.serializers.json = {
    inherit
      toJSONGraph
      toCytoscape
      ;
  };
}
