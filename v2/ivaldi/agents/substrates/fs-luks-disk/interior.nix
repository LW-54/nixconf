{
  bound,
  lib,
  ...
}: let
  durablePaths =
    lib.sort builtins.lessThan
    (lib.mapAttrsToList (_: vol: vol.path) bound."state:persist");
in {
  nixos = {
    fileSystems."/" = {
      device = "/dev/mapper/cryptroot";
      fsType = "ext4";
    };
    security.tpm2.enable = true;
    environment.etc."aky/durable-state.json".text = builtins.toJSON durablePaths;
  };
}
