{
  check,
  lib,
  option,
  output,
  hostLib,
  hostMonitoringModule,
  hostTestingModule,
  ...
}: {
  primitive.host = {
    description = "Declarative target host definitions binding concrete hardware configurations, platform architectures, active implementations, and enabled system features into bootable NixOS systems.";

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
      system = lib.mkOption {
        type = lib.types.str;
        default = "x86_64-linux";
        description = "Target Nix platform architecture for this host.";
      };

      vmTest = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this host is included in CI QEMU VM runtime tests.";
      };

      installTest = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Whether this host is included in CI Disko install lifecycle tests.";
      };

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
    }: let
      sharedPkgs = lib.genAttrs (import inputs.systems) (system:
        import inputs.nixpkgs {
          inherit system;
          config.allowUnfree = true;
        });
      systemArgs =
        lib.mapAttrs (name: host: {
          specialArgs =
            {
              inherit self inputs;
            }
            // host.specialArgs;
          modules = [
            {
              nixpkgs.pkgs = lib.mkDefault sharedPkgs.${host.system or "x86_64-linux"};
              # Disable NixOS manual / option-doc generation by default to speed up host evaluation and builds
              documentation.nixos.enable = lib.mkDefault false;
            }
            config.flake.nixosModules.${name}
            (config.flake.nixosModules.contracts or {})
            (config.flake.nixosModules.testing or {})
            (hostTestingModule {inherit name;})
            (hostMonitoringModule {inherit name;})
          ];
        })
        instances;
    in
      lib.mkMerge [
        (output.standard instances)
        {
          flake.nixosConfigurations = lib.mapAttrs (_: inputs.nixpkgs.lib.nixosSystem) systemArgs;

          flake.lib.host = {
            inherit (hostLib) collectHostImportedModules;
            mkHostTests = args: hostLib.mkHostTests ({inherit config inputs;} // args);
            inherit systemArgs;
          };

          perSystem = {
            pkgs,
            system,
            ...
          }: let
            names = lib.filter (name: (instances.${name}.system or "x86_64-linux") == system) (builtins.attrNames instances);
            tests = lib.genAttrs names (name: hostLib.mkHostTests {inherit pkgs name config inputs;});
          in {
            _module.args.pkgs = sharedPkgs.${system};
            legacyPackages.hostTests = tests;
            checks =
              lib.concatMapAttrs (name: t: {
                "eval-${name}" = t.eval;
                "inspect-${name}" = t.inspect;
              })
              tests;
          };
        }
      ];
  };
}
