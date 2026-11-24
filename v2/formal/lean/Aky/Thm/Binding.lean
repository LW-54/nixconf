/-
  Aky.Thm.Binding — Layer 2 Machine-Checked Proofs (100% Usage-Agnostic, ZERO `sorry`)
  Proves:
    - Diagnostic completeness (`validateScope ps = [] ↔ isScopeValid ps = true`)
    - Commutative Binding Order-Invariance (`List.Perm`)
    - B3 Exclusive 1:1 Soundness, Mandatory Broadcast >= 1 Soundness,
      Partitioned AttrExpr Disjointness & Mandatory Coverage Soundness
    - C4 Budget Conservation + Critical-Tier Priority OOM Protection
    - Conditional Soft Promise Law Soundness
    - Multi-Stratum Strict Stratification Soundness & Acyclic Termination
    - Recursive `checkAgentTree` Soundness & Compositional Non-Piercing Substitution Invariance!
-/

import Aky.Data.ListLemmas
import Aky.Spec.Binding
import Aky.Thm.Agency

namespace Aky.Thm

open Aky.Data
open Aky.Spec

/-- Structured Diagnostics Equivalence: zero errors iff `isScopeValid = true`. -/
theorem validateScope_nil_iff_valid (ps : List Promise) :
    validateScope ps = [] ↔ isScopeValid ps = true := by
  unfold validateScope isScopeValid
  simp only [List.flatMap_eq_nil_iff, List.all_eq_true, List.isEmpty_iff]

theorem countMatchingOffers_perm {xs ys : List Promise} (h : xs.Perm ys) (pt k : String) :
    countMatchingOffers xs pt k = countMatchingOffers ys pt k := by
  unfold countMatchingOffers
  exact (h.filter _).length_eq

theorem countMatchingBroadcastOffers_perm {xs ys : List Promise} (h : xs.Perm ys) (pt : String) :
    countMatchingBroadcastOffers xs pt = countMatchingBroadcastOffers ys pt := by
  unfold countMatchingBroadcastOffers
  exact (h.filter _).length_eq

theorem countMatchingPartitionHandlers_perm {xs ys : List Promise} (h : xs.Perm ys) (pt : String) (tags : List String) :
    countMatchingPartitionHandlers xs pt tags = countMatchingPartitionHandlers ys pt tags := by
  unfold countMatchingPartitionHandlers
  exact (h.filter _).length_eq

theorem totalBudgetSupply_perm {xs ys : List Promise} (h : xs.Perm ys) (pt : String) :
    totalBudgetSupply xs pt = totalBudgetSupply ys pt := by
  unfold totalBudgetSupply
  exact foldl_add_perm (·.amount) (h.filter _)

theorem totalBudgetDemand_perm {xs ys : List Promise} (h : xs.Perm ys) (pt : String) :
    totalBudgetDemand xs pt = totalBudgetDemand ys pt := by
  unfold totalBudgetDemand
  exact foldl_add_perm (·.amount) (h.filter _)

theorem criticalBudgetDemand_perm {xs ys : List Promise} (h : xs.Perm ys) (pt : String) :
    criticalBudgetDemand xs pt = criticalBudgetDemand ys pt := by
  unfold criticalBudgetDemand
  exact foldl_add_perm (·.amount) (h.filter _)

/-- Commutative Binding Order-Invariance under arbitrary permutations `ps1 ~ ps2`. -/
theorem checkPromise_perm {ps1 ps2 : List Promise} (h : ps1.Perm ps2) (p : Promise) :
    checkPromise ps1 p = checkPromise ps2 p := by
  unfold checkPromise
  rw [countMatchingOffers_perm h, countMatchingBroadcastOffers_perm h,
      countMatchingPartitionHandlers_perm h,
      totalBudgetDemand_perm h, totalBudgetSupply_perm h, criticalBudgetDemand_perm h]

