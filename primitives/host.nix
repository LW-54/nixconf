{
  lib,
  option,
  ...
}: {
  primitive.host = {
    description = "Declarative target host definitions binding concrete hardware configurations, platform architectures, active implementations, and enabled system features into bootable NixOS systems.";

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
    }: {
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

      flake.nixosModules = lib.mkMerge (
        lib.mapAttrsToList (
          name: host:
            {
              ${name} = host.configuration;
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
        instances
      );
    };
  };
}
