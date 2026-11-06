{
  inputs,
  lib ? inputs.nixpkgs.lib,
  ...
}: let
  /**
  Constructs a standard Disko disk configuration with EFI system partition, BIOS boot partition, LVM volume group, Btrfs subvolumes, and ephemeral tmpfs root.

  # Inputs

  `device`
  : Primary disk block device path (e.g., "/dev/nvme0n1", "/dev/sda").

  `espSize`
  : Size of EFI system partition (default: "1G").

  `biosBootSize`
  : Size of BIOS boot partition for MBR compatibility (default: "1M").

  `swapSize`
  : Size of swap partition or subvolume, or null if swap is disabled (default: null).

  `swapResume`
  : Whether to enable resume offset configuration for swap hibernation (default: false).

  `persistSize`
  : Size allocated to persistent data subvolume (default: "100%").

  `filesystem`
  : Root filesystem type (currently must be "btrfs").

  # Type
  ```
  mkLayout :: AttrSet -> AttrSet
  ```

  # Examples
  ```nix
  disko.mkLayout {
    device = "/dev/nvme0n1";
    swapSize = "8G";
  }
  ```
  */
  mkLayout = {
    device,
    espSize ? "1G",
    biosBootSize ? "1M",
    swapSize ? null,
    swapResume ? false,
    persistSize ? "100%",
    filesystem ? "btrfs",
  }:
    assert device != "";
    assert filesystem == "btrfs"; {
      disko.devices = {
        disk.main = {
          inherit device;
          type = "disk";
          content = {
            type = "gpt";
            partitions =
              {
                bios = {
                  name = "BIOS";
                  size = biosBootSize;
                  type = "EF02";
                  priority = 1;
                };
                esp = {
                  name = "ESP";
                  size = espSize;
                  type = "EF00";
                  priority = 2;
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                  };
                };
                root = {
                  name = "root";
                  size = persistSize;
                  content = {
                    type = "lvm_pv";
                    vg = "system";
                  };
                };
              }
              // (lib.optionalAttrs (swapSize != null) {
                swap = {
                  size = swapSize;
                  content = {
                    type = "swap";
                    resumeDevice = swapResume;
                  };
                };
              });
          };
        };
        lvm_vg.system = {
          type = "lvm_vg";
          lvs.root = {
            size = "100%FREE";
            content = {
              type = filesystem;
              extraArgs = ["-f"];
              subvolumes = {
                "/root" = {};
                "/persist" = {
                  mountOptions = ["subvol=persist" "noatime" "compress=zstd:1"];
                  mountpoint = "/persist";
                };
                "/nix" = {
                  mountOptions = ["subvol=nix" "noatime" "compress=zstd:1"];
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
        nodev."/" = {
          fsType = "tmpfs";
          mountOptions = ["size=25%" "mode=755"];
        };
      };
    };

  # Canonical lsblk-style columnar ASCII tree of Disko storage devices
  formatDiskLayout = {devices, ...}: let
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
in {
  # Storage layout section on every host page using Disko.
  docs.sections.host.storage = {
    order = 45;
    content = ctx: let
      devices = ctx.query.eval ctx.name ["disko" "devices"] {};
      layout = formatDiskLayout {inherit devices;};
    in
      if devices == {}
      then null
      else ''
        ## Storage Layout

        Evaluated Disko layout in canonical `lsblk(8)` format (see ${ctx.instanceLink "feature" "disko"}):

        ${ctx.md.code "text" layout}
      '';
  };

  feature.disko = {
    description = "Declarative disk partitioning and filesystem layouts via Disko.";
    modules = {
      disko = inputs.disko.nixosModules.disko;
    };
    lib = {
      mkLayout = {
        docstring = ''
          Constructs a standard Disko disk configuration with EFI system partition, BIOS boot partition, LVM volume group, Btrfs subvolumes, and ephemeral tmpfs root.

          # Inputs

          `device`
          : Primary disk block device path (e.g., "/dev/nvme0n1", "/dev/sda").

          `espSize`
          : Size of EFI system partition (default: "1G").

          `biosBootSize`
          : Size of BIOS boot partition for MBR compatibility (default: "1M").

          `swapSize`
          : Size of swap partition or subvolume, or null if swap is disabled (default: null).

          `swapResume`
          : Whether to enable resume offset configuration for swap hibernation (default: false).

          `persistSize`
          : Size allocated to persistent data subvolume (default: "100%").

          `filesystem`
          : Root filesystem type (currently must be "btrfs").

          # Type
          ```
          mkLayout :: AttrSet -> AttrSet
          ```

          # Examples
          ```nix
          disko.mkLayout {
            device = "/dev/nvme0n1";
            swapSize = "8G";
          }
          ```
        '';
        value = mkLayout;
      };
    };
  };
}
