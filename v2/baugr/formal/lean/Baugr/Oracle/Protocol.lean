/-
  Baugr.Oracle.Protocol — Thin NDJSON DRT Boundary (F-2, F-3, F-5, F-6)
  100% Usage-Agnostic: evaluates `checkAgentTree`, `resolveAgentTree`, `projectAgentSST`,
  `impactCone`, `reverseImpactCone`, `allInvariantsHold`, `isScopeValid`, Cedar `authorize`,
  `isDelegatedAuthorized`, and `blastRadius`!
-/

import Lean.Data.Json
import Baugr.Data.AttrExpr
import Baugr.Theory.Promise
import Baugr.Theory.Spacetime
import Baugr.Engine.Conformance
import Baugr.Engine.Invariants
import Baugr.Engine.Authority
import Baugr.Engine.Binding
import Baugr.Engine.Resolve

namespace Baugr.Oracle

open Lean (Json FromJson ToJson fromJson? toJson)
open Baugr.Data
open Baugr.Theory
open Baugr.Engine

instance : FromJson Polarity where
  fromJson? j := do
    match ← j.getStr? with
    | "offer" => pure Polarity.offer
    | "use"   => pure Polarity.use
    | s       => throw s!"invalid polarity: {s}"

instance : FromJson Strength where
  fromJson? j := do
    match ← j.getStr? with
    | "hard" => pure Strength.hard
    | "soft" => pure Strength.soft
    | s      => throw s!"invalid strength: {s}"

instance : FromJson Cardinality where
  fromJson? j := do
    match ← j.getStr? with
    | "exclusive"   => pure Cardinality.exclusive
    | "broadcast"   => pure Cardinality.broadcast
    | "partitioned" => pure Cardinality.partitioned
    | "budgeted"    => pure Cardinality.budgeted
    | s             => throw s!"invalid cardinality: {s}"

instance : FromJson SoftContract where
  fromJson? j := do
    pure {
      conditionRef := ← j.getObjValAs? String "conditionRef"
      degradedMode := ← j.getObjValAs? String "degradedMode"
      probeId      := ← j.getObjValAs? String "probeId"
    }

partial def parseAttrExpr (j : Json) : Except String AttrExpr := do
  match ← j.getObjValAs? String "kind" with
  | "atom"  => AttrExpr.atom <$> j.getObjValAs? String "tag"
  | "union" => AttrExpr.union <$> (j.getObjVal? "left" >>= parseAttrExpr) <*> (j.getObjVal? "right" >>= parseAttrExpr)
  | "inter" => AttrExpr.inter <$> (j.getObjVal? "left" >>= parseAttrExpr) <*> (j.getObjVal? "right" >>= parseAttrExpr)
  | "diff"  => AttrExpr.diff  <$> (j.getObjVal? "left" >>= parseAttrExpr) <*> (j.getObjVal? "right" >>= parseAttrExpr)
  | "compl" => AttrExpr.compl <$> (j.getObjVal? "inner" >>= parseAttrExpr)
  | "any"   => pure AttrExpr.any
  | "none"  => pure AttrExpr.none
  | s       => throw s!"invalid AttrExpr kind: {s}"

instance : FromJson AttrExpr where
  fromJson? := parseAttrExpr

instance : FromJson Promise where
  fromJson? j := do
    let softInfo : Option SoftContract ←
      match j.getObjVal? "softInfo" with
      | Except.ok Json.null => pure none
      | Except.ok sj => some <$> fromJson? sj
      | Except.error _ => pure none
    let tags : List String ←
      match j.getObjVal? "tags" with
      | Except.ok tj => fromJson? tj
      | Except.error _ => pure []
    let selector : AttrExpr ←
      match j.getObjVal? "selector" with
      | Except.ok sj => parseAttrExpr sj
      | Except.error _ => pure AttrExpr.any
    let priority : Nat ←
      match j.getObjVal? "priority" with
      | Except.ok pj => fromJson? pj
      | Except.error _ => pure 1
    let stratum : Nat ←
      match j.getObjVal? "stratum" with
      | Except.ok sj => fromJson? sj
      | Except.error _ => pure 0
    pure {
      id          := ← j.getObjValAs? String "id"
      ptype       := ← j.getObjValAs? String "ptype"
      key         := ← j.getObjValAs? String "key"
      polarity    := ← j.getObjValAs? Polarity "polarity"
      strength    := ← j.getObjValAs? Strength "strength"
      cardinality := ← j.getObjValAs? Cardinality "cardinality"
      mandatory   := ← j.getObjValAs? Bool "mandatory"
      amount      := ← j.getObjValAs? Nat "amount"
      priority, stratum, tags, selector, softInfo
    }

