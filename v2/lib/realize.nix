# Antikythera S1 Pure-Nix Recursive Model-A Realizer
# Zero IFD, Zero `${self}`, Zero interior piercing, Zero global `config` backdoors!
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

  # Exact AttrExpr Boolean Lattice evaluator matching `Aky/Data/AttrExpr.lean` & `aky-core`
  evalAttrExpr = expr: tags: let
    k = expr.kind or "any";
  in
    if k == "atom"
    then builtins.elem expr.tag tags
    else if k == "union"
    then (evalAttrExpr expr.left tags) || (evalAttrExpr expr.right tags)
    else if k == "inter"
    then (evalAttrExpr expr.left tags) && (evalAttrExpr expr.right tags)
    else if k == "diff"
    then (evalAttrExpr expr.left tags) && !(evalAttrExpr expr.right tags)
    else if k == "compl"
    then !(evalAttrExpr expr.inner tags)
    else if k == "any"
    then true
    else if k == "none"
    then false
    else throw "aky: unknown AttrExpr kind '${k}'";

  # Normalize offer payload to match `aky_core::fleet::offer_to_json` bit-for-bit
  normalizeOffer = o:
    {kind = o.kind or "exclusive";}
    // (lib.optionalAttrs ((o.amount or 0) > 0) {inherit (o) amount;})
    // (builtins.removeAttrs o ["ptype" "key" "kind" "strength" "amount" "tags" "soft"]);

  toScopeOffer = tableKey: o: {
    ptype = o.ptype or tableKey;
    key = o.key or tableKey;
    kind = o.kind or "exclusive";
    tags = o.tags or [];
    value = normalizeOffer o;
  };

  mapToScopeOffers = attrs:
    lib.mapAttrsToList toScopeOffer attrs;

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

  # Non-Piercing S2+ persistent-path collector:
  # Reads ONLY `rootName`'s own exterior `state` and its DIRECT children's exterior `state`!
  # Never pierces nested Superagents (conformance guarantees nested stacks surface their state!).
  collectDirectPersistentPaths = rootName: let
    b = loadBoundary rootName;
    extractPaths = boundary:
      lib.mapAttrsToList (_: vol: vol.path)
      (lib.filterAttrs (_: vol: needsLocalPersistence (vol.traits or [])) (boundary.state or {}));
    own = extractPaths b;
    directChildPaths =
      if isSuperagent b
      then lib.concatMap (ch: extractPaths (loadBoundary ch.agent)) (expandChildren b)
      else [];
  in
    lib.unique (lib.sort builtins.lessThan (own ++ directChildPaths));

  findLast = pred: xs: let
    matches = builtins.filter pred xs;
  in
    if matches == []
    then null
    else lib.last matches;

  bindChildRequires = childBoundary: childPath: scopeOffers: localOffers:
    lib.mapAttrs (reqName: rspec: let
      reqPtype = rspec.ptype or reqName;
      reqKey = rspec.key or reqName;
      reqKind = rspec.kind or "exclusive";
      selector = rspec.selector or {kind = "any";};
      allOffers = scopeOffers ++ localOffers;
    in
      if reqKind == "partitioned"
      then let
        matched =
          builtins.filter
          (o: o.ptype == reqPtype && o.kind == "partitioned" && evalAttrExpr selector o.tags)
          allOffers;
      in
        builtins.listToAttrs (map (o: {
            name = o.key;
            inherit (o) value;
          })
          matched)
      else if reqKind == "broadcast"
      then let
        matched = builtins.filter (o: o.ptype == reqPtype) allOffers;
      in
        builtins.listToAttrs (map (o: {
            name = o.key;
            inherit (o) value;
          })
          matched)
      else let
        localHit = findLast (o: o.ptype == reqPtype && o.key == reqKey) localOffers;
        scopeHit = findLast (o: o.ptype == reqPtype && o.key == reqKey) scopeOffers;
      in
        if localHit != null
        then localHit.value
        else if scopeHit != null
        then scopeHit.value
        else if builtins.hasAttr "default" rspec
        then rspec.default
        else throw "aky: agent '${childPath}' requires unsatisfied promise '${reqName}'")
    (childBoundary.requires or {});

  # Recursive Non-Piercing Binder:
  # Each Dressed Superagent ONLY passes offers matching a child's declared `requires` across Σ!
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
      inboundOffers = lib.concatLists (lib.mapAttrsToList (rkey: rspec:
        if builtins.hasAttr rkey inboundBound
        then [
          {
            ptype = rspec.ptype or rkey;
            key = rspec.key or rkey;
            kind = rspec.kind or "exclusive";
            tags = [];
            value = inboundBound.${rkey};
          }
        ]
        else [])
      (b.requires or {}));
      internalOffers = mapToScopeOffers (b.internal_offers or {});
      childExtOffers =
        lib.concatMap (ch: mapToScopeOffers ((loadBoundary ch.agent).offers or {})) children;
      scopeOffers = inboundOffers ++ internalOffers ++ childExtOffers;
    in
      lib.concatMap (ch: let
        cb = loadBoundary ch.agent;
        localOffers = mapToScopeOffers ch.offers;
        childPath =
          if prefix == ""
          then ch.localName
          else "${prefix}/${ch.localName}";
        childBound = bindChildRequires cb childPath scopeOffers localOffers;
      in
        resolveTree ch.agent childPath childBound)
      children;

  # Gap #5 Hard Boundary Enforcement:
  # Forbids atomic `interior.nix` files from returning NixOS module lambdas `{ config, ... }:`
  # (which would pierce Σ via NixOS's global `config` fixpoint!), and forbids non-substrate
  # atomic agents from smuggling inline lambdas via `imports = [ ... ]`.
  assertNonPiercingNixos = agentName: boundary: nixosMod:
    if !(builtins.isAttrs nixosMod)
    then throw "aky: interior '${agentName}/interior.nix' exported a non-attrset `nixos` (${builtins.typeOf nixosMod}); `{ config, ... }:` module functions are FORBIDDEN across Σ!"
    else if (builtins.hasAttr "imports" nixosMod) && ((boundary.kind or "atomic") != "substrate")
    then throw "aky: non-substrate atomic agent '${agentName}' may not use `nixos.imports` (prevents global NixOS `config` piercing across Σ)!"
    else nixosMod;

  resolveRootData = rootName: let
    b = loadBoundary rootName;
    leaves = resolveTree rootName "" {};
    persistentPaths = collectDirectPersistentPaths rootName;
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
          then let
            raw = (loadInterior leaf.agentName) {
              self = leaf.boundary;
              inherit (leaf) bound;
              inherit (data) persistentPaths;
              inherit pkgs lib inputs;
            };
          in [
            (assertNonPiercingNixos leaf.agentName leaf.boundary raw.nixos)
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
  inherit assertNonPiercingNixos;
  nixosConfigurations = lib.genAttrs rootTargetNames realizeRoot;
  resolvedBindings = lib.genAttrs rootTargetNames (r: (resolveRootData r).summary);
  standalonePackages = system: lib.genAttrs standaloneNames (realizeStandalone system);
}
