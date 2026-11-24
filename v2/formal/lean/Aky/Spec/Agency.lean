/-
  Aky.Spec.Agency — Layer 1 Executable Specification (NO PROOFS)
  Fractal Uniform Agency (ADR-0002), P-Dual (ADR-0003), Boundary-First Stratification (C2),
  P-Explicit Interior Conformance (Gap #1 closed), Standalone Scope (X4), Epistemic Zoom (C5).
-/

import Aky.Data.AttrExpr

namespace Aky.Spec

open Aky.Data

inductive Polarity where
  | offer -- +b
  | use   -- -b
  deriving Repr, DecidableEq, BEq

inductive Strength where
  | hard  -- Build/closure/cryptographic invariant (binary calibration)
  | soft  -- Runtime conditional (+b | C), assessed continuously via alpha
  deriving Repr, DecidableEq, BEq

inductive Cardinality where
  | exclusive   -- 1:1 unique provider (0 -> missing, >1 -> conflict)
  | broadcast   -- 1:N 0..N commutative observers
  | partitioned -- N:K routed by disjoint AttrExpr predicates on promise tags
  | budgeted    -- Additive quantitative capacity (sum demands <= supply) + priority tier
  deriving Repr, DecidableEq, BEq

structure SoftContract where
  conditionRef : String
  degradedMode : String
  probeId      : String
  deriving Repr, DecidableEq, BEq

def SoftContract.isComplete (sc : SoftContract) : Bool :=
  !sc.conditionRef.isEmpty && !sc.degradedMode.isEmpty && !sc.probeId.isEmpty

structure Promise where
  id            : String
  ptype         : String               -- Promise type tau (e.g. "secret", "http-endpoint", "ram-mb")
  key           : String               -- Commutative merge / unique key
  polarity      : Polarity
  strength      : Strength
  cardinality   : Cardinality
  mandatory     : Bool                 -- For use (-b): true -> must be satisfied in closed root
  amount        : Nat                  -- For budgeted: supply (+b) or demand (-b)
  priority      : Nat := 1             -- For budgeted: 0 = critical-edge, 1 = core, 2 = ai, 3 = obs
  stratum       : Nat := 0             -- Strict stratification level (S0 -> S1 -> S2 -> ...)
  tags          : List String := []    -- Expressed tags for B3 Partitioned AttrExpr routing
  selector      : AttrExpr := AttrExpr.any -- Partition/disambiguation predicate for providers
  softInfo      : Option SoftContract := none
  deriving Repr, DecidableEq, BEq

/-- Exterior Promise Surface (Pi_ext): The ONLY surface observable across Boundary Sigma. -/
structure ExteriorSurface where
  agentId    : String
  promises   : List Promise
  attributes : List String
  deriving Repr, DecidableEq, BEq

/--
  Fractal Uniform Agent (ADR-0002) with P-Dual (ADR-0003):
  - `atomic`: opaque interior (binary, hardware quirk, foreign NixOS wrapper, human, AI, SaaS).
  - `superagent`: Opaque encapsulation boundary `Sigma` with explicit `exterior` (Pi_ext).
  - `profile`: Transparent reusable Agent Set (NOT a boundary) flattened into enclosing scope.
-/
inductive Agent where
  | atomic     (ext : ExteriorSurface) (interiorHash : String)
  | superagent (ext : ExteriorSurface) (children : List Agent)
  | profile    (members : List Agent)
  deriving Repr, BEq

inductive BoundaryError where
  | unbackedExteriorOffer   (superagentId ptype key : String)
  | leakedInteriorUse       (superagentId ptype key : String)
  deriving Repr, DecidableEq, BEq

/-- Flatten transparent Profiles while halting strictly at opaque Boundaries. -/
def flattenScope : List Agent -> List Agent
  | [] => []
  | Agent.profile ms :: rest => flattenScope ms ++ flattenScope rest
  | a :: rest => a :: flattenScope rest

/--
  Boundary-First Exterior Projection (ADR-0006 C2: Pi_ext ⊥ Interior):
  Reads ONLY an agent's exterior surface without ever inspecting interior children!
-/
def exteriorOf : Agent -> List ExteriorSurface
  | Agent.atomic ext _     => [ext]
  | Agent.superagent ext _ => [ext]
  | Agent.profile ms       => ms.flatMap exteriorOf

/-- Operational view seen by external siblings inside a parent Superagent's scope. -/
def siblingOperationalView (siblings : List Agent) : List ExteriorSurface :=
  siblings.flatMap exteriorOf

def isMandatoryHardUse (p : Promise) : Bool :=
  match p.polarity, p.strength, p.mandatory with
  | Polarity.use, Strength.hard, true => true
  | _, _, _                           => false

/--
  P-Explicit Interior Conformance Validator (Gap #1 CLOSED!):
  Checks that a Dressed Superagent's `Interior(children)` faithfully backs its declared `Pi_ext`:
    1. No lying offers: every `+b` promise exported in `ext` must be offered by some interior child.
    2. No leaked requirements: every mandatory hard `-b` inside `children` that is NOT satisfied
       internally by a sibling offer MUST be explicitly declared as a `-b` in `ext`.
-/
def hasOffer (ps : List Promise) (ptype key : String) : Bool :=
  ps.any (fun p => p.polarity == Polarity.offer && p.ptype == ptype && p.key == key)

def hasUse (ps : List Promise) (ptype key : String) : Bool :=
  ps.any (fun p => p.polarity == Polarity.use && p.ptype == ptype && p.key == key)

def checkSuperagentConformance (ext : ExteriorSurface) (children : List Agent) : List BoundaryError :=
  let intPs := (siblingOperationalView children).flatMap (·.promises)
  let offerErrs :=
    ext.promises.filterMap fun p =>
      match p.polarity with
      | Polarity.offer =>
        if hasOffer intPs p.ptype p.key then none
        else some (BoundaryError.unbackedExteriorOffer ext.agentId p.ptype p.key)
      | Polarity.use => none
  let useErrs :=
    intPs.filterMap fun p =>
      if isMandatoryHardUse p && !hasOffer intPs p.ptype p.key then
        if hasUse ext.promises p.ptype p.key then none
        else some (BoundaryError.leakedInteriorUse ext.agentId p.ptype p.key)
      else none
  offerErrs ++ useErrs

/-- Scope-Emergent Standalone Check (X4): satisfiable in minimal store-only Standalone Superagent. -/
def checkStandalone (ext : ExteriorSurface) : Bool :=
  ext.promises.all (fun p => !isMandatoryHardUse p || p.ptype == "store-pkg")

/- Authorized Epistemic Zoom (C5): read-only CONTAINS traversal with zero operational coupling. -/
mutual
  def epistemicZoomIds : Agent -> List String
    | Agent.atomic ext _      => [ext.agentId]
    | Agent.superagent ext cs => ext.agentId :: epistemicZoomIdsList cs
    | Agent.profile ms        => epistemicZoomIdsList ms

  def epistemicZoomIdsList : List Agent -> List String
    | [] => []
    | a :: rest => epistemicZoomIds a ++ epistemicZoomIdsList rest
end

end Aky.Spec
