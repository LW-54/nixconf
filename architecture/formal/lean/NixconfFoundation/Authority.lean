/-
  NixconfFoundation.Authority
  Formalization of ADR-0004 (L3+ Boolean Set-Algebra Authorization Lattice),
  RES-0013 (AWS Cedar Default-Deny + forbid-overrides-permit + Biscuit Offline Attenuation),
  and ADR-0006 C1 (Mechanical Blast-Radius Revocation).

  Pure Lean 4 core (zero Mathlib). Every theorem is machine-checked without `sorry`.
-/

namespace NixconfFoundation

/-- Boolean Set-Algebra Predicate over Agent Attributes & Group Memberships (L3+). -/
inductive AttrExpr where
  | atom   (tag : String)                   -- x ∈ tag (attribute or group membership)
  | union  (e1 e2 : AttrExpr)               -- e1 ∪ e2 (OR)
  | inter  (e1 e2 : AttrExpr)               -- e1 ∩ e2 (AND)
  | diff   (e1 e2 : AttrExpr)               -- e1 \ e2 (Inclusion with Exclusion)
  | compl  (e : AttrExpr)                   -- ¬e (Complement)
  | any                                     -- Top (⊤)
  | none                                    -- Bottom (⊥)
  deriving Repr, DecidableEq, BEq

def AttrExpr.eval (tags : List String) : AttrExpr -> Bool
  | AttrExpr.atom t      => tags.contains t
  | AttrExpr.union e1 e2 => e1.eval tags || e2.eval tags
  | AttrExpr.inter e1 e2 => e1.eval tags && e2.eval tags
  | AttrExpr.diff e1 e2  => e1.eval tags && !(e2.eval tags)
  | AttrExpr.compl e     => !(e.eval tags)
  | AttrExpr.any         => true
  | AttrExpr.none        => false

inductive Effect where
  | permit
  | forbid
  deriving Repr, DecidableEq, BEq

structure AuthPolicy where
  id            : String
  effect        : Effect
  action        : String
  principalPred : AttrExpr
  resourcePred  : AttrExpr
  deriving Repr, DecidableEq, BEq

structure Entity where
  id   : String
  tags : List String
  deriving Repr, DecidableEq, BEq

def AuthPolicy.matches (pol : AuthPolicy) (principal : Entity) (action : String) (resource : Entity) : Bool :=
  pol.action == action &&
  pol.principalPred.eval principal.tags &&
  pol.resourcePred.eval resource.tags

/--
  AWS Cedar Semantics (OOPSLA 2024):
  Authorized iff (at least one `permit` matches) AND (ZERO `forbid` policies match). Default-Deny!
-/
def isAuthorized (policies : List AuthPolicy) (principal : Entity) (action : String) (resource : Entity) : Bool :=
  let hasPermit := policies.any (fun p => p.effect == Effect.permit && p.matches principal action resource)
  let hasForbid := policies.any (fun p => p.effect == Effect.forbid && p.matches principal action resource)
  hasPermit && !hasForbid

/--
  Biscuit-Style Offline-Verifiable Attenuated Capability (RES-0013):
  A root grant restricted monotonically by an append-only list of narrowing caveats.
-/
structure Capability where
  rootPolicyId : String
  allowedAction : String
  caveats       : List AttrExpr -- Every caveat MUST hold on the target resource!
  deriving Repr, DecidableEq, BEq

def Capability.attenuate (cap : Capability) (extraCaveat : AttrExpr) : Capability :=
  { cap with caveats := cap.caveats ++ [extraCaveat] }

def Capability.allows (cap : Capability) (action : String) (resource : Entity) : Bool :=
  cap.allowedAction == action && cap.caveats.all (fun c => c.eval resource.tags)

/-- Mechanical Blast-Radius Calculator (ADR-0006 C1): all resources a principal can access for an action. -/
def blastRadius (policies : List AuthPolicy) (principal : Entity) (action : String) (allResources : List Entity) : List Entity :=
  allResources.filter (fun r => isAuthorized policies principal action r)

