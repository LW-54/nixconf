# Rendering engine: renders sections in order, and exposes `lib.docs.generateAll`.
{
  lib,
  config,
  ...
}: let
  graphLib = config.flake.lib.graph;
  md = config.internal.docs.md;
  pages = config.docs.pages;
  mkContext = config.internal.docs.mkContext;
  loadSnippetFile = config.internal.docs.loadSnippetFile;

  renderSection = ctx: s: let
    raw =
      if (s.content or null) != null
      then s.content
      else s.body or null;
    evaluated =
      if lib.isFunction raw
      then raw ctx
      else raw;
    trimmed =
      if evaluated == null
      then ""
      else md.trim evaluated;
  in
    if trimmed == ""
    then null
    else trimmed;

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
    graph ? null,
  }: let
    resolvedCPG =
      if cpg != null
      then cpg
      else graphLib.buildCPG {inherit system;};
    resolvedGraph =
      if graph != null
      then graph
      else config.internal.graph.core.algebra.overlay (graphLib.toArchitectureLPG {cpg = resolvedCPG;}) resolvedCPG;
    nodesByKind = lib.groupBy (n: n.kind) (lib.sort (a: b: a.name < b.name) (builtins.attrValues resolvedGraph.nodes));
    graphWithoutContains =
      graphLib.filterGraph {
        edgeFilter = e: lib.toLower (e.relation or "") != "contains";
      }
      resolvedGraph;
    knownFiles = lib.unique (lib.concatMap (n:
      lib.optional (n ? meta && (n.meta.file or null) != null) n.meta.file
      ++ (
        if n ? meta && builtins.isList (n.meta.files or null)
        then n.meta.files
        else []
      )
      ++ lib.optional (n ? source && (n.source.file or null) != null) n.source.file
      ++ lib.optional (n ? origin && (n.origin.file or null) != null) n.origin.file) (builtins.attrValues resolvedGraph.nodes));
    fileCache = lib.genAttrs knownFiles loadSnippetFile;
    byPath = lib.groupBy (id: pages.${id}.path) (builtins.attrNames pages);
    clashes = lib.filterAttrs (_: ids: builtins.length ids > 1) byPath;
  in
    if clashes != {}
    then throw "docs: several pages render to the same path: ${lib.concatStringsSep "; " (lib.mapAttrsToList (path: ids: "${path} <- ${lib.concatStringsSep ", " ids}") clashes)}"
    else
      lib.mapAttrs' (id: page:
        lib.nameValuePair page.path (renderPage (mkContext {
          inherit id system nodesByKind graphWithoutContains fileCache;
          graph = resolvedGraph;
          cpg = resolvedCPG;
        })))
      pages;
in {
  internal.docs = {
    inherit renderPage;
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