instance : FromJson ExteriorSurface where
  fromJson? j := do
    pure {
      agentId    := ← j.getObjValAs? String "agentId"
      promises   := ← j.getObjValAs? (List Promise) "promises"
      attributes := ← j.getObjValAs? (List String) "attributes"
    }

partial def parseAgent (j : Json) : Except String Agent := do
  match ← j.getObjValAs? String "kind" with
  | "atomic" =>
    let ext ← j.getObjValAs? ExteriorSurface "ext"
    let hash ← j.getObjValAs? String "interiorHash"
    pure (Agent.atomic ext hash)
  | "superagent" =>
    let ext ← j.getObjValAs? ExteriorSurface "ext"
    let arr ← (← j.getObjVal? "children").getArr?
    let children ← arr.toList.mapM parseAgent
    pure (Agent.superagent ext children)
  | "profile" =>
    let arr ← (← j.getObjVal? "members").getArr?
    let members ← arr.toList.mapM parseAgent
    pure (Agent.profile members)
  | s => throw s!"invalid Agent kind: {s}"

instance : FromJson Agent where
  fromJson? := parseAgent

instance : FromJson PromiseInvariant where
  fromJson? j := do
    pure {
      id         := ← j.getObjValAs? String "id"
      ptype      := ← j.getObjValAs? String "ptype"
      forbidTags := ← j.getObjValAs? AttrExpr "forbidTags"
    }

instance : FromJson Effect where
  fromJson? j := do
    match ← j.getStr? with
    | "permit" => pure Effect.permit
    | "forbid" => pure Effect.forbid
    | s        => throw s!"invalid effect: {s}"

instance : FromJson AuthPolicy where
  fromJson? j := do
    pure {
      id            := ← j.getObjValAs? String "id"
      effect        := ← j.getObjValAs? Effect "effect"
      action        := ← j.getObjValAs? String "action"
      principalPred := ← j.getObjValAs? AttrExpr "principalPred"
      resourcePred  := ← j.getObjValAs? AttrExpr "resourcePred"
    }

instance : FromJson AuthBinding where
  fromJson? j := do
    let polarity : Polarity ←
      match j.getObjVal? "polarity" with
      | Except.ok pj => fromJson? pj
      | Except.error _ => pure Polarity.use
    let principalFilter : AttrExpr ←
      match j.getObjVal? "principalFilter" with
      | Except.ok pf => parseAttrExpr pf
      | Except.error _ => pure AttrExpr.any
    pure {
      id              := ← j.getObjValAs? String "id"
      ptype           := ← j.getObjValAs? String "ptype"
      action          := ← j.getObjValAs? String "action"
      polarity, principalFilter
    }

instance : FromJson Entity where
  fromJson? j := do
    pure {
      id   := ← j.getObjValAs? String "id"
      tags := ← j.getObjValAs? (List String) "tags"
    }

instance : FromJson Capability where
  fromJson? j := do
    pure {
      rootPolicyId  := ← j.getObjValAs? String "rootPolicyId"
      allowedAction := ← j.getObjValAs? String "allowedAction"
      caveats       := ← j.getObjValAs? (List AttrExpr) "caveats"
    }

structure AuthQuery where
  principal : Entity
  action    : String
  resource  : Entity

instance : FromJson AuthQuery where
  fromJson? j := do
    pure {
      principal := ← j.getObjValAs? Entity "principal"
      action    := ← j.getObjValAs? String "action"
      resource  := ← j.getObjValAs? Entity "resource"
    }

structure DelegatedQuery where
  delegator  : Entity
  delegatee  : Entity
  capability : Capability
  action     : String
  resource   : Entity

instance : FromJson DelegatedQuery where
  fromJson? j := do
    pure {
      delegator  := ← j.getObjValAs? Entity "delegator"
      delegatee  := ← j.getObjValAs? Entity "delegatee"
      capability := ← j.getObjValAs? Capability "capability"
      action     := ← j.getObjValAs? String "action"
      resource   := ← j.getObjValAs? Entity "resource"
    }