-- === MACHINE-CHECKED SECURITY THEOREMS ===

/-- THEOREM 9 (Cedar Default-Deny): An empty policy set denies every request. -/
theorem default_deny_empty (p r : Entity) (a : String) :
    isAuthorized [] p a r = false := by
  rfl

/--
  THEOREM 10 (Cedar Forbid-Overrides-Permit):
  If ANY `forbid` policy in `policies` matches `(principal, action, resource)`, then `isAuthorized`
  is GUARANTEED to return `false`, regardless of how many `permit` policies exist!
-/
theorem forbid_overrides_permit (policies : List AuthPolicy) (p r : Entity) (a : String)
    (f : AuthPolicy) (hfMem : f ∈ policies)
    (hfEff : f.effect = Effect.forbid)
    (hfMatch : f.matches p a r = true) :
    isAuthorized policies p a r = false := by
  unfold isAuthorized
  have hAny : policies.any (fun pol => pol.effect == Effect.forbid && pol.matches p a r) = true := by
    rw [List.any_eq_true]
    exact ⟨f, hfMem, by rw [hfEff, hfMatch]; rfl⟩
  simp [hAny]

/-- Helper: `List.any` is invariant under arbitrary list permutations. -/
theorem any_perm {α : Type} {xs ys : List α} (h : xs.Perm ys) (f : α -> Bool) :
    xs.any f = ys.any f := by
  induction h with
  | nil => rfl
  | cons x _ ih => simp [List.any_cons, ih]
  | swap x y l => simp [List.any_cons, Bool.or_left_comm]
  | trans _ _ ih1 ih2 => exact Eq.trans ih1 ih2

/--
  THEOREM 11 (Cedar Policy Order-Invariance):
  Permuting the order of policies in `policies` NEVER changes the authorization verdict!
-/
theorem policy_order_invariance {ps1 ps2 : List AuthPolicy} (h : ps1.Perm ps2)
    (p r : Entity) (a : String) :
    isAuthorized ps1 p a r = isAuthorized ps2 p a r := by
  unfold isAuthorized
  rw [any_perm h, any_perm h]

/--
  THEOREM 12 (Biscuit Monotonic Attenuation — Non-Escalation):
  Attenuating a Capability with ANY extra caveat can ONLY restrict (never widen) access:
  if the attenuated capability allows `(a, r)`, then the parent capability already allowed `(a, r)`.
-/
theorem attenuation_monotonic (cap : Capability) (extra : AttrExpr) (a : String) (r : Entity) :
    (cap.attenuate extra).allows a r = true → cap.allows a r = true := by
  unfold Capability.attenuate Capability.allows
  simp only [List.all_append, List.all_cons, List.all_nil, Bool.and_true, Bool.and_eq_true]
  intro ⟨hAct, hAll, _⟩
  exact ⟨hAct, hAll⟩

/--
  THEOREM 13 (Mechanical Blast-Radius Soundness & Completeness — ADR-0006 C1):
  For every resource `r ∈ allResources`, `r` is included in `blastRadius` IF AND ONLY IF
  `principal` is authorized to perform `action` on `r`. Zero missed secrets on device theft!
-/
theorem blast_radius_sound_and_complete
    (policies : List AuthPolicy) (p : Entity) (a : String) (allResources : List Entity)
    (r : Entity) (hr : r ∈ allResources) :
    r ∈ blastRadius policies p a allResources ↔ isAuthorized policies p a r = true := by
  unfold blastRadius
  simp [List.mem_filter, hr]

/--
  THEOREM 14 (Boolean Set-Algebra Inclusion/Exclusion Law):
  `diff(A, B)` holds iff `A` holds and `B` does NOT hold — guaranteeing exclusions strictly block access.
-/
theorem attr_diff_excludes (tags : List String) (e1 e2 : AttrExpr) :
    (AttrExpr.diff e1 e2).eval tags = true ↔ (e1.eval tags = true ∧ e2.eval tags = false) := by
  simp [AttrExpr.eval]

end NixconfFoundation
