{
  bound,
  lib,
  ...
}: {
  nixos = {
    environment.etc."aky/mdbook-manifest.json".text = builtins.toJSON {
      persistTreePaths = lib.sort builtins.lessThan (lib.attrNames bound."doc-state-tree");
      sstNearDocLinks = bound."doc-links";
      zone = "mesh-only";
      idleRamMib = 0;
    };
  };
}
