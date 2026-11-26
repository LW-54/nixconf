/-
  Baugr.Engine.Binding — Unified B3 Scoped Binding, Cedar Structural Auth & Recursive Tree Verifier
  Closes F-3 (dead `HandlerRule` removed) & F-6 (`Agent.atomic` principal auth + tight tag-matched outbound sinks)!
-/

import Baugr.Data.AttrExpr
import Baugr.Theory.Promise
import Baugr.Engine.Conformance
import Baugr.Engine.Authority
import Baugr.Engine.Invariants

namespace Baugr.Engine

open Baugr.Data
open Baugr.Theory

inductive BindingError where
  | missingExclusiveProvider   (ptype key : String)
  | ambiguousExclusiveConflict (ptype key : String) (count : Nat)
  | missingBroadcastProvider   (ptype : String)
  | broadcastKeyConflict       (ptype key : String) (count : Nat)
  | unhandledBroadcastOffer    (ptype key : String)
  | partitionedRouteConflict   (ptype key : String) (count : Nat)
  | partitionedSelectorOverlap (ptype key : String) (count : Nat)
  | unhandledPartitionedOffer  (ptype key : String)
  | budgetExceeded             (ptype : String) (demand supply : Nat)
  | criticalTierExceeded       (ptype : String) (critDemand supply : Nat)
  | incompleteSoftPromise      (promiseId : String)
  deriving Repr, DecidableEq, BEq

/-- Usage-agnostic Cedar structural authorization binding (zero domain strings in core!). -/
structure AuthBinding where
  id              : String
  ptype           : String
  polarity        : Polarity := Polarity.use
  action          : String
  principalFilter : AttrExpr := AttrExpr.any
  deriving Repr, DecidableEq, BEq

inductive AuthBindingError where
  | unauthorizedPromise (bindingId principalId action promiseId key : String)
  deriving Repr, DecidableEq, BEq

def countMatchingOffers (ps : List Promise) (ptype key : String) : Nat :=
  (ps.filter (fun p => p.polarity == Polarity.offer && p.ptype == ptype && p.key == key)).length

def countMatchingBroadcastOffers (ps : List Promise) (ptype : String) (sel : AttrExpr) : Nat :=
  (ps.filter (fun p => p.polarity == Polarity.offer && p.ptype == ptype && sel.eval p.tags)).length

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
      let n := countMatchingBroadcastOffers allPs p.ptype p.selector
      if n == 0 then [BindingError.missingBroadcastProvider p.ptype] else []
    | Cardinality.broadcast, Polarity.offer, _, _ =>
      let keyDup := countMatchingOffers allPs p.ptype p.key
      let keyErr := if keyDup > 1 then [BindingError.broadcastKeyConflict p.ptype p.key keyDup] else []
      let selHits := countMatchingBroadcastHandlers allPs p.ptype p.tags
      let mandErr :=
        if p.strength == Strength.hard && p.mandatory && selHits == 0 then
          [BindingError.unhandledBroadcastOffer p.ptype p.key]
        else []
      keyErr ++ mandErr
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

/-- Structural Cedar `L3+` authorization validator for any principal Agent or Superagent. -/
def validateScopeAuth
    (policies : List AuthPolicy) (bindings : List AuthBinding)
    (principal : Entity) (ps : List Promise) : List AuthBindingError :=
  bindings.flatMap fun ab =>
    if ab.principalFilter.eval principal.tags then
      ps.filterMap fun p =>
        if p.ptype == ab.ptype && p.polarity == ab.polarity then
          let res : Entity := { id := p.key, tags := p.tags }
          if isAuthorized policies principal ab.action res then none
          else some (AuthBindingError.unauthorizedPromise ab.id principal.id ab.action p.id p.key)
        else none
    else []

def isScopeAuthValid
    (policies : List AuthPolicy) (bindings : List AuthBinding)
    (principal : Entity) (ps : List Promise) : Bool :=
  (validateScopeAuth policies bindings principal ps).isEmpty

/-- Project exterior `-b` uses into inbound `+b` supplies inside a Dressed Superagent's scope. -/
def inboundFromExterior (ext : ExteriorSurface) : List Promise :=
  ext.promises.filterMap fun p =>
    match p.polarity with
    | Polarity.use =>
      some { p with
        id := s!"{ext.agentId}:inbound:{p.id}"
        polarity := Polarity.offer
        mandatory := false
        stratum := 0
      }
    | Polarity.offer => none

