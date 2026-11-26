{
  bound,
  lib,
  ...
}: let
  brokers = lib.mapAttrsToList (_: b: "${b.host}:${toString b.port}") bound."nats-broker";
in {
  nixos = {
    environment.etc."aky/nats-worker.json".text = builtins.toJSON {
      inherit brokers;
      role = "worker-only";
      lidCloseLockRequired = true;
      batteryHysteresis = {
        startPct = 35;
        stopPct = 25;
      };
      thermalWatchdogC = {
        pause = 80;
        abort = 90;
      };
    };
  };
}
