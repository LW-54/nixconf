{lib, ...}: let
  renderPkgRow = {
    p,
    relPrefix ? "..",
    desc ? "Executable application package",
  }: "| [`${p}`](${relPrefix}/PACKAGES.md#${p}) | `nix run .#${p}` | ${desc} | [More →](${relPrefix}/PACKAGES.md#${p}) |";

  renderShellRow = {
    s,
    relPrefix ? "..",
    desc ? "Interactive development shell",
  }: "| [`${s}`](${relPrefix}/DEVSHELLS.md#${s}) | `nix develop .#${s}` | ${desc} | [More →](${relPrefix}/DEVSHELLS.md#${s}) |";

  renderModRow = {
    m,
    relPrefix ? "..",
    desc ? "Exported NixOS configuration module",
  }: "| [`${m}`](${relPrefix}/modules/${m}.md) | ${desc} | [More →](${relPrefix}/modules/${m}.md) |";

  renderLibRow = {
    sym,
    ns,
    relPrefix ? "..",
    desc ? "Library helper symbol",
  }: "| [`flake.lib.${ns}.${sym}`](${relPrefix}/lib/${ns}.md#${sym}) | ${desc} | [More →](${relPrefix}/lib/${ns}.md#${sym}) |";

  renderTypeRow = {
    t,
    cName,
    relPrefix ? "..",
  }: let
    d = builtins.replaceStrings ["\n" "|"] [" " "\\|"] (lib.trim (t.properties.description or "Custom type"));
  in "| [`${t.name}`](${relPrefix}/lib/${cName}.md#${t.name}) | ${d} | [More →](${relPrefix}/lib/${cName}.md#${t.name}) |";

  renderOptRow = o: let
    d = builtins.replaceStrings ["\n" "|"] [" " "\\|"] (lib.trim o.properties.description);
    def =
      if o.properties.default != null
      then
        if builtins.isAttrs o.properties.default
        then "`{ ... }`"
        else if builtins.isList o.properties.default
        then "`[ ... ]`"
        else "`${toString o.properties.default}`"
      else "*null*";
    ex =
      if o.properties.example != null
      then
        if builtins.isAttrs o.properties.example
        then "`{ ... }`"
        else if builtins.isList o.properties.example
        then "`[ ... ]`"
        else "`${toString o.properties.example}`"
      else "*none*";
  in "| `options.${o.name}` | `${o.properties.type}` | ${def} | ${ex} | ${d} |";
in {
  internal.docs.markdown.shared = {
    inherit
      renderPkgRow
      renderShellRow
      renderModRow
      renderLibRow
      renderTypeRow
      renderOptRow
      ;
  };
}
