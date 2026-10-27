{
  lib,
  config,
  ...
}: let
  graphLib = config.flake.lib.graph;
  renderTable = graphLib.renderTable;

  /**
  Builds an interactive link resolver function for graph nodes pointing to their documentation page.
  */
  makeDocLinkFn = {relPrefix ? ".."}: node:
    if node.kind == "host" || node.kind == "configuration"
    then "${relPrefix}/hosts/${node.name}.md"
    else if node.kind == "contract"
    then "${relPrefix}/contracts/${node.name}.md"
    else if node.kind == "impl" || node.kind == "implementation"
    then "${relPrefix}/implementations/${node.name}.md"
    else if node.kind == "feature"
    then "${relPrefix}/features/${node.name}.md"
    else if node.kind == "pkg" || node.kind == "package"
    then "${relPrefix}/PACKAGES.md#${node.name}"
    else if node.kind == "shell" || node.kind == "devShell"
    then "${relPrefix}/DEVSHELLS.md#${node.name}"
    else if node.kind == "module"
    then "${relPrefix}/modules/${node.name}.md"
    else if node.kind == "lib"
    then "${relPrefix}/lib/${node.name}.md"
    else null;

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

  /**
  Renders a table of exported packages.
  */
  renderPkgTable = {
    packages,
    relPrefix ? "..",
    desc ? "Executable application package",
  }:
    if packages == []
    then "*No packages exported.*"
    else
      renderTable {
        headers = ["Package" "Run Command" "Description" "Details"];
        columns = [
          (p: "[`${p}`](${relPrefix}/PACKAGES.md#${p})")
          (p: "`nix run .#${p}`")
          (_: desc)
          (p: "[More →](${relPrefix}/PACKAGES.md#${p})")
        ];
        rows = packages;
      };

  /**
  Renders a table of exported development shells.
  */
  renderShellTable = {
    devShells,
    relPrefix ? "..",
    desc ? "Interactive development shell",
  }:
    if devShells == []
    then "*No development shells exported.*"
    else
      renderTable {
        headers = ["Devshell" "Develop Command" "Description" "Details"];
        columns = [
          (s: "[`${s}`](${relPrefix}/DEVSHELLS.md#${s})")
          (s: "`nix develop .#${s}`")
          (_: desc)
          (s: "[More →](${relPrefix}/DEVSHELLS.md#${s})")
        ];
        rows = devShells;
      };

  /**
  Renders a table of exported NixOS modules.
  */
  renderModTable = {
    modules,
    relPrefix ? "..",
    desc ? "Exported NixOS configuration module",
  }:
    if modules == []
    then "*No modules exported.*"
    else
      renderTable {
        headers = ["Module" "Description" "Details"];
        columns = [
          (m: "[`${m}`](${relPrefix}/modules/${m}.md)")
          (_: desc)
          (m: "[More →](${relPrefix}/modules/${m}.md)")
        ];
        rows = modules;
      };

  /**
  Renders a table of exported library symbols.
  */
  renderLibTable = {
    libExports,
    ns,
    relPrefix ? "..",
    desc ? "Library helper symbol",
  }:
    if libExports == []
    then "*No library symbols exported.*"
    else
      renderTable {
        headers = ["Symbol" "Description" "Details"];
        columns = [
          (sym: "[`flake.lib.${ns}.${sym}`](${relPrefix}/lib/${ns}.md#${sym})")
          (_: desc)
          (sym: "[More →](${relPrefix}/lib/${ns}.md#${sym})")
        ];
        rows = libExports;
      };

  /**
  Renders a table of contract options.
  */
  renderOptTable = {options}:
    if options == []
    then "*No options declared.*"
    else
      renderTable {
        headers = ["Option" "Type" "Default" "Example" "Description"];
        columns = [
          (o: "`options.${o.name}`")
          (o: "`${o.properties.type}`")
          (
            o:
              if o.properties.default != null
              then
                if builtins.isAttrs o.properties.default
                then "`{ ... }`"
                else if builtins.isList o.properties.default
                then "`[ ... ]`"
                else "`${toString o.properties.default}`"
              else "*null*"
          )
          (
            o:
              if o.properties.example != null
              then
                if builtins.isAttrs o.properties.example
                then "`{ ... }`"
                else if builtins.isList o.properties.example
                then "`[ ... ]`"
                else "`${toString o.properties.example}`"
              else "*none*"
          )
          (o: builtins.replaceStrings ["\n" "|"] [" " "\\|"] (lib.trim o.properties.description))
        ];
        rows = options;
      };

  /**
  Renders a table of contract types.
  */
  renderTypeTable = {
    types,
    cName,
    relPrefix ? "..",
  }:
    if types == []
    then "*No custom types declared.*"
    else
      renderTable {
        headers = ["Type" "Description" "Details"];
        columns = [
          (t: "[`${t.name}`](${relPrefix}/lib/${cName}.md#${t.name})")
          (t: builtins.replaceStrings ["\n" "|"] [" " "\\|"] (lib.trim (t.properties.description or "Custom type")))
          (t: "[More →](${relPrefix}/lib/${cName}.md#${t.name})")
        ];
        rows = types;
      };
in {
  internal.docs.markdown.shared = {
    inherit
      makeDocLinkFn
      renderPkgRow
      renderShellRow
      renderModRow
      renderLibRow
      renderTypeRow
      renderOptRow
      renderPkgTable
      renderShellTable
      renderModTable
      renderLibTable
      renderOptTable
      renderTypeTable
      ;
  };
}
