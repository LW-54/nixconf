{lib, ...}: let
  /**
  Sanitizes an arbitrary node identifier into a valid Mermaid identifier.

  # Inputs

  `id`
  : Raw identifier string containing punctuation or spaces.

  # Type
  ```
  sanitizeId :: String -> String
  ```

  # Examples
  ```nix
  sanitizeId "contract:reverse-proxy"
  ```
  */
  sanitizeId = id: builtins.replaceStrings [":" "-" "." "/" "@" "~" " "] ["__" "_" "_" "_" "_" "_" "_"] id;

  # Format label escaping quotes
  escapeLabel = s: builtins.replaceStrings ["\""] ["'"] s;

  # Node rendering helper
  renderNode = node: let
    v = sanitizeId node.id;
    name = node.name;
    props = node.properties or {};
  in
    if node.kind == "host"
    then "        ${v}[\"${escapeLabel name}\"]:::hostNode"
    else if node.kind == "contract"
    then "        ${v}([\"${escapeLabel name}\"]):::contractNode"
    else if node.kind == "impl"
    then "        ${v}[\"${escapeLabel name}\"]:::implNode"
    else if node.kind == "feature"
    then "        ${v}[\"${escapeLabel name}\"]:::featureNode"
    else if node.kind == "lib"
    then "        ${v}([\"lib: ${escapeLabel name}\"]):::libNode"
    else if node.kind == "opt"
    then let
      t = props.type or "";
      typeStr =
        if t != ""
        then ": ${escapeLabel t}"
        else "";
    in "        ${v}[/\"${escapeLabel name}${typeStr}\"/]:::optNode"
    else if node.kind == "type"
    then "        ${v}{{\"${escapeLabel name}\"}}:::typeNode"
    else if node.kind == "fn"
    then "        ${v}([\"${escapeLabel name}\"]):::fnNode"
    else if node.kind == "pkg"
    then "        ${v}[\"pkg: ${escapeLabel name}\"]:::pkgNode"
    else if node.kind == "shell"
    then "        ${v}[\"shell: ${escapeLabel name}\"]:::shellNode"
    else "        ${v}[\"${escapeLabel name}\"]";

  # Edge rendering helper with quoted labels to prevent parse errors
  renderEdge = edge: let
    src = sanitizeId edge.source;
    tgt = sanitizeId edge.target;
    kind = edge.kind;
    props = edge.properties or {};
  in
    if kind == "IMPORTS"
    then "    ${src} -->|\"imports\"| ${tgt}"
    else if kind == "IMPLEMENTS"
    then "    ${src} -.->|\"implements\"| ${tgt}"
    else if kind == "CONSUMES"
    then let
      opts = props.optionsWritten or [];
      optLabel =
        if builtins.length opts > 0 && builtins.length opts <= 3
        then "consumes (${lib.concatStringsSep ", " opts})"
        else "consumes";
    in "    ${src} -->|\"${escapeLabel optLabel}\"| ${tgt}"
    else if kind == "EXPORTS"
    then "    ${src} -->|\"exports\"| ${tgt}"
    else if kind == "PROVIDES"
    then "    ${src} -.->|\"provides\"| ${tgt}"
    else if kind == "HAS_OPTION"
    then "    ${src} --- ${tgt}"
    else if kind == "HAS_TYPE"
    then "    ${src} --- ${tgt}"
    else if kind == "REFERENCES"
    then "    ${src} -.->|\"references\"| ${tgt}"
    else "    ${src} -->|\"${escapeLabel kind}\"| ${tgt}";

  # Decoupled 5-node conceptual architecture diagram
  renderConceptualDiagram = ''
    ```mermaid
    flowchart TD
        Host["Host"]
        Implementation["Implementation"]
        Feature["Feature"]
        Contract["Contract"]
        Library["Library"]

        Host -->|"imports"| Implementation
        Host -->|"imports"| Feature
        Host -->|"consumes"| Contract
        Implementation -.->|"implements"| Contract
        Implementation -->|"consumes"| Contract
        Feature -->|"consumes"| Contract
        Contract -.->|"provides"| Library
        Implementation -.->|"provides"| Library
        Feature -.->|"provides"| Library

        classDef default fill:#1e1e2e,stroke:#cba6f7,stroke-width:2px,color:#cdd6f4;
        classDef contract fill:#181825,stroke:#89b4fa,stroke-width:2px,color:#cdd6f4;
        classDef impl fill:#181825,stroke:#a6e3a1,stroke-width:2px,color:#cdd6f4;
        classDef feat fill:#181825,stroke:#f38ba8,stroke-width:2px,color:#cdd6f4;
        classDef lib fill:#181825,stroke:#94e2d5,stroke-width:2px,color:#cdd6f4;

        class Host default;
        class Contract contract;
        class Implementation impl;
        class Feature feat;
        class Library lib;
    ```
  '';

  /**
  Renders a typed graph data structure into formatted Mermaid flowchart syntax.

  # Inputs

  `args`
  : Graph attribute set or options containing graph, direction, raw, and subgraphs.

  # Type
  ```
  renderMermaid :: AttrSet -> String
  ```

  # Examples
  ```nix
  renderMermaid {
    graph = {
      nodes = {};
      edges = [];
    };
    direction = "TD";
  }
  ```
  */
  renderMermaid = args: let
    opts =
      if args ? nodes && args ? edges
      then {graph = args;}
      else args;
    graph = opts.graph;
    direction = opts.direction or "TD";
    raw = opts.raw or false;
    subgraphs = opts.subgraphs or true;

    allNodesList = builtins.attrValues graph.nodes;
    validNodeIds = builtins.attrNames graph.nodes;

    # Filter edges to ensure both endpoints exist in the graph
    validEdges = lib.filter (e:
      builtins.elem e.source validNodeIds
      && builtins.elem e.target validNodeIds)
    graph.edges;

    # Group nodes by kind
    hosts = lib.filter (n: n.kind == "host") allNodesList;
    contracts = lib.filter (n: n.kind == "contract") allNodesList;
    impls = lib.filter (n: n.kind == "impl") allNodesList;
    features = lib.filter (n: n.kind == "feature") allNodesList;
    libs = lib.filter (n: n.kind == "lib") allNodesList;
    options = lib.filter (n: n.kind == "opt") allNodesList;
    types = lib.filter (n: n.kind == "type") allNodesList;
    fns = lib.filter (n: n.kind == "fn") allNodesList;
    pkgs = lib.filter (n: n.kind == "pkg") allNodesList;
    shells = lib.filter (n: n.kind == "shell") allNodesList;
    others = lib.filter (n:
      !builtins.elem n.kind [
        "host"
        "contract"
        "impl"
        "feature"
        "lib"
        "opt"
        "type"
        "fn"
        "pkg"
        "shell"
      ])
    allNodesList;

    renderSubgraph = title: nodes:
      if nodes == []
      then ""
      else ''
            subgraph ${title}
        ${lib.concatMapStringsSep "\n" renderNode nodes}
            end
      '';

    nodeLines =
      if subgraphs
      then
        lib.concatStringsSep "\n" (lib.filter (s: s != "") [
          (renderSubgraph "Hosts[\"Hosts\"]" hosts)
          (renderSubgraph "Contracts[\"Contracts\"]" contracts)
          (renderSubgraph "Implementations[\"Implementations\"]" impls)
          (renderSubgraph "Features[\"Features\"]" features)
          (renderSubgraph "Libraries[\"Libraries\"]" libs)
          (renderSubgraph "ContractOptions[\"Contract Options\"]" options)
          (renderSubgraph "ContractTypes[\"Contract Types\"]" types)
          (renderSubgraph "Functions[\"Library Functions\"]" fns)
          (renderSubgraph "Packages[\"Packages\"]" pkgs)
          (renderSubgraph "Shells[\"Devshells\"]" shells)
          (renderSubgraph "OtherNodes[\"Other Entities\"]" others)
        ])
      else lib.concatMapStringsSep "\n" renderNode allNodesList;

    edgeLines = lib.concatMapStringsSep "\n" renderEdge validEdges;

    classDefs = ''
      classDef hostNode fill:#1e1e2e,stroke:#cba6f7,stroke-width:2px,color:#cdd6f4;
      classDef contractNode fill:#181825,stroke:#89b4fa,stroke-width:2px,color:#cdd6f4;
      classDef implNode fill:#181825,stroke:#a6e3a1,stroke-width:2px,color:#cdd6f4;
      classDef featureNode fill:#181825,stroke:#f38ba8,stroke-width:2px,color:#cdd6f4;
      classDef libNode fill:#181825,stroke:#94e2d5,stroke-width:2px,color:#cdd6f4;
      classDef optNode fill:#11111b,stroke:#fab387,stroke-width:1px,color:#cdd6f4;
      classDef typeNode fill:#11111b,stroke:#f9e2af,stroke-width:1px,color:#cdd6f4;
      classDef fnNode fill:#181825,stroke:#94e2d5,stroke-width:1px,color:#cdd6f4;
      classDef pkgNode fill:#181825,stroke:#b4befe,stroke-width:1px,color:#cdd6f4;
      classDef shellNode fill:#181825,stroke:#f5c2e7,stroke-width:1px,color:#cdd6f4;
    '';

    content = ''
      flowchart ${direction}
      ${nodeLines}

      ${edgeLines}

      ${classDefs}
    '';
  in
    if raw
    then content
    else ''
      ```mermaid
      ${content}```
    '';
in {
  flake.lib.docsMermaid = {
    inherit
      renderMermaid
      renderConceptualDiagram
      sanitizeId
      ;
  };
}
