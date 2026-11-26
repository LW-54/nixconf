{
  bound,
  inputs,
  lib,
  ...
}: let
  persistentPaths =
    lib.sort builtins.lessThan
    (lib.mapAttrsToList (_: vol: vol.path) bound."state:persist");
in {
  nixos = {
    imports = [
      (inputs.impermanence + "/nixos.nix")
    ];
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
    };
    fileSystems."/persist" = {
      device = "/dev/disk/by-label/persist";
      fsType = "btrfs";
      options = ["subvol=@persist" "compress=zstd:3" "noatime"];
      neededForBoot = true;
    };
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = persistentPaths;
    };
  };
}
