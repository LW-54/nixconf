{
  bound,
  lib,
  ...
}: let
  targets = lib.mapAttrsToList (_: v: v.path) bound."state:backup";
  repos = lib.attrNames bound."backup:offhost";
  keepDaily = 21;
  wormLockDays = 14;
in
  assert keepDaily > wormLockDays; {
    nixos = {
      environment.etc."aky/restic-plan.json".text = builtins.toJSON {
        inherit keepDaily wormLockDays repos;
        paths = lib.sort builtins.lessThan targets;
      };
    };
  }
