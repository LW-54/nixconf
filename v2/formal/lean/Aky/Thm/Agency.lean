/-
  Aky.Thm.Agency — Layer 2 Machine-Checked Proofs (100% Usage-Agnostic, ZERO `sorry`)
  Covers ADR-0002, P-Dual, Boundary-First Stratification (C2), P-Explicit Interior Conformance
  (Offers, Uses, Mandatory Partitioned Offers, Coarse-Grained Budgets), and Scope-Emergent Composition.
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

private theorem filterMap_eq_nil_iff {α β : Type} (f : α -> Option β) (xs : List α) :
    xs.filterMap f = [] ↔ ∀ x ∈ xs, f x = none := by
  induction xs with
  | nil => simp
  | cons x rest ih =>
    cases hx : f x with
    | none => simp [hx, ih]
    | some b => simp [hx]

/-- P-Explicit No-Lying-Offers Theorem (preserving exact tags on Partitioned offers). -/
theorem conforms_no_lying_offers (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (p : Promise) (hp : p ∈ ext.promises) (hPol : p.polarity = Polarity.offer) :
    hasBackingOffer ((siblingOperationalView children).flatMap (·.promises)) p = true := by
  unfold checkSuperagentConformance at hConf
  simp only [List.append_eq_nil_iff] at hConf
  have hOffers := (filterMap_eq_nil_iff _ ext.promises).mp hConf.1.1.1 p hp
  rw [hPol] at hOffers
  dsimp only at hOffers
  cases hBack : hasBackingOffer ((siblingOperationalView children).flatMap (·.promises)) p with
  | true  => rfl
  | false => rw [hBack] at hOffers; simp at hOffers

/-- P-Explicit No-Leaked-Requirements Theorem. -/
theorem conforms_no_leaked_requirements (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (p : Promise) (hp : p ∈ (siblingOperationalView children).flatMap (·.promises))
    (hMand : isMandatoryHardUse p = true)
    (hUnmet : isInternallySatisfied ((siblingOperationalView children).flatMap (·.promises)) p = false) :
    hasUse ext.promises p.ptype p.key = true := by
  unfold checkSuperagentConformance at hConf
  simp only [List.append_eq_nil_iff] at hConf
  have hUses := (filterMap_eq_nil_iff _ _).mp hConf.1.1.2 p hp
  rw [hMand, hUnmet] at hUses
  simp only [Bool.not_false, Bool.and_true, ↓reduceIte] at hUses
  cases hExt : hasUse ext.promises p.ptype p.key with
  | true  => rfl
  | false => rw [hExt] at hUses; simp at hUses

/--
  P-Explicit No-Dropped-Mandatory-Offers Theorem:
  If an interior child emits a mandatory hard `Partitioned` `+b` offer that NO interior sibling
  handles, a conforming Superagent MUST re-export it on `Pi_ext` with exact tag preservation!
  (Guarantees stateful volumes, routes, or any mandatory partitioned capability can never be hidden!)
-/
theorem conforms_no_dropped_mandatory_offers (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (p : Promise) (hp : p ∈ (siblingOperationalView children).flatMap (·.promises))
    (hMand : isMandatoryHardPartitionedOffer p = true)
    (hUnhandled : countMatchingPartitionHandlers ((siblingOperationalView children).flatMap (·.promises)) p.ptype p.tags = 0) :
    hasBackingOffer ext.promises p = true := by
  unfold checkSuperagentConformance at hConf
  simp only [List.append_eq_nil_iff] at hConf
  have hDrop := (filterMap_eq_nil_iff _ _).mp hConf.1.2 p hp
  rw [hMand, hUnhandled] at hDrop
  simp only [beq_self_eq_true, Bool.and_true, ↓reduceIte] at hDrop
  cases hExt : hasBackingOffer ext.promises p with
  | true  => rfl
  | false => rw [hExt] at hDrop; simp at hDrop

/-- Coarse-Grained Budget & Critical-Tier Conservation Across Boundary `Σ` (any `ptype`!). -/
theorem conforms_budget_and_critical_sound (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (p : Promise) (hp : p ∈ (siblingOperationalView children).flatMap (·.promises))
    (hPol : p.polarity = Polarity.use) (hCard : p.cardinality = Cardinality.budgeted) :
    totalBudgetDemand ext.promises p.ptype +
      totalBudgetSupply ((siblingOperationalView children).flatMap (·.promises)) p.ptype ≥
      totalBudgetDemand ((siblingOperationalView children).flatMap (·.promises)) p.ptype ∧
    criticalBudgetDemand ext.promises p.ptype +
      totalBudgetSupply ((siblingOperationalView children).flatMap (·.promises)) p.ptype ≥
      criticalBudgetDemand ((siblingOperationalView children).flatMap (·.promises)) p.ptype := by
  unfold checkSuperagentConformance at hConf
  simp only [List.append_eq_nil_iff] at hConf
  have hBud := (List.flatMap_eq_nil_iff.mp hConf.2) p hp
  rw [hPol, hCard] at hBud
  dsimp only at hBud
  rw [List.append_eq_nil_iff] at hBud
  constructor
  · by_cases hlt :
      totalBudgetDemand ext.promises p.ptype +
        totalBudgetSupply ((siblingOperationalView children).flatMap (·.promises)) p.ptype <
      totalBudgetDemand ((siblingOperationalView children).flatMap (·.promises)) p.ptype
    · simp [hlt] at hBud
    · omega
  · by_cases hlt :
      criticalBudgetDemand ext.promises p.ptype +
        totalBudgetSupply ((siblingOperationalView children).flatMap (·.promises)) p.ptype <
      criticalBudgetDemand ((siblingOperationalView children).flatMap (·.promises)) p.ptype
    · simp [hlt] at hBud
    · omega

/-- Scope-Emergent Portability (X4): sound & complete for ANY ambient scope `ambient`! -/
def closesInAmbient (ambient ext : ExteriorSurface) : Prop :=
  ∀ p ∈ ext.promises, isMandatoryHardUse p = true → isInternallySatisfied ambient.promises p = true

theorem canComposeInScope_sound_and_complete (ambient ext : ExteriorSurface) :
    canComposeInScope ambient ext = true ↔ closesInAmbient ambient ext := by
  unfold canComposeInScope closesInAmbient
  simp only [List.all_eq_true, Bool.or_eq_true, Bool.not_eq_true']
  constructor
  · intro h p hp hmand
    cases h p hp with
    | inl hfalse => rw [hmand] at hfalse; contradiction
    | inr hsat   => exact hsat
  · intro h p hp
    by_cases hmand : isMandatoryHardUse p = true
    · exact Or.inr (h p hp hmand)
    · have hfalse : isMandatoryHardUse p = false := by cases hval : isMandatoryHardUse p <;> simp_all
      exact Or.inl hfalse

end Aky.Thm
