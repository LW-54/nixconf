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

  # ASCII tree of the evaluated Disko layout of a NixOS configuration.
  layoutTree = devices: let
    mount = c:
      lib.optionalString ((c.mountpoint or null) != null) " -> ${c.mountpoint}";
    contentChildren = c:
      if (c.type or null) == "gpt"
      then lib.mapAttrsToList partition (c.partitions or {})
      else if (c.type or null) == "btrfs"
      then
        lib.mapAttrsToList (name: sv: {
          label = "${name} (subvolume)${mount sv}${lib.optionalString ((sv.swap or {}) != {}) " (swapfile)"}";
        }) (c.subvolumes or {})
      else [];
    contentSummary = c:
      if c == null
      then ""
      else if (c.type or null) == "filesystem"
      then ", ${c.format or "filesystem"}"
      else if (c.type or null) == "lvm_pv"
      then ", LVM PV of '${c.vg or "?"}'"
      else ", ${c.type or "raw"}";
    partition = name: p: {
      label = "${name} (${p.size or "?"}${contentSummary (p.content or null)})${mount (p.content or {})}";
      children = contentChildren (p.content or {});
    };
    volume = name: lv: {
      label = "${name} (${lv.size or "?"}${contentSummary (lv.content or null)})${mount (lv.content or {})}";
      children = contentChildren (lv.content or {});
    };
  in
    lib.mapAttrsToList (name: disk: {
      label = "${disk.device or name} (disk '${name}', ${disk.content.type or "raw"})";
      children = contentChildren (disk.content or {});
    }) (devices.disk or {})
    ++ lib.mapAttrsToList (name: vg: {
      label = "${name} (LVM volume group)";
      children = lib.mapAttrsToList volume (vg.lvs or {});
    }) (devices.lvm_vg or {})
    ++ lib.mapAttrsToList (mountpoint: fs: {
      label = "${mountpoint} (${fs.fsType or "nodev"}${lib.optionalString ((fs.mountOptions or []) != []) ", ${lib.concatStringsSep "," fs.mountOptions}"})";
    }) (devices.nodev or {});
in {
  # Storage layout section on every host page using Disko.
  docs.sections.host.storage = {
    order = 45;
    content = ctx: let
      devices = ctx.query.eval ctx.name ["disko" "devices"] {};
      layout = ctx.md.formatDiskLayout {inherit devices;};
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
