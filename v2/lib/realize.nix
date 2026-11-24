# Antikythera S1 Pure-Nix Recursive Model-A Realizer
# Zero IFD, Zero `${self}`, Zero special Host type, Parameters ARE Promises (`bound` only!).
{inputs}: let
  inherit (inputs.nixpkgs) lib;

  readToml = path: builtins.fromTOML (builtins.readFile path);

  # Pure recursive P-Dual transparent profile flattening
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

  loadBoundary = name: readToml (../agents + "/${name}/agent.toml");
  hasInterior = name: builtins.pathExists (../agents + "/${name}/interior.nix");
  loadInterior = name: import (../agents + "/${name}/interior.nix");

  isSuperagent = b: (b.contains or []) != [] || (b.profiles or []) != [];

  # Exact S2+ persistence predicate matching `Aky/Spec/StateSafety.lean` & `aky-core`
  needsLocalPersistence = traits:
    (builtins.elem "survives-reboot" traits)
    && !(builtins.elem "reconstructible" traits)
    && !(builtins.elem "external-owned" traits);

  # Normalize offer payload to match `aky_core::fleet::offer_to_json` bit-for-bit
  normalizeOffer = o:
    {kind = o.kind or "exclusive";}
    // (lib.optionalAttrs ((o.amount or 0) > 0) {inherit (o) amount;})
    // (builtins.removeAttrs o ["kind" "strength" "amount" "tags" "soft"]);

  expandChildren = b: let
    profRefs =
      builtins.listToAttrs
      (map (aid: {
          name = aid;
          value = {
            agent = aid;
            localName = aid;
            offers = {};
          };
        })
        (flattenProfiles [] (b.profiles or []) []));
    explicitRefs =
      builtins.listToAttrs
      (map (ch: let
          localName = ch.instance or ch.agent;
        in {
          name = localName;
          value = {
            inherit (ch) agent;
            inherit localName;
            offers = ch.offers or {};
          };
        })
        (b.contains or []));
    merged = profRefs // explicitRefs;
  in
    map (name: merged.${name}) (lib.sort builtins.lessThan (builtins.attrNames merged));

  # Recursive S2+ persistent-path collector across any Dressed Superagent tree
  collectPersistentPaths = visited: name:
    if builtins.elem name visited
    then []
    else let
      b = loadBoundary name;
      own =
        lib.mapAttrsToList (_: vol: vol.path)
        (lib.filterAttrs (_: vol: needsLocalPersistence (vol.traits or [])) (b.state or {}));
      childPaths =
        if isSuperagent b
        then lib.concatMap (ch: collectPersistentPaths (visited ++ [name]) ch.agent) (expandChildren b)
        else [];
    in
      lib.unique (lib.sort builtins.lessThan (own ++ childPaths));

  # Recursive Non-Piercing Binder:
  # Each Dressed Superagent ONLY passes offers declared in a child's `requires` across Σ!
  resolveTree = name: prefix: inboundBound: let
    b = loadBoundary name;
  in
    if !(isSuperagent b)
    then [
      {
        instancePath = prefix;
        agentName = name;
        boundary = b;
        bound = inboundBound;
      }
    ]
    else let
      children = expandChildren b;
      internalOffers = lib.mapAttrs (_: normalizeOffer) (b.internal_offers or {});
      childExtOffers =
        lib.foldl'
        (acc: ch: acc // (lib.mapAttrs (_: normalizeOffer) ((loadBoundary ch.agent).offers or {})))
        {}
        children;
      scopeOffers = inboundBound // internalOffers // childExtOffers;
    in
      lib.concatMap (ch: let
        cb = loadBoundary ch.agent;
        localOffers = lib.mapAttrs (_: normalizeOffer) ch.offers;
        childPath =
          if prefix == ""
          then ch.localName
          else "${prefix}/${ch.localName}";
        childBound = lib.mapAttrs (reqName: rspec:
          if builtins.hasAttr reqName localOffers
          then localOffers.${reqName}
          else if builtins.hasAttr reqName scopeOffers
          then scopeOffers.${reqName}
          else if builtins.hasAttr "default" rspec
          then rspec.default
          else throw "aky: agent '${childPath}' requires unsatisfied promise '${reqName}'")
        (cb.requires or {});
      in
        resolveTree ch.agent childPath childBound)
      children;

  resolveRootData = rootName: let
    b = loadBoundary rootName;
    leaves = resolveTree rootName "" {};
    persistentPaths = collectPersistentPaths [] rootName;
    leafInstances = lib.sort builtins.lessThan (map (l: l.instancePath) leaves);
    boundByInstance = builtins.listToAttrs (map (l: {
        name = l.instancePath;
        value = l.bound;
      })
      leaves);
  in {
    inherit b leaves persistentPaths;
    # Exact JSON shape matching `aky_core::fleet::ResolvedTargetBindings`
    summary = {
      root_id = b.id;
      inherit (b.realize) system;
      leaf_instances = leafInstances;
      persistent_paths = persistentPaths;
      bound_by_instance = boundByInstance;
    };
  };

  realizeRoot = rootName: let
    data = resolveRootData rootName;
    pkgs = import inputs.nixpkgs {inherit (data.b.realize) system;};
    agentModules =
      lib.concatMap (
        leaf:
          if hasInterior leaf.agentName
          then [
            ((loadInterior leaf.agentName) {
              self = leaf.boundary;
              inherit (leaf) bound;
              inherit (data) persistentPaths;
              inherit pkgs lib inputs;
            }).nixos
          ]
          else []
      )
      data.leaves;
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit (data.b.realize) system;
      modules = agentModules;
    };

  realizeStandalone = system: agentName: let
    pkgs = import inputs.nixpkgs {inherit system;};
    b = loadBoundary agentName;
  in
    ((loadInterior agentName) {
      self = b;
      bound = {};
      inherit pkgs lib inputs;
    }).package;

  allAgentNames = builtins.attrNames (builtins.readDir ../agents);

  rootTargetNames =
    lib.filter (n: builtins.hasAttr "realize" (loadBoundary n)) allAgentNames;

  standaloneNames =
    lib.filter (n: (loadBoundary n).kind or "" == "standalone") allAgentNames;
in {
  nixosConfigurations = lib.genAttrs rootTargetNames realizeRoot;
  resolvedBindings = lib.genAttrs rootTargetNames (r: (resolveRootData r).summary);
  standalonePackages = system: lib.genAttrs standaloneNames (realizeStandalone system);
}
