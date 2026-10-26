{
  check,
  lib,
  option,
  output,
  hostLib,
  ...
}: {
  primitive.host = {
    schema = option.schema {
      what = "NixOS host configuration";
      doc = "Declarative target host definitions binding concrete hardware configurations, platform architectures, active implementations, and enabled system features into bootable NixOS systems.";
      checks = {
        hasConfiguration = check.hasAttr "configuration";
        validSymbols = check.validSymbols;
      };
    };

    relationships = {};

    schemas = {
      name,
      instance,
      config,
      ...
    }:
      {
        configuration = {
          what = "NixOS system configuration";
          shortDescription = "Root configuration module for host ${name}.";
          evalChecks = {
            hasConfiguration = instance ? configuration;
          };
        };
      }
      // (hostLib.checkContractFulfillment {
        inherit name config;
        host = instance;
      })
      // (lib.mapAttrs (
        subName: subDef: {
          what = "host submodule";
          shortDescription = "Host configuration submodule '${subName}'.";
          evalChecks = {
            isValidSubmodule = builtins.isFunction subDef || builtins.isAttrs subDef || builtins.isPath subDef;
          };
        }
      ) (instance.subModules or {}));

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
        (output.standard instances)
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

          flake.lib.host = {
            inherit (hostLib) collectHostImportedModules;
          };
        }
      ];
  };
}