/-- Disjunction of exact tag-conjunctions across a list of exported offers (F-6 tight outbound matching). -/
def unionTagsExpr (ps : List Promise) : AttrExpr :=
  ps.foldl (fun acc p => AttrExpr.union acc (exactTagsExpr p.tags)) AttrExpr.none

/--
  F-6 Tightened Dual Outbound Projection:
    1. For every `Partitioned` `ptype` exported on `ext`, synthesize ONE non-overlapping outbound `-b`
       sink whose selector matches strictly exported offer tag-sets not already handled internally.
    2. For every `Broadcast` `ptype` exported on `ext`, synthesize ONE outbound `Broadcast` `-b` sink
       matching strictly exported offer tag-sets (`unionTagsExpr`), never discharging unrelated interior offers!
-/
def outboundFromExterior (ext : ExteriorSurface) (intPs : List Promise) : List Promise :=
  let exportedPart : List Promise :=
    ext.promises.filter (fun (p : Promise) => p.polarity == Polarity.offer && p.cardinality == Cardinality.partitioned)
  let partPtypes : List String := (exportedPart.map (·.ptype)).eraseDups
  let partSinks := partPtypes.map fun pt =>
    let matchingExported := exportedPart.filter (fun p => p.ptype == pt)
    let intHandlers : List Promise :=
      intPs.filter (fun (h : Promise) =>
        h.polarity == Polarity.use &&
        h.cardinality == Cardinality.partitioned &&
        h.ptype == pt)
    let notHandled :=
      intHandlers.foldl (fun acc h => AttrExpr.inter acc (AttrExpr.compl h.selector)) AttrExpr.any
    {
      id := s!"{ext.agentId}:outbound:part:{pt}"
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
      selector := AttrExpr.inter notHandled (unionTagsExpr matchingExported)
      softInfo := none
    }
  let exportedBcast : List Promise :=
    ext.promises.filter (fun (p : Promise) => p.polarity == Polarity.offer && p.cardinality == Cardinality.broadcast)
  let bcastPtypes : List String := (exportedBcast.map (·.ptype)).eraseDups
  let bcastSinks := bcastPtypes.map fun pt =>
    let matchingExported := exportedBcast.filter (fun p => p.ptype == pt)
    {
      id := s!"{ext.agentId}:outbound:bcast:{pt}"
      ptype := pt
      key := pt
      polarity := Polarity.use
      strength := Strength.hard
      cardinality := Cardinality.broadcast
      mandatory := false
      amount := 0
      priority := 0
      stratum := 0
      tags := []
      selector := unionTagsExpr matchingExported
      softInfo := none
    }
  partSinks ++ bcastSinks

/-
  Recursive Fractal Uniform Agent Tree Verifier (100% Usage-Agnostic TCB):
    - `Agent.atomic`: verifies declarative invariants AND `isScopeAuthValid` (F-6 closed!).
    - `Agent.superagent`: verifies invariants, `P-Explicit` conformance, `B3` scope,
      structural Cedar auth on real interior promises `intPs`, and recursively every child.
    - `Agent.profile`: verifies every member recursively.
-/
mutual
  def checkAgentTree
      (invs : List PromiseInvariant) (policies : List AuthPolicy) (authBindings : List AuthBinding) : Agent -> Bool
    | Agent.atomic ext _ =>
      let principal : Entity := { id := ext.agentId, tags := ext.attributes }
      allInvariantsHold invs ext.promises &&
      isScopeAuthValid policies authBindings principal ext.promises
    | Agent.superagent ext children =>
      let intPs := (siblingOperationalView children).flatMap (·.promises)
      let scopePs := inboundFromExterior ext ++ outboundFromExterior ext intPs ++ intPs
      let principal : Entity := { id := ext.agentId, tags := ext.attributes }
      allInvariantsHold invs ext.promises &&
      (checkSuperagentConformance ext children).isEmpty &&
      isScopeValid scopePs &&
      isScopeAuthValid policies authBindings principal intPs &&
      checkAgentTreeList invs policies authBindings children
    | Agent.profile ms =>
      checkAgentTreeList invs policies authBindings ms

  def checkAgentTreeList
      (invs : List PromiseInvariant) (policies : List AuthPolicy) (authBindings : List AuthBinding) : List Agent -> Bool
    | [] => true
    | a :: rest => checkAgentTree invs policies authBindings a && checkAgentTreeList invs policies authBindings rest
end

end Baugr.Engine
