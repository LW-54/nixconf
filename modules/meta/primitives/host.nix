{
  lib,
  config,
  inputs,
  self,
  ...
}: let
  hostSubmodule = lib.types.submodule ({name, ...}: {
    options = {
      description = lib.mkOption {
        type = lib.types.str;
        description = "Formal description of this target host and its system role.";
      };

      system = lib.mkOption {
        type = lib.types.str;
        default = "x86_64-linux";
        description = "Target system architecture tuple (e.g. x86_64-linux).";
      };

      modules = lib.mkOption {
        type = lib.types.listOf lib.types.deferredModule;
        default = [];
        description = "List of top-level NixOS modules (implementations, features) enabled for this host.";
      };

      subModules = lib.mkOption {
        type = lib.types.attrsOf lib.types.deferredModule;
        default = {};
        description = "Host configuration submodules partitioning hardware, disks, and local system services.";
      };

      packages = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Attribute set or function ({ pkgs, ... }: { ... }) of host-specific packages.";
      };

      devShells = lib.mkOption {
        type = lib.types.raw;
        default = {};
        description = "Attribute set or function ({ pkgs, ... }: { ... }) of host-specific recovery or admin shells.";
      };

      lib = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Host-specific helper functions and values exported on flake.lib.<host>.";
      };

      specialArgs = lib.mkOption {
        type = lib.types.attrsOf lib.types.raw;
        default = {};
        description = "Additional special arguments forwarded to nixpkgs.lib.nixosSystem.";
      };
    };
  });
in {
  options.host = lib.mkOption {
    type = lib.types.attrsOf hostSubmodule;
    default = {};
    description = "Declarative target host definitions binding concrete hardware configurations, platform architectures, active implementations, and enabled system features into bootable NixOS systems.";
  };

  config = {
    lib = lib.mapAttrs (_: host: {
      description = host.description;
      symbols = host.lib;
    }) (lib.filterAttrs (_: host: host.lib != {}) config.host);

    flake.nixosConfigurations =
      lib.mapAttrs (
        name: host:
          inputs.nixpkgs.lib.nixosSystem {
            inherit (host) system;
            specialArgs =
              {
                inherit self inputs;
              }
              // host.specialArgs;
            modules = host.modules;
          }
      )
      config.host;

    # Export unified host modules as well as submodules on flake.nixosModules
    flake.nixosModules = lib.mkMerge (lib.mapAttrsToList (
        name: host:
          {
            ${name} = {...}: {
              imports =
                (lib.mapAttrsToList (
                    subName: _: let
                      cleanSub =
                        if lib.hasPrefix "${name}-" subName
                        then subName
                        else "${name}-${subName}";
                    in
                      config.flake.nixosModules.${cleanSub}
                  )
                  host.subModules)
                ++ host.modules;
            };
          }
          // (lib.mapAttrs' (
              subName: subMod: let
                cleanSub =
                  if lib.hasPrefix "${name}-" subName
                  then subName
                  else "${name}-${subName}";
              in
                lib.nameValuePair cleanSub subMod
            )
            host.subModules)
      )
      config.host);

    perSystem = {
      pkgs,
      self',
      ...
    } @ args: {
      packages = lib.mkMerge (lib.mapAttrsToList (
          _: host:
            if builtins.isFunction host.packages
            then host.packages args
            else host.packages
        )
        config.host);

      devShells = lib.mkMerge (lib.mapAttrsToList (
          _: host:
            if builtins.isFunction host.devShells
            then host.devShells args
            else host.devShells
        )
        config.host);
    };
  };
}