structure OracleRequest where
  agentTree        : Agent
  invariants       : List PromiseInvariant
  promises         : List Promise
  policies         : List AuthPolicy
  authBindings     : List AuthBinding
  authQueries      : List AuthQuery
  delegatedQueries : List DelegatedQuery
  blastTarget      : Entity
  blastAction      : String
  allResources     : List Entity
  sstSeed          : String

instance : FromJson OracleRequest where
  fromJson? j := do
    let authBindings : List AuthBinding ←
      match j.getObjVal? "authBindings" with
      | Except.ok ab => fromJson? ab
      | Except.error _ => pure []
    let sstSeed : String ←
      match j.getObjVal? "sstSeed" with
      | Except.ok s => fromJson? s
      | Except.error _ => pure ""
    pure {
      agentTree        := ← j.getObjValAs? Agent "agentTree"
      invariants       := ← j.getObjValAs? (List PromiseInvariant) "invariants"
      promises         := ← j.getObjValAs? (List Promise) "promises"
      policies         := ← j.getObjValAs? (List AuthPolicy) "policies"
      authBindings
      authQueries      := ← j.getObjValAs? (List AuthQuery) "authQueries"
      delegatedQueries := ← j.getObjValAs? (List DelegatedQuery) "delegatedQueries"
      blastTarget      := ← j.getObjValAs? Entity "blastTarget"
      blastAction      := ← j.getObjValAs? String "blastAction"
      allResources     := ← j.getObjValAs? (List Entity) "allResources"
      sstSeed
    }

def authResponseToJson (r : AuthResponse) : Json :=
  let dec := match r.decision with | Decision.allow => "allow" | Decision.deny => "deny"
  Json.mkObj [
    ("decision", toJson dec),
    ("determiningPolicies", toJson r.determiningPolicies)
  ]

def resolvedUseToJson (ru : ResolvedUse) : Json :=
  Json.mkObj [
    ("key", toJson ru.key),
    ("offerIds", toJson ru.offerIds),
    ("ptype", toJson ru.ptype),
    ("useId", toJson ru.useId)
  ]

def resolvedScopeToJson (rs : ResolvedScope) : Json :=
  Json.mkObj [
    ("agentId", toJson rs.agentId),
    ("bindings", toJson (rs.bindings.map resolvedUseToJson))
  ]

def evalRequest (req : OracleRequest) : Json :=
  let treeValid := checkAgentTree req.invariants req.policies req.authBindings req.agentTree
  let resolvedJson : Json :=
    match resolveAgentTree req.agentTree with
    | some rs => toJson (rs.map resolvedScopeToJson)
    | none    => Json.null
  let sst := projectAgentSST req.agentTree
  let sstImpact :=
    if req.sstSeed.isEmpty then []
    else (impactCone sst 4 [req.sstSeed]).mergeSort (· ≤ ·)
  let sstRevImpact :=
    if req.sstSeed.isEmpty then []
    else (reverseImpactCone sst 4 [req.sstSeed]).mergeSort (· ≤ ·)
  let invariantsValid := allInvariantsHold req.invariants req.promises
  let scopeValid := isScopeValid req.promises
  let authResponses := req.authQueries.map (fun q => authResponseToJson (authorize req.policies q.principal q.action q.resource))
  let delegatedResults := req.delegatedQueries.map (fun q =>
    isDelegatedAuthorized req.policies q.delegator q.delegatee q.capability q.action q.resource)
  let blastIds := (blastRadius req.policies req.blastTarget req.blastAction req.allResources).map (·.id)
  Json.mkObj [
    ("authResponses", toJson authResponses),
    ("blastRadius", toJson blastIds),
    ("delegatedResults", toJson delegatedResults),
    ("invariantsValid", toJson invariantsValid),
    ("resolvedScopes", resolvedJson),
    ("scopeValid", toJson scopeValid),
    ("sstEdgeCount", toJson sst.edges.length),
    ("sstImpactCone", toJson sstImpact),
    ("sstNodeCount", toJson sst.nodes.length),
    ("sstReverseImpactCone", toJson sstRevImpact),
    ("treeValid", toJson treeValid)
  ]

end Baugr.Oracle
