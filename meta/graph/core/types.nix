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
      mkNode
      mkEdge
      ;
  };
}
