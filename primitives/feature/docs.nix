# Parallel documentation module for features: declares docs/features/README.md
# and each feature instance (docs/features/<name>.md).
{lib, ...}: {
  docs = {config, ...}: {
    docs.pages =
      {
        features = {
          path = "docs/features/README.md";
          sections = {
            header = {
              order = 10;
              content = ctx: ''
                # Features

                Reusable system configurations, applications, desktop environments, development toolchains, and services that consume contracts to integrate with the host system.

                ${ctx.backTo "readme" "Main README"}
              '';
            };

            specification = {
              order = 15;
              content = ctx: ''
                ## Specification

                ${ctx.md.bullets [
                  "**Declared as**: `feature.<name>` in any flake-parts module under `modules/features/`"
                  "**Primitive definition**: ${ctx.sourceLink (ctx.sourceOf "primitive" "feature")}"
                  "**Instances**: ${toString (builtins.length (builtins.attrNames (config.feature or {})))}"
                ]}
              '';
            };

            schema = {
              order = 20;
              content = ctx: ''
                ## Option Schema (`feature.<name>`)

                ${ctx.schemaOptionsTable "feature"}
              '';
            };

            example = {
              order = 30;
              content = ctx: ctx.exampleBlock "feature";
            };

            catalog = {
              order = 50;
              content = ctx: let
                formatFeatureOutputs = featName: let
                  isFromFeat = n:
                    (n.origin.primitive or null)
                    == "feature"
                    && (n.origin.instance or null) == featName;
                  featMods = lib.filter isFromFeat (ctx.nodes "module");
                  featPkgs = lib.filter isFromFeat (ctx.nodes "package");
                  featShells = lib.filter isFromFeat (ctx.nodes "devShell");
                  modLinks = map (m: "[`${m.name}`](${ctx.link (ctx.pages."modules/${m.name}".path)}) (module)") featMods;
                  pkgLinks = map (p: "[`${p.name}`](${ctx.link ctx.pages.packages.path}#${p.name}) (package)") featPkgs;
                  shellLinks = map (s: "[`${s.name}`](${ctx.link ctx.pages.devshells.path}#${s.name}) (devShell)") featShells;
                  all = modLinks ++ pkgLinks ++ shellLinks;
                in
                  if all == []
                  then "—"
                  else lib.concatStringsSep ", " all;
              in ''
                ## Catalog

                ${ctx.md.table {
                  headers = ["Feature" "Description" "Outputs" "Definition" "Docs"];
                  columns = [
                    (f: ctx.instanceLink "feature" f)
                    (f: ctx.md.oneLine (config.feature.${f}.description or ""))
                    (f: formatFeatureOutputs f)
                    (f: ctx.sourceLink (ctx.sourceOf "feature" f))
                    (f: ctx.moreLink "feature" f)
                  ];
                  rows = builtins.attrNames (config.feature or {});
                }}
              '';
            };
          };
        };
      }
      // (lib.mapAttrs' (name: feat:
        lib.nameValuePair "features/${name}" {
          path = "docs/features/${name}.md";
          sections = {
            header = {
              order = 10;
              content = ctx: ''
                # Feature: `${name}`

                ${feat.description or ""}

                ${ctx.backTo "features" "Features Documentation"} | ${ctx.backTo "readme" "Main README"}

                - **Feature**: `${name}`
                - **Definition File**: ${ctx.sourceLink (ctx.sourceOf "feature" name)}
              '';
            };

            diagram = {
              order = 20;
              content = ctx: ctx.neighborhoodDiagram {nodeId = "urn:nixconf:onto:feature:${name}";};
            };

            outputs = {
              order = 50;
              content = ctx: let
                producedBy = n: (n.properties.producerPrimitive or (n.origin.primitive or null)) == "feature" && (n.properties.producerInstance or (n.origin.instance or null)) == name;
                mods = lib.filter producedBy (ctx.nodes "module");
                pkgs = lib.filter producedBy (ctx.nodes "package");
                devShells = lib.filter producedBy (ctx.nodes "devShell");
                libHelpers = builtins.attrNames (feat.lib or {});
                typesList = builtins.attrNames (feat.types or {});
              in
                if mods == [] && pkgs == [] && devShells == [] && libHelpers == [] && typesList == []
                then ''
                  ## Outputs

                  *No flake outputs exported.*
                ''
                else
                  ctx.md.blocks [
                    "## Outputs"
                    (
                      if mods == []
                      then null
                      else ''
                        ### NixOS Modules

                        ${ctx.md.table {
                          headers = ["Module" "Description" "Docs"];
                          columns = [
                            (m: "[`${m.name}`](${ctx.link (ctx.pages."modules/${m.name}".path)})")
                            (m: ctx.md.oneLine (m.properties.description or ""))
                            (m: "[More →](${ctx.link (ctx.pages."modules/${m.name}".path)})")
                          ];
                          rows = mods;
                        }}
                      ''
                    )
                    (
                      if pkgs == []
                      then null
                      else ''
                        ### Packages

                        ${ctx.md.table {
                          headers = ["Package" "Command" "Description" "Docs"];
                          columns = [
                            (p: "[`${p.name}`](${ctx.link ctx.pages.packages.path}#${p.name})")
                            (p: "`nix run .#${p.name}`")
                            (p: ctx.md.oneLine (p.properties.description or ""))
                            (p: "[More →](${ctx.link ctx.pages.packages.path}#${p.name})")
                          ];
                          rows = pkgs;
                        }}
                      ''
                    )
                    (
                      if devShells == []
                      then null
                      else ''
                        ### Development Shells

                        ${ctx.md.table {
                          headers = ["Development Shell" "Command" "Description" "Docs"];
                          columns = [
                            (s: "[`${s.name}`](${ctx.link ctx.pages.devshells.path}#${s.name})")
                            (s: "`nix develop .#${s.name}`")
                            (s: ctx.md.oneLine (s.properties.description or ""))
                            (s: "[More →](${ctx.link ctx.pages.devshells.path}#${s.name})")
                          ];
                          rows = devShells;
                        }}
                      ''
                    )
                    (
                      if libHelpers == []
                      then null
                      else ''
                        ### Library Helpers

                        ${ctx.md.table {
                          headers = ["Symbol" "Type" "Description" "Docs"];
                          columns = [
                            (s: "[`${s}`](${ctx.link (ctx.pages."lib/${name}".path or "")}#${s})")
                            (s: let
                              symNode = ctx.graph.nodes.${"urn:nixconf:ast:function:${name}.${s}"} or (ctx.graph.nodes.${"urn:nixconf:ast:symbol:${name}.${s}"} or null);
                              t = symNode.properties.typeSignature or "";
                            in
                              if t != ""
                              then "`${t}`"
                              else "—")
                            (s: let
                              symNode = ctx.graph.nodes.${"urn:nixconf:ast:function:${name}.${s}"} or (ctx.graph.nodes.${"urn:nixconf:ast:symbol:${name}.${s}"} or null);
                              sum = symNode.properties.summary or "";
                            in
                              if sum != ""
                              then ctx.md.oneLine sum
                              else "—")
                            (s: "[More →](${ctx.link (ctx.pages."lib/${name}".path or "")}#${s})")
                          ];
                          rows = libHelpers;
                        }}
                      ''
                    )
                    (
                      if typesList == []
                      then null
                      else ''
                        ### Custom Types

                        ${ctx.md.bullets (map (t: "`${t}`: Custom option submodule/type declared by `${name}`.") typesList)}
                      ''
                    )
                  ];
            };

            importingHosts = {
              order = 60;
              content = ctx: let
                hosts = lib.filter (h: let
                  feats = ctx.enabledFeatures h;
                in
                  lib.any (f: f.name == name) feats) (builtins.attrNames (config.host or {}));
              in
                if hosts == []
                then null
                else ''
                  ## Importing Hosts

                  ${ctx.md.bullets (map (h: "${ctx.instanceLink "host" h}: ${ctx.md.oneLine (config.host.${h}.description or "")}") hosts)}
                '';
            };

            consumedContracts = {
              order = 70;
              content = ctx: let
                node = ctx.instanceNode "feature" name;
                edges =
                  if node == null
                  then []
                  else lib.filter (e: e.source == node.id && lib.toUpper (e.relation or "") == "CONSUMES") ctx.graph.edges;
                grouped = lib.groupBy (e: e.target) edges;

                srcFile = ctx.sourceOf "feature" name;

                renderConsumedContract = targetId: let
                  cNode = ctx.graph.nodes.${targetId} or null;
                  cName =
                    if cNode != null
                    then cNode.name
                    else lib.last (lib.splitString ":" targetId);
                  opts = lib.unique (lib.filter (o: o != null) (map (e: e.qualifier or (e.properties.optionWritten or null)) grouped.${targetId}));
                  optsStr =
                    if opts != []
                    then lib.concatStringsSep ", " (map (o: "`${o}`") opts)
                    else "*general capability bindings*";
                  codeSnippet = ctx.targetedSnippet {
                    file = srcFile;
                    options = opts;
                    terms = ["${cName}." "${cName} =" "self.lib.${cName}"];
                  };
                in ''
                  <details>
                  <summary><code><a href="../contracts/${cName}.md">${cName}</a></code></summary>

                  **Configures options**: ${optsStr}

                  ```nix
                  ${codeSnippet}
                  ```

                  </details>
                '';
              in
                if edges == []
                then null
                else ''
                  ## Consumed Contracts

                  Capability contracts configured by this feature:

                  ${lib.concatMapStringsSep "\n\n" renderConsumedContract (builtins.attrNames grouped)}
                '';
            };
          };
        })
      (config.feature or {}));
  };
}
