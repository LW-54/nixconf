/-
  Baugr.Engine.Thm.Conformance — P-Explicit Interior Conformance Proofs (ZERO `sorry`)
-/

import Baugr.Data.ListLemmas
import Baugr.Engine.Conformance

namespace Baugr.Engine.Thm

open Baugr.Data
open Baugr.Theory
open Baugr.Engine

/-- P-Explicit No-Lying-Offers Theorem (preserving exact tags on Partitioned/Broadcast offers). -/
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

/-- P-Explicit No-Leaked-Requirements Theorem (preserving classification tags across Σ). -/
theorem conforms_no_leaked_requirements (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (p : Promise) (hp : p ∈ (siblingOperationalView children).flatMap (·.promises))
    (hMand : isMandatoryHardUse p = true)
    (hUnmet : isInternallySatisfied ((siblingOperationalView children).flatMap (·.promises)) p = false) :
    hasBackingUse ext.promises p = true := by
  unfold checkSuperagentConformance at hConf
  simp only [List.append_eq_nil_iff] at hConf
  have hUses := (filterMap_eq_nil_iff _ _).mp hConf.1.1.2 p hp
  rw [hMand, hUnmet] at hUses
  simp only [Bool.not_false, Bool.and_true, ↓reduceIte] at hUses
  cases hExt : hasBackingUse ext.promises p with
  | true  => rfl
  | false => rw [hExt] at hUses; simp at hUses

/-- P-Explicit No-Dropped-Mandatory-Offers Theorem (Partitioned). -/
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
  simp only [beq_self_eq_true, Bool.and_true, Bool.true_or, ↓reduceIte] at hDrop
  cases hExt : hasBackingOffer ext.promises p with
  | true  => rfl
  | false => rw [hExt] at hDrop; simp at hDrop

/-- P-Explicit No-Dropped-Mandatory-Broadcast-Offers Theorem. -/
theorem conforms_no_dropped_mandatory_broadcast_offers (ext : ExteriorSurface) (children : List Agent)
    (hConf : checkSuperagentConformance ext children = [])
    (p : Promise) (hp : p ∈ (siblingOperationalView children).flatMap (·.promises))
    (hMand : isMandatoryHardBroadcastOffer p = true)
    (hUnhandled : countMatchingBroadcastHandlers ((siblingOperationalView children).flatMap (·.promises)) p.ptype p.tags = 0) :
    hasBackingOffer ext.promises p = true := by
  unfold checkSuperagentConformance at hConf
  simp only [List.append_eq_nil_iff] at hConf
  have hDrop := (filterMap_eq_nil_iff _ _).mp hConf.1.2 p hp
  rw [hMand, hUnhandled] at hDrop
  simp only [beq_self_eq_true, Bool.and_true, Bool.or_true, ↓reduceIte] at hDrop
  cases hExt : hasBackingOffer ext.promises p with
  | true  => rfl
  | false => rw [hExt] at hDrop; simp at hDrop

/-- Coarse-Grained Budget & Critical-Tier Conservation Across Boundary `Σ`. -/
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

/-- Scope-Emergent Portability: sound & complete for ANY ambient scope `ambient`! -/
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

end Baugr.Engine.Thm
