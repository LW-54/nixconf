# Markdown toolkit shared by every page: relative links, tables, code blocks,
# collapsible details, ASCII trees, and compact value rendering (`ctx.md`).
{
  lib,
  config,
  ...
}: let
  graphLib = config.flake.lib.graph;

  # Directory components of a repository-relative file path.
  dirParts = path: lib.init (lib.splitString "/" path);

  /*
  Relative link from the page at `from` to the repository path `to`
  (optionally suffixed with `#anchor`).
  */
  relPath = from: to: let
    split = lib.splitString "#" to;
    target = builtins.head split;
    anchor = lib.optionalString (builtins.length split > 1) "#${lib.last split}";
    fromDir = dirParts from;
    targetParts = lib.splitString "/" target;
    common = let
      go = n:
        if n < builtins.length fromDir && n < builtins.length targetParts - 1 && builtins.elemAt fromDir n == builtins.elemAt targetParts n
        then go (n + 1)
        else n;
    in
      go 0;
    ups = lib.genList (_: "..") (builtins.length fromDir - common);
    rest = lib.drop common targetParts;
    rel = lib.concatStringsSep "/" (ups ++ rest);
  in
    if target == ""
    then anchor
    else if target == from
    then
      if anchor == ""
      then builtins.baseNameOf from
      else anchor
    else rel + anchor;

  # Collapses whitespace so text fits in a table cell or a bullet.
  oneLine = s: lib.concatStringsSep " " (lib.filter (w: w != "") (lib.splitString " " (builtins.replaceStrings ["\n" "\r" "\t"] [" " " " " "] (toString s))));

  code = lang: text: ''
    ```${lang}
    ${lib.trim text}
    ```'';

  details = summary: body: ''
    <details>
    <summary>${summary}</summary>

    ${lib.trim body}

    </details>'';

  bullets = items: lib.concatMapStringsSep "\n" (i: "- ${i}") items;

  # Compact, single-line rendering of an option default/example value.
  value = v:
    if v == null
    then "*null*"
    else if builtins.isAttrs v && (v._type or null) == "literalExpression"
    then "`${oneLine v.text}`"
    else if builtins.isAttrs v && (v._type or null) == "literalMD"
    then oneLine v.text
    else if lib.isDerivation v
    then "`<derivation ${v.name or "?"}>`"
    else if builtins.isFunction v
    then "`<function>`"
    else if builtins.isAttrs v
    then
      if v == {}
      then "`{ }`"
      else "`{ ... }`"
    else if builtins.isList v
    then
      if v == []
      then "`[ ]`"
      else "`[ ... ]`"
    else if builtins.isString v
    then "`\"${oneLine v}\"`"
    else if builtins.isBool v
    then "`${lib.boolToString v}`"
    else "`${toString v}`";

  # Joins non-empty markdown blocks with blank lines.
  blocks = parts: lib.concatStringsSep "\n\n" (map lib.trim (lib.filter (p: p != null && lib.trim p != "") parts));

  /*
  Renders a markdown table, or `empty` when there are no rows.
  */
  table = {
    headers,
    columns,
    rows,
    empty ? null,
  }:
    if rows == []
    then empty
    else graphLib.renderTable {inherit headers columns rows;};

  /*
  Renders an ASCII tree from `{ label; children ? [ ... ]; }` nodes.
  */
  tree = root: let
    renderChildren = prefix: children: let
      n = builtins.length children;
    in
      lib.concatLists (lib.imap0 (i: child: let
        last = i == n - 1;
      in
        [
          "${prefix}${
            if last
            then "└── "
            else "├── "
          }${child.label}"
        ]
        ++ renderChildren "${prefix}${
          if last
          then "    "
          else "│   "
        }" (child.children or []))
      children);
  in
    lib.concatStringsSep "\n" ([root.label] ++ renderChildren "" (root.children or []));

  # Capitalizes the first character of a string.
  capitalize = s: lib.toUpper (builtins.substring 0 1 s) + builtins.substring 1 (builtins.stringLength s) s;
in {
  internal.docs.md = {
    inherit
      relPath
      oneLine
      code
      details
      bullets
      value
      blocks
      table
      tree
      capitalize
      ;
  };
}
