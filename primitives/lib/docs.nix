# Parallel documentation module for libraries: declares docs/lib/README.md
# and each library instance (docs/lib/<name>.md).
{lib, ...}: {
  docs = {config, ...}: {
    docs.pages =
      {
        lib = {
          path = "docs/lib/README.md";
          sections = {
            header = {
              order = 10;
              content = ctx: ''
                # Library

                Pure reusable helper functions, data types, calculations, and configuration presets exported across the repository.

                ${ctx.backTo "readme" "Main README"}
              '';
            };

            specification = {
              order = 15;
              content = ctx: ''
                ## Specification

                ${ctx.md.bullets [
                  "**Declared as**: `lib.<name>` in any flake-parts module under `modules/` or `primitives/`"
                  "**Primitive definition**: ${ctx.sourceLink (ctx.sourceOf "primitive" "lib")}"
                  "**Instances**: ${toString (builtins.length (builtins.attrNames (config.lib or {})))}"
                ]}
              '';
            };

            schema = {
              order = 20;
              content = ctx: ''
                ## Option Schema (`lib.<name>`)

                ${ctx.schemaOptionsTable "lib"}
              '';
            };

            example = {
              order = 30;
              content = ctx: ctx.exampleBlock "lib";
            };

            catalog = {
              order = 50;
              content = ctx: ''
                ## Catalog

                ${ctx.md.table {
                  headers = ["Library Namespace" "Description" "Exported Functions" "Definition" "Docs"];
                  columns = [
                    (l: ctx.instanceLink "lib" l)
                    (l: ctx.md.oneLine (config.lib.${l}.description or ""))
                    (l: let
                      syms = builtins.attrNames (config.lib.${l}.symbols or {});
                    in
                      if syms == []
                      then "—"
                      else lib.concatMapStringsSep ", " (s: "[`${s}`](${l}.md#${s})") syms)
                    (l: ctx.sourceLink (ctx.sourceOf "lib" l))
                    (l: ctx.moreLink "lib" l)
                  ];
                  rows = builtins.attrNames (config.lib or {});
                }}
              '';
            };
          };
        };
      }
      // (lib.mapAttrs' (name: libInst:
        lib.nameValuePair "lib/${name}" {
          path = "docs/lib/${name}.md";
          sections = {
            header = {
              order = 10;
              content = ctx: ''
                # Library: `${name}`

                ${libInst.description or ""}

                ${ctx.backTo "lib" "Library Documentation"} | ${ctx.backTo "readme" "Main README"}

                - **Library**: `flake.lib.${name}`
                - **Definition File**: ${ctx.sourceLink (ctx.sourceOf "lib" name)}
              '';
            };

            diagram = {
              order = 20;
              content = ctx: ctx.neighborhoodDiagram {nodeId = "urn:nixconf:onto:lib:${name}";};
            };

            usage = {
              order = 30;
              content = ctx: let
                syms = builtins.attrNames (libInst.symbols or {});
                firstFn =
                  if syms != []
                  then builtins.head syms
                  else "exampleHelper";
              in ''
                ## Usage

                This library namespace can be consumed both internally within repository modules and externally by downstream flakes.

                ### Internal Usage

                ```nix
                { self, lib, pkgs, ... }: {
                  example = self.lib.${name}.${firstFn};
                }
                ```

                ### External Usage

                ```nix
                {
                  inputs.nixconf.url = "github:LW-54/nixconf";

                  outputs = { self, nixconf, ... }: {
                    example = nixconf.lib.${name}.${firstFn};
                  };
                }
                ```
              '';
            };

            symbols = {
              order = 50;
              content = ctx: let
                syms = libInst.symbols or {};
                symNames = builtins.attrNames syms;

                renderSymbol = s: let
                  rawSym = syms.${s};
                in
                  if s == "types" && builtins.isAttrs rawSym
                  then
                    ctx.md.blocks [
                      "<a id=\"types\"></a>\n### `types`"
                      "Custom option types declared under this library namespace:"
                      (ctx.md.bullets (lib.mapAttrsToList (tName: tDef: "`${tName}`: ${tDef.description or "Custom option type."}") rawSym))
                    ]
                  else let
                    node =
                      ctx.graph.nodes."urn:nixconf:ast:function:${name}.${s}"
                      or (ctx.graph.nodes."urn:nixconf:ast:symbol:${name}.${s}" or null);
                    props =
                      if node != null
                      then node.properties or {}
                      else {};
                    summary = props.summary or "";
                    body = props.body or "";
                    typeSig = props.typeSignature or "";
                    examples = props.examples or "";
                    inputs = props.inputs or [];

                    fallbackDesc =
                      if builtins.isAttrs rawSym && rawSym ? description
                      then rawSym.description
                      else "";
                    descText =
                      if summary != ""
                      then summary
                      else fallbackDesc;
                  in
                    ctx.md.blocks [
                      "<a id=\"${s}\"></a>\n### `${s}`"
                      (lib.optionalString (descText != "") descText)
                      (lib.optionalString (body != "") body)
                      (
                        if inputs != []
                        then ''
                          #### Inputs

                          ${lib.concatMapStringsSep "\n" (inp: "- `${inp.name}`: ${inp.description}") inputs}
                        ''
                        else null
                      )
                      (
                        if typeSig != ""
                        then ''
                          #### Type

                          ```
                          ${typeSig}
                          ```
                        ''
                        else null
                      )
                      (
                        if examples != ""
                        then ''
                          #### Examples

                          ```nix
                          ${examples}
                          ```
                        ''
                        else null
                      )
                    ];
              in
                if symNames == []
                then null
                else ''
                  ## Exported Symbols

                  ${ctx.md.blocks (map renderSymbol symNames)}
                '';
            };
          };
        })
      (config.lib or {}));
  };
}
