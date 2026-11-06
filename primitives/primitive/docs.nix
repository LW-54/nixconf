# Parallel documentation module for the meta-primitive: declares docs/primitives/README.md.
{lib, ...}: {
  docs = {config, ...}: let
    primitives = lib.filterAttrs (name: _: name != "primitive") config.primitive;
  in {
    docs.pages = {
      primitives = {
        path = "docs/primitives/README.md";
        sections = {
          header = {
            order = 10;
            content = ctx: ''
              # Primitives

              First-class structural primitives governing repository architecture, typing, and outputs.

              ${ctx.backTo "readme" "Main README"}
            '';
          };
          catalog = {
            order = 50;
            content = ctx: ''
              ## Catalog

              ${ctx.md.table {
                headers = ["Primitive" "Description" "Instances" "Definition"];
                columns = [
                  (k:
                    ctx.pageLink (
                      if k == "lib"
                      then "lib"
                      else "${k}s"
                    ) "`${k}`")
                  (k: ctx.md.oneLine primitives.${k}.schema.doc)
                  (k: toString (builtins.length (builtins.attrNames (config.${k} or {}))))
                  (k: ctx.sourceLink (ctx.sourceOf "primitive" k))
                ];
                rows = builtins.attrNames primitives;
              }}
            '';
          };
        };
      };
    };
  };
}
