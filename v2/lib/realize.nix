# Antikythera S1 Pure-Nix Realizer (Zero IFD, Zero `${self}`, Non-Piercing Keyed Binder)
{inputs}: let
  inherit (inputs.nixpkgs) lib;

  readToml = path: builtins.fromTOML (builtins.readFile path);

  # Pure recursive P-Dual transparent profile flattening (sorted unique agent IDs)
  flattenProfiles = visited: stack: acc:
    if stack == []
    then lib.unique (lib.sort builtins.lessThan acc)
    else let
      pid = builtins.head stack;
      rest = builtins.tail stack;
    in
      if builtins.elem pid visited
      then flattenProfiles visited rest acc
      else let
        prof = readToml (../profiles + "/${pid}.toml");
      in
        flattenProfiles
        (visited ++ [pid])
        ((prof.profiles or []) ++ rest)
        (acc ++ (prof.agents or []));

  loadAgent = name: {
    boundary = readToml (../agents + "/${name}/agent.toml");
    interior = import (../agents + "/${name}/interior.nix");
  };

  # Exact S2+ persistence predicate matching `Aky/Spec/StateSafety.lean` & `aky-core`
  needsLocalPersistence = traits:
    (builtins.elem "survives-reboot" traits)
    && !(builtins.elem "reconstructible" traits)
    && !(builtins.elem "external-owned" traits);

  # Deterministic S1 binding resolution (verified bit-for-bit against `aky resolve <host>`!)
  resolveHostData = hostName: let
    host = readToml (../hosts + "/${hostName}.toml");
    instanceAgents = lib.mapAttrsToList (_: inst: inst.agent) (host.instances or {});
    agentNames = lib.unique (lib.sort builtins.lessThan (
      (flattenProfiles [] (host.profiles or []) [])
      ++ (host.agents or [])
      ++ instanceAgents
    ));
    loaded = builtins.listToAttrs (map (n: {
        name = n;
        value = loadAgent n;
      })
      agentNames);

    ambientOffers = builtins.listToAttrs (map (o: {
        name = o;
        value = {kind = "exclusive";};
      })
      (host.substrate_offers or []));

    allOffers =
      lib.foldl'
      (acc: a: acc // (a.boundary.offers or {}))
      ambientOffers
      (builtins.attrValues loaded);

    # Non-piercing enforcement: each agent ONLY sees offers matching its declared `requires`!
    boundByAgent = builtins.mapAttrs (n: a:
      builtins.mapAttrs (
        reqName: _:
          if builtins.hasAttr reqName allOffers
          then allOffers.${reqName}
          else throw "aky: agent '${n}' requires undeclared offer '${reqName}' on host '${host.id}'"
      ) (a.boundary.requires or {}))
    loaded;

    persistentPaths = lib.unique (lib.sort builtins.lessThan (
      lib.concatMap (
        a:
          lib.mapAttrsToList (_: vol: vol.path) (
            lib.filterAttrs (_: vol: needsLocalPersistence (vol.traits or [])) (a.boundary.state or {})
          )
      ) (builtins.attrValues loaded)
    ));
  in {
    inherit host agentNames loaded boundByAgent persistentPaths;
    # Exact JSON shape matching `aky_core::fleet::ResolvedHostBindings`
    summary = {
      host_id = host.id;
      inherit (host) system;
      agents = agentNames;
      persistent_paths = persistentPaths;
      bound_by_agent = boundByAgent;
    };
  };

  realizeHost = hostName: let
    data = resolveHostData hostName;
    pkgs = import inputs.nixpkgs {system = data.host.system;};
    agentModules =
      map (
        n: let
          a = data.loaded.${n};
        in
          (a.interior {
            self = a.boundary;
            bound = data.boundByAgent.${n};
            inherit (data) host persistentPaths;
            inherit pkgs lib inputs;
          }).nixos
      )
      data.agentNames;
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit (data.host) system;
      modules = agentModules;
    };

  realizeStandalone = system: agentName: let
    pkgs = import inputs.nixpkgs {inherit system;};
    a = loadAgent agentName;
  in
    (a.interior {
      self = a.boundary;
      bound = {};
      inherit pkgs lib inputs;
    }).package;

  hostNames =
    map (lib.removeSuffix ".toml")
    (lib.filter (lib.hasSuffix ".toml") (builtins.attrNames (builtins.readDir ../hosts)));

  standaloneNames =
    lib.filter (
      n:
        (readToml (../agents + "/${n}/agent.toml")).kind or "" == "standalone"
    )
    (builtins.attrNames (builtins.readDir ../agents));
in {
  nixosConfigurations = lib.genAttrs hostNames realizeHost;
  resolvedBindings = lib.genAttrs hostNames (h: (resolveHostData h).summary);
  standalonePackages = system: lib.genAttrs standaloneNames (realizeStandalone system);
}
