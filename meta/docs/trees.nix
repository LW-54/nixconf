{lib, ...}: let
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
in {
  internal.docs.trees = {
    inherit
      generateDiskTree
      generatePersistTree
      ;
  };
}
