/-
  Baugr.Engine.Thm.Invariants — Generic Declarative Invariant Proofs (ZERO `sorry`)
-/

import Baugr.Data.ListLemmas
import Baugr.Engine.Invariants

namespace Baugr.Engine.Thm

open Baugr.Data
open Baugr.Theory
open Baugr.Engine

theorem validateInvariants_nil_iff_hold (invs : List PromiseInvariant) (ps : List Promise) :
    validateInvariants invs ps = [] ↔ allInvariantsHold invs ps = true := by
  unfold validateInvariants allInvariantsHold
  simp only [List.flatMap_eq_nil_iff, List.all_eq_true, List.isEmpty_iff]

theorem invariant_violation_sound (invs : List PromiseInvariant) (ps : List Promise)
    (hHold : allInvariantsHold invs ps = true)
    (inv : PromiseInvariant) (hInv : inv ∈ invs)
    (p : Promise) (hp : p ∈ ps)
    (hMatch : invariantApplies inv p = true) :
    inv.forbidTags.eval p.tags = false := by
  have hNil := (validateInvariants_nil_iff_hold invs ps).mpr hHold
  unfold validateInvariants at hNil
  have hInvNil := (List.flatMap_eq_nil_iff.mp hNil) inv hInv
  unfold checkInvariant at hInvNil
  have hpNone := (filterMap_eq_nil_iff _ ps).mp hInvNil p hp
  rw [hMatch] at hpNone
  cases hForb : inv.forbidTags.eval p.tags with
  | false => rfl
  | true  => rw [hForb] at hpNone; simp at hpNone

theorem allInvariantsHold_perm {invs1 invs2 : List PromiseInvariant} (h : invs1.Perm invs2) (ps : List Promise) :
    allInvariantsHold invs1 ps = allInvariantsHold invs2 ps := by
  unfold allInvariantsHold
  exact all_perm h _

/-- Domain-Emergence Corollary: CALM monotonicity emerges purely as a data instance! -/
theorem calm_emerges_from_generic_invariant (invs : List PromiseInvariant) (ps : List Promise)
    (inv : PromiseInvariant) (hInv : inv ∈ invs)
    (hRule : inv.forbidTags = AttrExpr.diff (AttrExpr.atom "multi-writer")
      (AttrExpr.union (AttrExpr.atom "monotonic") (AttrExpr.atom "single-auth-writer")))
    (hHold : allInvariantsHold invs ps = true)
    (p : Promise) (hp : p ∈ ps) (hMatch : invariantApplies inv p = true)
    (hMulti : p.tags.contains "multi-writer" = true)
    (hNoSingle : p.tags.contains "single-auth-writer" = false) :
    p.tags.contains "monotonic" = true := by
  have hFalse := invariant_violation_sound invs ps hHold inv hInv p hp hMatch
  rw [hRule] at hFalse
  simp only [AttrExpr.eval, hMulti, hNoSingle, Bool.or_false, Bool.true_and, Bool.not_eq_false'] at hFalse
  exact hFalse

end Baugr.Engine.Thm
