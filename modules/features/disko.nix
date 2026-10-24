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
in {
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
