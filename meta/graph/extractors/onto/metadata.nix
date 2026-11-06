# Instance metadata builder for the Ontological Intent Stratum.
{
  lib,
  config,
  ...
}: let
  source = config.internal.graph.extractors.source;
  inherit (source) resolveFile instanceSourceText attrSourceCode referenceConfiguration;

  computeInstanceMeta = {
    pName,
    iName,
    iDef,
  }:
    if pName == "contract"
    then {
      implementers = lib.mapAttrsToList (implName: impl: {
        name = implName;
        description = impl.description;
        file = resolveFile "implementation" implName;
      }) (lib.filterAttrs (_: impl: impl.contract == iName) (config.implementation or {}));
      types = builtins.attrNames (iDef.types or {});
      lib =
        (
          if iDef.mkOption != null
          then ["mkOption"]
          else []
        )
        ++ (
          if iDef.mkConfig != null
          then ["mkConfig"]
          else []
        )
        ++ (
          if (iDef.types or {}) != {}
          then ["types"]
          else []
        )
        ++ builtins.attrNames (iDef.lib or {});
      packages = builtins.attrNames (
        if builtins.isFunction (iDef.packages or {})
        then
          iDef.packages {
            pkgs = (referenceConfiguration).pkgs or null;
            self' = {};
          }
        else (iDef.packages or {})
      );
      devShells = builtins.attrNames (
        if builtins.isFunction (iDef.devShells or {})
        then
          iDef.devShells {
            pkgs = (referenceConfiguration).pkgs or null;
            self' = {};
          }
        else (iDef.devShells or {})
      );
    }
    else if pName == "implementation"
    then let
      cDef = config.contract.${iDef.contract} or {};
    in {
      contract = iDef.contract;
      contractDescription = cDef.description or "";
      modules = [iName];
      lib = builtins.attrNames (iDef.lib or {});
      packages = builtins.attrNames (
        if builtins.isFunction (iDef.packages or {})
        then
          iDef.packages {
            pkgs = (referenceConfiguration).pkgs or null;
            self' = {};
          }
        else (iDef.packages or {})
      );
      devShells = builtins.attrNames (
        if builtins.isFunction (iDef.devShells or {})
        then
          iDef.devShells {
            pkgs = (referenceConfiguration).pkgs or null;
            self' = {};
          }
        else (iDef.devShells or {})
      );
      importingHosts = lib.filter (
        hName: let
          hostContent = instanceSourceText "host" hName;
        in
          lib.hasInfix "nixosModules.${iName}" hostContent
          || builtins.elem (config.flake.nixosModules.${iName} or null) ((config.host.${hName} or {}).modules or [])
      ) (builtins.attrNames (config.host or {}));
    }
    else if pName == "feature"
    then {
      modules = builtins.attrNames (iDef.modules or {});
      types = builtins.attrNames (iDef.types or {});
      lib = builtins.attrNames (iDef.lib or {});
      packages = builtins.attrNames (
        if builtins.isFunction (iDef.packages or {})
        then
          iDef.packages {
            pkgs = (referenceConfiguration).pkgs or null;
            self' = {};
          }
        else (iDef.packages or {})
      );
      devShells = builtins.attrNames (
        if builtins.isFunction (iDef.devShells or {})
        then
          iDef.devShells {
            pkgs = (referenceConfiguration).pkgs or null;
            self' = {};
          }
        else (iDef.devShells or {})
      );
      importingHosts = lib.filter (
        hName: let
          hostContent = instanceSourceText "host" hName;
        in
          lib.hasInfix "nixosModules.${iName}" hostContent
          || builtins.any (
            mName: let
              actualName =
                if mName == "default"
                then iName
                else mName;
            in
              lib.hasInfix "nixosModules.${actualName}" hostContent
              || builtins.elem (config.flake.nixosModules.${actualName} or null) ((config.host.${hName} or {}).modules or [])
          ) (builtins.attrNames (iDef.modules or {}))
      ) (builtins.attrNames (config.host or {}));
    }
    else if pName == "host"
    then let
      hCfg = config.flake.nixosConfigurations.${iName} or null;
      hostContent = instanceSourceText "host" iName;
      activeImpls = lib.filter (
        implName:
          lib.hasInfix "nixosModules.${implName}" hostContent
          || builtins.elem (config.flake.nixosModules.${implName} or null) (iDef.modules or [])
      ) (builtins.attrNames (config.implementation or {}));
      activeContracts =
        map (implName: let
          impl = config.implementation.${implName};
          contract = config.contract.${impl.contract};
        in {
          contract = impl.contract;
          contractDescription = contract.description;
          implementation = implName;
          implementationDescription = impl.description;
        })
        activeImpls;
      activeFeatures = lib.filterAttrs (
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
              || builtins.elem (config.flake.nixosModules.${actualName} or null) (iDef.modules or [])
          ) (builtins.attrNames feat.modules)
      ) (config.feature or {});
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
                  pkgs =
                    if hCfg != null
                    then hCfg.pkgs
                    else null;
                  self' = {};
                }
              else feat.packages
            ))
          );
        })
        activeFeatures;
      subModulesList = map (subName: {
        name = subName;
        code = attrSourceCode "host" iName ["subModules"] subName;
      }) (builtins.attrNames (iDef.subModules or {}));
    in {
      system =
        if hCfg != null
        then hCfg.pkgs.stdenv.hostPlatform.system
        else (iDef.system or "x86_64-linux");
      stateVersion =
        if hCfg != null
        then hCfg.config.system.stateVersion
        else "25.11";
      inherit activeContracts featureList subModulesList;
      lib = builtins.attrNames (iDef.lib or {});
      packages = builtins.attrNames (
        if builtins.isFunction (iDef.packages or {})
        then
          iDef.packages {
            pkgs =
              if hCfg != null
              then hCfg.pkgs
              else null;
            self' = {};
          }
        else (iDef.packages or {})
      );
      devShells = builtins.attrNames (
        if builtins.isFunction (iDef.devShells or {})
        then
          iDef.devShells {
            pkgs =
              if hCfg != null
              then hCfg.pkgs
              else null;
            self' = {};
          }
        else (iDef.devShells or {})
      );
    }
    else if pName == "lib"
    then {
      symbols = builtins.attrNames (iDef.symbols or {});
    }
    else {};
in {
  internal.graph.extractors.ontoMetadata = {
    inherit computeInstanceMeta;
  };
}
