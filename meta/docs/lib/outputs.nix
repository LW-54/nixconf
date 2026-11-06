# Helpers for documenting non-primitive flake outputs:
# NixOS modules, packages, and development shells.
{
  lib,
  config,
  ...
}: let
  md = config.internal.docs.md;

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
  internal.docs.outputs = {
    inherit producer derivationPage;
  };
}
