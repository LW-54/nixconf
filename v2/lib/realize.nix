# Antikythera S1 Pure-Nix Zero-Sugar Recursive Realizer
# Reads ONLY raw primitives (`promises`, `internal_promises`, `profiles`, `contains`, `attributes`).
# Zero IFD, Zero `${self}`, Zero `persistentPaths`, Zero interior piercing, Zero global `config` backdoors!
{
  inputs,
  nixosTargets,
  standaloneTargets,
}: let
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

  specsToOffers = ps:
    map (p: {
      inherit (p) ptype key;
      kind = p.cardinality;
      tags = p.tags or [];
      value = p.payload or {};
    })
    (builtins.filter (p: p.polarity == "offer") ps);

  expandChildren = b: let
    profRefs =
      builtins.listToAttrs
      (map (aid: {
          name = aid;
          value = {
            agent = aid;
            localName = aid;
            promises = [];
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
  in
    builtins.listToAttrs (lib.concatMap (r: let
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
          name = r.key;
          value = builtins.listToAttrs (map (o: {
              name = o.key;
              inherit (o) value;
            })
            matched);
        }
      ]
      else if reqKind == "broadcast"
      then let
        matched = builtins.filter (o: o.ptype == r.ptype) allOffers;
      in [
        {
          name = r.key;
          value = builtins.listToAttrs (map (o: {
              name = o.key;
              inherit (o) value;
            })
            matched);
        }
      ]
      else let
        localHit = findLast (o: o.ptype == r.ptype && o.key == r.key) localOffers;
        scopeHit = findLast (o: o.ptype == r.ptype && o.key == r.key) scopeOffers;
      in
        if localHit != null
        then [
          {
            name = r.key;
            inherit (localHit) value;
          }
        ]
        else if scopeHit != null
        then [
          {
            name = r.key;
            inherit (scopeHit) value;
          }
        ]
        else if builtins.hasAttr "default" r
        then [
          {
            name = r.key;
            value = r.default;
          }
        ]
        else if !(r.mandatory or true)
        then []
        else throw "aky: agent '${childPath}' requires unsatisfied promise '${r.ptype}:${r.key}'")
    uses);

  # Recursive Non-Piercing Binder:
  # Each Dressed Superagent ONLY passes offers matching a child's declared `-b` promises across Σ!
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
      inboundOffers = lib.concatMap (p:
        if p.polarity == "use" && builtins.hasAttr p.key inboundBound
        then [
          {
            inherit (p) ptype key;
            kind = p.cardinality;
            tags = [];
            value = inboundBound.${p.key};
          }
        ]
        else [])
      (b.promises or []);
      internalOffers = specsToOffers (b.internal_promises or []);
      childExtOffers =
        lib.concatMap (ch: specsToOffers ((loadBoundary ch.agent).promises or [])) children;
      scopeOffers = inboundOffers ++ internalOffers ++ childExtOffers;
    in
      lib.concatMap (ch: let
        cb = loadBoundary ch.agent;
        localOffers = specsToOffers ch.promises;
        childPath =
          if prefix == ""
          then ch.localName
          else "${prefix}/${ch.localName}";
        childBound = bindChildUses cb childPath scopeOffers localOffers;
      in
        resolveTree ch.agent childPath childBound)
      children;

  # Gap #5 Hard Boundary Enforcement:
  # Forbids atomic `interior.nix` files from returning NixOS module lambdas `{ config, ... }:`
  # and gates `nixos.imports` strictly on the factual attribute `"foreign:nixos-module"`.
  assertNonPiercingNixos = agentName: boundary: nixosMod:
    if !(builtins.isAttrs nixosMod)
    then throw "aky: interior '${agentName}/interior.nix' exported a non-attrset `nixos` (${builtins.typeOf nixosMod}); `{ config, ... }:` module functions are FORBIDDEN across Σ!"
    else if (builtins.hasAttr "imports" nixosMod) && !(builtins.elem "foreign:nixos-module" (boundary.attributes or []))
    then throw "aky: agent '${agentName}' without attribute `foreign:nixos-module` may not use `nixos.imports` (prevents global NixOS `config` piercing across Σ)!"
    else nixosMod;

  resolveRootData = rootName: let
    b = loadBoundary rootName;
    leaves = resolveTree rootName "" {};
    leafInstances = lib.sort builtins.lessThan (map (l: l.instancePath) leaves);
    boundByInstance = builtins.listToAttrs (map (l: {
        name = l.instancePath;
        value = l.bound;
      })
      leaves);
  in {
    inherit b leaves;
    # Exact JSON shape matching `aky_core::fleet::ResolvedTargetBindings`
    summary = {
      root_id = b.id;
      leaf_instances = leafInstances;
      bound_by_instance = boundByInstance;
    };
  };

  realizeRoot = rootName: system: let
    data = resolveRootData rootName;
    pkgs = import inputs.nixpkgs {inherit system;};
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
          in [
            (assertNonPiercingNixos leaf.agentName leaf.boundary raw.nixos)
          ]
          else []
      )
      data.leaves;
  in
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
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
in {
  inherit assertNonPiercingNixos;
  nixosConfigurations = lib.mapAttrs realizeRoot nixosTargets;
  resolvedBindings = lib.mapAttrs (r: _: (resolveRootData r).summary) nixosTargets;
  standalonePackages = system: lib.genAttrs standaloneTargets (realizeStandalone system);
}
