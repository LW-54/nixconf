{
  bound,
  lib,
  ...
}: let
  ingestTargets = lib.mapAttrsToList (_: s: "https://${s.host}:${toString s.port}") bound."obs-ingest";
in {
  nixos = {
    environment.etc."aky/fluent-node.json".text = builtins.toJSON {
      inherit ingestTargets;
      storageType = "filesystem";
      storageSync = "full";
      storageChecksum = true;
      nativeCgroupsPsi = true;
    };
  };
}
