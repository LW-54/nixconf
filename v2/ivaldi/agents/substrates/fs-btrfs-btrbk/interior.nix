{
  bound,
  lib,
  ...
}: let
  snapshotPaths =
    lib.sort builtins.lessThan
    (lib.mapAttrsToList (_: vol: vol.path) bound."state:btrfs-snapshot");
  squotaVolumes = lib.mapAttrs (_: vol: vol.squota_gib or 10) bound."state:squota";
in {
  nixos = {
    environment.etc."aky/btrfs-btrbk.json".text = builtins.toJSON {
      inherit snapshotPaths squotaVolumes;
      emergencyHeadroomGib = 2;
    };
  };
}