theorem isScopeValid_perm {ps1 ps2 : List Promise} (h : ps1.Perm ps2) :
    isScopeValid ps1 = isScopeValid ps2 := by
  unfold isScopeValid
  have h1 : ps1.all (fun p => (checkPromise ps1 p).isEmpty) =
            ps1.all (fun p => (checkPromise ps2 p).isEmpty) := by
    congr 1; funext p; rw [checkPromise_perm h p]
  rw [h1]
  exact all_perm h _

/-- B3 Exclusive Soundness: every mandatory hard exclusive use has strictly 1 matching offer. -/
theorem exclusive_binding_sound (ps : List Promise) (hvalid : isScopeValid ps = true)
    (p : Promise) (hp : p ∈ ps)
    (hcard : p.cardinality = Cardinality.exclusive)
    (hpol  : p.polarity = Polarity.use)
    (hstr  : p.strength = Strength.hard)
    (hmand : p.mandatory = true) :
    countMatchingOffers ps p.ptype p.key = 1 := by
  unfold isScopeValid at hvalid
  rw [List.all_eq_true] at hvalid
  have hpErr := hvalid p hp
  unfold checkPromise at hpErr
  rw [hcard, hpol, hstr, hmand, append_isEmpty_iff] at hpErr
  have hCard := hpErr.2
  dsimp only at hCard
  generalize hn : countMatchingOffers ps p.ptype p.key = n at hCard ⊢
  match n with
  | 0 => simp at hCard
  | 1 => rfl
  | k + 2 =>
    have hgt : k + 2 > 1 := by omega
    simp [hgt] at hCard

/-- B3 Mandatory Broadcast Soundness: every mandatory hard broadcast use has >= 1 matching offer. -/
theorem broadcast_mandatory_sound (ps : List Promise) (hvalid : isScopeValid ps = true)
    (p : Promise) (hp : p ∈ ps)
    (hcard : p.cardinality = Cardinality.broadcast)
    (hpol  : p.polarity = Polarity.use)
    (hstr  : p.strength = Strength.hard)
    (hmand : p.mandatory = true) :
    countMatchingBroadcastOffers ps p.ptype > 0 := by
  unfold isScopeValid at hvalid
  rw [List.all_eq_true] at hvalid
  have hpErr := hvalid p hp
  unfold checkPromise at hpErr
  rw [hcard, hpol, hstr, hmand, append_isEmpty_iff] at hpErr
  have hCard := hpErr.2
  dsimp only at hCard
  by_cases hZero : countMatchingBroadcastOffers ps p.ptype == 0
  · rw [hZero] at hCard; simp at hCard
  · simp only [beq_iff_eq] at hZero; omega

/-- B3 Partitioned AttrExpr Disjointness Soundness: at most ONE partitioned handler matches `p.tags`. -/
theorem partitioned_selector_disjoint_sound (ps : List Promise) (hvalid : isScopeValid ps = true)
    (p : Promise) (hp : p ∈ ps)
    (hcard : p.cardinality = Cardinality.partitioned)
    (hpol  : p.polarity = Polarity.offer) :
    countMatchingPartitionHandlers ps p.ptype p.tags ≤ 1 := by
  unfold isScopeValid at hvalid
  rw [List.all_eq_true] at hvalid
  have hpErr := hvalid p hp
  unfold checkPromise at hpErr
  rw [hcard, hpol, append_isEmpty_iff] at hpErr
  have hCard := hpErr.2
  simp only [List.append_eq_nil_iff] at hCard
  have hSel := hCard.1.2
  by_cases hgt : countMatchingPartitionHandlers ps p.ptype p.tags > 1
  · simp [hgt] at hSel
  · omega

/-- B3 Mandatory Partitioned Offer Soundness: every mandatory hard partitioned offer has strictly 1 handler! -/
theorem partitioned_mandatory_handled_sound (ps : List Promise) (hvalid : isScopeValid ps = true)
    (p : Promise) (hp : p ∈ ps)
    (hcard : p.cardinality = Cardinality.partitioned)
    (hpol  : p.polarity = Polarity.offer)
    (hstr  : p.strength = Strength.hard)
    (hmand : p.mandatory = true) :
    countMatchingPartitionHandlers ps p.ptype p.tags = 1 := by
  have hLe := partitioned_selector_disjoint_sound ps hvalid p hp hcard hpol
  unfold isScopeValid at hvalid
  rw [List.all_eq_true] at hvalid
  have hpErr := hvalid p hp
  unfold checkPromise at hpErr
  rw [hcard, hpol, hstr, hmand, append_isEmpty_iff] at hpErr
  have hCard := hpErr.2
  simp only [List.append_eq_nil_iff] at hCard
  have hMand := hCard.2
  by_cases hZero : countMatchingPartitionHandlers ps p.ptype p.tags == 0
  · simp [hZero] at hMand; exact absurd hMand (by decide)
  · simp only [beq_iff_eq] at hZero; omega

