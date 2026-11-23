/-
  NixconfFoundation.Agency
  Formalization of ADR-0002 (Model A: Fractal Uniform Agency & Non-Piercing Superagent Boundaries)
  and ADR-0006 Corollaries C2 (Boundary-First Stratification), C5 (Epistemic Zoom), C6 (Standalone).

  Pure Lean 4 core (zero Mathlib dependencies). Every theorem is machine-checked without `sorry`.
-/

namespace NixconfFoundation

inductive Polarity where
  | offer -- +b
  | use   -- -b
  deriving Repr, DecidableEq, BEq

inductive Strength where
  | hard  -- Verified statically/cryptographically (binary calibration)
  | soft  -- Runtime conditional (+b | C), assessed continuously via alpha
  deriving Repr, DecidableEq, BEq

inductive Cardinality where
  | exclusive   -- 1:1 unique provider; 0 -> missing, >1 -> conflict
  | broadcast   -- 1:N 0..N commutative observers
  | partitioned -- N:K disjoint route keys; overlap -> conflict
  | budgeted    -- Additive quantitative capacity (sum demands <= supply)
  deriving Repr, DecidableEq, BEq

structure SoftContract where
  conditionRef  : String
  degradedMode  : String
  probeId       : String
  deriving Repr, DecidableEq, BEq

def SoftContract.isComplete (sc : SoftContract) : Bool :=
  !sc.conditionRef.isEmpty && !sc.degradedMode.isEmpty && !sc.probeId.isEmpty

structure Promise where
  id          : String
  ptype       : String       -- Promise type tau (e.g., "secret", "http-endpoint", "ram-mb")
  key         : String       -- Commutative merge / partition key
  polarity    : Polarity
  strength    : Strength
  cardinality : Cardinality
  mandatory   : Bool         -- For use (-b): true -> must be satisfied in closed root
  amount      : Nat          -- For budgeted capacity: supply (+b) or demand (-b)
  softInfo    : Option SoftContract := none
  deriving Repr, DecidableEq, BEq

/-- Exterior Promise Surface (Pi_ext): The ONLY surface observable across a Boundary Sigma. -/
structure ExteriorSurface where
  agentId    : String
  promises   : List Promise
  attributes : List String   -- Expressed SST attributes / groups for L3+ Boolean lattice
  deriving Repr, DecidableEq, BEq

/--
  Fractal Uniform Agent (ADR-0002) with P-Dual (ADR-0003):
  - `atomic`: opaque interior (binary, hardware quirk, foreign NixOS wrapper, human, AI, SaaS).
  - `superagent`: Dressed Superagent with explicit opaque boundary `exterior` (Pi_ext)
                  enclosing interior children.
  - `profile`: Transparent Agent Set (NOT a boundary Sigma) flattened directly into parent scope.
-/
inductive Agent where
  | atomic     (ext : ExteriorSurface) (interiorHash : String)
  | superagent (ext : ExteriorSurface) (children : List Agent)
  | profile    (members : List Agent)
  deriving Repr, BEq

/-- Flatten transparent Profiles while halting strictly at opaque Boundaries (atomic / superagent). -/
def flattenScope : List Agent -> List Agent
  | [] => []
  | Agent.profile ms :: rest => flattenScope ms ++ flattenScope rest
  | a :: rest => a :: flattenScope rest

/--
  Boundary-First Exterior Projection (ADR-0006 C2: Pi_ext ⊥ Interior):
  Reads ONLY an agent's exterior surface without ever inspecting or recursing into interior children!
-/
def exteriorOf : Agent -> List ExteriorSurface
  | Agent.atomic ext _      => [ext]
  | Agent.superagent ext _  => [ext]
  | Agent.profile ms        => ms.flatMap exteriorOf

/-- The operational view seen by any sibling inside a parent Superagent's scope. -/
def siblingOperationalView (siblings : List Agent) : List ExteriorSurface :=
  siblings.flatMap exteriorOf

