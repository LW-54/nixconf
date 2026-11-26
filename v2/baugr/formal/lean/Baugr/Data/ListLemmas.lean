/-
  Baugr.Data.ListLemmas — Layer 0 Shared Permutation & Aggregation Proof Helpers
  Pure reusable lemmas (zero Mathlib) shared across Baugr.Theory.* & Baugr.Engine.Thm.*.
-/

namespace Baugr.Data

theorem foldl_add_shift {α : Type} (f : α -> Nat) (xs : List α) (init : Nat) :
    xs.foldl (fun acc x => acc + f x) init = init + xs.foldl (fun acc x => acc + f x) 0 := by
  induction xs generalizing init with
  | nil => simp
  | cons x rest ih =>
    simp only [List.foldl_cons, Nat.zero_add]
    rw [ih (init + f x), ih (f x), Nat.add_assoc]

theorem foldl_add_perm {α : Type} (f : α -> Nat) {xs ys : List α} (h : xs.Perm ys) :
    xs.foldl (fun acc x => acc + f x) 0 = ys.foldl (fun acc x => acc + f x) 0 := by
  induction h with
  | nil => rfl
  | cons x _ ih =>
    simp only [List.foldl_cons, Nat.zero_add]
    rw [foldl_add_shift f _ (f x), foldl_add_shift f _ (f x), ih]
  | swap x y l =>
    simp only [List.foldl_cons, Nat.zero_add]
    rw [foldl_add_shift f _ (f y + f x), foldl_add_shift f _ (f x + f y), Nat.add_comm (f y) (f x)]
  | trans _ _ ih1 ih2 => exact Eq.trans ih1 ih2

theorem all_perm {α : Type} {xs ys : List α} (h : xs.Perm ys) (p : α -> Bool) :
    xs.all p = ys.all p := by
  induction h with
  | nil => rfl
  | cons x _ ih => simp [List.all_cons, ih]
  | swap x y l => simp [List.all_cons, Bool.and_left_comm]
  | trans _ _ ih1 ih2 => exact Eq.trans ih1 ih2

theorem any_perm {α : Type} {xs ys : List α} (h : xs.Perm ys) (p : α -> Bool) :
    xs.any p = ys.any p := by
  induction h with
  | nil => rfl
  | cons x _ ih => simp [List.any_cons, ih]
  | swap x y l => simp [List.any_cons, Bool.or_left_comm]
  | trans _ _ ih1 ih2 => exact Eq.trans ih1 ih2

theorem append_isEmpty_iff {α : Type} (a b : List α) :
    (a ++ b).isEmpty = true ↔ a = [] ∧ b = [] := by
  cases a <;> cases b <;> simp

theorem filterMap_eq_nil_iff {α β : Type} (f : α -> Option β) (xs : List α) :
    xs.filterMap f = [] ↔ ∀ x ∈ xs, f x = none := by
  induction xs with
  | nil => simp
  | cons x rest ih =>
    cases hx : f x with
    | none => simp [hx, ih]
    | some b => simp [hx]

end Baugr.Data
