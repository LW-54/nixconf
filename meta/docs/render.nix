# Rendering engine: builds the per-page context (links, graph lookups,
# diagrams), renders sections in order, and exposes `lib.docs.generateAll`.
{
  lib,
  config,
  self,
  inputs,
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

    nodesByKind = lib.groupBy (n: n.kind) (lib.sort (a: b: a.name < b.name) (builtins.attrValues graph.nodes));

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
    nodes = kind: nodesByKind.${kind} or [];

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

    # Repository-relative source path of an instance
    sourceOf = kind: name: config.internal.graph.extractors.onto.resolveFile kind name;

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

    # Neighborhood Mermaid diagram (auto-collapses if large or requested)
    neighborhoodDiagram = {
      nodeId,
      depth ? 2,
      collapsible ? false,
      title ? "Architecture Diagram",
    }: let
      node = graph.nodes.${nodeId} or null;
      neighborhood = graphLib.getNeighborhood {
        graph =
          graphLib.filterGraph {
            edgeFilter = e: lib.toLower (e.relation or "") != "contains";
          }
          graph;
        inherit nodeId depth;
      };
      diagram =
        if node == null || neighborhood.edges == []
        then null
        else
          graphLib.renderMermaid {
            linkFn = nodeLink;
            graph = neighborhood;
            layout = "LR";
          };
      lineCount =
        if diagram == null
        then 0
        else builtins.length (lib.splitString "\n" diagram);
      shouldCollapse = collapsible || lineCount > 16;
    in
      if diagram == null
      then null
      else if shouldCollapse
      then md.details "${title} (click to expand)" diagram
      else diagram;

    # Generic mermaid renderer with node linking
    mermaid = args: graphLib.renderMermaid ({linkFn = nodeLink;} // args);

    # Targeted source code snippet matching specific terms/options with line numbers
    targetedSnippet = {
      file,
      terms ? [],
      options ? [],
      hostName ? null,
    }: let
      fullPath = self + "/${file}";
      exists = file != null && builtins.pathExists fullPath;
      lines =
        if exists
        then lib.splitString "\n" (builtins.readFile fullPath)
        else [];
      withIdx = lib.imap1 (idx: line: {inherit idx line;}) lines;
      clean = l: lib.trim l;
      isComment = l: lib.hasPrefix "#" (clean l) || lib.hasPrefix "//" (clean l) || lib.hasPrefix "/*" (clean l);
      allTerms = terms ++ options;
      matches =
        lib.filter (
          x:
            !isComment x.line && clean x.line != "" && lib.any (t: lib.hasInfix t x.line) allTerms
        )
        withIdx;
      formattedMatches = map (m: let
        trimmed = clean m.line;
        needsBlock = lib.hasSuffix "{" trimmed || lib.hasSuffix "=" trimmed;
        blockLines =
          if needsBlock
          then map (i: "${toString i}: ${clean (builtins.elemAt lines (i - 1))}") (lib.range m.idx (lib.min (m.idx + 3) (builtins.length lines)))
          else ["${toString m.idx}: ${trimmed}"];
      in
        lib.concatStringsSep "\n" blockLines)
      matches;
      evalSnippet =
        if options != []
        then
          lib.concatMapStringsSep "\n  " (o: let
            cfg =
              if hostName != null && config.flake.nixosConfigurations ? ${hostName}
              then config.flake.nixosConfigurations.${hostName}.config
              else config;
            valTry = builtins.tryEval (lib.attrByPath (lib.splitString "." o) null cfg);
            valStr =
              if valTry.success && valTry.value != null
              then lib.generators.toPretty {} valTry.value
              else "...";
          in "${o} = ${valStr};")
          options
        else null;
    in
      if matches != []
      then "# " + file + "\n...\n" + lib.concatStringsSep "\n...\n" formattedMatches + "\n..."
      else if evalSnippet != null
      then "config = {\n  " + evalSnippet + "\n};"
      else null;
  };

  renderSection = ctx: s: let
    raw =
      if (s.content or null) != null
      then s.content
      else s.body or null;
    evaluated =
      if lib.isFunction raw
      then raw ctx
      else raw;
  in
    if evaluated == null || lib.trim evaluated == ""
    then null
    else lib.trim evaluated;

  renderPage = ctx: let
    page = ctx.page;
    kind = ctx.kind;
    id = ctx.id;
    name = ctx.name;

    # Collect page sections + cross-cutting sections
    ownSections =
      if builtins.isList page.sections
      then lib.listToAttrs (lib.imap0 (i: s: lib.nameValuePair "s_${toString i}" s) page.sections)
      else page.sections;

    # Injected sections by primitive kind (supports both singular e.g. "host" and plural e.g. "hosts")
    injectedKindSections =
      if kind != null
      then (config.docs.sections.${kind} or {}) // (config.docs.sections."${kind}s" or {})
      else {};

    # Injected sections for a specific page target
    injectedPageSections =
      (config.docs.sections.${id} or {})
      // (
        if kind != null && name != null
        then (config.docs.sections."${kind}/${name}" or {}) // (config.docs.sections."${kind}s/${name}" or {})
        else {}
      );

    allSections = ownSections // injectedKindSections // injectedPageSections;

    sorted = lib.sort (a: b:
      if (a.value.order or 100) == (b.value.order or 100)
      then a.name < b.name
      else (a.value.order or 100) < (b.value.order or 100))
    (lib.mapAttrsToList lib.nameValuePair allSections);

    rendered = lib.filter (s: s != null) (map (s: renderSection ctx s.value) sorted);
  in
    lib.concatStringsSep "\n\n" rendered + "\n";

  generateAll = {
    system ? "x86_64-linux",
    cpg ? null,
    graph ? graphLib.buildGraph {inherit system;},
  }: let
    byPath = lib.groupBy (id: pages.${id}.path) (builtins.attrNames pages);
    clashes = lib.filterAttrs (_: ids: builtins.length ids > 1) byPath;
  in
    if clashes != {}
    then throw "docs: several pages render to the same path: ${lib.concatStringsSep "; " (lib.mapAttrsToList (path: ids: "${path} <- ${lib.concatStringsSep ", " ids}") clashes)}"
    else
      lib.mapAttrs' (id: page:
        lib.nameValuePair page.path (renderPage (mkContext {inherit id graph cpg system;})))
      pages;
