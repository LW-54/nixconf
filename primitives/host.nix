{
  lib,
  option,
  output,
  ...
}: {
  primitive.host = {
    schema = option.schema {
      what = "NixOS host configuration";
      doc = "Declarative target host definitions binding concrete hardware configurations, platform architectures, active implementations, and enabled system features into bootable NixOS systems.";
      checks = {
        hasConfiguration = inst: {
          valid = inst ? configuration;
          message = "Host definition must declare a 'configuration' module.";
        };
      };
    };

    relationships = {
      feature = "imports";
      implementation = "imports";
      contract = "consumes";
    };

    options = {
      configuration = lib.mkOption {
        type = lib.types.deferredModule;
        default = {};
        description = "Host NixOS configuration module defining system settings, imports, and services.";
      };

      subModules = option.modules "Host configuration submodules partitioning hardware, disks, and local system services.";

      packages = option.packages;

      devShells = option.devShells;

      lib = option.lib;

      specialArgs = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Additional special arguments forwarded to nixpkgs.lib.nixosSystem.";
      };
    };

    outputs = {
      instances,
      lib,
      inputs,
      self,
      config,
      ...
    }:
      lib.mkMerge [
        (output.packages instances)
        (output.devShells instances)
        (output.lib instances)
        (output.nixosModules instances)
        {
          flake.nixosConfigurations =
            lib.mapAttrs (
              name: host:
                inputs.nixpkgs.lib.nixosSystem {
                  specialArgs =
                    {
                      inherit self inputs;
                    }
                    // host.specialArgs;
                  modules = [
                    config.flake.nixosModules.${name}
                  ];
                }
            )
            instances;
        }
      ];
  };
}
