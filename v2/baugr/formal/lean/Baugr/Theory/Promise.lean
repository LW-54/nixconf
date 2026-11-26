/-
  Baugr.Theory.Promise — Pure Burgess & Bergstra Promise Theory Foundation (F-5)
  100% Universal, Zero Engine Policy, Zero Cedar, Zero Nix/Linux/Domain Strings!

  Formalizes:
    - Autonomous Agents & Fractal Uniform Agency (`Agent = atomic | superagent | profile`)
    - Voluntary Polarity (`+b` Offer vs. `-b` Use) & Autonomy / Imposition Rejection
    - Conditional Promises (`+b | C` via `Strength.soft` + `SoftContract`)
    - Boundary-First Non-Piercing Exterior Projection (`Π_ext ⊥ Interior`)
    - Operadic Profile Flattening (`flattenScope`) & Read-Only Epistemic Zoom (`epistemicZoomIds`)
-/

import Baugr.Data.AttrExpr

namespace Baugr.Theory

open Baugr.Data

/-- Burgess Promise Polarity: `+b` (autonomous offer) vs. `-b` (autonomous acceptance/use). -/
inductive Polarity where
  | offer -- +b
  | use   -- -b
  deriving Repr, DecidableEq, BEq

/-- Promise Strength: static invariant (`hard`) vs. runtime conditional (`soft`: `+b | C`). -/
inductive Strength where
  | hard
  | soft
  deriving Repr, DecidableEq, BEq

/-- Scope binding cardinality semantics (`B3`). -/
inductive Cardinality where
  | exclusive   -- 1:1 unique provider per (ptype, key)
  | broadcast   -- M:N commutative pub-sub fan-out with AttrExpr filtering
  | partitioned -- N:K disjoint AttrExpr routing
  | budgeted    -- Additive quantitative conservation + priority tier
  deriving Repr, DecidableEq, BEq

/-- Mandatory completeness payload for a conditional promise (`+b | C`). -/
structure SoftContract where
  conditionRef : String
  degradedMode : String
  probeId      : String
  deriving Repr, DecidableEq, BEq

def SoftContract.isComplete (sc : SoftContract) : Bool :=
  !sc.conditionRef.isEmpty && !sc.degradedMode.isEmpty && !sc.probeId.isEmpty

/-- A typed Promise Theory statement inside a scope. -/
structure Promise where
  id            : String
  ptype         : String
  key           : String
  polarity      : Polarity
  strength      : Strength
  cardinality   : Cardinality
  mandatory     : Bool
  amount        : Nat
  priority      : Nat := 1
  stratum       : Nat := 0
  tags          : List String := []
  selector      : AttrExpr := AttrExpr.any
  softInfo      : Option SoftContract := none
  deriving Repr, DecidableEq, BEq

/--
  Burgess Autonomy Axiom (Imposition Rejection):
  A statement emitted by `speaker` about `subject`'s behavior is a valid autonomous Promise
  ONLY when `speaker == subject`; any statement trying to command another agent (`speaker ≠ subject`)
  is an invalid Imposition!
-/
structure BehavioralClaim where
  speaker : String
  subject : String
  promise : Promise
  deriving Repr, DecidableEq, BEq

def BehavioralClaim.isAutonomousPromise (c : BehavioralClaim) : Bool :=
  c.speaker == c.subject

/-- Two autonomous claims cooperate voluntarily iff one offers (`+b`) and the other accepts (`-b`) on the same `(ptype, key)`. -/
def cooperatesVoluntarily (c1 c2 : BehavioralClaim) : Bool :=
  c1.isAutonomousPromise &&
  c2.isAutonomousPromise &&
  c1.promise.polarity == Polarity.offer &&
  c2.promise.polarity == Polarity.use &&
  c1.promise.ptype == c2.promise.ptype &&
  c1.promise.key == c2.promise.key

/-- Exterior Promise Surface (`Π_ext`): the ONLY surface observable across boundary `Σ`. -/
structure ExteriorSurface where
  agentId    : String
  promises   : List Promise
  attributes : List String
  deriving Repr, DecidableEq, BEq

/--
  Fractal Uniform Agent:
    - `atomic`: opaque leaf with content hash.
    - `superagent`: opaque encapsulation boundary `Σ` with explicit exterior `Π_ext`.
    - `profile`: transparent reusable Agent set (NOT a boundary) flattened into enclosing scope.
-/
inductive Agent where
  | atomic     (ext : ExteriorSurface) (interiorHash : String)
  | superagent (ext : ExteriorSurface) (children : List Agent)
  | profile    (members : List Agent)
  deriving Repr, BEq

/-- Flatten transparent Profiles while halting strictly at opaque Boundaries `Σ`. -/
def flattenScope : List Agent -> List Agent
  | [] => []
  | Agent.profile ms :: rest => flattenScope ms ++ flattenScope rest
  | a :: rest => a :: flattenScope rest

/--
  Boundary-First Exterior Projection (`Π_ext ⊥ Interior`):
  Reads ONLY an agent's exterior surface without ever inspecting interior children!
-/
def exteriorOf : Agent -> List ExteriorSurface
  | Agent.atomic ext _     => [ext]
  | Agent.superagent ext _ => [ext]
  | Agent.profile ms       => ms.flatMap exteriorOf

/-- Operational view seen by external siblings inside a parent Superagent's scope. -/
def siblingOperationalView (siblings : List Agent) : List ExteriorSurface :=
  siblings.flatMap exteriorOf

/- Read-only Epistemic Zoom (`CONTAINS` traversal with zero operational coupling). -/
mutual
  def epistemicZoomIds : Agent -> List String
    | Agent.atomic ext _      => [ext.agentId]
    | Agent.superagent ext cs => ext.agentId :: epistemicZoomIdsList cs
    | Agent.profile ms        => epistemicZoomIdsList ms

  def epistemicZoomIdsList : List Agent -> List String
    | [] => []
    | a :: rest => epistemicZoomIds a ++ epistemicZoomIdsList rest
end

end Baugr.Theory
