{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.noctalia-greeter = {
    config,
    lib,
    ...
  }: {
    imports = [inputs.noctalia-greeter.nixosModules.default];

    config = {
      services.displayManager.noctalia-greeter.enable = true;
      persistence.directories = ["/var/lib/noctalia-greeter"];
    };
  };
}
