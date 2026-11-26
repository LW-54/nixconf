/-
  Baugr.Theory.Spacetime — Pure Semantic Spacetime γ(3,4) Epistemic Spine (F-3 & F-5)
  4x4 Burgess & Couch Weak-Transitivity Composition Algebra, Causal Impact Cones,
  and Non-Piercing `projectAgentSST` Projection (wired directly into DRT!).
-/

import Baugr.Theory.Promise

namespace Baugr.Theory

/-- The four irreducible Semantic Spacetime link meta-types (arXiv:2506.07756). -/
inductive STType where
  | contains  -- Space-like / Superagent hierarchy Σ
  | follows   -- Time-like / Operational causal dependency order
  | expresses -- Scalar / Expressed attributes, offers, and assessments
  | near      -- Non-causal contextual proximity / associative link
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
  4x4 Burgess & Couch Heterogeneous Weak-Transitivity Composition Table:
    - Homogeneous: CONTAINS ∘ CONTAINS = CONTAINS; FOLLOWS ∘ FOLLOWS = FOLLOWS; NEAR ∘ NEAR = NEAR
    - Coarse-graining: CONTAINS ∘ EXPRESSES = EXPRESSES
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

/-- Direct operational causal dependencies strictly follow `FOLLOWS` edges. -/
def operationalDeps (g : SSTGraph) (node : String) : List String :=
  (g.edges.filter (fun e => e.sttype == STType.follows && e.src == node)).map (·.dst)

/-- Direct operational reverse dependents (nodes that `FOLLOW` `target`). -/
def operationalDependents (g : SSTGraph) (target : String) : List String :=
  (g.edges.filter (fun e => e.sttype == STType.follows && e.dst == target)).map (·.src)

/-- Bounded transitive forward causal impact cone along `FOLLOWS` edges. -/
def impactCone (g : SSTGraph) : Nat -> List String -> List String
  | 0, frontier     => frontier.eraseDups
  | k + 1, frontier =>
    let next := frontier.flatMap (operationalDeps g)
    let combined := (frontier ++ next).eraseDups
    impactCone g k combined

/-- Bounded transitive reverse causal impact cone (all downstream dependents of `target`). -/
def reverseImpactCone (g : SSTGraph) : Nat -> List String -> List String
  | 0, frontier     => frontier.eraseDups
  | k + 1, frontier =>
    let next := frontier.flatMap (operationalDependents g)
    let combined := (frontier ++ next).eraseDups
    reverseImpactCone g k combined

/-- Returns `true` iff an offer promise `o` satisfies a use promise `u` for SST `FOLLOWS` projection. -/
def offerMatchesUseForSST (o u : Promise) : Bool :=
  o.polarity == Polarity.offer &&
  u.polarity == Polarity.use &&
  o.ptype == u.ptype &&
  match u.cardinality with
  | Cardinality.partitioned => o.cardinality == Cardinality.partitioned && u.selector.eval o.tags
  | Cardinality.broadcast   => u.selector.eval o.tags
  | Cardinality.exclusive | Cardinality.budgeted => o.key == u.key

/-- Exterior `EXPRESSES` edges emitted by an `ExteriorSurface` (attributes + offers). -/
def surfaceExpressesEdges (ext : ExteriorSurface) : List STEdge :=
  let attrEdges := ext.attributes.map fun a =>
    { src := ext.agentId, dst := s!"attr:{a}", sttype := STType.expresses }
  let offerEdges := ext.promises.filterMap fun p =>
    if p.polarity == Polarity.offer then
      some { src := ext.agentId, dst := s!"promise:{p.ptype}:{p.key}", sttype := STType.expresses }
    else none
  attrEdges ++ offerEdges

/-- Sibling `FOLLOWS` edges inside a Superagent scope (strictly observing `siblingOperationalView`!). -/
def siblingFollowsEdges (siblings : List Agent) : List STEdge :=
  let views := siblingOperationalView siblings
  views.flatMap fun consumer =>
    let uses := consumer.promises.filter (fun p => p.polarity == Polarity.use)
    views.filterMap fun provider =>
      if provider.agentId == consumer.agentId then none
      else
        let hit := uses.any (fun u => provider.promises.any (fun o => offerMatchesUseForSST o u))
        if hit then some { src := consumer.agentId, dst := provider.agentId, sttype := STType.follows }
        else none

/- Recursive Non-Piercing `Agent -> SSTGraph` projection (`CONTAINS`, `FOLLOWS`, `EXPRESSES`). -/
mutual
  def projectAgentEdges : Agent -> List STEdge
    | Agent.atomic ext _ => surfaceExpressesEdges ext
    | Agent.superagent ext children =>
      let childViews := siblingOperationalView children
      let containsEdges := childViews.map fun cv =>
        { src := ext.agentId, dst := cv.agentId, sttype := STType.contains }
      let followsEdges := siblingFollowsEdges children
      surfaceExpressesEdges ext ++ containsEdges ++ followsEdges ++ projectAgentListEdges children
    | Agent.profile ms => projectAgentListEdges ms

  def projectAgentListEdges : List Agent -> List STEdge
    | [] => []
    | a :: rest => projectAgentEdges a ++ projectAgentListEdges rest
end

def projectAgentSST (a : Agent) : SSTGraph :=
  let edges := (projectAgentEdges a).eraseDups
  let baseNodes := epistemicZoomIds a
  let edgeNodes := edges.flatMap (fun e => [e.src, e.dst])
  { nodes := (baseNodes ++ edgeNodes).eraseDups, edges }

end Baugr.Theory
