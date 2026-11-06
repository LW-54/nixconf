# Parallel documentation module for contracts: declares docs/contracts/README.md
# and each contract instance (docs/contracts/<name>.md).
{lib, ...}: {
  docs = {config, ...}: {
    docs.pages =
      {
        contracts = {
          path = "docs/contracts/README.md";
          sections = {
            header = {
              order = 10;
              content = ctx: ''
                # Contracts

                Pure contract interfaces defining shared option schemas, custom types, and configuration contracts decoupled from any specific service provider or backend implementation.

                ${ctx.backTo "readme" "Main README"}
              '';
            };

            specification = {
              order = 15;
              content = ctx: ''
                ## Specification

                ${ctx.md.bullets [
                  "**Declared as**: `contract.<name>` in any flake-parts module under `modules/contracts/`"
                  "**Primitive definition**: ${ctx.sourceLink "primitives/contract/default.nix"}"
                  "**Instances**: ${toString (builtins.length (builtins.attrNames (config.contract or {})))}"
                ]}
              '';
            };

            schema = {
              order = 20;
              content = ctx: ''
                ## Option Schema (`contract.<name>`)

                ${ctx.schemaOptionsTable "contract"}
              '';
            };

            example = {
              order = 30;
              content = ctx: ctx.exampleBlock "contract";
            };

            catalog = {
              order = 50;
              content = ctx: ''
                ## Catalog

                ${ctx.md.table {
                  headers = ["Contract" "Description" "Implementations" "Definition" "Docs"];
                  columns = [
                    (c: ctx.instanceLink "contract" c)
                    (c: ctx.md.oneLine (config.contract.${c}.description or ""))
                    (c: let
                      impls = builtins.attrNames (lib.filterAttrs (_: i: (i.contract or "") == c) (config.implementation or {}));
                    in
                      if impls == []
                      then "—"
                      else lib.concatMapStringsSep ", " (i: ctx.instanceLink "implementation" i) impls)
                    (c: ctx.sourceLink (ctx.sourceOf "contract" c))
                    (c: ctx.moreLink "contract" c)
                  ];
                  rows = builtins.attrNames (config.contract or {});
                }}
              '';
            };
          };
        };
      }
      // (lib.mapAttrs' (name: contract:
        lib.nameValuePair "contracts/${name}" {
          path = "docs/contracts/${name}.md";
          sections = {
            header = {
              order = 10;
              content = ctx: ''
                # Contract: `${name}`

                ${contract.description or ""}

                ${ctx.backTo "contracts" "Contracts Documentation"} | ${ctx.backTo "readme" "Main README"}

                - **Contract**: `${name}`
                - **Definition File**: ${ctx.sourceLink (ctx.sourceOf "contract" name)}
              '';
            };

            diagram = {
              order = 20;
              content = ctx: ctx.neighborhoodDiagram {nodeId = "urn:nixconf:onto:contract:${name}";};
            };

            outputs = {
              order = 22;
              content = ctx: let
                modNode = ctx.graph.nodes."urn:nixconf:ast:module:${name}" or null;
                hasMod = config.flake.nixosModules ? ${name};
                typesList = builtins.attrNames (contract.types or {});
                allLibSymbols = config.lib.${name}.symbols or (contract.lib or {});
                libHelpers = lib.filter (s: s != "types") (builtins.attrNames allLibSymbols);
              in
                if !hasMod && typesList == [] && libHelpers == []
                then ''
                  ## Outputs

                  *No flake outputs exported.*
                ''
                else
                  ctx.md.blocks [
                    "## Outputs"
                    (
                      if hasMod
                      then ''
                        ### NixOS Modules

                        ${ctx.md.table {
                          headers = ["Module" "Description" "Docs"];
                          columns = [
                            (_: "[`${name}`](${ctx.link (ctx.pages."modules/${name}".path)})")
                            (_: ctx.md.oneLine (modNode.properties.description or "Contract interface module."))
                            (_: "[More →](${ctx.link (ctx.pages."modules/${name}".path)})")
                          ];
                          rows = [name];
                        }}
                      ''
                      else null
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
                      if typesList != []
                      then ''
                        ### Custom Types

                        ${ctx.md.bullets (map (t: let
                          typeNode = ctx.graph.nodes."urn:nixconf:ast:type:${name}.${t}" or null;
                          desc =
                            if typeNode != null && (typeNode.properties.description or "") != ""
                            then typeNode.properties.description
                            else "Custom option submodule/type declared by contract `${name}`.";
                        in "`${t}`: ${desc}")
                        typesList)}
                      ''
                      else null
                    )
                  ];
            };

            options = {
              order = 25;
              content = ctx: let
                allOpts = ctx.nodes "option";
                contractOpts = lib.filter (o: (o.properties.contract or (o.meta.contract or "")) == name) allOpts;
              in
                if contractOpts == []
                then null
                else ''
                  ## Option Schema Definitions

                  ${ctx.md.table {
                    headers = ["Option" "Type" "Default" "Description"];
                    columns = [
                      (o: "`${o.name}`")
                      (o: "`${o.properties.type or (o.meta.type or "unspecified")}`")
                      (o:
                        if o.properties ? default
                        then ctx.md.value o.properties.default
                        else "—")
                      (o: ctx.md.oneLine (o.properties.description or (o.meta.doc or "")))
                    ];
                    rows = contractOpts;
                  }}
                '';
            };

            implementations = {
              order = 30;
              content = ctx: let
                impls = lib.filterAttrs (_: i: (i.contract or "") == name) (config.implementation or {});
              in
                if impls == {}
                then null
                else ''
                  ## Fulfilling Implementations

                  Providers satisfying the `${name}` contract capability:

                  ${ctx.md.table {
                    headers = ["Implementation" "Description" "Definition" "Docs"];
                    columns = [
                      (i: ctx.instanceLink "implementation" i)
                      (i: ctx.md.oneLine (impls.${i}.description or ""))
                      (i: ctx.sourceLink (ctx.sourceOf "implementation" i))
                      (i: ctx.moreLink "implementation" i)
                    ];
                    rows = builtins.attrNames impls;
                  }}
                '';
            };

            consumers = {
              order = 50;
              content = ctx: let
                node = ctx.instanceNode "contract" name;
                edges =
                  if node == null
                  then []
                  else lib.filter (e: e.target == node.id && lib.toUpper (e.relation or "") == "CONSUMES") ctx.graph.edges;
                grouped = lib.groupBy (e: e.source) edges;

                renderConsumer = srcId: let
                  srcNode = ctx.graph.nodes.${srcId} or null;
                  srcName =
                    if srcNode != null
                    then srcNode.name
                    else lib.last (lib.splitString ":" srcId);
                  srcKind =
                    if srcNode != null
                    then srcNode.kind
                    else if lib.hasInfix "host:" srcId
                    then "host"
                    else if lib.hasInfix "implementation:" srcId
                    then "implementation"
                    else "feature";
                  opts = lib.unique (lib.filter (o: o != null) (map (e: e.qualifier or (e.properties.optionWritten or null)) grouped.${srcId}));
                  optsStr =
                    if opts != []
                    then lib.concatStringsSep ", " (map (o: "`${o}`") opts)
                    else "*general contract configuration*";

                  srcFile = ctx.sourceOf srcKind srcName;

                  codeSnippet = ctx.targetedSnippet {
                    file = srcFile;
                    options = opts;
                    terms = ["${name}." "${name} =" "self.lib.${name}"];
                    hostName =
                      if srcKind == "host"
                      then srcName
                      else null;
                  };
                in ''
                  <details>
                  <summary><code><a href="../${
                    if srcKind == "lib"
                    then "lib"
                    else "${srcKind}s"
                  }/${srcName}.md">${srcName}</a></code></summary>

                  **Configures options**: ${optsStr}

                  ```nix
                  ${codeSnippet}
                  ```

                  </details>
                '';

                hostConsumers = lib.filter (id: lib.hasInfix "host:" id) (builtins.attrNames grouped);
                implConsumers = lib.filter (id: lib.hasInfix "implementation:" id) (builtins.attrNames grouped);
                featConsumers = lib.filter (id: lib.hasInfix "feature:" id) (builtins.attrNames grouped);
              in
                if edges == []
                then null
                else ''
                  ## Contract Consumers

                  Modules and instances configuring options under the `${name}` contract capability:

                  ${lib.optionalString (hostConsumers != []) ''
                    ### Hosts

                    ${lib.concatMapStringsSep "\n\n" renderConsumer hostConsumers}
                  ''}

                  ${lib.optionalString (implConsumers != []) ''
                    ### Implementations

                    ${lib.concatMapStringsSep "\n\n" renderConsumer implConsumers}
                  ''}

                  ${lib.optionalString (featConsumers != []) ''
                    ### Features

                    ${lib.concatMapStringsSep "\n\n" renderConsumer featConsumers}
                  ''}
                '';
            };
          };
        })
      (config.contract or {}));
  };
}
