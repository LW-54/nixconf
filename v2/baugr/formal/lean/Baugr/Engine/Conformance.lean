/-
  Baugr.Engine.Conformance — P-Explicit Interior Conformance & Coarse-Grained Budgets (F-5)
  100% Usage-Agnostic Engine Layer built cleanly on `Baugr.Theory.Promise`.
-/

import Baugr.Data.AttrExpr
import Baugr.Theory.Promise

namespace Baugr.Engine

open Baugr.Data
open Baugr.Theory

inductive BoundaryError where
  | unbackedExteriorOffer       (superagentId ptype key : String)
  | leakedInteriorUse           (superagentId ptype key : String)
  | droppedMandatoryOffer       (superagentId ptype key : String)
  | underreportedBudget         (superagentId ptype : String) (extPlusIntSupply intDemand : Nat)
  | underreportedCriticalBudget (superagentId ptype : String) (extCritPlusIntSupply intCritDemand : Nat)
  deriving Repr, DecidableEq, BEq

def isMandatoryHardUse (p : Promise) : Bool :=
  match p.polarity, p.strength, p.mandatory with
  | Polarity.use, Strength.hard, true => true
  | _, _, _                           => false

def isMandatoryHardPartitionedOffer (p : Promise) : Bool :=
  match p.polarity, p.strength, p.cardinality, p.mandatory with
  | Polarity.offer, Strength.hard, Cardinality.partitioned, true => true
  | _, _, _, _                                                   => false

def isMandatoryHardBroadcastOffer (p : Promise) : Bool :=
  match p.polarity, p.strength, p.cardinality, p.mandatory with
  | Polarity.offer, Strength.hard, Cardinality.broadcast, true => true
  | _, _, _, _                                                 => false

def sameTagSet (xs ys : List String) : Bool :=
  xs.all (fun x => ys.contains x) && ys.all (fun y => xs.contains y)

def hasOffer (ps : List Promise) (ptype key : String) : Bool :=
  ps.any (fun p => p.polarity == Polarity.offer && p.ptype == ptype && p.key == key)

def hasBackingOffer (ps : List Promise) (extOffer : Promise) : Bool :=
  match extOffer.cardinality with
  | Cardinality.partitioned | Cardinality.broadcast =>
    ps.any (fun o =>
      o.polarity == Polarity.offer &&
      o.cardinality == extOffer.cardinality &&
      o.ptype == extOffer.ptype &&
      o.key == extOffer.key &&
      sameTagSet o.tags extOffer.tags)
  | _ => hasOffer ps extOffer.ptype extOffer.key

def hasBackingUse (ps : List Promise) (intUse : Promise) : Bool :=
  ps.any (fun u =>
    u.polarity == Polarity.use &&
    u.ptype == intUse.ptype &&
    u.key == intUse.key &&
    (intUse.tags.isEmpty || sameTagSet u.tags intUse.tags))

/-- Count partitioned consumers whose `AttrExpr` selector matches a given offer's tags (B3). -/
def countMatchingPartitionHandlers (ps : List Promise) (ptype : String) (offerTags : List String) : Nat :=
  (ps.filter (fun h =>
    h.polarity == Polarity.use &&
    h.cardinality == Cardinality.partitioned &&
    h.ptype == ptype &&
    h.selector.eval offerTags)).length

/-- Count broadcast subscribers whose `AttrExpr` selector matches a given offer's tags (B3 M:N fan-out). -/
def countMatchingBroadcastHandlers (ps : List Promise) (ptype : String) (offerTags : List String) : Nat :=
  (ps.filter (fun h =>
    h.polarity == Polarity.use &&
    h.cardinality == Cardinality.broadcast &&
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
    intPs.any (fun o =>
      o.polarity == Polarity.offer &&
      o.ptype == p.ptype &&
      p.selector.eval o.tags)
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
  P-Explicit Interior Conformance Validator:
  Verifies that a Dressed Superagent's `Interior(children)` faithfully backs `Π_ext`
  observing strictly `exteriorOf` of direct children.
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
        if hasBackingUse ext.promises p then none
        else some (BoundaryError.leakedInteriorUse ext.agentId p.ptype p.key)
      else none
  let droppedOfferErrs :=
    intPs.filterMap fun p =>
      if (isMandatoryHardPartitionedOffer p && countMatchingPartitionHandlers intPs p.ptype p.tags == 0) ||
         (isMandatoryHardBroadcastOffer p && countMatchingBroadcastHandlers intPs p.ptype p.tags == 0) then
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

/-- Scope-Emergent Portability: an exterior closes inside ANY ambient scope iff all mandatory uses satisfy. -/
def canComposeInScope (ambient ext : ExteriorSurface) : Bool :=
  ext.promises.all (fun p => !isMandatoryHardUse p || isInternallySatisfied ambient.promises p)

end Baugr.Engine
