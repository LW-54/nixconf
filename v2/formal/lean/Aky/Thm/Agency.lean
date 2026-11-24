/-
  Aky.Thm.Agency — Layer 2 Machine-Checked Proofs (1:1 mirror of Aky.Spec.Agency)
  Zero `sorry`. Covers ADR-0002, P-Dual, Boundary-First Stratification (C2),
  P-Explicit Interior Conformance (Gap #1), and Scope-Emergent Standalone Portability (X4).
-/

import Aky.Data.ListLemmas
import Aky.Spec.Agency

namespace Aky.Thm

open Aky.Data
open Aky.Spec

/-- Operadic associativity of transparent Profiles (P-Dual). -/
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

/-- Boundary-First Stratification (C2): `exteriorOf` never depends on interior children. -/
theorem boundary_first_stratification (ext : ExteriorSurface) (cs1 cs2 : List Agent) :
    exteriorOf (Agent.superagent ext cs1) = exteriorOf (Agent.superagent ext cs2) := by
  simp [exteriorOf]

/--
  Non-Piercing Interior Substitution (Crown Jewel of ADR-0002 + Nix Cache Isolation):
  Replacing ANY Dressed Superagent's interior while preserving `Pi_ext` leaves every external
  sibling's operational view strictly identical.
-/
theorem non_piercing_interior_substitution
    (pre post : List Agent) (ext : ExteriorSurface) (cs1 cs2 : List Agent) :
    siblingOperationalView (pre ++ [Agent.superagent ext cs1] ++ post) =
    siblingOperationalView (pre ++ [Agent.superagent ext cs2] ++ post) := by
  simp [siblingOperationalView, exteriorOf]

/-- Helper: if `filterMap f xs = []`, then `f x = none` for every `x ∈ xs`. -/
private theorem filterMap_eq_nil_iff {α β : Type} (f : α -> Option β) (xs : List α) :
    xs.filterMap f = [] ↔ ∀ x ∈ xs, f x = none := by
  induction xs with
  | nil => simp
  | cons x rest ih =>
    cases hx : f x with
    | none => simp [hx, ih]
    | some b => simp [hx]

/--
  GAP #1 CLOSED — P-Explicit No-Lying-Offers Theorem:
  If `checkSuperagentConformance ext children = []`, then EVERY `+b` offer declared in `Pi_ext`
  is actually backed by a matching interior offer inside `children`!
-/
theorem conforms_no_lying_offers (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (p : Promise) (hp : p ∈ ext.promises) (hPol : p.polarity = Polarity.offer) :
    hasOffer ((siblingOperationalView children).flatMap (·.promises)) p.ptype p.key = true := by
  unfold checkSuperagentConformance at hConf
  rw [List.append_eq_nil_iff] at hConf
  have hOffers := (filterMap_eq_nil_iff _ ext.promises).mp hConf.1 p hp
  rw [hPol] at hOffers
  dsimp only at hOffers
  cases hBack : hasOffer ((siblingOperationalView children).flatMap (·.promises)) p.ptype p.key with
  | true  => rfl
  | false => rw [hBack] at hOffers; simp at hOffers

/--
  GAP #1 CLOSED — P-Explicit No-Leaked-Requirements Theorem:
  If `checkSuperagentConformance ext children = []`, then EVERY mandatory hard `-b` inside
  `children` that is NOT satisfied internally is explicitly declared in `Pi_ext` (zero hidden deps!).
-/
theorem conforms_no_leaked_requirements (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (p : Promise) (hp : p ∈ (siblingOperationalView children).flatMap (·.promises))
    (hMand : isMandatoryHardUse p = true)
    (hUnmet : hasOffer ((siblingOperationalView children).flatMap (·.promises)) p.ptype p.key = false) :
    hasUse ext.promises p.ptype p.key = true := by
  unfold checkSuperagentConformance at hConf
  rw [List.append_eq_nil_iff] at hConf
  have hUses := (filterMap_eq_nil_iff _ _).mp hConf.2 p hp
  rw [hMand, hUnmet] at hUses
  simp only [Bool.not_false, Bool.and_true, ↓reduceIte] at hUses
  cases hExt : hasUse ext.promises p.ptype p.key with
  | true  => rfl
  | false => rw [hExt] at hUses; simp at hUses

/-- Scope-Emergent Standalone Portability (X4): sound & complete iff store-only. -/
def standaloneSatisfiable (ext : ExteriorSurface) : Prop :=
  ∀ p ∈ ext.promises, isMandatoryHardUse p = true → p.ptype = "store-pkg"

theorem checkStandalone_sound_and_complete (ext : ExteriorSurface) :
    checkStandalone ext = true ↔ standaloneSatisfiable ext := by
  unfold checkStandalone standaloneSatisfiable
  simp only [List.all_eq_true, Bool.or_eq_true, Bool.not_eq_true', beq_iff_eq]
  constructor
  · intro h p hp hmand
    cases h p hp with
    | inl hfalse => rw [hmand] at hfalse; contradiction
    | inr hpkg   => exact hpkg
  · intro h p hp
    by_cases hmand : isMandatoryHardUse p = true
    · exact Or.inr (h p hp hmand)
    · have hfalse : isMandatoryHardUse p = false := by cases hval : isMandatoryHardUse p <;> simp_all
      exact Or.inl hfalse

end Aky.Thm
