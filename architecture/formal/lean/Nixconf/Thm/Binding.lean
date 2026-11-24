/-
  Nixconf.Thm.Binding — Layer 2 Machine-Checked Proofs (1:1 mirror of Nixconf.Spec.Binding)
  Zero `sorry`. Proves:
    - Diagnostic completeness (`validateScope ps = [] ↔ isScopeValid ps = true`)
    - Commutative Binding Order-Invariance (`List.Perm`)
    - B3 Exclusive 1:1 Soundness & Partitioned AttrExpr Disjointness (Gap #2)
    - C4 Budget Conservation + Critical-Tier Priority OOM Protection (Gap #2)
    - Conditional Soft Promise Law Soundness
    - Multi-Stratum Strict Stratification Soundness & Acyclic Termination (Gap #2)
-/

import Nixconf.Data.ListLemmas
import Nixconf.Spec.Binding

namespace Nixconf.Thm

open Nixconf.Data
open Nixconf.Spec

/-- Structured Diagnostics Equivalence: zero errors iff `isScopeValid = true`. -/
theorem validateScope_nil_iff_valid (ps : List Promise) :
    validateScope ps = [] ↔ isScopeValid ps = true := by
  unfold validateScope isScopeValid
  simp only [List.flatMap_eq_nil_iff, List.all_eq_true, List.isEmpty_iff]

theorem countMatchingOffers_perm {xs ys : List Promise} (h : xs.Perm ys) (pt k : String) :
    countMatchingOffers xs pt k = countMatchingOffers ys pt k := by
  unfold countMatchingOffers
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
  rw [countMatchingOffers_perm h, countMatchingPartitionHandlers_perm h,
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

/--
  GAP #2 CLOSED — B3 Partitioned AttrExpr Disjointness Soundness:
  If `isScopeValid ps = true`, then for EVERY partitioned offer `p`, at most ONE partitioned
  provider's `AttrExpr` selector matches `p.tags` (zero ambiguous routing between proxies!).
-/
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
  rw [List.append_eq_nil_iff] at hCard
  have hSel := hCard.2
  by_cases hgt : countMatchingPartitionHandlers ps p.ptype p.tags > 1
  · simp [hgt] at hSel
  · omega

/-- C4 Budget Conservation + Priority-Tier Critical OOM Protection (Gap #2 CLOSED!). -/
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

/--
  GAP #2 CLOSED — Multi-Stratum Strict Stratification Soundness:
  If `validateStratumRules rules = []`, every rule strictly advances stratum (`in < out`), AND
  evaluating `evalStratified rules base k` ONLY produces promises with `stratum ≤ k` (assuming
  base promises live at stratum 0) — proving strict forward acyclic termination with zero cycles!
-/
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

end Nixconf.Thm
