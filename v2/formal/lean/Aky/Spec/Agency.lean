/-
  Aky.Spec.Agency — Layer 1 Executable Specification (100% Usage-Agnostic, NO PROOFS)
  Fractal Uniform Agency (ADR-0002), P-Dual (ADR-0003), Boundary-First Stratification (C2),
  P-Explicit Interior Conformance (Offers, Uses, Mandatory Partitioned Offers, Budgets),
  Scope-Emergent Composition (X4), and Epistemic Zoom (C5).
-/

import Aky.Data.AttrExpr

namespace Aky.Spec

open Aky.Data

inductive Polarity where
  | offer -- +b
  | use   -- -b
  deriving Repr, DecidableEq, BEq

inductive Strength where
  | hard  -- Statically/cryptographically enforced invariant
  | soft  -- Runtime conditional (+b | C), assessed continuously via alpha
  deriving Repr, DecidableEq, BEq

inductive Cardinality where
  | exclusive   -- 1:1 unique provider (0 -> missing, >1 -> conflict)
  | broadcast   -- 1:N commutative providers (mandatory use requires >= 1)
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
  ptype         : String               -- Promise contract type tau
  key           : String               -- Commutative merge / unique key
  polarity      : Polarity
  strength      : Strength
  cardinality   : Cardinality
  mandatory     : Bool                 -- For use (-b) or partitioned offer (+b): must bind in closed scope
  amount        : Nat                  -- For budgeted: supply (+b) or demand (-b)
  priority      : Nat := 1             -- For budgeted: 0 = critical survival tier, >0 = non-critical
  stratum       : Nat := 0             -- Strict stratification level
  tags          : List String := []    -- Expressed tags for Partitioned routing & Invariant rules
  selector      : AttrExpr := AttrExpr.any -- Partition predicate for consumers
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
  - `atomic`: opaque interior.
  - `superagent`: Opaque encapsulation boundary `Sigma` with explicit `exterior` (Pi_ext).
  - `profile`: Transparent reusable Agent Set (NOT a boundary) flattened into enclosing scope.
-/
inductive Agent where
  | atomic     (ext : ExteriorSurface) (interiorHash : String)
  | superagent (ext : ExteriorSurface) (children : List Agent)
  | profile    (members : List Agent)
  deriving Repr, BEq

inductive BoundaryError where
  | unbackedExteriorOffer       (superagentId ptype key : String)
  | leakedInteriorUse           (superagentId ptype key : String)
  | droppedMandatoryOffer       (superagentId ptype key : String)
  | underreportedBudget         (superagentId ptype : String) (extPlusIntSupply intDemand : Nat)
  | underreportedCriticalBudget (superagentId ptype : String) (extCritPlusIntSupply intCritDemand : Nat)
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

def isMandatoryHardPartitionedOffer (p : Promise) : Bool :=
  match p.polarity, p.strength, p.cardinality, p.mandatory with
  | Polarity.offer, Strength.hard, Cardinality.partitioned, true => true
  | _, _, _, _                                                   => false

def sameTagSet (xs ys : List String) : Bool :=
  xs.all (fun x => ys.contains x) && ys.all (fun y => xs.contains y)

def hasOffer (ps : List Promise) (ptype key : String) : Bool :=
  ps.any (fun p => p.polarity == Polarity.offer && p.ptype == ptype && p.key == key)

def hasBackingOffer (ps : List Promise) (extOffer : Promise) : Bool :=
  match extOffer.cardinality with
  | Cardinality.partitioned =>
    ps.any (fun o =>
      o.polarity == Polarity.offer &&
      o.cardinality == Cardinality.partitioned &&
      o.ptype == extOffer.ptype &&
      o.key == extOffer.key &&
      sameTagSet o.tags extOffer.tags)
  | _ => hasOffer ps extOffer.ptype extOffer.key

def hasUse (ps : List Promise) (ptype key : String) : Bool :=
  ps.any (fun p => p.polarity == Polarity.use && p.ptype == ptype && p.key == key)

/-- Count partitioned consumers whose `AttrExpr` selector matches a given offer's tags (B3). -/
def countMatchingPartitionHandlers (ps : List Promise) (ptype : String) (offerTags : List String) : Nat :=
  (ps.filter (fun h =>
    h.polarity == Polarity.use &&
    h.cardinality == Cardinality.partitioned &&
    h.ptype == ptype &&
    h.selector.eval offerTags)).length

