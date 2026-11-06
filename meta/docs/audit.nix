# Documentation Quality & Coverage Audit Engine
# Analyzes repository docstrings, schema options, library symbols, and primitives.
# Evaluates purely on AST and Onto spine in < 0.4s without forcing host fixpoints.
{
  lib,
  config,
  options,
  ...
}: let
  kinds = ["host" "feature" "contract" "implementation" "lib" "primitive"];

  resolveFile = kind: name:
    if config ? internal && config.internal ? graph && config.internal.graph ? extractors && config.internal.graph.extractors ? onto
    then config.internal.graph.extractors.onto.resolveFile kind name
    else "modules/${kind}s/${name}.nix";

  schemaOptions = kind: let
    rawEval = (options.${kind}.type.getSubOptions or (_: {})) [];
    evaluated =
      if builtins.isAttrs rawEval
      then rawEval
      else {};
    declared =
      if evaluated != {}
      then evaluated
      else config.primitive.${kind}.options or {};
  in
    lib.filterAttrs (n: o: !lib.hasPrefix "_" n && lib.isOption o) declared;

  # 1. Audit Primitives
  primitiveAudit = lib.concatMap (kind: let
    instances = config.${kind} or {};
  in
    lib.mapAttrsToList (name: inst: let
      desc = inst.description or "";
      isDocumented = desc != "" && desc != "TODO" && desc != "..." && !lib.hasPrefix "TODO" desc;
      file = resolveFile kind name;
    in {
      category = "primitives";
      inherit kind name file;
      target = "${kind}.${name}";
      documented = isDocumented;
      warning =
        if isDocumented
        then null
        else {
          category = "primitives";
          inherit kind name file;
          target = "${kind}.${name}";
          missing = "description";
          suggestedFix = "Add 'description = \"...\";' to ${kind}.${name}";
        };
    })
    instances)
  kinds;

  # 2. Audit Library Symbols
  allLibs = lib.filterAttrs (name: _: name != "options" && (config.primitive.lib ? ${name} || (config.lib ? ${name} && (config.lib.${name} ? symbols || config.lib.${name} ? description)))) ((config.lib or {}) // (config.primitive.lib or {}));
  symbolAudit = lib.concatMap (lName: let
    lDef = allLibs.${lName};
    symbols = lDef.symbols or {};
    file = resolveFile "lib" lName;
  in
    lib.mapAttrsToList (sName: sym: let
      isContainer = sName == "types" || sName == "options";
      doc = sym.docstring or (sym.description or "");
      hasDoc = doc != "" && doc != "TODO" && doc != "..." && !lib.hasPrefix "TODO" doc;
      hasType = (sym ? type) || lib.hasInfix "# Type" doc || lib.hasInfix "::" doc;
      isDocumented =
        if isContainer
        then (builtins.isAttrs sym && sym != {}) || hasDoc
        else hasDoc && hasType;
      missingDesc =
        if isContainer
        then
          if !(builtins.isAttrs sym && sym != {}) && !hasDoc
          then "empty container"
          else null
        else if !hasDoc
        then "docstring"
        else if !hasType
        then "type signature (# Type)"
        else null;
    in {
      category = "symbols";
      kind = "lib";
      name = "${lName}.${sName}";
      inherit file;
      target = "lib.${lName}.${sName}";
      documented = isDocumented;
      warning =
        if isDocumented
        then null
        else {
          category = "symbols";
          kind = "lib";
          name = "${lName}.${sName}";
          inherit file;
          target = "lib.${lName}.${sName}";
          missing = missingDesc;
          suggestedFix =
            if isContainer
            then "Populate type definitions in lib.${lName}.${sName}"
            else if !hasDoc
            then "Add docstring with '# Inputs' and '# Type' to lib.${lName}.${sName}"
            else "Add '# Type' section to docstring of lib.${lName}.${sName}";
        };
    })
    symbols)
  (builtins.attrNames allLibs);

  # 3. Audit Schema Options
  optionAudit = lib.concatMap (kind: let
    opts = schemaOptions kind;
  in
    lib.mapAttrsToList (optName: opt: let
      desc = opt.description or "";
      isDocumented = desc != "" && desc != null;
    in {
      category = "options";
      inherit kind;
      name = "${kind}.${optName}";
      file = "primitives/${kind}/default.nix";
      target = "options.${kind}.${optName}";
      documented = isDocumented;
      warning =
        if isDocumented
        then null
        else {
          category = "options";
          inherit kind;
          name = "${kind}.${optName}";
          file = "primitives/${kind}/default.nix";
          target = "options.${kind}.${optName}";
          missing = "description";
          suggestedFix = "Add 'description = \"...\";' to option ${kind}.${optName}";
        };
    })
    opts)
  kinds;

  allAudits = primitiveAudit ++ symbolAudit ++ optionAudit;

  warnings = lib.filter (w: w != null) (map (a: a.warning) allAudits);

  totalItems = builtins.length allAudits;
  undocumentedItems = builtins.length warnings;
  documentedItems = totalItems - undocumentedItems;

  # Pure integer arithmetic for deterministic percentage representation (e.g. 94.2%)
  scoreInt =
    if totalItems == 0
    then 1000
    else (documentedItems * 1000) / totalItems;
  scoreWhole = toString (scoreInt / 10);
  scoreFrac = toString (scoreInt - ((scoreInt / 10) * 10));
  scoreString = "${scoreWhole}.${scoreFrac}%";

  isPerfect = undocumentedItems == 0;

  warningsByCategory = lib.groupBy (w: w.category) warnings;

  report = {
    inherit
      totalItems
      documentedItems
      undocumentedItems
      scoreInt
      scoreString
      isPerfect
      warnings
      ;

    byCategory = {
      primitives = {
        total = builtins.length primitiveAudit;
        documented = builtins.length (lib.filter (a: a.documented) primitiveAudit);
        warnings = warningsByCategory.primitives or [];
      };
      symbols = {
        total = builtins.length symbolAudit;
        documented = builtins.length (lib.filter (a: a.documented) symbolAudit);
        warnings = warningsByCategory.symbols or [];
      };
      options = {
        total = builtins.length optionAudit;
        documented = builtins.length (lib.filter (a: a.documented) optionAudit);
        warnings = warningsByCategory.options or [];
      };
    };

    summaryLine =
      if isPerfect
      then ""
      else "==> [docs] Documentation Health: ${scoreString} (${toString documentedItems}/${toString totalItems} items documented, ${toString undocumentedItems} warnings). See docs/coverage.md";
  };
in {
  internal.docs = {
    audit = report;
    health = report;
  };
}
