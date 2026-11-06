# Source file resolution and AST syntax extraction utilities for NixOS modules and primitives.
{
  lib,
  config,
  options,
  self,
  ...
}: let
  # Repository-relative path of a module-system definition file.
  relativeSource = file: let
    noVia = builtins.head (lib.splitString ", via option" (toString file));
    stripped = lib.removePrefix "${toString self.outPath}/" noVia;
    storeMatch = builtins.match "/nix/store/[^/]+/(.*)" stripped;
  in
    if storeMatch != null
    then builtins.head storeMatch
    else stripped;

  # Any evaluated NixOS configuration, used to instantiate per-system attributes
  # (package sets, option trees) of instances that are not host-specific.
  referenceConfiguration = lib.findFirst (_: true) {} (builtins.attrValues (config.flake.nixosConfigurations or {}));

  # Raw definitions `{ file; value; }` of a primitive instance, as written in source files.
  instanceDefinitions = pName: iName:
    map (d: {
      inherit (d) file;
      value = d.value.${iName};
    }) (lib.filter (d: builtins.isAttrs d.value && d.value ? ${iName}) (options.${pName}.definitionsWithLocations or []));

  # Repository-relative file declaring a primitive instance (the definition carrying its description).
  resolveFile = pName: iName:
    if pName == "lib"
    then
      if config.feature ? ${iName}
      then resolveFile "feature" iName
      else if config.implementation ? ${iName}
      then resolveFile "implementation" iName
      else if config.contract ? ${iName}
      then resolveFile "contract" iName
      else if config.primitive ? ${iName}
      then "primitives/${iName}/default.nix"
      else let
        defs = lib.filter (d: let f = relativeSource d.file; in builtins.pathExists (self + "/${f}") && f != "primitives/default.nix") (instanceDefinitions "lib" iName);
        primary = lib.filter (d: builtins.isAttrs d.value && d.value ? description) defs;
        chosen =
          if primary != []
          then primary
          else defs;
      in
        if chosen == []
        then null
        else relativeSource (builtins.head chosen).file
    else if pName == "primitive"
    then "primitives/${iName}/default.nix"
    else let
      defs = lib.filter (d: let f = relativeSource d.file; in builtins.pathExists (self + "/${f}")) (instanceDefinitions pName iName);
      primary = lib.filter (d: builtins.isAttrs d.value && d.value ? description) defs;
      chosen =
        if primary != []
        then primary
        else defs;
    in
      if chosen == []
      then null
      else relativeSource (builtins.head chosen).file;

  # Source text of the file declaring a primitive instance.
  instanceSourceText = pName: iName: let
    file = resolveFile pName iName;
  in
    if file != null && builtins.pathExists (self + "/${file}")
    then builtins.readFile (self + "/${file}")
    else "";

  # Source code of an attribute (e.g. a host submodule), located via its definition position.
  attrSourceCode = pName: iName: path: attr: let
    positions = lib.concatMap (d: let
      container = lib.attrByPath path null d.value;
    in
      lib.optional (builtins.isAttrs container && container ? ${attr}) (builtins.unsafeGetAttrPos attr container))
    (instanceDefinitions pName iName);
    pos = lib.findFirst (p: p != null) null positions;
  in
    if pos == null
    then ""
    else let
      lines = lib.splitString "\n" (builtins.readFile pos.file);
      rem = lib.drop (pos.line - 1) lines;
      countChars = char: s: builtins.length (lib.filter (c: c == char) (lib.stringToCharacters s));
      folder = acc: line:
        if acc.isFinished
        then acc
        else let
          newDepth = acc.depth + countChars "{" line - countChars "}" line;
        in {
          depth = newDepth;
          lines = acc.lines ++ [line];
          isFinished = (acc.depth > 0 || countChars "{" line > 0) && newDepth <= 0;
        };
      block =
        (lib.foldl' folder {
            depth = 0;
            lines = [];
            isFinished = false;
          }
          rem).lines;
      indentOf = line: builtins.stringLength (builtins.head (builtins.match "( *).*" line));
      indent = lib.foldl' lib.min (pos.column - 1) (map indentOf (lib.filter (l: lib.trim l != "") block));
    in
      lib.concatMapStringsSep "\n" (l: builtins.substring indent (builtins.stringLength l) l) block;
in {
  internal.graph.extractors.source = {
    inherit relativeSource referenceConfiguration instanceDefinitions resolveFile instanceSourceText attrSourceCode;
  };
}
