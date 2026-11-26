/-
  Baugr.Engine.Thm.Resolve — Type Soundness (Progress & Preservation) for `checkAgentTree → resolveAgentTree` (F-2!)
  ZERO `sorry`. Proves:
    1. `valid_use_resolves`: every promise in a valid B3 scope resolves without error.
    2. `valid_scope_resolves_safely` (Single-Scope Progress): `isScopeValid ps = true → ∃ bs, resolveScope ps = some bs`.
    3. `valid_agent_tree_resolves_safely` (Full Tree Type Soundness / Progress):
       `checkAgentTree invs policies authBindings a = true → ∃ rs, resolveAgentTree a = some rs`!
    4. `resolve_parent_scope_non_piercing` (Evaluator Non-Piercing Preservation):
       swapping any child Superagent's interior while preserving `Π_ext` produces strictly identical
       resolved bindings for the enclosing parent scope!
-/

import Baugr.Theory.Thm
import Baugr.Engine.Resolve
import Baugr.Engine.Thm.Binding

namespace Baugr.Engine.Thm

open Baugr.Data
open Baugr.Theory
open Baugr.Engine

/-- Helper: every promise inside a valid `B3` scope resolves cleanly via `resolveUse`. -/
theorem valid_use_resolves (allPs : List Promise) (hvalid : isScopeValid allPs = true)
    (p : Promise) (hp : p ∈ allPs) :
    ∃ r, resolveUse allPs p = some r := by
  unfold resolveUse
  cases hPol : p.polarity with
  | offer => exact ⟨none, rfl⟩
  | use =>
    cases hCard : p.cardinality with
    | exclusive =>
      cases hStr : p.strength with
      | hard =>
        cases hMand : p.mandatory with
        | true =>
          have hCnt := exclusive_binding_sound allPs hvalid p hp hCard hPol hStr hMand
          unfold countMatchingOffers at hCnt
          simp [hCnt]
        | false => exact ⟨_, rfl⟩
      | soft => exact ⟨_, rfl⟩
    | broadcast =>
      cases hStr : p.strength with
      | hard =>
        cases hMand : p.mandatory with
        | true =>
          have hPos := broadcast_mandatory_sound allPs hvalid p hp hCard hPol hStr hMand
          unfold countMatchingBroadcastOffers at hPos
          have hNotEmpty : (allPs.filter (fun o => o.polarity == Polarity.offer && o.ptype == p.ptype && p.selector.eval o.tags)).isEmpty = false := by
            cases hFilt : allPs.filter (fun o => o.polarity == Polarity.offer && o.ptype == p.ptype && p.selector.eval o.tags) with
            | nil => rw [hFilt] at hPos; simp at hPos
            | cons _ _ => rfl
          simp [hNotEmpty]
        | false => exact ⟨_, rfl⟩
      | soft => exact ⟨_, rfl⟩
    | partitioned => exact ⟨_, rfl⟩
    | budgeted =>
      have ⟨hDem, hCrit⟩ := budget_and_critical_tier_sound allPs hvalid p hp hCard hPol
      have hCond : (totalBudgetDemand allPs p.ptype > totalBudgetSupply allPs p.ptype ||
                    criticalBudgetDemand allPs p.ptype > totalBudgetSupply allPs p.ptype) = false := by
        have h1 : decide (totalBudgetDemand allPs p.ptype > totalBudgetSupply allPs p.ptype) = false := by
          simp only [decide_eq_false_iff_not]; omega
        have h2 : decide (criticalBudgetDemand allPs p.ptype > totalBudgetSupply allPs p.ptype) = false := by
          simp only [decide_eq_false_iff_not]; omega
        rw [h1, h2]; rfl
      simp [hCond]

private theorem resolveScopeList_progress (allPs : List Promise) (hvalid : isScopeValid allPs = true)
    (sub : List Promise) (hSub : ∀ p ∈ sub, p ∈ allPs) :
    ∃ bs, resolveScopeList allPs sub = some bs := by
  induction sub with
  | nil => exact ⟨[], rfl⟩
  | cons p rest ih =>
    have hpMem : p ∈ allPs := hSub p (List.mem_cons_self)
    have hRestSub : ∀ q ∈ rest, q ∈ allPs := fun q hq => hSub q (List.mem_cons_of_mem p hq)
    obtain ⟨r, hr⟩ := valid_use_resolves allPs hvalid p hpMem
    obtain ⟨tail, htail⟩ := ih hRestSub
    unfold resolveScopeList
    rw [hr, htail]
    cases r with
    | none => exact ⟨tail, rfl⟩
    | some ru => exact ⟨ru :: tail, rfl⟩

