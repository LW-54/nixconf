/-
  Aky.Spec.Binding — Layer 1 Executable Specification (NO PROOFS)
  Unified B3 Scoped Binding (Exclusive, Broadcast, Partitioned via shared `AttrExpr`,
  Budgeted Capacity with Priority Tiers), Soft Conditional Law, and Multi-Stratum
  Stratified Handler Resolution (Gap #2 CLOSED!).
-/

import Aky.Data.AttrExpr
import Aky.Spec.Agency

namespace Aky.Spec

open Aky.Data

inductive BindingError where
  | missingExclusiveProvider   (ptype key : String)
  | ambiguousExclusiveConflict (ptype key : String) (count : Nat)
  | partitionedRouteConflict   (ptype key : String) (count : Nat)
  | partitionedSelectorOverlap (ptype key : String) (count : Nat)
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

/-- Count partitioned providers whose `AttrExpr` selector matches a given offer's tags (B3). -/
def countMatchingPartitionHandlers (ps : List Promise) (ptype : String) (offerTags : List String) : Nat :=
  (ps.filter (fun h =>
    h.polarity == Polarity.use &&
    h.cardinality == Cardinality.partitioned &&
    h.ptype == ptype &&
    h.selector.eval offerTags)).length

def totalBudgetSupply (ps : List Promise) (ptype : String) : Nat :=
  List.foldl (fun acc p => acc + p.amount) 0
    (ps.filter (fun p => p.polarity == Polarity.offer && p.cardinality == Cardinality.budgeted && p.ptype == ptype))

def totalBudgetDemand (ps : List Promise) (ptype : String) : Nat :=
  List.foldl (fun acc p => acc + p.amount) 0
    (ps.filter (fun p => p.polarity == Polarity.use && p.cardinality == Cardinality.budgeted && p.ptype == ptype))

/-- Sum of critical-tier (`priority == 0`, e.g. Vaultwarden/Caddy) budgeted demands (C4 OOM protection). -/
def criticalBudgetDemand (ps : List Promise) (ptype : String) : Nat :=
  List.foldl (fun acc p => acc + p.amount) 0
    (ps.filter (fun p => p.polarity == Polarity.use && p.cardinality == Cardinality.budgeted && p.ptype == ptype && p.priority == 0))

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
    | Cardinality.partitioned, Polarity.offer, _, _ =>
      let keyDup := countMatchingOffers allPs p.ptype p.key
      let keyErr := if keyDup > 1 then [BindingError.partitionedRouteConflict p.ptype p.key keyDup] else []
      let selHits := countMatchingPartitionHandlers allPs p.ptype p.tags
      let selErr := if selHits > 1 then [BindingError.partitionedSelectorOverlap p.ptype p.key selHits] else []
      keyErr ++ selErr
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
  Multi-Stratum Stratified Evaluation (ADR-0003 Strict Stratification — Gap #2 CLOSED!):
  Every handler rule MUST strictly increase stratum (`inStratum < outStratum`) and tag every
  emitted derived promise with `outStratum`. Bounded recursion over `maxStratum` is guaranteed
  to terminate deterministically without fixed-point cycles!
-/
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
