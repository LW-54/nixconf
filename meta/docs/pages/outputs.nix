# Pages documenting flake outputs that are not primitive instances:
# NixOS modules, packages, and development shells.
{
  lib,
  config,
  ...
}: let
  md = config.internal.docs.md;
  types = config.internal.graph.core.types;
  urn = stratum: kind: id: types.mkURN {inherit stratum kind id;};
  ast = config.internal.graph.extractors.ast;

  # "Provided by" reference: the producing instance, or else the instance carrying the same name.
  producer = ctx: node: let
    declaredKind = node.properties.producerPrimitive or (node.origin.primitive or null);
    declaredInst = node.properties.producerInstance or (node.origin.instance or null);
    sameNameKind = lib.findFirst (k: k != "primitive" && (config.${k} or {}) ? ${node.name}) null (builtins.attrNames config.primitive);
    resolved =
      if declaredKind != null && declaredInst != null && config.primitive ? ${declaredKind}
      then {
        kind = declaredKind;
        inst = declaredInst;
      }
      else if sameNameKind != null
      then {
        kind = sameNameKind;
        inst = node.name;
      }
      else null;
  in
    if resolved == null
    then null
    else "${resolved.kind} ${ctx.instanceLink resolved.kind resolved.inst}";

  derivationPage = {
    path,
    title,
    description,
    kind,
    commandsFor,
    renderHelp ? (_: null),
  }: {
    inherit path;
    sections = {
      header = {
        order = 10;
        content = ctx: ''
          # ${title}

          ${description}

          ${ctx.backTo "readme" "Main README"}
        '';
      };
      catalog = {
        order = 50;
        content = ctx: let
          flake = config.docs.project.flakeRef;
        in
          md.blocks (map (n: let
            by = producer ctx n;
            helpContent = renderHelp n;
          in
            md.blocks [
              "<a id=\"${n.name}\"></a>\n### `${n.name}`"
              (md.oneLine (n.properties.description or ""))
              (lib.optionalString (by != null) "Provided by ${by}.")
              (commandsFor flake n.name)
              (lib.optionalString (helpContent != null) helpContent)
            ]) (ctx.nodes kind));
      };
    };
  };
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

      packages = derivationPage {
        path = "docs/packages.md";
        title = "Packages";
        description = "Executable packages exported on `flake.packages`.";
        kind = "package";
        commandsFor = flake: name:
          md.blocks [
            (md.code "bash" "nix run .#${name}")
            (md.code "bash" "nix run ${flake}#${name}")
          ];
        renderHelp = n: let
          usage = n.properties.usage or null;
          helpCommand = n.properties.helpCommand or null;
          homepage = n.properties.homepage or null;
        in
          if usage != null
          then ''
            #### Usage

            ${usage}
          ''
          else if helpCommand != null || homepage != null
          then ''
            #### Help & Documentation

            ${lib.optionalString (helpCommand != null) ''
              Display command-line flags and subcommands:

              ${md.code "bash" helpCommand}
            ''}
            ${lib.optionalString (homepage != null) "Official Documentation: [${homepage}](${homepage})"}
          ''
          else null;
      };

      devshells = derivationPage {
        path = "docs/devshells.md";
        title = "Development Shells";
        description = "Interactive environments exported on `flake.devShells`.";
        kind = "devShell";
        commandsFor = flake: name:
          md.blocks [
            (md.code "bash" "nix develop .#${name}")
            (md.code "bash" "nix develop ${flake}#${name}")
          ];
        renderHelp = n: let
          usage = n.properties.usage or null;
        in
          if usage != null
          then ''
            #### Usage

            ${usage}
          ''
          else null;
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
