/-
  Aky.Thm.Agency — Layer 2 Machine-Checked Proofs (1:1 mirror of Aky.Spec.Agency)
  Zero `sorry`. Covers ADR-0002, P-Dual, Boundary-First Stratification (C2),
  P-Explicit Interior Conformance (Promises + Coarse-Grained Budgets + Non-Piercing State Volumes),
  and Scope-Emergent Standalone Portability (X4).
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
  P-Explicit No-Lying-Offers Theorem:
  If `checkSuperagentConformance ext children = []`, then EVERY `+b` offer declared in `Pi_ext`
  is actually backed by a matching interior offer inside `children`!
-/
theorem conforms_no_lying_offers (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (p : Promise) (hp : p ∈ ext.promises) (hPol : p.polarity = Polarity.offer) :
    hasOffer ((siblingOperationalView children).flatMap (·.promises)) p.ptype p.key = true := by
  unfold checkSuperagentConformance at hConf
  simp only [List.append_eq_nil_iff] at hConf
  have hOffers := (filterMap_eq_nil_iff _ ext.promises).mp hConf.1.1.1.1 p hp
  rw [hPol] at hOffers
  dsimp only at hOffers
  cases hBack : hasOffer ((siblingOperationalView children).flatMap (·.promises)) p.ptype p.key with
  | true  => rfl
  | false => rw [hBack] at hOffers; simp at hOffers

/--
  P-Explicit No-Leaked-Requirements Theorem:
  If `checkSuperagentConformance ext children = []`, then EVERY mandatory hard `-b` inside
  `children` that is NOT satisfied internally is explicitly declared in `Pi_ext` (zero hidden deps!).
-/
theorem conforms_no_leaked_requirements (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (p : Promise) (hp : p ∈ (siblingOperationalView children).flatMap (·.promises))
    (hMand : isMandatoryHardUse p = true)
    (hUnmet : isInternallySatisfied ((siblingOperationalView children).flatMap (·.promises)) p = false) :
    hasUse ext.promises p.ptype p.key = true := by
  unfold checkSuperagentConformance at hConf
  simp only [List.append_eq_nil_iff] at hConf
  have hUses := (filterMap_eq_nil_iff _ _).mp hConf.1.1.1.2 p hp
  rw [hMand, hUnmet] at hUses
  simp only [Bool.not_false, Bool.and_true, ↓reduceIte] at hUses
  cases hExt : hasUse ext.promises p.ptype p.key with
  | true  => rfl
  | false => rw [hExt] at hUses; simp at hUses

/--
  Coarse-Grained Budget & Critical-Tier Conservation Across Boundary `Σ` (F1 Gap #1 CLOSED!):
  If `checkSuperagentConformance ext children = []`, then for every budgeted `-b` inside `children`,
  the exterior budget plus internal supply covers BOTH total and critical-tier interior demands —
  allowing parent Superagents to verify budgets strictly from `Pi_ext` with ZERO interior piercing!
-/
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
  have hBud := (List.flatMap_eq_nil_iff.mp hConf.1.1.2) p hp
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

/--
  Non-Piercing Persistent Volume Conformance Theorem (F1 Gap #1 CLOSED!):
  If `checkSuperagentConformance ext children = []`, and an interior volume `v` requires durable
  local persistence that `children` does NOT internally supply, then `ext.volumes` MUST expose
  a matching volume preserving `predNeedsLocalPersistence`!
-/
theorem conforms_volume_persistence_sound (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (v : StateVolume) (hv : v ∈ (siblingOperationalView children).flatMap (·.volumes))
    (hPersist : predNeedsLocalPersistence.eval v.traits = true)
    (hNoDur : (deriveSubstrate (siblingOperationalView children)).providesDurableStorage = false) :
    ∃ ev ∈ ext.volumes, ev.id = v.id ∧ predNeedsLocalPersistence.eval ev.traits = true := by
  unfold checkSuperagentConformance at hConf
  simp only [List.append_eq_nil_iff] at hConf
  have hVol := (List.flatMap_eq_nil_iff.mp hConf.2) v hv
  simp only [List.append_eq_nil_iff] at hVol
  have hP := hVol.1.2
  rw [hPersist, hNoDur] at hP
  simp only [Bool.not_false, Bool.and_true, ↓reduceIte] at hP
  cases hAny : ext.volumes.any (fun ev => ev.id == v.id && predNeedsLocalPersistence.eval ev.traits) with
  | false => rw [hAny] at hP; simp at hP
  | true =>
    rw [List.any_eq_true] at hAny
    rcases hAny with ⟨ev, hMem, hCond⟩
    simp only [Bool.and_eq_true, beq_iff_eq] at hCond
    exact ⟨ev, hMem, hCond.1, hCond.2⟩

/--
  Non-Piercing Backup Coverage Conformance Theorem (F1 Gap #1 CLOSED!):
  If `checkSuperagentConformance ext children = []`, and an interior volume `v` requires backup
  that `children` does NOT internally supply, then `ext.volumes` MUST expose a matching volume
  preserving `predBackupRequired`!
-/
theorem conforms_volume_backup_sound (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (v : StateVolume) (hv : v ∈ (siblingOperationalView children).flatMap (·.volumes))
    (hBak : predBackupRequired.eval v.traits = true)
    (hNoBak : (deriveSubstrate (siblingOperationalView children)).backupProviderCount = 0) :
    ∃ ev ∈ ext.volumes, ev.id = v.id ∧ predBackupRequired.eval ev.traits = true := by
  unfold checkSuperagentConformance at hConf
  simp only [List.append_eq_nil_iff] at hConf
  have hVol := (List.flatMap_eq_nil_iff.mp hConf.2) v hv
  simp only [List.append_eq_nil_iff] at hVol
  have hB := hVol.2
  rw [hBak, hNoBak] at hB
  simp only [beq_self_eq_true, Bool.and_true, ↓reduceIte] at hB
  cases hAny : ext.volumes.any (fun ev => ev.id == v.id && predBackupRequired.eval ev.traits) with
  | false => rw [hAny] at hB; simp at hB
  | true =>
    rw [List.any_eq_true] at hAny
    rcases hAny with ⟨ev, hMem, hCond⟩
    simp only [Bool.and_eq_true, beq_iff_eq] at hCond
    exact ⟨ev, hMem, hCond.1, hCond.2⟩

/-- Interior CALM Monotonicity Enforcement Theorem: every direct child volume is CALM-safe. -/
theorem conforms_volume_calm_sound (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (v : StateVolume) (hv : v ∈ (siblingOperationalView children).flatMap (·.volumes)) :
    predCalmSafe.eval v.traits = true := by
  unfold checkSuperagentConformance at hConf
  simp only [List.append_eq_nil_iff] at hConf
  have hVol := (List.flatMap_eq_nil_iff.mp hConf.2) v hv
  simp only [List.append_eq_nil_iff] at hVol
  have hC := hVol.1.1
  cases hSafe : predCalmSafe.eval v.traits with
  | true  => rfl
  | false => rw [hSafe] at hC; simp at hC

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
