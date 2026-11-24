/-
  Nixconf.Spec.Spacetime — Layer 1 Executable Specification (NO PROOFS)
  Semantic Spacetime γ(3,4) Epistemic Spine (ADR-0005 E3) + Full 4x4 Burgess & Couch
  Weak-Transitivity Composition Algebra (Gap #5 CLOSED!) + Causal Impact Cone.
-/

namespace Nixconf.Spec

/-- The four irreducible Semantic Spacetime link meta-types (arXiv:2506.07756). -/
inductive STType where
  | contains  -- Space-like / Superagent hierarchy Sigma
  | follows   -- Time-like / Proper-time causal order
  | expresses -- Scalar / Boundary attributes, promises, assessment alpha
  | near      -- Non-causal contextual proximity / associative shortcut
  deriving Repr, DecidableEq, BEq

structure STEdge where
  src    : String
  dst    : String
  sttype : STType
  deriving Repr, DecidableEq, BEq

structure SSTGraph where
  nodes : List String
  edges : List STEdge
  deriving Repr, DecidableEq, BEq

/--
  Full 4x4 Burgess & Couch Heterogeneous Weak-Transitivity Composition Table (Gap #5 CLOSED!):
  Given X --r--> Y and Y --s--> Z, what valid weak-transitive edge X --t--> Z may be inferred?
    - Homogeneous: CONTAINS ∘ CONTAINS = CONTAINS; FOLLOWS ∘ FOLLOWS = FOLLOWS; NEAR ∘ NEAR = NEAR
    - Coarse-graining: CONTAINS ∘ EXPRESSES = EXPRESSES (scaling boundary properties)
    - Absorbing endpoints: EXPRESSES ∘ _ = none; NEAR never forges CONTAINS or FOLLOWS!
-/
def stCompose : STType -> STType -> Option STType
  | STType.contains,  STType.contains  => some STType.contains
  | STType.contains,  STType.expresses => some STType.expresses
  | STType.follows,   STType.follows   => some STType.follows
  | STType.near,      STType.near      => some STType.near
  | _,                _                => none

/-- One-step weak-transitive edge derivation over an SST graph. -/
def weakTransitiveStep (g : SSTGraph) : List STEdge :=
  g.edges.flatMap fun e1 =>
    g.edges.filterMap fun e2 =>
      if e1.dst == e2.src then
        match stCompose e1.sttype e2.sttype with
        | some t => some { src := e1.src, dst := e2.dst, sttype := t }
        | none   => none
      else none

/-- Direct operational causal dependencies strictly follow FOLLOWS edges. -/
def operationalDeps (g : SSTGraph) (node : String) : List String :=
  (g.edges.filter (fun e => e.sttype == STType.follows && e.src == node)).map (·.dst)

/-- Bounded transitive causal impact cone along FOLLOWS edges (terminating on finite depth). -/
def impactCone (g : SSTGraph) : Nat -> List String -> List String
  | 0, frontier     => frontier
  | k + 1, frontier =>
    let next := frontier.flatMap (operationalDeps g)
    let combined := (frontier ++ next).eraseDups
    impactCone g k combined

end Nixconf.Spec