/-- C4 Budget Conservation + Priority-Tier Critical OOM Protection. -/
theorem budget_and_critical_tier_sound (ps : List Promise) (hvalid : isScopeValid ps = true)
    (p : Promise) (hp : p ∈ ps)
    (hcard : p.cardinality = Cardinality.budgeted)
    (hpol  : p.polarity = Polarity.use) :
    totalBudgetDemand ps p.ptype ≤ totalBudgetSupply ps p.ptype ∧
    criticalBudgetDemand ps p.ptype ≤ totalBudgetSupply ps p.ptype := by
  unfold isScopeValid at hvalid
  rw [List.all_eq_true] at hvalid
  have hpErr := hvalid p hp
  unfold checkPromise at hpErr
  rw [hcard, hpol, append_isEmpty_iff] at hpErr
  have hCard := hpErr.2
  rw [List.append_eq_nil_iff] at hCard
  constructor
  · by_cases hgt : totalBudgetDemand ps p.ptype > totalBudgetSupply ps p.ptype
    · simp [hgt] at hCard
    · omega
  · by_cases hgt : criticalBudgetDemand ps p.ptype > totalBudgetSupply ps p.ptype
    · simp [hgt] at hCard
    · omega

/-- Conditional Soft Promise Completeness Law. -/
theorem soft_conditional_law_sound (ps : List Promise) (hvalid : isScopeValid ps = true)
    (p : Promise) (hp : p ∈ ps) (hstr : p.strength = Strength.soft) :
    ∃ sc, p.softInfo = some sc ∧ sc.isComplete = true := by
  unfold isScopeValid at hvalid
  rw [List.all_eq_true] at hvalid
  have hpErr := hvalid p hp
  unfold checkPromise at hpErr
  rw [hstr, append_isEmpty_iff] at hpErr
  have hSoft := hpErr.1
  cases hinfo : p.softInfo with
  | none => rw [hinfo] at hSoft; simp at hSoft
  | some sc =>
    rw [hinfo] at hSoft; dsimp only at hSoft
    cases hcomp : sc.isComplete with
    | false => rw [hcomp] at hSoft; simp at hSoft
    | true  => exact ⟨sc, rfl, hcomp⟩

/-- Multi-Stratum Strict Stratification Soundness. -/
theorem multi_stratum_bounded (rules : List HandlerRule) (base : List Promise)
    (hRules : validateStratumRules rules = [])
    (hBase : ∀ p ∈ base, p.stratum = 0) (k : Nat) :
    ∀ p ∈ evalStratified rules base k, p.stratum ≤ k := by
  induction k with
  | zero =>
    intro p hp
    simp only [evalStratified] at hp
    have := hBase p hp
    omega
  | succ k ih =>
    intro p hp
    simp only [evalStratified, List.mem_append, List.mem_flatMap, List.mem_filter, beq_iff_eq] at hp
    cases hp with
    | inl hprev =>
      have := ih p hprev
      omega
    | inr hfired =>
      rcases hfired with ⟨r, ⟨hrMem, hrOut⟩, hpEmit⟩
      unfold validateStratumRules at hRules
      have hNone : ∀ x ∈ rules,
          (if x.inStratum < x.outStratum && x.emitted.all (fun q => q.stratum == x.outStratum)
           then none else some (BindingError.stratumOrderViolation x.id x.inStratum x.outStratum)) = none := by
        clear hrMem hrOut hpEmit hBase ih
        induction rules with
        | nil => intro x hx; cases hx
        | cons hd tl ihR =>
          simp only [List.filterMap_cons] at hRules
          split at hRules
          · rename_i hEq
            intro x hx
            cases hx with
            | head => exact hEq
            | tail _ htl => exact ihR hRules x htl
          · cases hRules
      have hRuleOk := hNone r hrMem
      split at hRuleOk
      · rename_i hCond
        simp only [Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true, beq_iff_eq] at hCond
        have hpStrat := hCond.2 p hpEmit
        omega
      · cases hRuleOk

