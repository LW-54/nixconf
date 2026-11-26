{
  bound,
  lib,
  ...
}: {
  nixos = {
    environment.etc."aky/simple-durable-state.json".text = builtins.toJSON (
      lib.sort builtins.lessThan (lib.mapAttrsToList (_: vol: vol.path) bound."state:persist")
    );
  };
}
