# Documentation pages for NixOS modules:
# catalog page (docs/modules/README.md) and individual module pages (docs/modules/<name>.md).
{
  lib,
  config,
  ...
}: let
  md = config.internal.docs.md;
  types = config.internal.graph.core.types;
  urn = stratum: kind: id: types.mkURN {inherit stratum kind id;};
  ast = config.internal.graph.extractors.ast;
  producer = config.internal.docs.outputs.producer;
in {
  docs.pages =
    {
      modules = {
        path = "docs/modules/README.md";
        sections = {
          header = {
            order = 10;
            content = ctx: ''
              # Modules

              Every NixOS module exported on `flake.nixosModules`.

              ${ctx.backTo "readme" "Main README"}
            '';
          };
          catalog = {
            order = 50;
            content = ctx:
              md.table {
                headers = ["Module" "Provided by" "Description" "Docs"];
                columns = [
                  (n: "[`${n.name}`](${ctx.link (ctx.pages."modules/${n.name}".path)})")
                  (n: let
                    p = producer ctx n;
                  in
                    if p == null
                    then "—"
                    else p)
                  (n: md.oneLine (n.properties.description or ""))
                  (n: "[More →](${ctx.link (ctx.pages."modules/${n.name}".path)})")
                ];
                rows = ctx.nodes "module";
              };
          };
        };
      };
    }
    // lib.mapAttrs' (name: _:
      lib.nameValuePair "modules/${name}" {
        path = "docs/modules/${name}.md";
        sections = let
          node = ctx: ctx.graph.nodes.${urn "ast" "module" name} or null;
          props = ctx: (node ctx).properties or {};
        in {
          header = {
            order = 10;
            content = ctx: let
              by =
                if node ctx == null
                then null
                else producer ctx (node ctx);
              desc = ast.describeModule {inherit name;};
            in ''
              # Module: `${name}`

              ${desc}

              ${ctx.backTo "modules" "Modules Documentation"} | ${ctx.backTo "readme" "Main README"}

              - **Attribute**: `flake.nixosModules.${name}`
              ${lib.optionalString (by != null) "- **Provided by**: ${by}"}
            '';
          };

          importingHosts = {
            order = 60;
            content = ctx: let
              hosts = (props ctx).importingHosts or [];
              snippets = (props ctx).hostConfigurations or {};
            in
              if hosts == []
              then null
              else ''
                ## Importing Hosts

                ${md.blocks (map (h: let
                  snippet = lib.trim (snippets.${h} or "");
                  isImport = snippet == "" || lib.hasPrefix "self.nixosModules." snippet;
                in
                  if isImport
                  then "- ${ctx.instanceLink "host" h}: ${md.oneLine (config.host.${h}.description or "")}"
                  else md.details "<code>${h}</code>" (md.code "nix" snippet))
                hosts)}
              '';
          };

          options = {
            order = 70;
            content = ctx: let
              opts = (props ctx).options or [];
            in ''
              ## Declared Options

              ${
                if opts == []
                then "*No direct top-level options declared.*"
                else
                  md.table {
                    headers = ["Option Path" "Type" "Default" "Example" "Description"];
                    columns = [
                      (o: "`${o.path}`")
                      (o: "`${o.type}`")
                      (o:
                        if o ? default && o.default != null
                        then md.value o.default
                        else "—")
                      (o:
                        if o ? example && o.example != null
                        then md.value o.example
                        else "—")
                      (o: md.oneLine o.description)
                    ];
                    rows = opts;
                  }
              }
            '';
          };
        };
      })
    config.flake.nixosModules;
}