private theorem checkAgentTreeList_append (invs : List PromiseInvariant) (xs ys : List Agent) :
    checkAgentTreeList invs (xs ++ ys) = (checkAgentTreeList invs xs && checkAgentTreeList invs ys) := by
  induction xs with
  | nil => simp [checkAgentTreeList]
  | cons x rest ih => simp [checkAgentTreeList, ih, Bool.and_assoc]

private theorem checkAgentTreeList_mem (invs : List PromiseInvariant) (xs : List Agent) :
    checkAgentTreeList invs xs = true ↔ ∀ a ∈ xs, checkAgentTree invs a = true := by
  induction xs with
  | nil => simp [checkAgentTreeList]
  | cons x rest ih =>
    simp only [checkAgentTreeList, Bool.and_eq_true, List.mem_cons, forall_eq_or_imp, ih]

/-- Recursive Agent Tree Verification Soundness (100% Usage-Agnostic TCB). -/
theorem checkAgentTree_superagent_sound (invs : List PromiseInvariant) (ext : ExteriorSurface) (children : List Agent)
    (hTree : checkAgentTree invs (Agent.superagent ext children) = true) :
    allInvariantsHold invs ext.promises = true ∧
    checkSuperagentConformance ext children = [] ∧
    isScopeValid (inboundFromExterior ext ++ outboundFromExterior ext ((siblingOperationalView children).flatMap (·.promises)) ++ (siblingOperationalView children).flatMap (·.promises)) = true ∧
    (∀ c ∈ children, checkAgentTree invs c = true) := by
  simp only [checkAgentTree, Bool.and_eq_true, List.isEmpty_iff] at hTree
  exact ⟨hTree.1.1.1, hTree.1.1.2, hTree.1.2, (checkAgentTreeList_mem invs children).mp hTree.2⟩

/--
  Compositional Non-Piercing Substitution Invariance (Crown Jewel):
  Replacing ANY nested Dressed Superagent's interior `cs1` with ANY valid conforming interior `cs2`
  that preserves `Pi_ext` is GUARANTEED to preserve full recursive validity of the enclosing Superagent!
-/
theorem checkAgentTree_substitution_invariant
    (invs : List PromiseInvariant) (parentExt ext : ExteriorSurface) (pre post cs1 cs2 : List Agent)
    (hParent : checkAgentTree invs (Agent.superagent parentExt (pre ++ [Agent.superagent ext cs1] ++ post)) = true)
    (hNew : checkAgentTree invs (Agent.superagent ext cs2) = true) :
    checkAgentTree invs (Agent.superagent parentExt (pre ++ [Agent.superagent ext cs2] ++ post)) = true := by
  have hView :
      siblingOperationalView (pre ++ [Agent.superagent ext cs2] ++ post) =
      siblingOperationalView (pre ++ [Agent.superagent ext cs1] ++ post) :=
    (non_piercing_interior_substitution pre post ext cs1 cs2).symm
  simp only [checkAgentTree, Bool.and_eq_true] at hParent ⊢
  refine ⟨⟨⟨hParent.1.1.1, ?_⟩, ?_⟩, ?_⟩
  · unfold checkSuperagentConformance at hParent ⊢
    rw [hView]
    exact hParent.1.1.2
  · rw [hView]
    exact hParent.1.2
  · have hKids := hParent.2
    simp only [checkAgentTreeList_append, checkAgentTreeList, Bool.and_true, Bool.and_eq_true] at hKids ⊢
    exact ⟨⟨hKids.1.1, hNew⟩, hKids.2⟩

end Aky.Thm
