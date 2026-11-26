/-
  Baugr.Engine.Thm.Authority — Cedar L3+ & Biscuit Delegation Proofs (ZERO `sorry`)
-/

import Baugr.Data.ListLemmas
import Baugr.Engine.Authority

namespace Baugr.Engine.Thm

open Baugr.Data
open Baugr.Engine

theorem isAuthorized_iff (policies : List AuthPolicy) (p r : Entity) (a : String) :
    isAuthorized policies p a r =
      (policies.any (fun pol => pol.effect == Effect.permit && pol.matches p a r) &&
       !policies.any (fun pol => pol.effect == Effect.forbid && pol.matches p a r)) := by
  unfold isAuthorized authorize
  cases hF : (policies.filter (fun pol => pol.effect == Effect.forbid && pol.matches p a r)).isEmpty <;>
  cases hP : (policies.filter (fun pol => pol.effect == Effect.permit && pol.matches p a r)).isEmpty
  · have hAnyF : policies.any (fun pol => pol.effect == Effect.forbid && pol.matches p a r) = true := by
      rw [List.any_eq_true]
      cases hList : policies.filter (fun pol => pol.effect == Effect.forbid && pol.matches p a r) with
      | nil => rw [hList] at hF; simp at hF
      | cons x _ =>
        have hx : x ∈ policies.filter (fun pol => pol.effect == Effect.forbid && pol.matches p a r) := by rw [hList]; simp
        exact ⟨x, (List.mem_filter.mp hx).1, (List.mem_filter.mp hx).2⟩
    simp [hF, hAnyF]; rfl
  · have hAnyF : policies.any (fun pol => pol.effect == Effect.forbid && pol.matches p a r) = true := by
      rw [List.any_eq_true]
      cases hList : policies.filter (fun pol => pol.effect == Effect.forbid && pol.matches p a r) with
      | nil => rw [hList] at hF; simp at hF
      | cons x _ =>
        have hx : x ∈ policies.filter (fun pol => pol.effect == Effect.forbid && pol.matches p a r) := by rw [hList]; simp
        exact ⟨x, (List.mem_filter.mp hx).1, (List.mem_filter.mp hx).2⟩
    simp [hF, hAnyF]; rfl
  · have hNoF : policies.any (fun pol => pol.effect == Effect.forbid && pol.matches p a r) = false := by
      rw [List.any_eq_false]
      intro x hx hBad
      have hMem : x ∈ policies.filter (fun pol => pol.effect == Effect.forbid && pol.matches p a r) :=
        List.mem_filter.mpr ⟨hx, hBad⟩
      rw [List.isEmpty_iff] at hF
      rw [hF] at hMem; cases hMem
    have hAnyP : policies.any (fun pol => pol.effect == Effect.permit && pol.matches p a r) = true := by
      rw [List.any_eq_true]
      cases hList : policies.filter (fun pol => pol.effect == Effect.permit && pol.matches p a r) with
      | nil => rw [hList] at hP; simp at hP
      | cons x _ =>
        have hx : x ∈ policies.filter (fun pol => pol.effect == Effect.permit && pol.matches p a r) := by rw [hList]; simp
        exact ⟨x, (List.mem_filter.mp hx).1, (List.mem_filter.mp hx).2⟩
    simp [hF, hP, hNoF, hAnyP]; rfl
  · have hNoP : policies.any (fun pol => pol.effect == Effect.permit && pol.matches p a r) = false := by
      rw [List.any_eq_false]
      intro x hx hBad
      have hMem : x ∈ policies.filter (fun pol => pol.effect == Effect.permit && pol.matches p a r) :=
        List.mem_filter.mpr ⟨hx, hBad⟩
      rw [List.isEmpty_iff] at hP
      rw [hP] at hMem; cases hMem
    simp [hF, hP, hNoP]; rfl

theorem default_deny_empty (p r : Entity) (a : String) :
    isAuthorized [] p a r = false := by
  rfl