/--
  THEOREM 1 (Operadic Associativity of Transparent Profiles — P-Dual):
  Grouping sibling agents inside nested transparent Profiles produces the exact same
  flattened scope list as flat concatenation.
-/
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

/--
  THEOREM 2 (Boundary-First Stratification — ADR-0006 C2):
  Computing `exteriorOf` of a Dressed Superagent is strictly invariant under ANY replacement
  of its interior children `{A_i} -> {A'_i}` so long as `Pi_ext` is preserved.
-/
theorem boundary_first_stratification (ext : ExteriorSurface) (cs1 cs2 : List Agent) :
    exteriorOf (Agent.superagent ext cs1) = exteriorOf (Agent.superagent ext cs2) := by
  simp [exteriorOf]

/--
  THEOREM 3 (Non-Piercing Interior Substitution — Crown Jewel of ADR-0002 + Nix Cache Isolation):
  Replacing the entire interior of any Dressed Superagent `S` (e.g., swapping Grafana -> Perses
  inside Observability, or changing x240's kernel/packages) while preserving `Pi_ext(S)` leaves
  the operational view observed by ALL external siblings strictly identical!
  Corollary: zero cascading external edits (Parnas) AND zero cross-host Nix cache invalidation (T5).
-/
theorem non_piercing_interior_substitution
    (pre post : List Agent) (ext : ExteriorSurface) (cs1 cs2 : List Agent) :
    siblingOperationalView (pre ++ [Agent.superagent ext cs1] ++ post) =
    siblingOperationalView (pre ++ [Agent.superagent ext cs2] ++ post) := by
  simp [siblingOperationalView, exteriorOf]

/--
  THEOREM 4 (Scope-Emergent Standalone Portability — ADR-0002 + X4):
  Define the minimal `Standalone` ambient scope as offering ONLY store-package promises (`ptype == "store-pkg"`).
  An agent's mandatory hard use-promises are all satisfiable in Standalone scope IF AND ONLY IF
  every mandatory hard use-promise it emits has `ptype == "store-pkg"`.
-/
def isMandatoryHardUse (p : Promise) : Bool :=
  p.polarity == Polarity.use && p.strength == Strength.hard && p.mandatory

def standaloneSatisfiable (ext : ExteriorSurface) : Prop :=
  ∀ p ∈ ext.promises, isMandatoryHardUse p = true → p.ptype = "store-pkg"

def checkStandalone (ext : ExteriorSurface) : Bool :=
  ext.promises.all (fun p => !isMandatoryHardUse p || p.ptype == "store-pkg")

theorem checkStandalone_sound_and_complete (ext : ExteriorSurface) :
    checkStandalone ext = true ↔ standaloneSatisfiable ext := by
  unfold checkStandalone standaloneSatisfiable
  simp only [List.all_eq_true, Bool.or_eq_true, Bool.not_eq_true', beq_iff_eq]
  constructor
  · intro h p hp hmand
    have hp' := h p hp
    cases hp' with
    | inl hfalse => rw [hmand] at hfalse; contradiction
    | inr hpkg => exact hpkg
  · intro h p hp
    by_cases hmand : isMandatoryHardUse p = true
    · exact Or.inr (h p hp hmand)
    · have hfalse : isMandatoryHardUse p = false := by
        cases hval : isMandatoryHardUse p <;> simp_all
      exact Or.inl hfalse

/-
  Authorized Epistemic Zoom (ADR-0006 C5):
  Read-only diagnostic traversal collects all descendant agent IDs across CONTAINS without
  modifying or expanding `siblingOperationalView` (zero operational reverse dependency).
-/
mutual
  def epistemicZoomIds : Agent -> List String
    | Agent.atomic ext _     => [ext.agentId]
    | Agent.superagent ext cs => ext.agentId :: epistemicZoomIdsList cs
    | Agent.profile ms       => epistemicZoomIdsList ms

  def epistemicZoomIdsList : List Agent -> List String
    | [] => []
    | a :: rest => epistemicZoomIds a ++ epistemicZoomIdsList rest
end

end NixconfFoundation
