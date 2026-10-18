{
  inputs,
  lib ? inputs.nixpkgs.lib,
  ...
}: {
  flake.nixosModules.disko = inputs.disko.nixosModules.disko;

  flake.lib.disko.mkLayout = {
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
}