theorem forbid_overrides_permit (policies : List AuthPolicy) (p r : Entity) (a : String)
    (f : AuthPolicy) (hfMem : f ∈ policies)
    (hfEff : f.effect = Effect.forbid) (hfMatch : f.matches p a r = true) :
    isAuthorized policies p a r = false := by
  rw [isAuthorized_iff]
  have hAny : policies.any (fun pol => pol.effect == Effect.forbid && pol.matches p a r) = true := by
    rw [List.any_eq_true]
    exact ⟨f, hfMem, by rw [hfEff, hfMatch]; rfl⟩
  simp [hAny]

theorem policy_order_invariance {ps1 ps2 : List AuthPolicy} (h : ps1.Perm ps2)
    (p r : Entity) (a : String) :
    isAuthorized ps1 p a r = isAuthorized ps2 p a r := by
  rw [isAuthorized_iff, isAuthorized_iff, any_perm h, any_perm h]

theorem attenuation_monotonic (cap : Capability) (extra : AttrExpr) (a : String) (r : Entity) :
    (cap.attenuate extra).allows a r = true → cap.allows a r = true := by
  unfold Capability.attenuate Capability.allows
  simp only [List.all_append, List.all_cons, List.all_nil, Bool.and_true, Bool.and_eq_true]
  intro ⟨hAct, hAll, _⟩
  exact ⟨hAct, hAll⟩

theorem delegation_never_exceeds_delegator
    (policies : List AuthPolicy) (delegator delegatee : Entity)
    (cap : Capability) (a : String) (r : Entity) :
    isDelegatedAuthorized policies delegator delegatee cap a r = true →
    isAuthorized policies delegator a r = true := by
  unfold isDelegatedAuthorized
  simp only [Bool.and_eq_true]
  intro ⟨⟨hDel, _⟩, _⟩
  exact hDel

theorem delegation_respects_delegatee_forbid
    (policies : List AuthPolicy) (delegator delegatee : Entity)
    (cap : Capability) (a : String) (r : Entity)
    (f : AuthPolicy) (hfMem : f ∈ policies)
    (hfEff : f.effect = Effect.forbid) (hfMatch : f.matches delegatee a r = true) :
    isDelegatedAuthorized policies delegator delegatee cap a r = false := by
  unfold isDelegatedAuthorized hasForbid
  have hAny : policies.any (fun pol => pol.effect == Effect.forbid && pol.matches delegatee a r) = true := by
    rw [List.any_eq_true]
    exact ⟨f, hfMem, by rw [hfEff, hfMatch]; rfl⟩
  simp [hAny]

theorem delegated_attenuation_monotonic
    (policies : List AuthPolicy) (delegator delegatee : Entity)
    (cap : Capability) (extra : AttrExpr) (a : String) (r : Entity) :
    isDelegatedAuthorized policies delegator delegatee (cap.attenuate extra) a r = true →
    isDelegatedAuthorized policies delegator delegatee cap a r = true := by
  unfold isDelegatedAuthorized
  simp only [Bool.and_eq_true]
  intro ⟨⟨hDel, hCap⟩, hNoF⟩
  exact ⟨⟨hDel, attenuation_monotonic cap extra a r hCap⟩, hNoF⟩

theorem blast_radius_sound_and_complete
    (policies : List AuthPolicy) (p : Entity) (a : String) (allResources : List Entity)
    (r : Entity) (hr : r ∈ allResources) :
    r ∈ blastRadius policies p a allResources ↔ isAuthorized policies p a r = true := by
  unfold blastRadius
  simp [List.mem_filter, hr]

theorem attr_diff_excludes (tags : List String) (e1 e2 : AttrExpr) :
    (AttrExpr.diff e1 e2).eval tags = true ↔ (e1.eval tags = true ∧ e2.eval tags = false) := by
  simp [AttrExpr.eval]

end Baugr.Engine.Thm
