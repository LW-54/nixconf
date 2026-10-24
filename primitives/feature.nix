{
  lib,
  option,
  ...
}: {
  primitive.feature = {
    description = "Reusable system configurations, applications, desktop environments, development toolchains, and services that consume contracts to integrate with the host system.";

    options = {
      modules = option.modules;
      packages = option.packages;
      devShells = option.devShells;
      lib = option.lib;
      types = option.types;
    };

    outputs = {
      instances,
      lib,
      ...
    }: {
      flake.nixosModules = lib.mkMerge (
        lib.mapAttrsToList (
          featName: feat:
            lib.concatMapAttrs (modName: mod: {
              "${
                if modName == "default"
                then featName
                else modName
              }" =
                mod;
            })
            feat.modules
        )
        instances
      );
    };
  };
}
