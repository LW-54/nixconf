/-
  NixconfFoundation.Spacetime
  Formalization of ADR-0005 (E3 Semantic Spacetime γ(3,4) Epistemic Spine: CONTAINS, FOLLOWS,
  EXPRESSES, NEAR) and ADR-0006 C2/C5 (Non-Piercing Impact Cones & Causal DAG Acyclicity).

  Pure Lean 4 core (zero Mathlib). Every theorem is machine-checked without `sorry`.
-/

import NixconfFoundation.Agency

namespace NixconfFoundation

/-- The four irreducible Semantic Spacetime link meta-types (Burgess & Couch, arXiv:2506.07756). -/
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

/-- Direct operational dependency edges strictly connect Exterior Boundary Surfaces (never interiors!). -/
def operationalDeps (g : SSTGraph) (node : String) : List String :=
  (g.edges.filter (fun e => e.sttype == STType.follows && e.src == node)).map (·.dst)

/-- Bounded transitive causal impact cone along FOLLOWS edges (guaranteed terminating on finite depth). -/
def impactCone (g : SSTGraph) : Nat -> List String -> List String
  | 0, frontier     => frontier
  | k + 1, frontier =>
    let next := frontier.flatMap (operationalDeps g)
    let combined := (frontier ++ next).eraseDups
    impactCone g k combined

/--
  Strict Topological Rank Certificate (for proving CONTAINS & FOLLOWS DAG Acyclicity):
  If every edge `u -> v` of a given `STType` strictly increases a Nat rank (`rank u < rank v`),
  then NO cycle (and no self-loop) can exist in that relation!
-/
def strictlyRanked (g : SSTGraph) (ty : STType) (rank : String -> Nat) : Prop :=
  ∀ e ∈ g.edges, e.sttype = ty → rank e.src < rank e.dst

/-- Directed path of length >= 1 along edges of type `ty`. -/
inductive STPath (g : SSTGraph) (ty : STType) : String -> String -> Prop where
  | single : ∀ e, e ∈ g.edges → e.sttype = ty → STPath g ty e.src e.dst
  | step   : ∀ e z, e ∈ g.edges → e.sttype = ty → STPath g ty e.dst z → STPath g ty e.src z

theorem path_increases_rank {g : SSTGraph} {ty : STType} {rank : String -> Nat}
    (hr : strictlyRanked g ty rank) {u v : String} (hp : STPath g ty u v) :
    rank u < rank v := by
  induction hp with
  | single e hmem hty => exact hr e hmem hty
  | step e z hmem hty _ ih => exact Nat.lt_trans (hr e hmem hty) ih

/--
  THEOREM 18 (Proper-Time & Containment DAG Acyclicity — ADR-0005 E3):
  Any SST graph admitting a strict topological ranking over `FOLLOWS` (proper time) or `CONTAINS`
  (superagent scale hierarchy) is GUARANTEED cycle-free (`¬ STPath g ty u u`)!
-/
theorem ranked_sst_acyclic {g : SSTGraph} {ty : STType} {rank : String -> Nat}
    (hr : strictlyRanked g ty rank) (u : String) :
    ¬ STPath g ty u u := by
  intro hcyc
  have hlt : rank u < rank u := path_increases_rank hr hcyc
  exact Nat.lt_irrefl (rank u) hlt

/--
  THEOREM 19 (Non-Piercing Absorbing Boundary Impact Theorem — arXiv:2506.07756 + ADR-0006 C2):
  If an interior node `x` inside Superagent `S` has NO outgoing operational `FOLLOWS` edges crossing
  boundary `Sigma_S` (because `Pi_ext(S)` did not change), then for ALL traversal depths `k`,
  its external impact cone contains ONLY `[x]` — proving ZERO external rebuild/blast impact!
-/
theorem absorbing_boundary_zero_external_impact
    (g : SSTGraph) (x : String)
    (hAbsorb : operationalDeps g x = []) (k : Nat) :
    impactCone g k [x] = [x] := by
  induction k with
  | zero => rfl
  | succ k ih =>
    simp only [impactCone, List.flatMap_cons, List.flatMap_nil, hAbsorb, List.append_nil]
    have hDups : ([x] : List String).eraseDups = [x] := by rfl
    rw [hDups]
    exact ih

/--
  THEOREM 20 (Operational Non-Piercing Invariance Under Epistemic Edges — ADR-0006 C5):
  Adding read-only `CONTAINS` or `NEAR` epistemic edges to an SST graph NEVER modifies
  `operationalDeps` (`FOLLOWS`) for any node!
-/
theorem epistemic_edges_preserve_operational_deps
    (g : SSTGraph) (e : STEdge) (hNotFollows : e.sttype ≠ STType.follows) (n : String) :
    operationalDeps { g with edges := e :: g.edges } n = operationalDeps g n := by
  unfold operationalDeps
  have hBeq : (e.sttype == STType.follows) = false := by
    cases hst : e.sttype with
    | contains  => rfl
    | follows   => exact absurd hst hNotFollows
    | expresses => rfl
    | near      => rfl
  simp [hBeq]

end NixconfFoundation
