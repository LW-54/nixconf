/-
  Baugr.Engine.Thm.Binding — B3 Scoped Binding, Cedar Structural Auth & Recursive Tree Proofs
  ZERO `sorry`. Includes F-6 (`checkAgentTree_atomic_sound`) & substitution invariance!
-/

import Baugr.Data.ListLemmas
import Baugr.Theory.Thm
import Baugr.Engine.Binding
import Baugr.Engine.Thm.Conformance
import Baugr.Engine.Thm.Authority

namespace Baugr.Engine.Thm

open Baugr.Data
open Baugr.Theory
open Baugr.Engine

theorem validateScope_nil_iff_valid (ps : List Promise) :
    validateScope ps = [] ↔ isScopeValid ps = true := by
  unfold validateScope isScopeValid
  simp only [List.flatMap_eq_nil_iff, List.all_eq_true, List.isEmpty_iff]

theorem countMatchingOffers_perm {xs ys : List Promise} (h : xs.Perm ys) (pt k : String) :
    countMatchingOffers xs pt k = countMatchingOffers ys pt k := by
  unfold countMatchingOffers
  exact (h.filter _).length_eq

theorem countMatchingBroadcastOffers_perm {xs ys : List Promise} (h : xs.Perm ys) (pt : String) (sel : AttrExpr) :
    countMatchingBroadcastOffers xs pt sel = countMatchingBroadcastOffers ys pt sel := by
  unfold countMatchingBroadcastOffers
  exact (h.filter _).length_eq

theorem countMatchingBroadcastHandlers_perm {xs ys : List Promise} (h : xs.Perm ys) (pt : String) (tags : List String) :
    countMatchingBroadcastHandlers xs pt tags = countMatchingBroadcastHandlers ys pt tags := by
  unfold countMatchingBroadcastHandlers
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

theorem checkPromise_perm {ps1 ps2 : List Promise} (h : ps1.Perm ps2) (p : Promise) :
    checkPromise ps1 p = checkPromise ps2 p := by
  unfold checkPromise
  rw [countMatchingOffers_perm h, countMatchingBroadcastOffers_perm h,
      countMatchingBroadcastHandlers_perm h, countMatchingPartitionHandlers_perm h,
      totalBudgetDemand_perm h, totalBudgetSupply_perm h, criticalBudgetDemand_perm h]

theorem isScopeValid_perm {ps1 ps2 : List Promise} (h : ps1.Perm ps2) :
    isScopeValid ps1 = isScopeValid ps2 := by
  unfold isScopeValid
  have h1 : ps1.all (fun p => (checkPromise ps1 p).isEmpty) =
            ps1.all (fun p => (checkPromise ps2 p).isEmpty) := by
    congr 1; funext p; rw [checkPromise_perm h p]
  rw [h1]
  exact all_perm h _

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

theorem broadcast_mandatory_sound (ps : List Promise) (hvalid : isScopeValid ps = true)
    (p : Promise) (hp : p ∈ ps)
    (hcard : p.cardinality = Cardinality.broadcast)
    (hpol  : p.polarity = Polarity.use)
    (hstr  : p.strength = Strength.hard)
    (hmand : p.mandatory = true) :
    countMatchingBroadcastOffers ps p.ptype p.selector > 0 := by
  unfold isScopeValid at hvalid
  rw [List.all_eq_true] at hvalid
  have hpErr := hvalid p hp
  unfold checkPromise at hpErr
  rw [hcard, hpol, hstr, hmand, append_isEmpty_iff] at hpErr
  have hCard := hpErr.2
  dsimp only at hCard
  by_cases hZero : countMatchingBroadcastOffers ps p.ptype p.selector == 0
  · rw [hZero] at hCard; simp at hCard
  · simp only [beq_iff_eq] at hZero; omega

theorem broadcast_mandatory_offer_handled_sound (ps : List Promise) (hvalid : isScopeValid ps = true)
    (p : Promise) (hp : p ∈ ps)
    (hcard : p.cardinality = Cardinality.broadcast)
    (hpol  : p.polarity = Polarity.offer)
    (hstr  : p.strength = Strength.hard)
    (hmand : p.mandatory = true) :
    countMatchingOffers ps p.ptype p.key ≤ 1 ∧
    countMatchingBroadcastHandlers ps p.ptype p.tags > 0 := by
  unfold isScopeValid at hvalid
  rw [List.all_eq_true] at hvalid
  have hpErr := hvalid p hp
  unfold checkPromise at hpErr
  rw [hcard, hpol, hstr, hmand, append_isEmpty_iff] at hpErr
  have hCard := hpErr.2
  simp only [List.append_eq_nil_iff] at hCard
  constructor
  · by_cases hgt : countMatchingOffers ps p.ptype p.key > 1
    · simp [hgt] at hCard
    · omega
  · by_cases hZero : countMatchingBroadcastHandlers ps p.ptype p.tags == 0
    · have hHard : (Strength.hard == Strength.hard) = true := by decide
      simp [hZero, hHard] at hCard
    · simp only [beq_iff_eq] at hZero; omega

