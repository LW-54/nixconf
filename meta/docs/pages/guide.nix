# Developer guide of the documentation system itself (docs/documentation.md):
# how pages are generated and where to put hand-written documentation.
{
  lib,
  config,
  options,
  self,
  ...
}: let
  md = config.internal.docs.md;
  inherit (config.internal.graph.extractors.onto) relativeSource;

  # Leading `#` comment block of a Nix file, used as its description.
  headerComment = file: let
    lines = lib.splitString "\n" (builtins.readFile (self + "/${file}"));
    commentLength = lib.findFirst (i: !lib.hasPrefix "#" (builtins.elemAt lines i)) (builtins.length lines) (lib.range 0 (builtins.length lines - 1));
    comment = lib.take commentLength lines;
  in
    md.oneLine (lib.concatMapStringsSep " " (l: lib.removePrefix "#" l) comment);

  nixFilesUnder = dir: let
    walk = rel: let
      entries = builtins.readDir (self + "/${rel}");
    in
      lib.concatLists (lib.mapAttrsToList (name: type:
        if type == "directory"
        then walk "${rel}/${name}"
        else lib.optional (lib.hasSuffix ".nix" name) "${rel}/${name}")
      entries);
  in
    walk dir;

  # Files contributing pages or cross-primitive sections, recovered from the module system.
  contributors = lib.unique (map (d: relativeSource d.file) (options.docs.pages.definitionsWithLocations ++ options.docs.sections.definitionsWithLocations));

  docOptions = lib.filter (o: o.visible && !o.internal) (lib.optionAttrSetToDocList options.docs);
in {
  docs.pages.documentation = {
    path = "docs/documentation.md";
    sections = {
      header = {
        order = 5;
        content = ctx: ''
          # Documentation System

          How the documentation is generated from code, and where to declare the documentation that cannot be inferred.

          ${ctx.backTo "readme" "Main README"}
        '';
      };

      principles = {
        order = 10;
        content = ctx: ''
          ## Principles

          ${md.bullets [
            "**Structure comes from code.** Pages, catalogs, option schemas, relationships, diagrams, source links, and examples are computed from primitives, evaluated option declarations, module definition locations, and the architecture graph."
            "**Prose lives next to code.** Anything that cannot be inferred (guides, curated examples, module descriptions, extra facts) is declared in parallel namespaces (`docs.pages`, `docs.sections`) right next to the code it describes."
            "**Minimal page and section model.** A page is strictly a `path` and a set of `sections`. A section is strictly an `order` and a markdown template function (`content = ctx: ...`)."
            "**No special cases.** A new primitive, instance, module, package, or shell is documented automatically; the generic renderer never names a specific instance."
          ]}
        '';
      };

      pipeline = {
        order = 20;
        content = ctx:
          md.blocks [
            "## Pipeline"
            (md.bullets [
              "Pass 1 (`primitives/`) exports parallel `docs.pages` for each primitive and its instances via deferred modules."
              "Pass 2 modules declare instances; operational configurations remain 100% pure and unpolluted."
              "`meta/graph` builds the Semantic Code Property Graph used for relationships, diagrams, and node links."
              "`meta/docs` turns the page registry (`config.docs.pages`) into markdown; `nix run .#docs -- --write` writes it and `checks.docs` keeps it in sync."
            ])
            "Generator sources:"
            (md.table {
              headers = ["File" "Role"];
              columns = [
                (f: ctx.sourceLink f)
                (f: let
                  c = headerComment f;
                in
                  if c == ""
                  then "—"
                  else c)
              ];
              rows = nixFilesUnder "meta/docs";
            })
            "Modules currently contributing pages or cross-primitive sections:"
            (md.bullets (map ctx.sourceLink contributors))
          ];
      };

      authoring = {
        order = 30;
        content = ctx: ''
          ## Writing Documentation

          ### Enrich the pages of a primitive

          A module can add a section to every instance page of a primitive via `docs.sections.<kind>`. The body receives the page context (`ctx.name`, `ctx.instance`, `ctx.graph`, `ctx.md`, `ctx.instanceLink`, ...) and may return `null` to skip:

          ${md.code "nix" ''
            docs.sections.host.storage = {
              order = 45;
              content = ctx:
                let devices = ((ctx.config.flake.nixosConfigurations.''${ctx.name} or {}).config or {}).disko.devices or {};
                in if devices == {} then null else '''
                  ## Storage Layout

                  ...
                ''';
            };
          ''}

          ### Add a page

          ${md.code "nix" ''
            docs.pages.troubleshooting = {
              path = "docs/troubleshooting.md";
              sections = {
                header = {
                  order = 10;
                  content = '''
                    # Troubleshooting

                    Common failures and how to fix them.
                  ''';
                };
              };
            };
          ''}
        '';
      };

      reference = {
        order = 70;
        content = ctx: ''
          ## Option Reference

          ${md.table {
            headers = ["Option" "Type" "Default" "Description"];
            columns = [
              (o: "`${o.name}`")
              (o: "`${o.type}`")
              (o:
                if o ? default
                then md.value o.default
                else "**required**")
              (o: md.oneLine o.description)
            ];
            rows = docOptions;
          }}
        '';
      };
    };
  };
}
