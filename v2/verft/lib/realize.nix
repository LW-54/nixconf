# Verft — Minimal Pure-Nix Multi-Root Recursive Auto-Discovering S1 Realizer
# Zero prebuilt agents, zero IFD, zero `${self}`, zero hardcoded host/package/devShell lists,
# zero interior piercing, zero artificial composability barriers across folders or repos!
{
  inputs,
  agentRoots,
  profileRoots ? [],
  fleetRoot ? "fleet",
}: let
  inherit (inputs.nixpkgs) lib;

  readToml = path: builtins.fromTOML (builtins.readFile path);

  # Recursively discover all `agent.toml` directories under `dir` (arbitrary organizational folders!)
  discoverAgentsInDir = dir:
    if !(builtins.pathExists dir)
    then {}
    else let
      entries = builtins.readDir dir;
      names = lib.sort builtins.lessThan (builtins.attrNames entries);
      mergeOne = acc: name: let
        entryType = entries.${name};
        sub = dir + "/${name}";
      in
        if entryType == "directory"
        then
          if builtins.pathExists (sub + "/agent.toml")
          then let
            b = readToml (sub + "/agent.toml");
          in
            acc
            // {
              ${b.id} = {
                dir = sub;
                boundary = b;
                hasInterior = builtins.pathExists (sub + "/interior.nix");
              };
            }
          else acc // (discoverAgentsInDir sub)
        else acc;
    in
      lib.foldl' mergeOne {} names;

  # Recursively discover all `*.toml` profiles under `dir`
  discoverProfilesInDir = dir:
    if !(builtins.pathExists dir)
    then {}
    else let
      entries = builtins.readDir dir;
      names = lib.sort builtins.lessThan (builtins.attrNames entries);
      mergeOne = acc: name: let
        entryType = entries.${name};
        sub = dir + "/${name}";
      in
        if entryType == "directory"
        then acc // (discoverProfilesInDir sub)
        else if entryType == "regular" && lib.hasSuffix ".toml" name
        then let
          p = readToml sub;
        in
          acc // {${p.id} = p;}
        else acc;
    in
      lib.foldl' mergeOne {} names;

  # Merge across arbitrary roots in order (later roots override matching IDs cleanly!)
  agentIndex = lib.foldl' (acc: r: acc // (discoverAgentsInDir r)) {} agentRoots;
  profileIndex = lib.foldl' (acc: r: acc // (discoverProfilesInDir r)) {} profileRoots;

  allAgentIds = lib.sort builtins.lessThan (builtins.attrNames agentIndex);

  loadBoundary = name: agentIndex.${name}.boundary;
  hasInterior = name: agentIndex.${name}.hasInterior;
  loadInterior = name: import (agentIndex.${name}.dir + "/interior.nix");

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
        prof = profileIndex.${pid};
      in
        flattenProfiles
        (visited ++ [pid])
        ((prof.profiles or []) ++ rest)
        (acc ++ (prof.agents or []));

  isSuperagent = b: (b.contains or []) != [] || (b.profiles or []) != [];

  # Exact AttrExpr Boolean Lattice evaluator matching `Baugr.Data.AttrExpr` & `baugr-core`
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
    else throw "verft: unknown AttrExpr kind '${k}'";

  # Namespaces outbound Offer keys as "${instance}:${key}" when explicit `instance` is set (`QA-02`)!
  specsToOffersPrefixed = instancePrefix: ps:
    map (p: {
      inherit (p) ptype;
      key =
        if instancePrefix != null
        then "${instancePrefix}:${p.key}"
        else p.key;
      kind = p.cardinality;
      tags = p.tags or [];
      value = p.payload or {};
    })
    (builtins.filter (p: p.polarity == "offer") ps);

  specsToOffers = specsToOffersPrefixed null;

  expandChildren = b: let
    profRefs =
      builtins.listToAttrs
      (map (aid: {
          name = aid;
          value = {
            agent = aid;
            instance = null;
            localName = aid;
            promises = [];
          };
        })
        (flattenProfiles [] (b.profiles or []) []));
    explicitRefs =
      builtins.listToAttrs
      (map (ch: let
          inst = ch.instance or null;
          localName =
            if inst != null
            then inst
            else ch.agent;
        in {
          name = localName;
          value = {
            inherit (ch) agent;
            instance = inst;
            inherit localName;
            promises = ch.promises or [];
          };
        })
        (b.contains or []));
    merged = profRefs // explicitRefs;
  in
    map (name: merged.${name}) (lib.sort builtins.lessThan (builtins.attrNames merged));

  findLast = pred: xs: let
    matches = builtins.filter pred xs;
  in
    if matches == []
    then null
    else lib.last matches;

  bindChildUses = childBoundary: childPath: scopeOffers: localOffers: let
    uses = builtins.filter (p: p.polarity == "use") (childBoundary.promises or []);
    allOffers = scopeOffers ++ localOffers;
    pairs = lib.concatMap (r: let
      reqKind = r.cardinality;
      selector = r.selector or {kind = "any";};
    in
      if reqKind == "partitioned"
      then let
        matched =
          builtins.filter
          (o: o.ptype == r.ptype && o.kind == "partitioned" && evalAttrExpr selector o.tags)
          allOffers;
      in [
        {
          key = r.key;
          boundVal = builtins.listToAttrs (map (o: {
              name = o.key;
              inherit (o) value;
            })
            matched);
          structured = matched;
        }
      ]
      else if reqKind == "broadcast"
      then let
        matched =
          builtins.filter
          (o: o.ptype == r.ptype && evalAttrExpr selector o.tags)
          allOffers;
      in [
        {
          key = r.key;
          boundVal = builtins.listToAttrs (map (o: {
              name = o.key;
              inherit (o) value;
            })
            matched);
          structured = matched;
        }
      ]
      else let
        localHit = findLast (o: o.ptype == r.ptype && o.key == r.key) localOffers;
        scopeHit = findLast (o: o.ptype == r.ptype && o.key == r.key) scopeOffers;
      in
        if localHit != null
        then [
          {
            key = r.key;
            boundVal = localHit.value;
            structured = [localHit];
          }
        ]
        else if scopeHit != null
        then [
          {
            key = r.key;
            boundVal = scopeHit.value;
            structured = [scopeHit];
          }
        ]
        else if builtins.hasAttr "default" r
        then [
          {
            key = r.key;
            boundVal = r.default;
            structured = [
              {
                inherit (r) ptype key;
                kind = r.cardinality;
                tags = r.tags or [];
                value = r.default;
              }
            ];
          }
        ]
        else if !(r.mandatory or true)
        then []
        else throw "verft: agent '${childPath}' requires unsatisfied promise '${r.ptype}:${r.key}'")
    uses;
  in {
    bound = builtins.listToAttrs (map (x: {
        name = x.key;
        value = x.boundVal;
      })
      pairs);
    structured = builtins.listToAttrs (map (x: {
        name = x.key;
        value = x.structured;
      })
      pairs);
  };

  # Recursive Non-Piercing Binder mirroring `baugr_core::fleet::resolve_target_bindings` bit-for-bit!
  resolveTree = name: prefix: inboundBound: inboundStructured: let
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
      inboundOffers = lib.concatMap (p:
        if p.polarity == "use" && builtins.hasAttr p.key inboundStructured
        then inboundStructured.${p.key}
        else [])
      (b.promises or []);
      internalOffers = specsToOffers (b.internal_promises or []);
      childExtOffers =
        lib.concatMap (ch: specsToOffersPrefixed ch.instance ((loadBoundary ch.agent).promises or [])) children;
      scopeOffers = inboundOffers ++ internalOffers ++ childExtOffers;
    in
      lib.concatMap (ch: let
        cb = loadBoundary ch.agent;
        localOffers = specsToOffers ch.promises;
        childPath =
          if prefix == ""
          then ch.localName
          else "${prefix}/${ch.localName}";
        childRes = bindChildUses cb childPath scopeOffers localOffers;
      in
        resolveTree ch.agent childPath childRes.bound childRes.structured)
      children;

  # Hard Non-Piercing Enforcement:
  # Forbids atomic `interior.nix` files from returning NixOS module lambdas `{ config, ... }:`
  # and gates `nixos.imports` strictly on the factual attribute `"foreign:nixos-module"`.
  assertNonPiercingNixos = agentName: boundary: nixosMod:
    if !(builtins.isAttrs nixosMod)
    then throw "verft: interior '${agentName}/interior.nix' exported a non-attrset `nixos` (${builtins.typeOf nixosMod}); `{ config, ... }:` module functions are FORBIDDEN across Σ!"
    else if (builtins.hasAttr "imports" nixosMod) && !(builtins.elem "foreign:nixos-module" (boundary.attributes or []))
    then throw "verft: agent '${agentName}' without attribute `foreign:nixos-module` may not use `nixos.imports` (prevents global NixOS `config` piercing across Σ)!"
    else nixosMod;

  resolveRootData = rootName: let
    b = loadBoundary rootName;
    leaves = resolveTree rootName "" {} {};
    leafInstances = lib.sort builtins.lessThan (map (l: l.instancePath) leaves);
    boundByInstance = builtins.listToAttrs (map (l: {
        name = l.instancePath;
        value = l.bound;
      })
      leaves);
  in {
    inherit b leaves;
    summary = {
      root_id = b.id;
      leaf_instances = leafInstances;
      bound_by_instance = boundByInstance;
    };
  };

  hasFleetRoot = builtins.hasAttr fleetRoot agentIndex;
  fleetData = resolveRootData fleetRoot;
  fleetChildren = expandChildren (loadBoundary fleetRoot);

  findTargetArch = leaves: let
    osOffers = lib.concatMap (l:
      builtins.filter (p: p.polarity == "offer" && p.ptype == "target:os") (l.boundary.promises or []))
    leaves;
  in
    if osOffers == []
    then null
    else (builtins.head osOffers).payload.arch or "x86_64-linux";

  discoveredHosts =
    if !hasFleetRoot
    then {}
    else
      builtins.listToAttrs (lib.concatMap (ch: let
        hostLeaves = builtins.filter (l: lib.hasPrefix "${ch.localName}/" l.instancePath) fleetData.leaves;
        arch = findTargetArch hostLeaves;
      in
        if arch != null
        then [
          {
            name = ch.localName;
            value = {
              inherit arch;
              leaves = hostLeaves;
            };
          }
        ]
        else [])
      fleetChildren);

  realizeHost = _hostName: hostInfo: let
    pkgs = import inputs.nixpkgs {system = hostInfo.arch;};
    agentModules =
      lib.concatMap (
        leaf:
          if hasInterior leaf.agentName
          then let
            raw = (loadInterior leaf.agentName) {
              self = leaf.boundary;
              inherit (leaf) bound;
              inherit pkgs lib inputs;
            };
          in
            if builtins.hasAttr "nixos" raw
            then [(assertNonPiercingNixos leaf.agentName leaf.boundary raw.nixos)]
            else []
          else []
      )
      hostInfo.leaves;
  in
    inputs.nixpkgs.lib.nixosSystem {
      system = hostInfo.arch;
      modules = agentModules;
    };

  discoverStandalonePackages = system: let
    pkgs = import inputs.nixpkgs {inherit system;};
  in
    builtins.listToAttrs (lib.concatMap (aid: let
      b = loadBoundary aid;
    in
      if !(isSuperagent b) && hasInterior aid
      then let
        raw = (loadInterior aid) {
          self = b;
          bound = {};
          inherit pkgs lib inputs;
        };
      in
        if builtins.hasAttr "package" raw
        then [
          {
            name = aid;
            value = raw.package;
          }
        ]
        else []
      else [])
    allAgentIds);

  discoverDevShells = system: let
    pkgs = import inputs.nixpkgs {inherit system;};
  in
    builtins.listToAttrs (lib.concatMap (aid: let
      b = loadBoundary aid;
      shellOffers = builtins.filter (p: p.polarity == "offer" && p.ptype == "dev:shell") (b.promises or []);
    in
      if shellOffers == []
      then []
      else let
        shellName = (builtins.head shellOffers).key;
        leaves =
          if isSuperagent b
          then (resolveRootData aid).leaves
          else [
            {
              instancePath = aid;
              agentName = aid;
              boundary = b;
              bound = {};
            }
          ];
        parts = lib.concatMap (l:
          if hasInterior l.agentName
          then let
            raw = (loadInterior l.agentName) {
              self = l.boundary;
              inherit (l) bound;
              inherit pkgs lib inputs;
            };
          in
            if builtins.hasAttr "devPackages" raw || builtins.hasAttr "devShellHook" raw
            then [raw]
            else []
          else [])
        leaves;
        packages = lib.concatMap (p: p.devPackages or []) parts;
        hooks = lib.concatStringsSep "\n" (builtins.filter (s: s != "") (map (p: p.devShellHook or "") parts));
      in [
        {
          name = shellName;
          value = pkgs.mkShellNoCC {
            name = "verft-dev-${shellName}";
            inherit packages;
            shellHook = hooks;
          };
        }
      ])
    allAgentIds);

  isClosedSuperagent = b:
    isSuperagent b
    && !(builtins.any (
      p:
        p.polarity
        == "use"
        && (p.strength or "hard") == "hard"
        && (p.mandatory or true)
        && p.cardinality == "exclusive"
    ) (b.promises or []));

  allSuperagentIds = builtins.filter (aid: isClosedSuperagent (loadBoundary aid)) allAgentIds;
in {
  inherit assertNonPiercingNixos allSuperagentIds allAgentIds;
  nixosConfigurations = lib.mapAttrs realizeHost discoveredHosts;
  resolvedBindings = lib.genAttrs allSuperagentIds (r: (resolveRootData r).summary);
  standalonePackages = discoverStandalonePackages;
  devShells = discoverDevShells;
}
