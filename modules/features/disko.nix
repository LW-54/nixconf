{
  inputs,
  lib ? inputs.nixpkgs.lib,
  ...
}: let
  /**
  Constructs a standard Disko disk configuration with EFI system partition, BIOS boot partition, and Btrfs subvolumes (@, @nix, @persist, @swap).

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
                ESP = {
                  size = espSize;
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = ["umask=0077"];
                  };
                };
              }
              // (lib.optionalAttrs (biosBootSize != null) {
                biosBoot = {
                  size = biosBootSize;
                  type = "EF02";
                };
              })
              // {
                root = {
                  size = "100%";
                  content = {
                    type = "btrfs";
                    extraArgs = ["-f"];
                    subvolumes =
                      {
                        "@" = {
                          mountpoint = "/";
                          mountOptions = ["compress=zstd" "noatime"];
                        };
                        "@nix" = {
                          mountpoint = "/nix";
                          mountOptions = ["compress=zstd" "noatime"];
                        };
                        "@persist" = {
                          mountpoint = "/persist";
                          mountOptions = ["compress=zstd" "noatime"];
                        };
                      }
                      // (lib.optionalAttrs (swapSize != null) {
                        "@swap" = {
                          mountpoint = "/swap";
                          swap.swapfile.size = swapSize;
                        };
                      });
                  };
                };
              };
          };
        };
      };
      boot.resumeDevice = lib.mkIf swapResume "/dev/disk/by-partlabel/disk-main-root";
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
          Constructs a standard Disko disk configuration with EFI system partition, BIOS boot partition, and Btrfs subvolumes (@, @nix, @persist, @swap).

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