in {
  internal.docs = {
    inherit mkContext renderPage;
  };

  lib.docs = {
    description = "Documentation generator turning the `docs` page registry, primitive metadata, and the architecture graph into markdown.";
    symbols = {
      generateAll = {
        docstring = ''
          Renders every page registered under `config.docs.pages` into an attribute set mapping repository-relative paths to markdown.

          # Inputs

          `system`
          : Platform used to evaluate packages and the architecture graph (default: "x86_64-linux").

          `cpg`
          : Pre-computed Semantic Code Property Graph (optional).

          `graph`
          : Pre-computed architecture graph (optional).

          # Type
          ```
          generateAll :: AttrSet -> AttrSet
          ```

          # Examples
          ```nix
          builtins.attrNames (self.lib.docs.generateAll {})
          ```
        '';
        value = generateAll;
      };

      relPath = {
        docstring = ''
          Computes the relative markdown link from one repository file to another path (optionally with an `#anchor`).

          # Inputs

          `from`
          : Repository-relative path of the page containing the link.

          `to`
          : Repository-relative target path, optionally suffixed by `#anchor`.

          # Type
          ```
          relPath :: String -> String -> String
          ```

          # Examples
          ```nix
          relPath "docs/hosts/x240.md" "docs/contracts/home.md"
          => "../contracts/home.md"
          ```
        '';
        value = md.relPath;
      };

      audit = {
        docstring = ''
          Documentation coverage and quality health report.

          # Type
          ```
          audit :: AttrSet
          ```
        '';
        value = config.internal.docs.audit;
      };
    };
  };
}
