/-
  Baugr.Theory.Thm — Pure Promise Theory & Semantic Spacetime γ(3,4) Proofs (ZERO `sorry`)
  Covers:
    - Burgess Autonomy / Imposition Rejection (`imposition_never_cooperates`)
    - Operadic Profile Associativity (`flattenScope_append`, `profile_nesting_invariant`)
    - Boundary-First Stratification (`boundary_first_stratification`)
    - Non-Piercing Interior Substitution (`non_piercing_interior_substitution`)
    - SST Proper-Time & Containment DAG Acyclicity (`ranked_sst_acyclic`)
    - Absorbing Boundary Zero-External-Impact (`absorbing_boundary_zero_external_impact`)
    - Epistemic Zoom Non-Piercing (`epistemic_edges_preserve_operational_deps`)
    - 4x4 Weak-Transitivity Laws (`stCompose_assoc`, `near_never_forges_causality_or_containment`,
      `expresses_is_absorbing_sink`)
    - SST Sibling Follows Non-Piercing Substitution (`siblingFollowsEdges_non_piercing`)
-/

import Baugr.Theory.Promise
import Baugr.Theory.Spacetime

namespace Baugr.Theory

/-- Burgess Autonomy Theorem: an Imposition (`speaker ≠ subject`) can NEVER form valid voluntary cooperation. -/
theorem imposition_never_cooperates (c1 c2 : BehavioralClaim)
    (hImp : c1.speaker ≠ c1.subject) :
    cooperatesVoluntarily c1 c2 = false := by
  unfold cooperatesVoluntarily BehavioralClaim.isAutonomousPromise
  have hFalse : (c1.speaker == c1.subject) = false := by
    simp [hImp]
  simp [hFalse]

/-- Operadic associativity of transparent Profiles (`P-Dual`). -/
theorem flattenScope_append (xs ys : List Agent) :
    flattenScope (xs ++ ys) = flattenScope xs ++ flattenScope ys := by
  induction xs with
  | nil => simp [flattenScope]
  | cons x rest ih =>
    cases x with
    | atomic ext h => simp [flattenScope, ih]
    | superagent ext cs => simp [flattenScope, ih]
    | profile ms => simp [flattenScope, ih, List.append_assoc]

theorem profile_nesting_invariant (ms rest : List Agent) :
    flattenScope (Agent.profile ms :: rest) = flattenScope (ms ++ rest) := by
  simp [flattenScope, flattenScope_append]

/-- Boundary-First Stratification (`Π_ext ⊥ Interior`): `exteriorOf` never depends on interior children. -/
theorem boundary_first_stratification (ext : ExteriorSurface) (cs1 cs2 : List Agent) :
    exteriorOf (Agent.superagent ext cs1) = exteriorOf (Agent.superagent ext cs2) := by
  simp [exteriorOf]

/--
  Non-Piercing Interior Substitution (Crown Jewel of Promise Theory Agency):
  Replacing ANY Dressed Superagent's interior while preserving `Π_ext` leaves every external
  sibling's operational view strictly identical.
-/
theorem non_piercing_interior_substitution
    (pre post : List Agent) (ext : ExteriorSurface) (cs1 cs2 : List Agent) :
    siblingOperationalView (pre ++ [Agent.superagent ext cs1] ++ post) =
    siblingOperationalView (pre ++ [Agent.superagent ext cs2] ++ post) := by
  simp [siblingOperationalView, exteriorOf]

/-- SST Sibling `FOLLOWS` Non-Piercing Theorem: replacing an interior preserves all external `FOLLOWS` edges! -/
theorem siblingFollowsEdges_non_piercing
    (pre post : List Agent) (ext : ExteriorSurface) (cs1 cs2 : List Agent) :
    siblingFollowsEdges (pre ++ [Agent.superagent ext cs1] ++ post) =
    siblingFollowsEdges (pre ++ [Agent.superagent ext cs2] ++ post) := by
  unfold siblingFollowsEdges
  rw [non_piercing_interior_substitution pre post ext cs1 cs2]

def strictlyRanked (g : SSTGraph) (ty : STType) (rank : String -> Nat) : Prop :=
  ∀ e ∈ g.edges, e.sttype = ty → rank e.src < rank e.dst

inductive STPath (g : SSTGraph) (ty : STType) : String -> String -> Prop where
  | single : ∀ e, e ∈ g.edges → e.sttype = ty → STPath g ty e.src e.dst
  | step   : ∀ e z, e ∈ g.edges → e.sttype = ty → STPath g ty e.dst z → STPath g ty e.src z

theorem path_increases_rank {g : SSTGraph} {ty : STType} {rank : String -> Nat}
    (hr : strictlyRanked g ty rank) {u v : String} (hp : STPath g ty u v) :
    rank u < rank v := by
  induction hp with
  | single e hmem hty => exact hr e hmem hty
  | step e z hmem hty _ ih => exact Nat.lt_trans (hr e hmem hty) ih

/-- Proper-Time (`FOLLOWS`) and Containment (`CONTAINS`) DAG Acyclicity. -/
theorem ranked_sst_acyclic {g : SSTGraph} {ty : STType} {rank : String -> Nat}
    (hr : strictlyRanked g ty rank) (u : String) :
    ¬ STPath g ty u u := by
  intro hcyc
  exact Nat.lt_irrefl (rank u) (path_increases_rank hr hcyc)

/-- Absorbing Boundary Zero-External-Impact Theorem. -/
theorem absorbing_boundary_zero_external_impact
    (g : SSTGraph) (x : String) (hAbsorb : operationalDeps g x = []) (k : Nat) :
    impactCone g k [x] = [x] := by
  induction k with
  | zero => rfl
  | succ k ih =>
    simp only [impactCone, List.flatMap_cons, List.flatMap_nil, hAbsorb, List.append_nil]
    have hDups : ([x] : List String).eraseDups = [x] := rfl
    rw [hDups]
    exact ih

/-- Operational Non-Piercing Invariance Under Read-Only Epistemic Zoom Edges. -/
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

/-- Associativity of Burgess & Couch 4x4 Weak-Transitivity Table across all 64 triples. -/
theorem stCompose_assoc (r s t : STType) :
    (stCompose r s).bind (fun rs => stCompose rs t) =
    (stCompose s t).bind (fun st => stCompose r st) := by
  cases r <;> cases s <;> cases t <;> rfl

/-- Non-Causal Shortcuts (`NEAR`) Never Forge Causality (`FOLLOWS`) or Containment (`CONTAINS`). -/
theorem near_never_forges_causality_or_containment (s : STType) :
    stCompose STType.near s ≠ some STType.follows ∧
    stCompose STType.near s ≠ some STType.contains ∧
    stCompose s STType.near ≠ some STType.follows ∧
    stCompose s STType.near ≠ some STType.contains := by
  cases s <;> decide

/-- Scalar Attributes (`EXPRESSES`) Are Absorbing Endpoints. -/
theorem expresses_is_absorbing_sink (s : STType) :
    stCompose STType.expresses s = none := by
  cases s <;> rfl

end Baugr.Theory
