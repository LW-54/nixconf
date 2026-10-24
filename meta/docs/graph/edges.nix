{
  lib,
  config,
  ...
}: let
  discovery = config.internal.docs.graph.discovery;

  /**
  Builds IMPORTS edges from hosts to active implementations and features.
  */
  buildImportEdges = {
    hosts,
    implementations,
    features,
  }: let
    implNames = builtins.attrNames implementations;
    featNames = builtins.attrNames features;
  in
    lib.concatMap (hName: let
      h = hosts.${hName};
      hostFile = ./../../../modules/hosts/${hName}.nix;
      hostContent =
        if builtins.pathExists hostFile
        then builtins.readFile hostFile
        else "";
      implImports = map (implName: {
        id = "${hName}-imports-impl-${implName}";
        source = "host:${hName}";
        target = "impl:${implName}";
        kind = "IMPORTS";
        properties = {};
      }) (lib.filter (i: lib.hasInfix "nixosModules.${i}" hostContent || builtins.elem (config.flake.nixosModules.${i} or null) (h.modules or [])) implNames);

      featImports =
        map (featName: {
          id = "${hName}-imports-feat-${featName}";
          source = "host:${hName}";
          target = "feature:${featName}";
          kind = "IMPORTS";
          properties = {};
        }) (
          lib.filter (
            f:
              lib.hasInfix "nixosModules.${f}" hostContent
              || builtins.any (
                m: let
                  act =
                    if m == "default"
                    then f
                    else m;
                in
                  lib.hasInfix "nixosModules.${act}" hostContent
                  || builtins.elem (config.flake.nixosModules.${act} or null) (h.modules or [])
              ) (builtins.attrNames features.${f}.modules)
          )
          featNames
        );
    in
      implImports ++ featImports) (builtins.attrNames hosts);

  /**
  Builds IMPLEMENTS edges from implementations to contracts.
  */
  buildImplementsEdges = {implementations}:
    lib.mapAttrsToList (name: impl: {
      id = "${name}-implements-${impl.contract}";
      source = "impl:${name}";
      target = "contract:${impl.contract}";
      kind = "IMPLEMENTS";
      properties = {};
    })
    implementations;

  /**
  Builds dynamic CONSUMES edges across all hosts, features, and implementations.
  */
  buildConsumesEdges = {
    hosts,
    features,
    implementations,
    contractNames,
    validOptionPaths ? [],
  }: let
    # 1. Dynamic scan on Host configurations
    hostConsumes = lib.concatMap (hName: let
      hostFile = ./../../../hosts/${hName}.nix;
      hostContent =
        if builtins.pathExists hostFile
        then builtins.readFile hostFile
        else "";
    in
      discovery.scanContractConsumption {
        consumerId = "host:${hName}";
        content = hostContent;
        inherit contractNames validOptionPaths;
      }) (builtins.attrNames hosts);

    # 2. Dynamic scan on Feature modules
    featConsumes = lib.concatMap (fName: let
      fAbs =
        if fName == "wifi-eduroam"
        then ./../../../features/wifi.nix
        else if fName == "vscode"
        then ./../../../features/vcode.nix
        else ./../../../features/${fName}.nix;
      fContent =
        if builtins.pathExists fAbs
        then builtins.readFile fAbs
        else "";
    in
      discovery.scanContractConsumption {
        consumerId = "feature:${fName}";
        content = fContent;
        inherit contractNames validOptionPaths;
      }) (builtins.attrNames features);

    # 3. Dynamic scan on Implementation providers
    implConsumes = lib.concatMap (iName: let
      iAbs = ./../../../implementations/${iName}.nix;
      iContent =
        if builtins.pathExists iAbs
        then builtins.readFile iAbs
        else "";
    in
      discovery.scanContractConsumption {
        consumerId = "impl:${iName}";
        content = iContent;
        inherit contractNames validOptionPaths;
      }) (builtins.attrNames implementations);

    allRaw = hostConsumes ++ featConsumes ++ implConsumes;
  in
    map (m: let
      srcClean = builtins.replaceStrings [":"] ["-"] m.consumer;
      tgtClean = builtins.replaceStrings [":"] ["-"] m.contract;
      optsKey = builtins.replaceStrings ["."] ["_"] (lib.concatStringsSep "-" m.optionsWritten);
    in {
      id = "${srcClean}-consumes-${tgtClean}-${optsKey}";
      source = m.consumer;
      target = m.contract;
      kind = "CONSUMES";
      properties = {
        optionsWritten = m.optionsWritten;
        codeSnippet = m.codeSnippet;
      };
    })
    allRaw;
in {
  internal.docs.graph.edges = {
    inherit
      buildImportEdges
      buildImplementsEdges
      buildConsumesEdges
      ;
  };
}
