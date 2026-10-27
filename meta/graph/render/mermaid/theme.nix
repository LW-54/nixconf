{lib, ...}: let
  sanitizeId = s: builtins.replaceStrings [":" "." "-" "/" "@" "~" " "] ["__" "_" "_" "_" "_" "_" "_"] s;
  escapeLabel = s: builtins.replaceStrings ["\""] ["'"] s;

  classDefs = ''
    classDef hostNode fill:#1e293b,stroke:#38bdf8,stroke-width:2px,color:#f8fafc;
    classDef contractNode fill:#1e1b4b,stroke:#818cf8,stroke-width:2px,color:#f8fafc;
    classDef implNode fill:#0f172a,stroke:#34d399,stroke-width:2px,color:#f8fafc;
    classDef featureNode fill:#134e4a,stroke:#2dd4bf,stroke-width:2px,color:#f8fafc;
    classDef optNode fill:#422006,stroke:#facc15,stroke-width:1px,color:#fefce8;
    classDef typeNode fill:#3b0764,stroke:#c084fc,stroke-width:1px,color:#faf5ff;
    classDef pkgNode fill:#4c0519,stroke:#fb7185,stroke-width:1px,color:#fff1f2;
    classDef devShellNode fill:#451a03,stroke:#fb923c,stroke-width:1px,color:#fff7ed;
    classDef drvNode fill:#18181b,stroke:#a1a1aa,stroke-width:1px,color:#f4f4f5;
    classDef defaultNode fill:#1e293b,stroke:#64748b,stroke-width:1px,color:#f8fafc;
  '';

  getNodeClass = kind:
    if kind == "host" || kind == "configuration"
    then "hostNode"
    else if kind == "contract"
    then "contractNode"
    else if kind == "implementation" || kind == "impl"
    then "implNode"
    else if kind == "feature"
    then "featureNode"
    else if kind == "option" || kind == "opt"
    then "optNode"
    else if kind == "type"
    then "typeNode"
    else if kind == "package" || kind == "pkg"
    then "pkgNode"
    else if kind == "devShell" || kind == "shell"
    then "devShellNode"
    else if kind == "derivation" || kind == "drv"
    then "drvNode"
    else "defaultNode";

  formatNode = node: let
    safeId = sanitizeId node.id;
    label = escapeLabel (node.label or node.name or node.id);
    kind = node.kind or "default";
    cls = getNodeClass kind;
  in
    if kind == "host" || kind == "configuration"
    then "${safeId}([\"${label}\"]):::${cls}"
    else if kind == "contract"
    then "${safeId}{{\"${label}\"}}:::${cls}"
    else if kind == "implementation" || kind == "impl"
    then "${safeId}[\"${label}\"]:::${cls}"
    else if kind == "feature"
    then "${safeId}(\"${label}\"):::${cls}"
    else if kind == "option" || kind == "opt"
    then "${safeId}[/\"${label}\"/]:::${cls}"
    else if kind == "type"
    then "${safeId}[[\"${label}\"]]:::${cls}"
    else if kind == "package" || kind == "pkg"
    then "${safeId}[(\"${label}\")]:::${cls}"
    else if kind == "devShell" || kind == "shell"
    then "${safeId}>\"${label}\"]:::${cls}"
    else "${safeId}[\"${label}\"]:::${cls}";

  formatEdge = edge: let
    src = sanitizeId edge.source;
    tgt = sanitizeId edge.target;
    rel = edge.relation;
    valueSnippet =
      if (edge.meta or {}) ? resolvedValue && edge.meta.resolvedValue != null
      then " = ${builtins.substring 0 20 (builtins.toJSON edge.meta.resolvedValue)}"
      else "";
  in
    if rel == "implements" || rel == "IMPLEMENTS"
    then "${src} == \"implements\" ==> ${tgt}"
    else if rel == "consumes" || rel == "CONSUMES"
    then "${src} -. \"consumes\" .-> ${tgt}"
    else if rel == "flowsTo" || rel == "FLOWS_TO"
    then "${src} -. \"flowsTo${valueSnippet}\" .-> ${tgt}"
    else if rel == "writes" || rel == "WRITES"
    then "${src} -. \"writes${valueSnippet}\" .-> ${tgt}"
    else if rel == "reads" || rel == "READS"
    then "${src} -. \"reads\" .-> ${tgt}"
    else if rel == "imports" || rel == "IMPORTS"
    then "${src} -->|\"imports\"| ${tgt}"
    else if rel == "dependsOn" || rel == "DEPENDS_ON"
    then "${src} -->|\"dependsOn\"| ${tgt}"
    else "${src} -->|\"${rel}\"| ${tgt}";
in {
  internal.graph.render.mermaid.theme = {
    inherit
      sanitizeId
      escapeLabel
      classDefs
      getNodeClass
      formatNode
      formatEdge
      ;
  };
}
