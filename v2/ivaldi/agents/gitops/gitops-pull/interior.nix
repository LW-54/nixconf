{
  bound,
  lib,
  ...
}: let
  cdns = lib.mapAttrsToList (_: c: c.url) bound."cache:cdn";
in {
  nixos = {
    nix.settings = {
      extra-substituters = cdns;
      fallback = true;
      connect-timeout = 5;
    };
    environment.etc."aky/pull-rollback-probes.json".text =
      builtins.toJSON (lib.attrNames bound."critical-probes");
  };
}
