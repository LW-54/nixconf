{inputs, ...}: {
  flake.nixosModules.noctalia-greeter = {...}: {
    imports = [inputs.noctalia-greeter.nixosModules.default];

    config = {
      services.displayManager.noctalia-greeter.enable = true;
      persistence.directories = ["/var/lib/noctalia-greeter"];
    };
  };
}
