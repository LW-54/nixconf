{
  lib,
  config,
  ...
}: let
  parser = config.flake.lib.docsParser;
  spec = config.flake.lib.docsSpec;

  cleanFilePath = p: let
    s = toString p;
    afterSource = lib.last (lib.splitString "-source/" s);
    afterRepo =
      if lib.hasInfix "nixconf/" afterSource
      then lib.last (lib.splitString "nixconf/" afterSource)
      else afterSource;
  in
    lib.removePrefix "/nix/store/" afterRepo;

  findLineInFile = absFile: pattern: let
    content = builtins.readFile absFile;
    lines = lib.splitString "\n" content;
    indexed = lib.imap1 (i: l: {inherit i l;}) lines;
    matches = lib.filter ({
      i,
      l,
    }:
      lib.hasInfix pattern l)
    indexed;
  in
    if matches != []
    then (builtins.head matches).i
    else 1;

  resolveFeatureRelativePath = name:
    if name == "wifi-eduroam"
    then "modules/features/wifi.nix"
    else if name == "vscode"
    then "modules/features/vcode.nix"
    else "modules/features/${name}.nix";

  # Extract Disko ASCII tree dynamically from evaluated host configuration
  generateDiskTree = hostConfig: let
    mainDisk = hostConfig.config.disko.devices.disk.main or null;
  in
    if mainDisk == null
    then "No Disko configuration defined."
    else let
      dev = mainDisk.device or "/dev/sda";
      parts = mainDisk.content.partitions or {};
      partNames = builtins.attrNames parts;
      renderPart = pName: let
        p = parts.${pName};
        size = p.size or "";
        fsType = p.content.format or (p.content.type or "");
        mp = p.content.mountpoint or "";
        isBtrfs = fsType == "btrfs";
        subvols =
          if isBtrfs
          then (p.content.subvolumes or {})
          else {};
        subvolNames = builtins.attrNames subvols;
        renderSubvol = svName: let
          sv = subvols.${svName};
          svMp =
            if sv ? mountpoint && sv.mountpoint != null
            then sv.mountpoint
            else "";
          swapSize = sv.swap.swapfile.size or null;
          swapInfo =
            if swapSize != null
            then " (swapfile ${swapSize})"
            else "";
        in "    ├── ${svName} (subvol)${lib.optionalString (svMp != "") " -> ${svMp}"}${swapInfo}";
        subvolLines =
          if subvolNames != []
          then "\n" + (lib.concatStringsSep "\n" (map renderSubvol subvolNames))
          else "";
        mountStr =
          if p ? content && p.content ? mountpoint && p.content.mountpoint != null
          then " -> ${p.content.mountpoint}"
          else "";
      in "├── ${pName} (${size}${lib.optionalString (fsType != null && fsType != "") ", ${fsType}"})${mountStr}${subvolLines}";
    in ''
      ${dev} (GPT)
      ${lib.concatStringsSep "\n" (map renderPart partNames)}
    '';

  # Extract Impermanence ASCII tree dynamically from evaluated host configuration
  generatePersistTree = hostConfig: let
    pCfg = hostConfig.config.persistence or {};
    sysDirs = pCfg.directories or [];
    sysFiles = pCfg.files or [];
    userUsers = pCfg.users or {};
    userNames = builtins.attrNames userUsers;

    renderUser = uName: let
      u = userUsers.${uName};
      dataDirs = u.data.directories or [];
      dataFiles = u.data.files or [];
      cacheDirs = u.cache.directories or [];
      renderList = items: map (i: "        ├── ${i}") (lib.sort (a: b: a < b) items);
      dataLines =
        if (dataDirs ++ dataFiles) != []
        then ["      ├── data/"] ++ (renderList (dataDirs ++ dataFiles))
        else [];
      cacheLines =
        if cacheDirs != []
        then ["      └── cache/"] ++ (renderList cacheDirs)
        else [];
    in
      [
        "  └── users/"
        "      └── ${uName}/"
      ]
      ++ dataLines
      ++ cacheLines;

    sysDirLines = map (d: "  ├── ${d}/") (lib.sort (a: b: a < b) sysDirs);
    sysFileLines = map (f: "  ├── ${f}") (lib.sort (a: b: a < b) sysFiles);
    userLines = lib.concatMap renderUser userNames;
  in
    lib.concatStringsSep "\n" ([
        "/persist"
        "├── system/"
      ]
      ++ sysDirLines
      ++ sysFileLines
      ++ userLines);

  # Extract submodule code block from host source file
  extractSubmoduleBlock = hostContent: subName: let
    lines = lib.splitString "\n" hostContent;
    indexed = lib.imap1 (i: l: {inherit i l;}) lines;
    startMatches = lib.filter (x: lib.hasInfix "${subName} =" x.l) indexed;
  in
    if startMatches == []
    then ""
    else let
      startLine = (builtins.head startMatches).i;
      rem = lib.sublist (startLine - 1) (builtins.length lines) lines;
      countChars = char: s: builtins.length (lib.filter (c: c == char) (lib.stringToCharacters s));
      folder = acc: line:
        if acc.isFinished
        then acc
        else let
          opens = countChars "{" line;
          closes = countChars "}" line;
          newDepth = acc.depth + opens - closes;
          newLines = acc.lines ++ [line];
          isDone = acc.depth > 0 && newDepth <= 0;
        in {
          depth = newDepth;
          lines = newLines;
          isFinished = isDone;
        };
      scan =
        lib.foldl' folder {
          depth = 0;
          lines = [];
          isFinished = false;
        }
        rem;
      rawBlock = lib.concatStringsSep "\n" scan.lines;
    in
      parser.stripLeadingIndentation rawBlock;

  # Extract contract configuration code snippet dynamically from file content
  extractContractSnippet = {
    fileContent,
    contractName,
    optionsWritten ? [],
  }: let
    lines = lib.splitString "\n" fileContent;
    countChars = char: s: builtins.length (lib.filter (c: c == char) (lib.stringToCharacters s));

    extractBlockFrom = startIdx: let
      rem = lib.sublist startIdx (builtins.length lines - startIdx) lines;
      folder = acc: line:
        if acc.done
        then acc
        else let
          opens = (countChars "{" line) + (countChars "(" line) + (countChars "[" line);
          closes = (countChars "}" line) + (countChars ")" line) + (countChars "]" line);
          newDepth = acc.depth + opens - closes;
          hasSemi = lib.hasSuffix ";" (lib.removeSuffix " " line);
          done = (acc.depth > 0 && newDepth <= 0) || (acc.depth == 0 && opens > 0 && opens == closes) || (acc.depth == 0 && hasSemi);
        in {
          depth = newDepth;
          lines = acc.lines ++ [line];
          done = done;
        };
      res =
        lib.foldl' folder {
          depth = 0;
          lines = [];
          done = false;
        }
        rem;
    in
      lib.concatStringsSep "\n" res.lines;

    isMatch = line:
      lib.hasInfix "self.lib.${contractName}." line
      || lib.hasInfix "${contractName}." line
      || builtins.any (opt: lib.hasInfix opt line) optionsWritten;

    matchingIndices = lib.filter (i: isMatch (builtins.elemAt lines i)) (lib.range 0 (builtins.length lines - 1));

    extractAll = indices: let
      folder = acc: idx:
        if idx < acc.lastEndIdx
        then acc
        else let
          block = extractBlockFrom idx;
          blockLines = lib.splitString "\n" block;
          endIdx = idx + builtins.length blockLines;
          clean = parser.stripLeadingIndentation block;
        in {
          lastEndIdx = endIdx;
          blocks = acc.blocks ++ [clean];
        };
      res =
        lib.foldl' folder {
          lastEndIdx = -1;
          blocks = [];
        }
        indices;
    in
      lib.concatStringsSep "\n\n" res.blocks;
  in
    if matchingIndices == []
    then ""
    else extractAll matchingIndices;

  /**
  Dynamically scans source file content for any options configured under active capability contracts.

  # Inputs

  `consumerId`
  : Canonical ID of the consumer (e.g. "feature:vaultwarden", "impl:caddy", "host:astrolabe").

  `content`
  : Raw Nix source code of the consumer module or host.

  `contractNames`
  : List of known active capability contracts.

  `validOptionPaths`
  : List of known declared contract option paths.

  # Type
  ```
  scanContractConsumption :: AttrSet -> [AttrSet]
  ```
  */
  scanContractConsumption = {
    consumerId,
    content,
    contractNames,
    validOptionPaths ? [],
  }:
    lib.concatMap (cName: let
      hasMention =
        lib.hasInfix "${cName}." content
        || lib.hasInfix "self.lib.${cName}." content;
    in
      if !hasMention
      then []
      else let
        lines = lib.splitString "\n" content;
        findOptionMatches = line: let
          m = builtins.match ".*[ (](${cName}\\.[a-zA-Z0-9_.-]+)[ =].*" line;
        in
          if m != null
          then builtins.head m
          else null;
        directOptions = lib.filter (x: x != null) (map findOptionMatches lines);
        filteredValid = lib.filter (p: lib.hasPrefix "${cName}." p && lib.hasInfix p content) validOptionPaths;
        allOptions = lib.unique (directOptions ++ filteredValid);
        optionsWritten =
          if allOptions != []
          then allOptions
          else ["${cName}.enable"];
        snippet = extractContractSnippet {
          fileContent = content;
          contractName = cName;
          inherit optionsWritten;
        };
      in
        if consumerId == "contract:${cName}" || consumerId == "impl:${cName}"
        then []
        else [
          {
            consumer = consumerId;
            contract = "contract:${cName}";
            inherit optionsWritten;
            codeSnippet = snippet;
          }
        ])
    contractNames;

  /**
  Resolves the originating source file and line for a flake.lib symbol.
  */
  resolveSymbolSource = {
    ns,
    symName,
    pos ? null,
    contracts,
    implementations,
    features,
    hosts,
  }: let
    knownPrimitiveFiles = {
      "primitive" = "primitives/primitive.nix";
      "host" = "primitives/host.nix";
      "contract" = "primitives/contract.nix";
      "implementation" = "primitives/implementation.nix";
      "feature" = "primitives/feature.nix";
      "lib" = "primitives/lib.nix";
      "docsSpec" = "meta/docs/spec/default.nix";
      "docsParser" = "meta/docs/parser.nix";
      "docsGraph" = "meta/docs/graph/default.nix";
      "docsMermaid" = "meta/docs/mermaid.nix";
      "docsMarkdown" = "meta/docs/markdown/default.nix";
    };

    inferredRel =
      if knownPrimitiveFiles ? ${ns}
      then knownPrimitiveFiles.${ns}
      else if knownPrimitiveFiles ? ${symName}
      then knownPrimitiveFiles.${symName}
      else if contracts ? ${ns}
      then "modules/contracts/${ns}.nix"
      else if implementations ? ${ns}
      then "modules/implementations/${ns}.nix"
      else if features ? ${ns}
      then resolveFeatureRelativePath ns
      else if hosts ? ${ns}
      then "modules/hosts/${ns}.nix"
      else null;

    relFile =
      if pos != null && pos ? file && !builtins.isPath pos.file
      then cleanFilePath pos.file
      else if inferredRel != null
      then inferredRel
      else "primitives/lib.nix";

    repoRoot = ./../../../.;
    absFile = repoRoot + "/${relFile}";

    foundLine =
      if builtins.pathExists absFile
      then let
        content = builtins.readFile absFile;
        lines = lib.splitString "\n" content;
        indexed = lib.imap1 (i: l: {inherit i l;}) lines;
        p1 = lib.filter (x: (lib.hasInfix "${symName} =" x.l || lib.hasInfix "${symName}  =" x.l) && !lib.hasInfix "::" x.l && !lib.hasPrefix "*" (lib.trim x.l)) indexed;
        p2 = lib.filter (x: lib.hasInfix symName x.l && !lib.hasInfix "::" x.l) indexed;
      in
        if p1 != []
        then (builtins.head p1).i
        else if p2 != []
        then (builtins.head p2).i
        else 1
      else 1;

    line =
      if pos != null && pos ? line && pos.line > 1
      then pos.line
      else foundLine;
  in {
    file = relFile;
    inherit line;
  };

  /**
  Extracts documentation metadata and validates an individual flake.lib symbol (function or value).
  */
  resolveSymbolDoc = {
    currName,
    rawSym,
    sourceInfo,
    spec,
    parser,
  }: let
    hasDocAttr = builtins.isAttrs rawSym && rawSym ? docstring && rawSym.docstring != null;
    rawComment =
      if hasDocAttr
      then rawSym.docstring
      else null;
    val =
      if builtins.isAttrs rawSym && rawSym ? value
      then rawSym.value
      else rawSym;
    parsedDoc = parser.parseDocstring rawComment;
    isFn = builtins.isFunction val;
    todos =
      if parsedDoc == null || parsedDoc.summary == ""
      then [
        (spec.recordTodo {
          id = "fn:${currName}";
          kind = "docstring";
          inherit (sourceInfo) file line;
          message = "Library symbol 'flake.lib.${currName}' is missing documentation.";
        })
      ]
      else if isFn
      then
        spec.validateFunction {
          name = currName;
          f = val;
          doc = parsedDoc;
          inherit (sourceInfo) file line;
        }
      else [];
  in {
    kind =
      if isFn
      then "fn"
      else "symbol";
    name = currName;
    inherit (sourceInfo) file line;
    parsedDoc =
      if parsedDoc != null
      then parsedDoc
      else {
        summary = "Flake library symbol ${currName}.";
        body = "";
        inputs = [];
        typeSignature = "${currName} :: ${builtins.typeOf val}";
        examples = "";
      };
    inherit todos;
  };

  /**
  Assigns a rich, contextual description to an exported NixOS module.
  */
  resolveModuleDescription = {
    name,
    contracts,
    implementations,
    features,
    hosts,
  }:
    if contracts ? ${name}
    then "Capability contract interface defining '${name}' option schemas and custom types."
    else if implementations ? ${name}
    then implementations.${name}.description
    else if features ? ${name}
    then features.${name}.description
    else if name == "contracts"
    then "Central contract registry importing all declared capability interfaces."
    else if hosts ? ${name}
    then "Unified NixOS system configuration root module for host '${name}'."
    else let
      # Check if module belongs to a feature
      featureMatch = lib.filter (fName: builtins.hasAttr name features.${fName}.modules) (builtins.attrNames features);
      # Check if module is a host submodule
      hostMatch = lib.filter (hName: builtins.hasAttr name hosts.${hName}.subModules || lib.hasPrefix "${hName}-" name) (builtins.attrNames hosts);
    in
      if featureMatch != []
      then let
        f = builtins.head featureMatch;
      in "System service module exported by the '${f}' feature."
      else if hostMatch != []
      then let
        h = builtins.head hostMatch;
        sub = lib.removePrefix "${h}-" name;
      in
        if sub == "hardware"
        then "Hardware profile, kernel modules, and bootloader configuration for ${h}."
        else if sub == "disk"
        then "Storage partition layout, Btrfs subvolumes, and swap configuration for ${h}."
        else if sub == "system"
        then "Core operating system foundation, networking, and locale configuration for ${h}."
        else if sub == "system-features"
        then "System services, networking utilities, and security toolchains for ${h}."
        else if sub == "services"
        then "Daemon services, reverse-proxy ingress, and automated backups for ${h}."
        else if sub == "desktop"
        then "Wayland compositor, graphical environment, and desktop services for ${h}."
        else if sub == "desktop-features"
        then "Graphical desktop applications, web browsers, and developer IDEs for ${h}."
        else if sub == "packages"
        then "Core system packages and command-line utilities installed for ${h}."
        else "Host configuration submodule partitioning ${sub} for ${h}."
      else "Exported NixOS configuration module '${name}'.";
in {
  internal.docs.graph.discovery = {
    inherit
      cleanFilePath
      findLineInFile
      resolveFeatureRelativePath
      generateDiskTree
      generatePersistTree
      extractSubmoduleBlock
      extractContractSnippet
      scanContractConsumption
      resolveSymbolSource
      resolveSymbolDoc
      resolveModuleDescription
      ;
  };
}
