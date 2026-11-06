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

  # Canonical lsblk-style columnar ASCII tree of Disko storage devices
  formatDiskLayout = {
    devices,
    format ? "lsblk",
  }: let
    visualWidth = s: builtins.stringLength (builtins.replaceStrings ["├─" "└─" "│"] ["--" "--" "|"] (toString s));
    pad = width: str: let
      s = toString str;
      len = visualWidth s;
    in
      if len >= width
      then s
      else s + lib.concatStrings (lib.genList (_: " ") (width - len));

    subvolRows = svName: sv: {
      name = "subvol:${svName}";
      type = "subvolume";
      fstype = "btrfs";
      size = "";
      mountpoint =
        if (sv.mountpoint or null) != null
        then sv.mountpoint
        else if (sv.swap or {}) != {}
        then "(swapfile)"
        else "(snapshot)";
      children = [];
    };

    lvRows = lvName: lv: let
      content = lv.content or {};
      cType = content.type or "";
    in {
      name = lvName;
      type = "lvm_lv";
      fstype =
        if cType == "btrfs"
        then "btrfs"
        else (content.format or cType);
      size = lv.size or "";
      mountpoint = content.mountpoint or "";
      children =
        if cType == "btrfs"
        then lib.mapAttrsToList subvolRows (content.subvolumes or {})
        else [];
    };

    vgRows = vgName: vg: {
      name = vgName;
      type = "lvm_vg";
      fstype = "";
      size = "";
      mountpoint = "";
      children = lib.mapAttrsToList lvRows (vg.lvs or {});
    };

    partRows = pName: p: let
      content = p.content or {};
      cType = content.type or "";
      isLvmPv = cType == "lvm_pv";
      vgName = content.vg or "";
      matchedVg =
        if isLvmPv && vgName != "" && devices ? lvm_vg && devices.lvm_vg ? ${vgName}
        then [(vgRows vgName devices.lvm_vg.${vgName})]
        else [];
    in {
      name = pName;
      type = "part";
      fstype =
        if isLvmPv
        then "lvm_pv"
        else (content.format or cType);
      size = p.size or "";
      mountpoint = content.mountpoint or "";
      children = matchedVg;
    };

    diskRows = dName: d: let
      content = d.content or {};
    in {
      name = d.device or dName;
      type = "disk";
      fstype = content.type or "";
      size = "";
      mountpoint = "";
      children =
        if (content.type or "") == "gpt"
        then lib.mapAttrsToList partRows (content.partitions or {})
        else [];
    };

    referencedVgs = lib.concatLists (lib.mapAttrsToList (_: d: let
      content = d.content or {};
    in
      if (content.type or "") == "gpt"
      then
        lib.concatMap (p:
          if (p.content.type or "") == "lvm_pv"
          then [(p.content.vg or "")]
          else [])
        (builtins.attrValues (content.partitions or {}))
      else []) (devices.disk or {}));

    standaloneVgs = lib.mapAttrsToList vgRows (lib.filterAttrs (name: _: !builtins.elem name referencedVgs) (devices.lvm_vg or {}));

    allRoots =
      lib.mapAttrsToList diskRows (devices.disk or {})
      ++ standaloneVgs
      ++ (
        if (devices.nodev or {}) != {}
        then [
          {
            name = "[nodev]";
            type = "";
            fstype = "";
            size = "";
            mountpoint = "";
            children =
              lib.mapAttrsToList (mp: fs: {
                name = fs.fsType or "tmpfs";
                type = "nodev";
                fstype = fs.fsType or "tmpfs";
                size =
                  if fs ? mountOptions
                  then let
                    sizeOpt = lib.findFirst (opt: lib.hasPrefix "size=" opt) null fs.mountOptions;
                  in
                    if sizeOpt != null
                    then builtins.substring 5 (builtins.stringLength sizeOpt) sizeOpt
                    else ""
                  else "";
                mountpoint = mp;
                children = [];
              })
              devices.nodev;
          }
        ]
        else []
      );

    flatten = depth: prefix: isLast: node: let
      branch =
        if depth == 0
        then ""
        else if isLast
        then "└─"
        else "├─";
      nextPrefix =
        if depth == 0
        then ""
        else if isLast
        then prefix + "  "
        else prefix + "│ ";
      nChildren = builtins.length node.children;
      row = {
        name = prefix + branch + node.name;
        inherit (node) type fstype size mountpoint;
      };
      childRows = lib.concatLists (lib.imap0 (i: child: flatten (depth + 1) nextPrefix (i == nChildren - 1) child) node.children);
    in
      [row] ++ childRows;

    rows = lib.concatMap (root: flatten 0 "" true root) allRoots;

    maxLen = fn:
      lib.foldl' (acc: r: let
        v = fn r;
        str =
          if v != null
          then toString v
          else "";
      in
        lib.max acc (visualWidth str))
      0
      rows;
    colNameW = lib.max (builtins.stringLength "NAME") (maxLen (r: r.name));
    colTypeW = lib.max (builtins.stringLength "TYPE") (maxLen (r: r.type));
    colFsW = lib.max (builtins.stringLength "FSTYPE") (maxLen (r: r.fstype));
    colSizeW = lib.max (builtins.stringLength "SIZE") (maxLen (r: r.size));
    gutter = "  ";

    trimRight = s: let
      m = builtins.match "(.*[^ ]) *" s;
    in
      if m != null
      then builtins.head m
      else "";

    header = "${pad colNameW "NAME"}${gutter}${pad colTypeW "TYPE"}${gutter}${pad colFsW "FSTYPE"}${gutter}${pad colSizeW "SIZE"}${gutter}MOUNTPOINT";
    formatRow = r: let
      mp =
        if (r.mountpoint or null) != null
        then toString r.mountpoint
        else "";
      raw = "${pad colNameW (r.name or "")}${gutter}${pad colTypeW (r.type or "")}${gutter}${pad colFsW (r.fstype or "")}${gutter}${pad colSizeW (r.size or "")}${gutter}${mp}";
    in
      trimRight raw;
    lines = [header] ++ map formatRow rows;
  in
    lib.concatStringsSep "\n" lines;

  # Pluggable persisted state formatter distinguishing [dir] vs [file]
  formatPersistence = {
    roots,
    format ? "flat-tree",
  }: let
    entryStr = e:
      if builtins.isString e
      then e
      else e.directory or (e.file or "?");

    cleanPath = p: lib.removePrefix "/" p;

    renderRoot = path: r: let
      dirs = map (d: "[dir]  /${cleanPath (entryStr d)}/") (r.directories or []);
      files = map (f: "[file] /${cleanPath (entryStr f)}") (r.files or []);
      userDirs =
        lib.concatLists (lib.mapAttrsToList (user: u:
            map (d: "[dir]  ~${user}/${cleanPath (entryStr d)}/") (u.directories or [])) (r.users or {}));
      userFiles =
        lib.concatLists (lib.mapAttrsToList (user: u:
            map (f: "[file] ~${user}/${cleanPath (entryStr f)}") (u.files or [])) (r.users or {}));
      allLeaves = lib.sort (a: b: a < b) (dirs ++ files ++ userDirs ++ userFiles);
    in {
      label = path;
      children = map (l: {label = l;}) allLeaves;
    };

    activeRoots = lib.filterAttrs (_: r:
      (r.directories or [])
      != []
      || (r.files or []) != []
      || lib.any (u: (u.directories or []) != [] || (u.files or []) != []) (builtins.attrValues (r.users or {})))
    roots;

    treeNodes = lib.mapAttrsToList renderRoot activeRoots;
  in
    if treeNodes == []
    then null
    else lib.concatMapStringsSep "\n\n" tree treeNodes;
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
      formatDiskLayout
      formatPersistence
      ;
  };
}
