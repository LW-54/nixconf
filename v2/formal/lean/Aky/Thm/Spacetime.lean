/-
  Aky.Thm.Spacetime — Layer 2 Machine-Checked Proofs (1:1 mirror of Aky.Spec.Spacetime)
  Zero `sorry`. Proves:
    - Proper-Time & Containment DAG Acyclicity (`ranked_sst_acyclic`)
    - Absorbing Non-Piercing Boundary Zero-External-Impact (`absorbing_boundary_zero_external_impact`)
    - Operational Non-Piercing under Read-Only Epistemic Zoom (`epistemic_edges_preserve_operational_deps`)
    - GAP #5 CLOSED: Full 4x4 Burgess & Couch Weak-Transitivity Algebraic Laws
      (`stCompose_assoc`, `near_never_forges_causality_or_containment`, `expresses_is_absorbing_sink`)
-/

import Aky.Spec.Spacetime

namespace Aky.Thm

open Aky.Spec

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

/-- Absorbing Boundary Zero-External-Impact Theorem (arXiv:2506.07756 + C2). -/
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

/-- Operational Non-Piercing Invariance Under Read-Only Epistemic Zoom Edges (C5). -/
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

/--
  GAP #5 CLOSED — Associativity of Burgess & Couch 4x4 Weak-Transitivity Table:
  `(r ∘ s) ∘ t = r ∘ (s ∘ t)` for all 64 triples `(r, s, t) ∈ STType³`!
  Guarantees path inference is strictly independent of parenthesization!
-/
theorem stCompose_assoc (r s t : STType) :
    (stCompose r s).bind (fun rs => stCompose rs t) =
    (stCompose s t).bind (fun st => stCompose r st) := by
  cases r <;> cases s <;> cases t <;> rfl

/--
  GAP #5 CLOSED — Non-Causal Shortcuts (`NEAR`) Never Forge Causality (`FOLLOWS`) or Containment (`CONTAINS`):
  Composing `NEAR` with ANY other relation can NEVER synthesize a fake `FOLLOWS` or `CONTAINS` edge!
-/
theorem near_never_forges_causality_or_containment (s : STType) :
    stCompose STType.near s ≠ some STType.follows ∧
    stCompose STType.near s ≠ some STType.contains ∧
    stCompose s STType.near ≠ some STType.follows ∧
    stCompose s STType.near ≠ some STType.contains := by
  cases s <;> decide

/--
  GAP #5 CLOSED — Scalar Attributes (`EXPRESSES`) Are Absorbing Endpoints:
  No outgoing weak-transitive composition can escape past an `EXPRESSES` boundary attribute!
-/
theorem expresses_is_absorbing_sink (s : STType) :
    stCompose STType.expresses s = none := by
  cases s <;> rfl

end Aky.Thm