theorem broadcast_subscriber_non_interference (ps : List Promise) (p h : Promise)
    (hpCard : p.cardinality = Cardinality.broadcast)
    (hpPol  : p.polarity = Polarity.offer)
    (_hhCard : h.cardinality = Cardinality.broadcast)
    (hhPol  : h.polarity = Polarity.use)
    (hOk    : (checkPromise ps p).isEmpty = true) :
    (checkPromise (h :: ps) p).isEmpty = true := by
  unfold checkPromise at hOk ⊢
  rw [hpCard, hpPol, append_isEmpty_iff] at hOk ⊢
  refine ⟨hOk.1, ?_⟩
  have hCard := hOk.2
  simp only [List.append_eq_nil_iff] at hCard ⊢
  have hOfferSame : countMatchingOffers (h :: ps) p.ptype p.key = countMatchingOffers ps p.ptype p.key := by
    unfold countMatchingOffers
    have hNe : (Polarity.use == Polarity.offer) = false := by decide
    simp [hhPol, hNe]
  have hHandlersGe : countMatchingBroadcastHandlers (h :: ps) p.ptype p.tags ≥ countMatchingBroadcastHandlers ps p.ptype p.tags := by
    unfold countMatchingBroadcastHandlers
    simp only [List.filter_cons]
    split <;> simp
  constructor
  · rw [hOfferSame]; exact hCard.1
  · by_cases hCond : p.strength == Strength.hard && p.mandatory
    · have hNz : countMatchingBroadcastHandlers ps p.ptype p.tags ≠ 0 := by
        intro hEq
        have hBad := hCard.2
        simp [hCond, hEq] at hBad
      have hNz' : countMatchingBroadcastHandlers (h :: ps) p.ptype p.tags ≠ 0 := by omega
      have hBeq : (countMatchingBroadcastHandlers (h :: ps) p.ptype p.tags == 0) = false := by
        simp [hNz']
      simp [hBeq]
    · simp [hCond]

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

theorem validateScopeAuth_nil_iff_valid
    (policies : List AuthPolicy) (bindings : List AuthBinding)
    (principal : Entity) (ps : List Promise) :
    validateScopeAuth policies bindings principal ps = [] ↔
    isScopeAuthValid policies bindings principal ps = true := by
  unfold isScopeAuthValid
  simp only [List.isEmpty_iff]

theorem scope_auth_sound
    (policies : List AuthPolicy) (bindings : List AuthBinding)
    (principal : Entity) (ps : List Promise)
    (hAuth : isScopeAuthValid policies bindings principal ps = true)
    (ab : AuthBinding) (hab : ab ∈ bindings)
    (hMatchP : ab.principalFilter.eval principal.tags = true)
    (p : Promise) (hp : p ∈ ps)
    (hPt : p.ptype = ab.ptype) (hPol : p.polarity = ab.polarity) :
    isAuthorized policies principal ab.action { id := p.key, tags := p.tags } = true := by
  rw [← validateScopeAuth_nil_iff_valid] at hAuth
  unfold validateScopeAuth at hAuth
  have hBind := (List.flatMap_eq_nil_iff.mp hAuth) ab hab
  rw [hMatchP] at hBind
  simp only [↓reduceIte] at hBind
  have hProm := (filterMap_eq_nil_iff _ ps).mp hBind p hp
  have hPolSelf : (ab.polarity == ab.polarity) = true := by cases ab.polarity <;> rfl
  rw [hPt, hPol] at hProm
  simp only [beq_self_eq_true, hPolSelf, Bool.and_true, ↓reduceIte] at hProm
  cases hDec : isAuthorized policies principal ab.action { id := p.key, tags := p.tags } with
  | true => rfl
  | false => rw [hDec] at hProm; simp at hProm

theorem scope_auth_forbid_blocks_promise
    (policies : List AuthPolicy) (bindings : List AuthBinding)
    (principal : Entity) (ps : List Promise)
    (ab : AuthBinding) (hab : ab ∈ bindings)
    (hMatchP : ab.principalFilter.eval principal.tags = true)
    (p : Promise) (hp : p ∈ ps)
    (hPt : p.ptype = ab.ptype) (hPol : p.polarity = ab.polarity)
    (f : AuthPolicy) (hfMem : f ∈ policies) (hfEff : f.effect = Effect.forbid)
    (hfMatch : f.matches principal ab.action { id := p.key, tags := p.tags } = true) :
    isScopeAuthValid policies bindings principal ps = false := by
  cases hAuth : isScopeAuthValid policies bindings principal ps with
  | false => rfl
  | true =>
    have hAllow := scope_auth_sound policies bindings principal ps hAuth ab hab hMatchP p hp hPt hPol
    have hDeny := forbid_overrides_permit policies principal { id := p.key, tags := p.tags } ab.action f hfMem hfEff hfMatch
    rw [hAllow] at hDeny
    contradiction

private theorem checkAgentTreeList_append
    (invs : List PromiseInvariant) (policies : List AuthPolicy) (authBindings : List AuthBinding)
    (xs ys : List Agent) :
    checkAgentTreeList invs policies authBindings (xs ++ ys) =
    (checkAgentTreeList invs policies authBindings xs && checkAgentTreeList invs policies authBindings ys) := by
  induction xs with
  | nil => simp [checkAgentTreeList]
  | cons x rest ih => simp [checkAgentTreeList, ih, Bool.and_assoc]

theorem checkAgentTreeList_mem
    (invs : List PromiseInvariant) (policies : List AuthPolicy) (authBindings : List AuthBinding)
    (xs : List Agent) :
    checkAgentTreeList invs policies authBindings xs = true ↔
    ∀ a ∈ xs, checkAgentTree invs policies authBindings a = true := by
  induction xs with
  | nil => simp [checkAgentTreeList]
  | cons x rest ih =>
    simp only [checkAgentTreeList, Bool.and_eq_true, List.mem_cons, forall_eq_or_imp, ih]

/-- F-6 Closed: Atomic Agent Verification Soundness (invariants AND Cedar principal auth!). -/
theorem checkAgentTree_atomic_sound
    (invs : List PromiseInvariant) (policies : List AuthPolicy) (authBindings : List AuthBinding)
    (ext : ExteriorSurface) (hHash : String)
    (hTree : checkAgentTree invs policies authBindings (Agent.atomic ext hHash) = true) :
    allInvariantsHold invs ext.promises = true ∧
    isScopeAuthValid policies authBindings { id := ext.agentId, tags := ext.attributes } ext.promises = true := by
  simp only [checkAgentTree, Bool.and_eq_true] at hTree
  exact hTree

theorem checkAgentTree_superagent_sound
    (invs : List PromiseInvariant) (policies : List AuthPolicy) (authBindings : List AuthBinding)
    (ext : ExteriorSurface) (children : List Agent)
    (hTree : checkAgentTree invs policies authBindings (Agent.superagent ext children) = true) :
    let intPs := (siblingOperationalView children).flatMap (·.promises)
    let scopePs := inboundFromExterior ext ++ outboundFromExterior ext intPs ++ intPs
    allInvariantsHold invs ext.promises = true ∧
    checkSuperagentConformance ext children = [] ∧
    isScopeValid scopePs = true ∧
    isScopeAuthValid policies authBindings { id := ext.agentId, tags := ext.attributes } intPs = true ∧
    (∀ c ∈ children, checkAgentTree invs policies authBindings c = true) := by
  simp only [checkAgentTree, Bool.and_eq_true, List.isEmpty_iff] at hTree
  exact ⟨hTree.1.1.1.1, hTree.1.1.1.2, hTree.1.1.2, hTree.1.2,
         (checkAgentTreeList_mem invs policies authBindings children).mp hTree.2⟩

theorem checkAgentTree_substitution_invariant
    (invs : List PromiseInvariant) (policies : List AuthPolicy) (authBindings : List AuthBinding)
    (parentExt ext : ExteriorSurface) (pre post cs1 cs2 : List Agent)
    (hParent : checkAgentTree invs policies authBindings (Agent.superagent parentExt (pre ++ [Agent.superagent ext cs1] ++ post)) = true)
    (hNew : checkAgentTree invs policies authBindings (Agent.superagent ext cs2) = true) :
    checkAgentTree invs policies authBindings (Agent.superagent parentExt (pre ++ [Agent.superagent ext cs2] ++ post)) = true := by
  have hView :
      siblingOperationalView (pre ++ [Agent.superagent ext cs2] ++ post) =
      siblingOperationalView (pre ++ [Agent.superagent ext cs1] ++ post) :=
    (non_piercing_interior_substitution pre post ext cs1 cs2).symm
  simp only [checkAgentTree, Bool.and_eq_true] at hParent ⊢
  refine ⟨⟨⟨⟨hParent.1.1.1.1, ?_⟩, ?_⟩, ?_⟩, ?_⟩
  · unfold checkSuperagentConformance at hParent ⊢
    rw [hView]
    exact hParent.1.1.1.2
  · rw [hView]
    exact hParent.1.1.2
  · rw [hView]
    exact hParent.1.2
  · have hKids := hParent.2
    simp only [checkAgentTreeList_append, checkAgentTreeList, Bool.and_true, Bool.and_eq_true] at hKids ⊢
    exact ⟨⟨hKids.1.1, hNew⟩, hKids.2⟩

end Baugr.Engine.Thm
