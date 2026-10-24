{
  lib,
  config,
  ...
}: let
  discovery = config.internal.docs.graph.discovery;

  /**
  Builds host nodes from declared options.host instances.
  */
  buildHostNodes = {
    hosts,
    hostConfigs,
    implementations,
    contracts,
    features,
  }:
    lib.mapAttrs' (name: host: let
      nodeId = "host:${name}";
      hConfig = hostConfigs.${name};
      sysArch = hConfig.pkgs.system or "x86_64-linux";
      stateVer = hConfig.config.system.stateVersion or "25.11";
      hostFile = ./../../../modules/hosts/${name}.nix;
      hostContent =
        if builtins.pathExists hostFile
        then builtins.readFile hostFile
        else "";

      implNames = builtins.attrNames implementations;
      activeImpls =
        lib.filter (
          implName:
            lib.hasInfix "nixosModules.${implName}" hostContent
            || builtins.elem (config.flake.nixosModules.${implName} or null) (host.modules or [])
        )
        implNames;

      activeContracts =
        map (implName: let
          impl = implementations.${implName};
          contract = contracts.${impl.contract};
        in {
          contract = impl.contract;
          contractDescription = contract.description;
          implementation = implName;
          implementationDescription = impl.description;
        })
        activeImpls;

      activeFeatures =
        lib.filterAttrs (
          featName: feat:
            lib.hasInfix "nixosModules.${featName}" hostContent
            || builtins.any (
              mName: let
                actualName =
                  if mName == "default"
                  then featName
                  else mName;
              in
                lib.hasInfix "nixosModules.${actualName}" hostContent
                || builtins.elem (config.flake.nixosModules.${actualName} or null) (host.modules or [])
            ) (builtins.attrNames feat.modules)
        )
        features;

      featureList =
        lib.mapAttrsToList (featName: feat: {
          name = featName;
          description = feat.description;
          modules = builtins.attrNames feat.modules;
          outputs = lib.concatStringsSep ", " (
            (builtins.attrNames feat.modules)
            ++ (builtins.attrNames (
              if builtins.isFunction feat.packages
              then
                feat.packages {
                  pkgs = hConfig.pkgs;
                  self' = {};
                }
              else feat.packages
            ))
          );
        })
        activeFeatures;

      diskTree = discovery.generateDiskTree hConfig;
      persistTree = discovery.generatePersistTree hConfig;

      subModulesMap = host.subModules or {};
      subModuleNames = builtins.attrNames subModulesMap;
      subModulesList =
        map (subName: {
          name = subName;
          code = discovery.extractSubmoduleBlock hostContent subName;
        })
        subModuleNames;
    in
      lib.nameValuePair nodeId {
        kind = "host";
        id = nodeId;
        name = name;
        properties = {
          description = host.description;
          system = sysArch;
          stateVersion = stateVer;
          file = "modules/hosts/${name}.nix";
          inherit activeContracts featureList diskTree persistTree subModulesList;
          extraModuleNames = subModuleNames;
          packages = builtins.attrNames (
            if builtins.isFunction host.packages
            then
              host.packages {
                pkgs = hConfig.pkgs;
                self' = {};
              }
            else host.packages
          );
          devShells = builtins.attrNames (
            if builtins.isFunction host.devShells
            then
              host.devShells {
                pkgs = hConfig.pkgs;
                self' = {};
              }
            else host.devShells
          );
          lib = builtins.attrNames host.lib;
        };
      })
    hosts;

  /**
  Builds contract nodes from declared options.contract instances.
  */
  buildContractNodes = {
    contracts,
    implementations,
    system,
    hostConfigs,
  }:
    lib.mapAttrs' (name: contract: let
      nodeId = "contract:${name}";
      implsForContract = lib.filterAttrs (_: impl: impl.contract == name) implementations;
      contractLib =
        (
          if contract.mkOption != null
          then ["mkOption"]
          else []
        )
        ++ (
          if contract.mkConfig != null
          then ["mkConfig"]
          else []
        )
        ++ (
          if contract.types != {}
          then ["types"]
          else []
        );

      explicitPkgs = builtins.attrNames (
        if builtins.isFunction contract.packages
        then
          contract.packages {
            pkgs = hostConfigs.astrolabe.pkgs;
            self' = {};
          }
        else contract.packages
      );
      discoveredPkgs = lib.filter (p: p == name || lib.hasPrefix "${name}-" p) (builtins.attrNames (config.flake.packages.${system} or {}));

      explicitShells = builtins.attrNames (
        if builtins.isFunction contract.devShells
        then
          contract.devShells {
            pkgs = hostConfigs.astrolabe.pkgs;
            self' = {};
          }
        else contract.devShells
      );
      discoveredShells = lib.filter (s: s == name || lib.hasPrefix "${name}-" s) (builtins.attrNames (config.flake.devShells.${system} or {}));

      discoveredLib = lib.unique (
        contractLib
        ++ (builtins.attrNames contract.lib)
        ++ (builtins.attrNames (config.flake.lib.${name} or {}))
      );
    in
      lib.nameValuePair nodeId {
        kind = "contract";
        id = nodeId;
        name = name;
        properties = {
          description = contract.description;
          collection = contract.collection or true;
          file = "modules/contracts/${name}.nix";
          implementers =
            lib.mapAttrsToList (implName: impl: {
              name = implName;
              description = impl.description;
              file = "modules/implementations/${implName}.nix";
            })
            implsForContract;
          types = builtins.attrNames contract.types;
          lib = discoveredLib;
          packages = lib.unique (explicitPkgs ++ discoveredPkgs);
          devShells = lib.unique (explicitShells ++ discoveredShells);
        };
      })
    contracts;

  /**
  Builds implementation nodes from declared options.implementation instances.
  */
  buildImplNodes = {
    implementations,
    contracts,
    hosts,
    system,
    hostConfigs,
  }:
    lib.mapAttrs' (name: impl: let
      nodeId = "impl:${name}";
      cName = impl.contract;
      cDesc = contracts.${cName}.description or "";
      hostNames = builtins.attrNames hosts;
      importingHosts =
        lib.filter (
          hName: let
            hostFile = ./../../../modules/hosts/${hName}.nix;
            hostContent =
              if builtins.pathExists hostFile
              then builtins.readFile hostFile
              else "";
          in
            lib.hasInfix "nixosModules.${name}" hostContent
            || builtins.elem (config.flake.nixosModules.${name} or null) (hosts.${hName}.modules or [])
        )
        hostNames;
      explicitPkgs = builtins.attrNames (
        if builtins.isFunction impl.packages
        then
          impl.packages {
            pkgs = hostConfigs.astrolabe.pkgs;
            self' = {};
          }
        else impl.packages
      );
      discoveredPkgs = lib.filter (p: p == name || lib.hasPrefix "${name}-" p) (builtins.attrNames (config.flake.packages.${system} or {}));

      explicitShells = builtins.attrNames (
        if builtins.isFunction impl.devShells
        then
          impl.devShells {
            pkgs = hostConfigs.astrolabe.pkgs;
            self' = {};
          }
        else impl.devShells
      );
      discoveredShells = lib.filter (s: s == name || lib.hasPrefix "${name}-" s) (builtins.attrNames (config.flake.devShells.${system} or {}));

      discoveredLib = lib.unique ((builtins.attrNames impl.lib) ++ (builtins.attrNames (config.flake.lib.${name} or {})));
    in
      lib.nameValuePair nodeId {
        kind = "impl";
        id = nodeId;
        name = name;
        properties = {
          contract = cName;
          contractDescription = cDesc;
          description = impl.description;
          file = "modules/implementations/${name}.nix";
          inherit importingHosts;
          modules = [name];
          packages = lib.unique (explicitPkgs ++ discoveredPkgs);
          devShells = lib.unique (explicitShells ++ discoveredShells);
          lib = discoveredLib;
        };
      })
    implementations;

  /**
  Builds feature nodes from declared options.feature instances.
  */
  buildFeatureNodes = {
    features,
    hosts,
    system,
    hostConfigs,
  }:
    lib.mapAttrs' (name: feat: let
      nodeId = "feature:${name}";
      modNames = builtins.attrNames feat.modules;
      hostNames = builtins.attrNames hosts;
      importingHosts =
        lib.filter (
          hName: let
            hostFile = ./../../../modules/hosts/${hName}.nix;
            hostContent =
              if builtins.pathExists hostFile
              then builtins.readFile hostFile
              else "";
          in
            lib.hasInfix "nixosModules.${name}" hostContent
            || builtins.any (
              mName:
                lib.hasInfix "nixosModules.${mName}" hostContent
                || builtins.elem (config.flake.nixosModules.${mName} or null) (hosts.${hName}.modules or [])
            )
            modNames
        )
        hostNames;
      explicitPkgs = builtins.attrNames (
        if builtins.isFunction feat.packages
        then
          feat.packages {
            pkgs = hostConfigs.astrolabe.pkgs;
            self' = {};
          }
        else feat.packages
      );
      discoveredPkgs = lib.filter (p: p == name || lib.hasPrefix "${name}-" p) (builtins.attrNames (config.flake.packages.${system} or {}));

      explicitShells = builtins.attrNames (
        if builtins.isFunction feat.devShells
        then
          feat.devShells {
            pkgs = hostConfigs.astrolabe.pkgs;
            self' = {};
          }
        else feat.devShells
      );
      discoveredShells = lib.filter (s: s == name || lib.hasPrefix "${name}-" s) (builtins.attrNames (config.flake.devShells.${system} or {}));

      discoveredLib = lib.unique ((builtins.attrNames feat.lib) ++ (builtins.attrNames (config.flake.lib.${name} or {})));
    in
      lib.nameValuePair nodeId {
        kind = "feature";
        id = nodeId;
        name = name;
        properties = {
          description = feat.description;
          file = discovery.resolveFeatureRelativePath name;
          modules = modNames;
          packages = lib.unique (explicitPkgs ++ discoveredPkgs);
          devShells = lib.unique (explicitShells ++ discoveredShells);
          lib = discoveredLib;
          types = builtins.attrNames feat.types;
          inherit importingHosts;
        };
      })
    features;

  /**
  Builds module nodes for all exported NixOS modules on flake.nixosModules.
  */
  buildModuleNodes = {
    contracts,
    implementations,
    features,
    hosts,
    findModuleOptions,
    extractHostConfigSnippet,
  }: let
    allModules = config.flake.nixosModules or {};
    hostNames = builtins.attrNames hosts;
  in
    lib.mapAttrs' (name: _: let
      nodeId = "module:${name}";
      desc = discovery.resolveModuleDescription {
        inherit name contracts implementations features hosts;
      };
      importingHosts =
        lib.filter (
          hName: let
            hostFile = ./../../../modules/hosts/${hName}.nix;
            hostContent =
              if builtins.pathExists hostFile
              then builtins.readFile hostFile
              else "";
          in
            lib.hasInfix "nixosModules.${name}" hostContent
            || builtins.elem (config.flake.nixosModules.${name} or null) (hosts.${hName}.modules or [])
        )
        hostNames;
      hostConfigurations = lib.genAttrs importingHosts (hName: let
        hostFile = ./../../../modules/hosts/${hName}.nix;
        hostContent =
          if builtins.pathExists hostFile
          then builtins.readFile hostFile
          else "";
      in
        extractHostConfigSnippet {
          inherit hostContent;
          moduleName = name;
        });
      options = findModuleOptions name;
    in
      lib.nameValuePair nodeId {
        kind = "module";
        id = nodeId;
        name = name;
        properties = {
          description = desc;
          inherit importingHosts hostConfigurations options;
        };
      })
    allModules;

  /**
  Builds package nodes from flake.packages.${system}.
  */
  buildPackageNodes = {system}: let
    rawPackages = config.flake.packages.${system} or {};
    packageNames = builtins.attrNames rawPackages;
  in
    lib.genAttrs (map (n: "pkg:${n}") packageNames) (nodeId: let
      name = lib.removePrefix "pkg:" nodeId;
      pkg = rawPackages.${name};
      desc =
        pkg.meta.description
        or (pkg.description or "Executable application package ${name}.");
    in {
      kind = "pkg";
      id = nodeId;
      name = name;
      properties = {
        description = desc;
        pname = pkg.pname or (pkg.name or name);
        runCommand = "nix run .#${name}";
        buildCommand = "nix build .#${name}";
      };
    });

  /**
  Builds development shell nodes from flake.devShells.${system}.
  */
  buildShellNodes = {system}: let
    rawShells = config.flake.devShells.${system} or {};
    shellNames = builtins.attrNames rawShells;
  in
    lib.genAttrs (map (n: "shell:${n}") shellNames) (nodeId: let
      name = lib.removePrefix "shell:" nodeId;
      shell = rawShells.${name};
      desc =
        shell.meta.description
        or "Interactive development shell ${name}.";
    in {
      kind = "shell";
      id = nodeId;
      name = name;
      properties = {
        description = desc;
        developCommand = "nix develop .#${name}";
      };
    });

  /**
  Builds library nodes from declared lib instances in config.lib.
  */
  buildLibNodes = {libs}:
    lib.mapAttrs' (name: l: let
      nodeId = "lib:${name}";
    in
      lib.nameValuePair nodeId {
        kind = "lib";
        id = nodeId;
        name = name;
        properties = {
          description = l.description or "Exported library namespace flake.lib.${name}.";
          symbols = builtins.attrNames (l.symbols or {});
        };
      })
    libs;
in {
  internal.docs.graph.nodes = {
    inherit
      buildHostNodes
      buildContractNodes
      buildImplNodes
      buildFeatureNodes
      buildLibNodes
      buildModuleNodes
      buildPackageNodes
      buildShellNodes
      ;
  };
}
