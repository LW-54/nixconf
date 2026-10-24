{
  lib,
  option,
  ...
}: {
  primitive.implementation = {
    description = "Concrete capability providers satisfying contract interfaces by translating abstract capability options into provider-specific NixOS services, packages, and system configurations.";

    options = {
      contract = option.contract;
      module = option.module;
      packages = option.packages;
      devShells = option.devShells;
      lib = option.lib;
    };

    outputs = {
      instances,
      lib,
      ...
    }: {
      flake.nixosModules = lib.mapAttrs (_: impl: impl.module) instances;
    };
  };
}
