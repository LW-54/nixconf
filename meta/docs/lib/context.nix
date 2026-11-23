# Context engine: builds the per-page evaluation and querying context
# (`ctx`) passed to section rendering functions.
{
  lib,
  config,
  self,
  options,
  ...
}: let
  graphLib = config.flake.lib.graph;
  types = config.internal.graph.core.types;
  md = config.internal.docs.md;
  pages = config.docs.pages;

  instanceURN = kind: name:
    types.mkURN {
      stratum = types.strata.onto;
      inherit kind;
      id = name;
    };

  # Resolves the path of any primitive instance or page dynamically from config.docs.pages
  # without hardcoded kind slugs.
  instancePath = kind: name:
    if pages ? "${kind}/${name}"
    then pages."${kind}/${name}".path
    else if pages ? "${kind}s/${name}"
    then pages."${kind}s/${name}".path
    else if pages ? "${kind}"
    then pages.${kind}.path
    else if pages ? "${kind}s"
    then pages."${kind}s".path
    else "docs/${kind}/${name}.md";

  schemaOptions = kind: let
    evaluated = (options.${kind}.type.getSubOptions or (_: {})) [];
    declared =
      if evaluated != {}
      then evaluated
      else config.primitive.${kind}.options or {};
  in
    lib.filterAttrs (n: o: !lib.hasPrefix "_" n && lib.isOption o) declared;

  mkContext = {
    id,
    graph,
    cpg,
    system,
    nodesByKind ? null,
    graphWithoutContains ? null,
  }: let
    page = pages.${id};
    link = md.relPath page.path;

    # Parse id dynamically if it is in "kind/name" or "kinds/name" format
    idParts = lib.splitString "/" id;
    inferredKind =
      if builtins.length idParts > 1
      then let
        prefix = builtins.head idParts;
      in
        if config.primitive ? ${prefix}
        then prefix
        else if config.primitive ? ${lib.removeSuffix "s" prefix}
        then lib.removeSuffix "s" prefix
        else prefix
      else null;

    inferredName =
      if builtins.length idParts > 1
      then lib.concatStringsSep "/" (lib.tail idParts)
      else id;

    resolvedNodesByKind =
      if nodesByKind != null
      then nodesByKind
      else lib.groupBy (n: n.kind) (lib.sort (a: b: a.name < b.name) (builtins.attrValues graph.nodes));

    resolvedGraphWithoutContains =
      if graphWithoutContains != null
      then graphWithoutContains
      else
        graphLib.filterGraph {
          edgeFilter = e: lib.toLower (e.relation or "") != "contains";
        }
        graph;

    # Resolves node documentation link
    nodeLink = node: let
      kind = node.kind or "";
      name = node.name or "";
      origin = node.origin or {};
      originKind = origin.primitive or (origin.kind or null);
      originName = origin.instance or null;
    in
      if kind == "module" && pages ? "modules/${name}"
      then link pages."modules/${name}".path
      else if (kind == "package" || kind == "pkg") && pages ? "packages"
      then "${link pages.packages.path}#${name}"
      else if (kind == "devShell" || kind == "shell") && pages ? "devshells"
      then "${link pages.devshells.path}#${name}"
      else if pages ? "${kind}/${name}"
      then link pages."${kind}/${name}".path
      else if pages ? "${kind}s/${name}"
      then link pages."${kind}s/${name}".path
      else if originKind != null && originName != null
      then link (instancePath originKind originName)
      else null;

    sourceLink = file:
      if file == null
      then "*unknown*"
      else "[`${file}`](${link file})";

    resolvedCPG =
      if cpg != null
      then cpg
      else graphLib.buildCPG {inherit system;};

    query = {
      onto = k: n: config.${k}.${n} or null;
      ast = {
        module = mName: config.flake.nixosModules.${mName} or null;
        lib = lName: (config.lib or {}).${lName} or ((config.primitive.lib or {}).${lName} or null);
        option = optPath: let
          pathList = lib.splitString "." optPath;
        in
          lib.attrByPath pathList null (config.options or {});
      };
      eval = hName: attrPath: default: let
        hostCfg = config.flake.nixosConfigurations.${hName}.config or {};
        res = builtins.tryEval (lib.attrByPath (lib.toList attrPath) default hostCfg);
      in
        if res.success
        then res.value
        else default;
      drv = sys: pkgName: attrPath: default: let
        pkg = config.flake.packages.${sys}.${pkgName} or null;
        res =
          if pkg != null
          then builtins.tryEval (lib.attrByPath (lib.toList attrPath) default pkg)
          else {success = false;};
      in
        if res.success
        then res.value
        else default;
      neighborhood = {
        nodeId,
        depth ? 1,
        g ? graph,
      }:
        graphLib.getNeighborhood {
          inherit nodeId depth;
          graph = g;
        };
    };

    hostQuery = pathList: default:
      query.eval inferredName pathList default;

    mkMermaidMarker = {
      graph,
      layout ? "TD",
      clusterBy ? null,
      includeTheme ? true,
      linkFn ? null,
      tooltipFn ? null,
      title ? null,
      wrapCodeBlock ? true,
      raw ? false,
      collapse ? null,
      ...
    }: let
      clusterFn =
        if builtins.isFunction clusterBy
        then clusterBy
        else null;
      nodes = map (n: let
        url =
          if linkFn != null
          then linkFn n
          else null;
        tooltip =
          if tooltipFn != null
          then tooltipFn n
          else n.name or n.id;
      in
        {
          inherit (n) id;
          label = n.label or n.name or n.id;
          kind = n.kind or "default";
          stratum = n.stratum or "other";
          inherit tooltip;
        }
        // lib.optionalAttrs (url != null && url != "") {inherit url;}
        // lib.optionalAttrs (clusterFn != null) {cluster = clusterFn n;})
      (builtins.attrValues graph.nodes);
      edges =
        map (e: {
          inherit (e) source target relation;
        })
        graph.edges;
      spec =
        {
          inherit layout includeTheme wrapCodeBlock raw nodes edges;
        }
        // lib.optionalAttrs (builtins.isString clusterBy) {inherit clusterBy;}
        // lib.optionalAttrs (title != null) {inherit title;}
        // lib.optionalAttrs (collapse != null) {inherit collapse;};
    in "<!--NIXCONF_MERMAID:${builtins.toJSON spec}-->";
  in {
    inherit config graph system md page pages link nodeLink sourceLink query hostQuery;
    cpg = resolvedCPG;
    inherit id;
    name = inferredName;
    kind = inferredKind;
    instance =
      if inferredKind != null
      then config.${inferredKind}.${inferredName} or {}
      else {};

    # Resolves relative URI to another page by id.
    pageUri = pageId:
      if pages ? ${pageId}
      then link pages.${pageId}.path
      else null;

    # Markdown link to another page by id.
    pageLink = pageId: text: let
      uri =
        if pages ? ${pageId}
        then link pages.${pageId}.path
        else null;
    in
      if uri != null
      then "[${text}](${uri})"
      else "`${text}`";

    # Markdown link to an anchor on another page by id.
    pageAnchorLink = pageId: anchor: text: let
      uri =
        if pages ? ${pageId}
        then link pages.${pageId}.path
        else null;
    in
      if uri != null
      then "[${text}](${uri}#${anchor})"
      else "`${text}`";

    # Convenience "← Back to <label>" link.
    backTo = pageId: label: "[← Back to ${label}](${link pages.${pageId}.path})";

    # Dedicated [More →](link) helper
    moreLink = kind: name: "[More →](${link (instancePath kind name)})";
    morePageLink = pageId: "[More →](${link pages.${pageId}.path})";

    # Graph nodes of a given kind, sorted by name.
    nodes = kind: resolvedNodesByKind.${kind} or [];

    # Graph node of a primitive instance (or null).
    instanceNode = kind: name: graph.nodes.${instanceURN kind name} or null;

    # Markdown link to a primitive instance page
    instanceLink = kind: name: let
      target = instancePath kind name;
    in "[`${name}`](${link target})";

    # Markdown link to any graph node by URN, or inline code if undocumented.
    nodeRef = nodeId: text: let
      node = graph.nodes.${nodeId} or {id = nodeId;};
      target = nodeLink node;
    in
      if target == null
      then "`${text}`"
      else "[`${text}`](${target})";

    # Repository-relative source path(s) of an instance
    sourceOf = kind: name: config.internal.graph.extractors.onto.resolveFile kind name;
    sourceFilesOf = kind: name: config.internal.graph.extractors.onto.resolveFiles kind name;

    # Evaluated option schema table for a primitive
    schemaOptionsTable = kind: let
      opts = schemaOptions kind;
    in
      if opts == {}
      then "*No options declared.*"
      else
        md.table {
          headers = ["Option" "Type" "Default" "Description"];
          columns = [
            (o: "`${o.name}`")
            (o: "`${o.value.type.description or "unspecified"}`")
            (o:
              if o.value ? defaultText
              then md.value o.value.defaultText
              else if o.value ? default
              then md.value o.value.default
              else "**required**")
            (o: md.oneLine (o.value.description or ""))
          ];
          rows = lib.mapAttrsToList lib.nameValuePair opts;
        };

    # Smallest or curated declaration example in the codebase
    exampleBlock = kind: let
      files = lib.mapAttrsToList (name: _: config.internal.graph.extractors.onto.resolveFile kind name) (config.${kind} or {});
      existing = lib.unique (lib.filter (f: f != null && builtins.pathExists (self + "/${f}")) files);
      withSize =
        map (f: {
          file = f;
          text = builtins.readFile (self + "/${f}");
        })
        existing;
      smallest =
        lib.foldl' (acc: x:
          if acc == null || builtins.stringLength x.text < builtins.stringLength acc.text
          then x
          else acc)
        null
        withSize;
    in
      if smallest == null
      then null
      else ''
        ## Declaration Example

        Smallest declaration in the repository, ${sourceLink smallest.file}:

        ${
          if builtins.length (lib.splitString "\n" smallest.text) > 40
          then md.details "<code>${smallest.file}</code>" (md.code "nix" smallest.text)
          else md.code "nix" smallest.text
        }
      '';

    # Active contracts on a host
    activeContracts = hostName: let
      node = graph.nodes.${instanceURN "host" hostName} or null;
    in
      node.properties.activeContracts or [];

    # Enabled features on a host
    enabledFeatures = hostName: let
      node = graph.nodes.${instanceURN "host" hostName} or null;
    in
      node.properties.featureList or [];

    # Host submodules list
    hostSubModules = hostName: let
      node = graph.nodes.${instanceURN "host" hostName} or null;
    in
      node.properties.subModulesList or [];

    # Neighborhood Mermaid diagram (auto-collapses if large or requested, rendered in native Rust)
    neighborhoodDiagram = {
      nodeId,
      depth ? 2,
      collapsible ? false,
      title ? "Architecture Diagram",
    }: let
      node = graph.nodes.${nodeId} or null;
      neighborhood = graphLib.getNeighborhood {
        graph = resolvedGraphWithoutContains;
        inherit nodeId depth;
      };
    in
      if node == null || neighborhood.edges == []
      then null
      else
        mkMermaidMarker {
          linkFn = nodeLink;
          graph = neighborhood;
          layout = "LR";
          collapse = {
            always = collapsible;
            maxLines = 16;
            summary = "${title} (click to expand)";
          };
        };

    # Generic mermaid renderer with node linking (deferred to native Rust unless custom formatters are supplied)
    mermaid = args: let
      merged = {linkFn = nodeLink;} // args;
    in
      if (merged.customNodeFormatter or null) != null || (merged.customEdgeFormatter or null) != null
      then graphLib.renderMermaid merged
      else mkMermaidMarker merged;

    # Targeted source code snippet matching specific terms/options with line numbers (file scan deferred to native Rust)
    targetedSnippet = {
      file ? null,
      files ? (lib.optional (file != null) file),
      terms ? [],
      options ? [],
      hostName ? null,
    }: let
      cleanFiles = lib.unique (lib.filter (f: f != null) files);
      allTerms = lib.unique (terms ++ options);
      summarizeValue = depth: v: let
        tried = builtins.tryEval v;
      in
        if !tried.success
        then "<unevaluated>"
        else let
          val = tried.value;
        in
          if val == null
          then "null"
          else if builtins.isBool val || builtins.isInt val || builtins.isFloat val
          then lib.generators.toPretty {} val
          else if builtins.isString val
          then let
            s = builtins.replaceStrings ["${toString self.outPath}/"] ["./"] (builtins.unsafeDiscardStringContext val);
          in
            if builtins.stringLength s > 160
            then builtins.toJSON (builtins.substring 0 157 s + "...")
            else builtins.toJSON s
          else if builtins.isPath val
          then builtins.replaceStrings ["${toString self.outPath}/"] ["./"] (toString val)
          else if builtins.isFunction val
          then "<function>"
          else if lib.isDerivation val
          then "<derivation ${val.name or "drv"}>"
          else if builtins.isList val
          then let
            len = builtins.length val;
          in
            if len == 0
            then "[]"
            else if depth <= 0 || len > 8
            then "[ /* ${toString len} items */ ]"
            else "[ ${lib.concatMapStringsSep " " (summarizeValue (depth - 1)) val} ]"
          else if builtins.isAttrs val
          then let
            names = builtins.attrNames val;
            len = builtins.length names;
          in
            if len == 0
            then "{}"
            else if depth <= 0
            then "{ /* ${toString len} attrs: ${lib.concatStringsSep ", " (lib.take 5 names)}${lib.optionalString (len > 5) ", ..."} */ }"
            else let
              shown = lib.take 8 names;
              entries = map (k: "${k} = ${summarizeValue (depth - 1) val.${k}};") shown;
              more = lib.optional (len > 8) "/* ... +${toString (len - 8)} more */";
            in "{ ${lib.concatStringsSep " " (entries ++ more)} }"
          else "...";
      evalSnippet =
        if options != []
        then
          "config = {\n  "
          + lib.concatMapStringsSep "\n  " (o: let
            cfg =
              if hostName != null && config.flake.nixosConfigurations ? ${hostName}
              then config.flake.nixosConfigurations.${hostName}.config
              else config;
            valTry = builtins.tryEval (lib.attrByPath (lib.splitString "." o) null cfg);
            valStr =
              if valTry.success && valTry.value != null
              then summarizeValue 2 valTry.value
              else "...";
          in "${o} = ${valStr};")
          options
          + "\n};"
        else null;
    in
      if cleanFiles != [] && allTerms != []
      then "<!--NIXCONF_SNIPPET:${builtins.toJSON ({
          files = cleanFiles;
          terms = allTerms;
        }
        // lib.optionalAttrs (evalSnippet != null) {fallback = evalSnippet;})}-->"
      else evalSnippet;
  };
in {
  internal.docs = {
    inherit mkContext;
  };
}
