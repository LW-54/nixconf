{inputs, ...}: {
  flake.nixosModules.hjem = {
    imports = [inputs.hjem.nixosModules.default];
    config.hjem.clobberByDefault = true;
  };
}
