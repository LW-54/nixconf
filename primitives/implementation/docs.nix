# Parallel documentation module for implementations: declares docs/implementations/README.md
# and each implementation instance (docs/implementations/<name>.md).
{lib, ...}: {
  docs = {config, ...}: {
    docs.pages =
      {
        implementations = {
          path = "docs/implementations/README.md";
          sections = {
            header = {
              order = 10;
              content = ctx: ''
                # Implementations

                Concrete capability providers satisfying contract interfaces by translating abstract capability options into provider-specific NixOS services, packages, and system configurations.

                ${ctx.backTo "readme" "Main README"}
              '';
            };

            specification = {
              order = 15;
              content = ctx: ''
                ## Specification

                ${ctx.md.bullets [
                  "**Declared as**: `implementation.<name>` in any flake-parts module under `modules/implementations/`"
                  "**Primitive definition**: ${ctx.sourceLink (ctx.sourceOf "primitive" "implementation")}"
                  "**Instances**: ${toString (builtins.length (builtins.attrNames (config.implementation or {})))}"
                ]}
              '';
            };

            schema = {
              order = 20;
              content = ctx: ''
                ## Option Schema (`implementation.<name>`)

                ${ctx.schemaOptionsTable "implementation"}
              '';
            };

            example = {
              order = 30;
              content = ctx: ctx.exampleBlock "implementation";
            };

            catalog = {
              order = 50;
              content = ctx: ''
                ## Catalog

                ${ctx.md.table {
                  headers = ["Implementation" "Contract" "Description" "Definition" "Docs"];
                  columns = [
                    (i: ctx.instanceLink "implementation" i)
                    (i: ctx.instanceLink "contract" config.implementation.${i}.contract)
                    (i: ctx.md.oneLine (config.implementation.${i}.description or ""))
                    (i: ctx.sourceLink (ctx.sourceOf "implementation" i))
                    (i: ctx.moreLink "implementation" i)
                  ];
                  rows = builtins.attrNames (config.implementation or {});
                }}
              '';
            };
          };
        };
      }
      // (lib.mapAttrs' (name: impl:
        lib.nameValuePair "implementations/${name}" {
          path = "docs/implementations/${name}.md";
          sections = {
            header = {
              order = 10;
              content = ctx: ''
                # Implementation: `${name}`

                ${impl.description or ""}

                ${ctx.backTo "implementations" "Implementations Documentation"} | ${ctx.backTo "readme" "Main README"}

                - **Implementation**: `${name}`
                - **Fulfills Contract**: ${ctx.instanceLink "contract" impl.contract}
                - **Definition File**: ${ctx.sourceLink (ctx.sourceOf "implementation" name)}
              '';
            };

            diagram = {
              order = 20;
              content = ctx: ctx.neighborhoodDiagram {nodeId = "urn:nixconf:onto:implementation:${name}";};
            };

            outputs = {
              order = 50;
              content = ctx: let
                producedBy = n: (n.properties.producerPrimitive or (n.origin.primitive or null)) == "implementation" && (n.properties.producerInstance or (n.origin.instance or null)) == name;
                mods = lib.filter producedBy (ctx.nodes "module");
                hasMod = config.flake.nixosModules ? ${name};
                allMods =
                  if hasMod && !lib.any (m: m.name == name) mods
                  then
                    [
                      {
                        name = name;
                        properties.description = "Implementation service module.";
                      }
                    ]
                    ++ mods
                  else mods;
                pkgs = lib.filter producedBy (ctx.nodes "package");
                devShells = lib.filter producedBy (ctx.nodes "devShell");
                libHelpers = builtins.attrNames (impl.lib or {});
              in
                if allMods == [] && pkgs == [] && devShells == [] && libHelpers == []
                then ''
                  ## Outputs

                  *No flake outputs exported.*
                ''
                else
                  ctx.md.blocks [
                    "## Outputs"
                    (
                      if allMods == []
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
                          rows = allMods;
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
                  ];
            };

            importingHosts = {
              order = 60;
              content = ctx: let
                hosts = lib.filter (h: let
                  active = ctx.activeContracts h;
                in
                  lib.any (c: (c.implementation or "") == name) active) (builtins.attrNames (config.host or {}));
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
                node = ctx.instanceNode "implementation" name;
                edges =
                  if node == null
                  then []
                  else lib.filter (e: e.source == node.id && lib.toUpper (e.relation or "") == "CONSUMES") ctx.graph.edges;
                grouped = lib.groupBy (e: e.target) edges;

                srcFile = ctx.sourceOf "implementation" name;

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

                  Capability contracts configured by this implementation:

                  ${lib.concatMapStringsSep "\n\n" renderConsumedContract (builtins.attrNames grouped)}
                '';
            };
          };
        })
      (config.implementation or {}));
  };
}
