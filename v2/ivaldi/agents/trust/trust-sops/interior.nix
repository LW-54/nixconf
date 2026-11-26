{
  bound,
  lib,
  ...
}: {
  nixos = {
    environment.etc."aky/trust-sops.json".text = builtins.toJSON {
      keyPath = "/persist/var/lib/sops-nix/key.txt";
      policyEngine = "cedar-l3plus";
      materializedSecrets = lib.sort builtins.lessThan (lib.attrNames bound."secret:claim");
    };
  };
}
