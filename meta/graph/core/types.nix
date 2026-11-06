{lib, ...}: let
  /**
  Universal Resource Name (URN) generator for canonical CPG graph nodes.
  Format: urn:nixconf:<stratum>:<kind>:<id>
  */
  mkURN = {
    stratum,
    kind,
    id,
  }: "urn:nixconf:${stratum}:${kind}:${id}";

  /**
  Parses a canonical URN into its structural components.
  */
  parseURN = urn:
    if lib.hasPrefix "urn:nixconf:" urn
    then let
      parts = lib.splitString ":" (lib.removePrefix "urn:nixconf:" urn);
      stratum = builtins.elemAt parts 0;
      kind = builtins.elemAt parts 1;
      id = lib.concatStringsSep ":" (lib.drop 2 parts);
    in {
      inherit stratum kind id;
      raw = urn;
    }
    else {
      stratum = "unknown";
      kind = "unknown";
      id = urn;
      raw = urn;
    };

  /**
  Closed enumeration of standard CPG strata.
  - onto: Ontological Meta-Model (Intent)
  - ast:  Lexical & Syntactic Structure (Syntax)
  - eval: Operational Fixpoint & PDG (Computation)
  - drv:  Derivation & Nix Store DAG (Materialization)
  */
  strata = {
    onto = "onto";
    ast = "ast";
    eval = "eval";
    drv = "drv";
  };

  /**
  Closed enumeration of canonical edge relations.
  */
  relations = {
    CONTAINS = "contains";
    DECLARES = "declares";
    OUTPUTS = "outputs";
    TYPED_BY = "typedBy";
    DOCUMENTS = "documents";
    IMPORTS = "imports";
    WRITES = "writes";
    READS = "reads";
    FLOWS_TO = "flowsTo";
    IMPLEMENTS = "implements";
    DEPENDS_ON = "dependsOn";
  };

  /*
  Documentation of the closed enumerations above. Kept next to the
  enumerations so that adding a stratum, relation, or node kind and
  documenting it happen in the same place (rendered on docs/graph.md).
  */
  strataInfo = {
    onto = {
      label = "Ontological Intent";
      description = "Primitives and their declared instances: what the repository intends to exist.";
    };
    ast = {
      label = "Syntactic Structure";
      description = "Modules, options, types, and library symbols as declared in Nix expressions.";
    };
    eval = {
      label = "Operational Fixpoint";
      description = "Evaluated NixOS configurations, option definitions, and data dependences.";
    };
    drv = {
      label = "Derivation Substrate";
      description = "Packages, development shells, and their store-level dependencies.";
    };
  };

  relationInfo = {
    contains = {
      description = "Lexical parent-child containment.";
      grounding = "Primitives containing their declared instances.";
    };
    declares = {
      description = "Interface specification declaration.";
      grounding = "Contracts declaring public options and custom types.";
    };
    outputs = {
      description = "Flake artifact emission.";
      grounding = "Primitive instances emitting configurations, modules, packages, devShells, and functions.";
    };
    typedBy = {
      description = "Option type-system binding.";
      grounding = "Contract options bound to custom submodule types.";
    };
    documents = {
      description = "Documentation attachment.";
      grounding = "Docstrings attached to library symbols.";
    };
    imports = {
      description = "Compilation unit composition.";
      grounding = "Evaluated NixOS configurations importing concrete NixOS modules.";
    };
    writes = {
      description = "Option value definition (def / store).";
      grounding = "Module definitions extracted via `definitionsWithLocations`.";
    };
    reads = {
      description = "Option value inspection (use / load).";
      grounding = "Implementations reading contract options.";
    };
    flowsTo = {
      description = "End-to-end data dependence channel.";
      grounding = "Option writers connected to the implementations consuming them.";
    };
    implements = {
      description = "Contract fulfillment.";
      grounding = "Primitive relationships such as `implementation.<name>.contract`.";
    };
    dependsOn = {
      description = "Software package dependency.";
      grounding = "Modules and devShells depending on executable packages.";
    };
  };

  kindInfo = {
    primitive = "Meta-primitives defining how instances are declared and exported.";
    host = "Target machines evaluated into NixOS systems.";
    contract = "Typed contract interfaces.";
    implementation = "Concrete providers fulfilling contracts.";
    feature = "Reusable system and desktop capability bundles.";
    lib = "Library namespaces grouping functions and symbols.";
    configuration = "Evaluated NixOS configurations on `flake.nixosConfigurations`.";
    module = "NixOS modules exported on `flake.nixosModules`.";
    option = "Public contract options with types and descriptions.";
    type = "Custom option types declared by contracts and features.";
    function = "Library functions with RFC 145 docstring metadata.";
    symbol = "Non-function library values and constants.";
    package = "Packages exported on `flake.packages`.";
    devShell = "Development shells exported on `flake.devShells`.";
  };

  /**
  Constructs a canonical typed CPG Node.
  */
  mkNode = {
    stratum,
    kind,
    id,
    label ? id,
    origin ? null,
    meta ? {},
  }: let
    urn = mkURN {inherit stratum kind id;};
  in {
    id = urn;
    name = id;
    inherit stratum kind label meta;
    properties = meta;
    origin =
      if origin != null
      then origin
      else {
        inherit stratum kind;
        instance = id;
      };
  };

  /**
  Constructs a canonical typed CPG Edge.
  */
  mkEdge = {
    source,
    target,
    relation,
    stratum ? "ast",
    qualifier ? null,
    meta ? {},
  }: let
    qualSuffix =
      if qualifier != null
      then "@${qualifier}"
      else "";
    edgeId = "${source}--[${stratum}:${relation}]-->${target}${qualSuffix}";
  in {
    id = edgeId;
    inherit source target relation stratum meta;
    properties = meta;
    kind = relation;
  };
in {
  internal.graph.core.types = {
    inherit
      mkURN
      parseURN
      strata
      relations
      strataInfo
      relationInfo
      kindInfo
      mkNode
      mkEdge
      ;
  };
}