def isInternallySatisfied (intPs : List Promise) (p : Promise) : Bool :=
  match p.cardinality with
  | Cardinality.partitioned =>
    intPs.any (fun o =>
      o.polarity == Polarity.offer &&
      o.cardinality == Cardinality.partitioned &&
      o.ptype == p.ptype &&
      p.selector.eval o.tags)
  | Cardinality.broadcast =>
    intPs.any (fun o => o.polarity == Polarity.offer && o.ptype == p.ptype)
  | _ => hasOffer intPs p.ptype p.key

def totalBudgetSupply (ps : List Promise) (ptype : String) : Nat :=
  List.foldl (fun acc p => acc + p.amount) 0
    (ps.filter (fun p => p.polarity == Polarity.offer && p.cardinality == Cardinality.budgeted && p.ptype == ptype))

def totalBudgetDemand (ps : List Promise) (ptype : String) : Nat :=
  List.foldl (fun acc p => acc + p.amount) 0
    (ps.filter (fun p => p.polarity == Polarity.use && p.cardinality == Cardinality.budgeted && p.ptype == ptype))

def criticalBudgetDemand (ps : List Promise) (ptype : String) : Nat :=
  List.foldl (fun acc p => acc + p.amount) 0
    (ps.filter (fun p => p.polarity == Polarity.use && p.cardinality == Cardinality.budgeted && p.ptype == ptype && p.priority == 0))

/--
  P-Explicit Interior Conformance Validator (100% Domain-Agnostic):
  Verifies that a Dressed Superagent's `Interior(children)` faithfully backs its declared `Pi_ext`
  observing strictly `exteriorOf` of direct children:
    1. No lying offers: every `+b` in `ext` must be backed by an interior offer (preserving exact tags if partitioned).
    2. No leaked uses: every mandatory hard `-b` inside `children` not satisfied internally MUST be declared in `ext`.
    3. No dropped mandatory offers: every mandatory hard `Partitioned` `+b` inside `children` with 0 interior
       handlers MUST be re-exported in `ext` (preserving exact tags).
    4. Coarse-grained budget & critical-tier conservation: for every `Budgeted` `-b` in `children`,
       exterior demand + internal supply must cover total and critical-tier interior demands.
-/
def checkSuperagentConformance (ext : ExteriorSurface) (children : List Agent) : List BoundaryError :=
  let intPs := (siblingOperationalView children).flatMap (·.promises)
  let offerErrs :=
    ext.promises.filterMap fun p =>
      match p.polarity with
      | Polarity.offer =>
        if hasBackingOffer intPs p then none
        else some (BoundaryError.unbackedExteriorOffer ext.agentId p.ptype p.key)
      | Polarity.use => none
  let useErrs :=
    intPs.filterMap fun p =>
      if isMandatoryHardUse p && !isInternallySatisfied intPs p then
        if hasUse ext.promises p.ptype p.key then none
        else some (BoundaryError.leakedInteriorUse ext.agentId p.ptype p.key)
      else none
  let droppedOfferErrs :=
    intPs.filterMap fun p =>
      if isMandatoryHardPartitionedOffer p && countMatchingPartitionHandlers intPs p.ptype p.tags == 0 then
        if hasBackingOffer ext.promises p then none
        else some (BoundaryError.droppedMandatoryOffer ext.agentId p.ptype p.key)
      else none
  let budgetErrs :=
    intPs.flatMap fun p =>
      match p.polarity, p.cardinality with
      | Polarity.use, Cardinality.budgeted =>
        let intSup := totalBudgetSupply intPs p.ptype
        let intDem := totalBudgetDemand intPs p.ptype
        let intCrit := criticalBudgetDemand intPs p.ptype
        let extDem := totalBudgetDemand ext.promises p.ptype
        let extCrit := criticalBudgetDemand ext.promises p.ptype
        let e1 :=
          if extDem + intSup < intDem then
            [BoundaryError.underreportedBudget ext.agentId p.ptype (extDem + intSup) intDem]
          else []
        let e2 :=
          if extCrit + intSup < intCrit then
            [BoundaryError.underreportedCriticalBudget ext.agentId p.ptype (extCrit + intSup) intCrit]
          else []
        e1 ++ e2
      | _, _ => []
  offerErrs ++ useErrs ++ droppedOfferErrs ++ budgetErrs

/-- Scope-Emergent Portability (X4): an exterior closes inside ANY ambient scope `ambient` iff all mandatory uses satisfy. -/
def canComposeInScope (ambient ext : ExteriorSurface) : Bool :=
  ext.promises.all (fun p => !isMandatoryHardUse p || isInternallySatisfied ambient.promises p)

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
