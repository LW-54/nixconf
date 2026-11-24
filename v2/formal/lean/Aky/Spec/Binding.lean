/-
  Aky.Spec.Binding — Layer 1 Executable Specification (100% Usage-Agnostic, NO PROOFS)
  Unified B3 Scoped Binding (Exclusive, Broadcast, Partitioned via shared `AttrExpr`,
  Budgeted Capacity with Priority Tiers), Soft Conditional Law, Multi-Stratum
  Stratified Handler Resolution, and Recursive Non-Piercing `Agent` Tree Verification!
-/

import Aky.Data.AttrExpr
import Aky.Spec.Agency
import Aky.Spec.Invariants

namespace Aky.Spec

open Aky.Data

inductive BindingError where
  | missingExclusiveProvider   (ptype key : String)
  | ambiguousExclusiveConflict (ptype key : String) (count : Nat)
  | missingBroadcastProvider   (ptype : String)
  | partitionedRouteConflict   (ptype key : String) (count : Nat)
  | partitionedSelectorOverlap (ptype key : String) (count : Nat)
  | unhandledPartitionedOffer  (ptype key : String)
  | budgetExceeded             (ptype : String) (demand supply : Nat)
  | criticalTierExceeded       (ptype : String) (critDemand supply : Nat)
  | incompleteSoftPromise      (promiseId : String)
  | stratumOrderViolation      (ruleId : String) (inputStratum outputStratum : Nat)
  deriving Repr, DecidableEq, BEq

/-- A Handler rule consuming promises from stratum `inStratum` and emitting derived promises at `outStratum`. -/
structure HandlerRule where
  id            : String
  inStratum     : Nat
  outStratum    : Nat
  emitted       : List Promise
  deriving Repr, DecidableEq, BEq

def countMatchingOffers (ps : List Promise) (ptype key : String) : Nat :=
  (ps.filter (fun p => p.polarity == Polarity.offer && p.ptype == ptype && p.key == key)).length

def countMatchingBroadcastOffers (ps : List Promise) (ptype : String) : Nat :=
  (ps.filter (fun p => p.polarity == Polarity.offer && p.ptype == ptype)).length

/-- Diagnostic validation of a single promise against full scope promise multiset. -/
def checkPromise (allPs : List Promise) (p : Promise) : List BindingError :=
  let softErrs :=
    match p.strength with
    | Strength.soft =>
      match p.softInfo with
      | some sc => if sc.isComplete then [] else [BindingError.incompleteSoftPromise p.id]
      | none    => [BindingError.incompleteSoftPromise p.id]
    | Strength.hard => []
  let cardErrs :=
    match p.cardinality, p.polarity, p.strength, p.mandatory with
    | Cardinality.exclusive, Polarity.use, Strength.hard, true =>
      let n := countMatchingOffers allPs p.ptype p.key
      if n == 0 then [BindingError.missingExclusiveProvider p.ptype p.key]
      else if n > 1 then [BindingError.ambiguousExclusiveConflict p.ptype p.key n]
      else []
    | Cardinality.exclusive, Polarity.offer, _, _ =>
      let n := countMatchingOffers allPs p.ptype p.key
      if n > 1 then [BindingError.ambiguousExclusiveConflict p.ptype p.key n] else []
    | Cardinality.broadcast, Polarity.use, Strength.hard, true =>
      let n := countMatchingBroadcastOffers allPs p.ptype
      if n == 0 then [BindingError.missingBroadcastProvider p.ptype] else []
    | Cardinality.partitioned, Polarity.offer, _, _ =>
      let keyDup := countMatchingOffers allPs p.ptype p.key
      let keyErr := if keyDup > 1 then [BindingError.partitionedRouteConflict p.ptype p.key keyDup] else []
      let selHits := countMatchingPartitionHandlers allPs p.ptype p.tags
      let selErr := if selHits > 1 then [BindingError.partitionedSelectorOverlap p.ptype p.key selHits] else []
      let mandErr :=
        if p.strength == Strength.hard && p.mandatory && selHits == 0 then
          [BindingError.unhandledPartitionedOffer p.ptype p.key]
        else []
      keyErr ++ selErr ++ mandErr
    | Cardinality.budgeted, Polarity.use, _, _ =>
      let dem := totalBudgetDemand allPs p.ptype
      let sup := totalBudgetSupply allPs p.ptype
      let crit := criticalBudgetDemand allPs p.ptype
      let e1 := if dem > sup then [BindingError.budgetExceeded p.ptype dem sup] else []
      let e2 := if crit > sup then [BindingError.criticalTierExceeded p.ptype crit sup] else []
      e1 ++ e2
    | _, _, _, _ => []
  softErrs ++ cardErrs

