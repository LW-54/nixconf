/-
  Aky.Oracle.Protocol — Layer 3 Thin JSON Interchange Boundary (AWS Cedar DRT Pattern)
  Strictly isolated from Spec & Thm. Serializes/deserializes structured verdicts including
  FULL RECURSIVE `Agent` trees (`atomic` | `superagent` | `profile`), P-Explicit boundary
  conformance (promises + budgets + state volumes), multi-stratum rules, and Cedar/Biscuit delegation!
-/

import Lean.Data.Json
import Aky.Data.AttrExpr
import Aky.Spec.Agency
import Aky.Spec.Binding
import Aky.Spec.Authority
import Aky.Spec.StateSafety

namespace Aky.Oracle

open Lean (Json FromJson ToJson fromJson? toJson)
open Aky.Data
open Aky.Spec

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

instance : FromJson StateVolume where
  fromJson? j := do
    pure {
      id     := ← j.getObjValAs? String "id"
      owner  := ← j.getObjValAs? String "owner"
      traits := ← j.getObjValAs? (List String) "traits"
    }

instance : FromJson ExteriorSurface where
  fromJson? j := do
    let volumes : List StateVolume ←
      match j.getObjVal? "volumes" with
      | Except.ok vj => fromJson? vj
      | Except.error _ => pure []
    pure {
      agentId    := ← j.getObjValAs? String "agentId"
      promises   := ← j.getObjValAs? (List Promise) "promises"
      attributes := ← j.getObjValAs? (List String) "attributes"
      volumes
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

instance : FromJson HandlerRule where
  fromJson? j := do
    pure {
      id         := ← j.getObjValAs? String "id"
      inStratum  := ← j.getObjValAs? Nat "inStratum"
      outStratum := ← j.getObjValAs? Nat "outStratum"
      emitted    := ← j.getObjValAs? (List Promise) "emitted"
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

instance : FromJson SubstrateCapabilities where
  fromJson? j := do
    pure {
      providesDurableStorage := ← j.getObjValAs? Bool "providesDurableStorage"
      backupProviderCount    := ← j.getObjValAs? Nat "backupProviderCount"
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
  promises         : List Promise
  stratumRules     : List HandlerRule
  policies         : List AuthPolicy
  authQueries      : List AuthQuery
  delegatedQueries : List DelegatedQuery
  blastTarget      : Entity
  blastAction      : String
  allResources     : List Entity
  substrate        : SubstrateCapabilities
  volumes          : List StateVolume

instance : FromJson OracleRequest where
  fromJson? j := do
    pure {
      agentTree        := ← j.getObjValAs? Agent "agentTree"
      promises         := ← j.getObjValAs? (List Promise) "promises"
      stratumRules     := ← j.getObjValAs? (List HandlerRule) "stratumRules"
      policies         := ← j.getObjValAs? (List AuthPolicy) "policies"
      authQueries      := ← j.getObjValAs? (List AuthQuery) "authQueries"
      delegatedQueries := ← j.getObjValAs? (List DelegatedQuery) "delegatedQueries"
      blastTarget      := ← j.getObjValAs? Entity "blastTarget"
      blastAction      := ← j.getObjValAs? String "blastAction"
      allResources     := ← j.getObjValAs? (List Entity) "allResources"
      substrate        := ← j.getObjValAs? SubstrateCapabilities "substrate"
      volumes          := ← j.getObjValAs? (List StateVolume) "volumes"
    }

def authResponseToJson (r : AuthResponse) : Json :=
  let dec := match r.decision with | Decision.allow => "allow" | Decision.deny => "deny"
  Json.mkObj [
    ("decision", toJson dec),
    ("determiningPolicies", toJson r.determiningPolicies)
  ]

def evalRequest (req : OracleRequest) : Json :=
  let treeValid := checkAgentTree req.agentTree
  let scopeValid := isScopeValid req.promises
  let stratumValid := (validateStratumRules req.stratumRules).isEmpty
  let authResponses := req.authQueries.map (fun q => authResponseToJson (authorize req.policies q.principal q.action q.resource))
  let delegatedResults := req.delegatedQueries.map (fun q =>
    isDelegatedAuthorized req.policies q.delegator q.delegatee q.capability q.action q.resource)
  let blastIds := (blastRadius req.policies req.blastTarget req.blastAction req.allResources).map (·.id)
  let stateValid := allVolumesValid req.substrate req.volumes
  Json.mkObj [
    ("authResponses", toJson authResponses),
    ("blastRadius", toJson blastIds),
    ("delegatedResults", toJson delegatedResults),
    ("scopeValid", toJson scopeValid),
    ("stateValid", toJson stateValid),
    ("stratumValid", toJson stratumValid),
    ("treeValid", toJson treeValid)
  ]

end Aky.Oracle