/-- Single-Scope Type Soundness (Progress): any valid `B3` scope resolves with ZERO runtime binding failures! -/
theorem valid_scope_resolves_safely (ps : List Promise) (hvalid : isScopeValid ps = true) :
    ∃ bs, resolveScope ps = some bs :=
  resolveScopeList_progress ps hvalid ps (fun _ h => h)

/-
  Crown Jewel Type Soundness (Progress & Preservation for Recursive Fractal Agent Trees):
  If `checkAgentTree` accepts ANY arbitrary-depth `Agent` tree, recursive `resolveAgentTree` is
  MATHEMATICALLY GUARANTEED to succeed without any runtime missing/ambiguous provider or budget error!
-/
mutual
  theorem valid_agent_tree_resolves_safely
      (invs : List PromiseInvariant) (policies : List AuthPolicy) (authBindings : List AuthBinding) :
      (a : Agent) → checkAgentTree invs policies authBindings a = true → ∃ rs, resolveAgentTree a = some rs
    | Agent.atomic _ _, _ => ⟨[], rfl⟩
    | Agent.superagent ext children, hTree => by
      have hSound := checkAgentTree_superagent_sound invs policies authBindings ext children hTree
      obtain ⟨bs, hbs⟩ := valid_scope_resolves_safely _ hSound.2.2.1
      have hKidsList : checkAgentTreeList invs policies authBindings children = true :=
        (checkAgentTreeList_mem invs policies authBindings children).mpr hSound.2.2.2.2
      obtain ⟨childScopes, hcs⟩ := valid_agent_tree_list_resolves_safely invs policies authBindings children hKidsList
      unfold resolveAgentTree
      dsimp only
      rw [hbs, hcs]
      exact ⟨{ agentId := ext.agentId, bindings := bs } :: childScopes, rfl⟩
    | Agent.profile ms, hTree => by
      unfold checkAgentTree at hTree
      unfold resolveAgentTree
      exact valid_agent_tree_list_resolves_safely invs policies authBindings ms hTree

  theorem valid_agent_tree_list_resolves_safely
      (invs : List PromiseInvariant) (policies : List AuthPolicy) (authBindings : List AuthBinding) :
      (xs : List Agent) → checkAgentTreeList invs policies authBindings xs = true → ∃ rs, resolveAgentTreeList xs = some rs
    | [], _ => ⟨[], rfl⟩
    | a :: rest, hxs => by
      simp only [checkAgentTreeList, Bool.and_eq_true] at hxs
      obtain ⟨ra, hra⟩ := valid_agent_tree_resolves_safely invs policies authBindings a hxs.1
      obtain ⟨rr, hrr⟩ := valid_agent_tree_list_resolves_safely invs policies authBindings rest hxs.2
      unfold resolveAgentTreeList
      rw [hra, hrr]
      exact ⟨ra ++ rr, rfl⟩
end

/-- Evaluator Non-Piercing Preservation: replacing a child's interior preserves the enclosing parent's resolved scope! -/
theorem resolve_parent_scope_non_piercing
    (parentExt ext : ExteriorSurface) (pre post cs1 cs2 : List Agent) :
    let intPs1 := (siblingOperationalView (pre ++ [Agent.superagent ext cs1] ++ post)).flatMap (·.promises)
    let intPs2 := (siblingOperationalView (pre ++ [Agent.superagent ext cs2] ++ post)).flatMap (·.promises)
    resolveScope (inboundFromExterior parentExt ++ outboundFromExterior parentExt intPs1 ++ intPs1) =
    resolveScope (inboundFromExterior parentExt ++ outboundFromExterior parentExt intPs2 ++ intPs2) := by
  dsimp only
  rw [non_piercing_interior_substitution pre post ext cs1 cs2]

end Baugr.Engine.Thm