/-- Structured scope validation returning all diagnostic errors (`[]` iff valid). -/
def validateScope (ps : List Promise) : List BindingError :=
  ps.flatMap (checkPromise ps)

def isScopeValid (ps : List Promise) : Bool :=
  ps.all (fun p => (checkPromise ps p).isEmpty)

/--
  Project exterior `-b` uses into inbound `+b` supplies inside a Dressed Superagent's scope.
-/
def inboundFromExterior (ext : ExteriorSurface) : List Promise :=
  ext.promises.filterMap fun p =>
    match p.polarity with
    | Polarity.use =>
      some { p with
        id := s!"{ext.agentId}:inbound:{p.id}"
        polarity := Polarity.offer
        stratum := 0
      }
    | Polarity.offer => none

/--
  Dual projection: for every `Partitioned` `ptype` re-exported on `ext`, synthesize ONE
  non-overlapping outbound `-b` sink whose selector is the complement of all internal handlers
  of that `ptype` (`⋂ ¬h.selector`), discharging forwarded mandatory offers cleanly!
-/
def outboundFromExterior (ext : ExteriorSurface) (intPs : List Promise) : List Promise :=
  let exported : List Promise :=
    ext.promises.filter (fun (p : Promise) => p.polarity == Polarity.offer && p.cardinality == Cardinality.partitioned)
  let exportedPtypes : List String := (exported.map (·.ptype)).eraseDups
  exportedPtypes.map fun pt =>
    let intHandlers : List Promise :=
      intPs.filter (fun (h : Promise) =>
        h.polarity == Polarity.use &&
        h.cardinality == Cardinality.partitioned &&
        h.ptype == pt)
    let notHandled :=
      intHandlers.foldl (fun acc h => AttrExpr.inter acc (AttrExpr.compl h.selector)) AttrExpr.any
    {
      id := s!"{ext.agentId}:outbound:{pt}"
      ptype := pt
      key := pt
      polarity := Polarity.use
      strength := Strength.hard
      cardinality := Cardinality.partitioned
      mandatory := false
      amount := 0
      priority := 0
      stratum := 0
      tags := []
      selector := notHandled
      softInfo := none
    }

/-
  Recursive Fractal Uniform Agent Tree Verifier (100% Usage-Agnostic TCB):
  Verifies EVERY node in an arbitrary-depth `Agent` tree strictly without piercing:
    1. All declarative `PromiseInvariant` rules hold on this node's exterior promises.
    2. For a Superagent: `checkSuperagentConformance ext children = []` AND
       `isScopeValid (inboundFromExterior ext ++ outboundFromExterior ext intPs ++ intPs) = true`.
    3. Recursively holds for every child `Agent`.
-/
mutual
  def checkAgentTree (invs : List PromiseInvariant) : Agent -> Bool
    | Agent.atomic ext _ =>
      allInvariantsHold invs ext.promises
    | Agent.superagent ext children =>
      let intPs := (siblingOperationalView children).flatMap (·.promises)
      let scopePs := inboundFromExterior ext ++ outboundFromExterior ext intPs ++ intPs
      allInvariantsHold invs ext.promises &&
      (checkSuperagentConformance ext children).isEmpty &&
      isScopeValid scopePs &&
      checkAgentTreeList invs children
    | Agent.profile ms =>
      checkAgentTreeList invs ms

  def checkAgentTreeList (invs : List PromiseInvariant) : List Agent -> Bool
    | [] => true
    | a :: rest => checkAgentTree invs a && checkAgentTreeList invs rest
end

/-- Multi-Stratum Stratified Evaluation (ADR-0003 Strict Stratification). -/
def validateStratumRules (rules : List HandlerRule) : List BindingError :=
  rules.filterMap fun r =>
    if r.inStratum < r.outStratum && r.emitted.all (fun p => p.stratum == r.outStratum) then
      none
    else
      some (BindingError.stratumOrderViolation r.id r.inStratum r.outStratum)

def evalStratified (rules : List HandlerRule) (base : List Promise) : Nat -> List Promise
  | 0     => base
  | k + 1 =>
    let prev := evalStratified rules base k
    let fired := (rules.filter (fun r => r.outStratum == k + 1)).flatMap (·.emitted)
    prev ++ fired

end Aky.Spec
