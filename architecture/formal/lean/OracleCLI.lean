/-
  OracleCLI.lean — AWS Cedar Verification-Guided Development (F3-b) Executable Oracle!
  Reads a JSON test vector on stdin, runs the EXACT machine-proved Lean 4 functions from
  NixconfFoundation.{Agency, Binding, Authority, StateSafety}, and prints deterministic JSON
  verdicts on stdout for Differential Randomized Testing (DRT) against the Rust production engine.
-/

import Lean.Data.Json
import NixconfFoundation

open Lean (Json FromJson ToJson fromJson? toJson)
open NixconfFoundation

-- Minimal JSON decoders for the Differential Testing Wire Protocol (Lean 4 <-> Rust)

instance : FromJson Polarity where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "offer" => pure Polarity.offer
    | "use"   => pure Polarity.use
    | _       => throw s!"invalid polarity: {s}"

instance : FromJson Strength where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "hard" => pure Strength.hard
    | "soft" => pure Strength.soft
    | _      => throw s!"invalid strength: {s}"

instance : FromJson Cardinality where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "exclusive"   => pure Cardinality.exclusive
    | "broadcast"   => pure Cardinality.broadcast
    | "partitioned" => pure Cardinality.partitioned
    | "budgeted"    => pure Cardinality.budgeted
    | _             => throw s!"invalid cardinality: {s}"

instance : FromJson SoftContract where
  fromJson? j := do
    let c ← j.getObjValAs? String "conditionRef"
    let d ← j.getObjValAs? String "degradedMode"
    let p ← j.getObjValAs? String "probeId"
    pure { conditionRef := c, degradedMode := d, probeId := p }

instance : FromJson Promise where
  fromJson? j := do
    let id ← j.getObjValAs? String "id"
    let ptype ← j.getObjValAs? String "ptype"
    let key ← j.getObjValAs? String "key"
    let polarity ← j.getObjValAs? Polarity "polarity"
    let strength ← j.getObjValAs? Strength "strength"
    let cardinality ← j.getObjValAs? Cardinality "cardinality"
    let mandatory ← j.getObjValAs? Bool "mandatory"
    let amount ← j.getObjValAs? Nat "amount"
    let softInfo : Option SoftContract ←
      match j.getObjVal? "softInfo" with
      | Except.ok Json.null => pure none
      | Except.ok sj => some <$> fromJson? sj
      | Except.error _ => pure none
    pure { id, ptype, key, polarity, strength, cardinality, mandatory, amount, softInfo }

partial def parseAttrExpr (j : Json) : Except String AttrExpr := do
  let kind ← j.getObjValAs? String "kind"
  match kind with
  | "atom"  => AttrExpr.atom <$> j.getObjValAs? String "tag"
  | "union" => AttrExpr.union <$> (j.getObjVal? "left" >>= parseAttrExpr) <*> (j.getObjVal? "right" >>= parseAttrExpr)
  | "inter" => AttrExpr.inter <$> (j.getObjVal? "left" >>= parseAttrExpr) <*> (j.getObjVal? "right" >>= parseAttrExpr)
  | "diff"  => AttrExpr.diff  <$> (j.getObjVal? "left" >>= parseAttrExpr) <*> (j.getObjVal? "right" >>= parseAttrExpr)
  | "compl" => AttrExpr.compl <$> (j.getObjVal? "inner" >>= parseAttrExpr)
  | "any"   => pure AttrExpr.any
  | "none"  => pure AttrExpr.none
  | _       => throw s!"invalid AttrExpr kind: {kind}"

instance : FromJson AttrExpr where
  fromJson? := parseAttrExpr

instance : FromJson Effect where
  fromJson? j := do
    let s ← j.getStr?
    match s with
    | "permit" => pure Effect.permit
    | "forbid" => pure Effect.forbid
    | _        => throw s!"invalid effect: {s}"

instance : FromJson AuthPolicy where
  fromJson? j := do
    let id ← j.getObjValAs? String "id"
    let effect ← j.getObjValAs? Effect "effect"
    let action ← j.getObjValAs? String "action"
    let principalPred ← j.getObjValAs? AttrExpr "principalPred"
    let resourcePred ← j.getObjValAs? AttrExpr "resourcePred"
    pure { id, effect, action, principalPred, resourcePred }

instance : FromJson Entity where
  fromJson? j := do
    let id ← j.getObjValAs? String "id"
    let tags ← j.getObjValAs? (List String) "tags"
    pure { id, tags }

instance : FromJson StateTraits where
  fromJson? j := do
    let reconstructible ← j.getObjValAs? Bool "reconstructible"
    let survivesReboot ← j.getObjValAs? Bool "survivesReboot"
    let monotonic ← j.getObjValAs? Bool "monotonic"
    let multiWriter ← j.getObjValAs? Bool "multiWriter"
    let singleAuthWriter ← j.getObjValAs? Bool "singleAuthWriter"
    let backupRequired ← j.getObjValAs? Bool "backupRequired"
    let externalOwned ← j.getObjValAs? Bool "externalOwned"
    pure { reconstructible, survivesReboot, monotonic, multiWriter, singleAuthWriter, backupRequired, externalOwned }

instance : FromJson StateVolume where
  fromJson? j := do
    let id ← j.getObjValAs? String "id"
    let owner ← j.getObjValAs? String "owner"
    let traits ← j.getObjValAs? StateTraits "traits"
    pure { id, owner, traits }

instance : FromJson SubstrateCapabilities where
  fromJson? j := do
    let providesDurableStorage ← j.getObjValAs? Bool "providesDurableStorage"
    let backupProviderCount ← j.getObjValAs? Nat "backupProviderCount"
    pure { providesDurableStorage, backupProviderCount }

structure AuthQuery where
  principal : Entity
  action    : String
  resource  : Entity

instance : FromJson AuthQuery where
  fromJson? j := do
    let principal ← j.getObjValAs? Entity "principal"
    let action ← j.getObjValAs? String "action"
    let resource ← j.getObjValAs? Entity "resource"
    pure { principal, action, resource }

structure OracleRequest where
  promises     : List Promise
  policies     : List AuthPolicy
  authQueries  : List AuthQuery
  blastTarget  : Entity
  blastAction  : String
  allResources : List Entity
  substrate    : SubstrateCapabilities
  volumes      : List StateVolume

instance : FromJson OracleRequest where
  fromJson? j := do
    let promises ← j.getObjValAs? (List Promise) "promises"
    let policies ← j.getObjValAs? (List AuthPolicy) "policies"
    let authQueries ← j.getObjValAs? (List AuthQuery) "authQueries"
    let blastTarget ← j.getObjValAs? Entity "blastTarget"
    let blastAction ← j.getObjValAs? String "blastAction"
    let allResources ← j.getObjValAs? (List Entity) "allResources"
    let substrate ← j.getObjValAs? SubstrateCapabilities "substrate"
    let volumes ← j.getObjValAs? (List StateVolume) "volumes"
    pure { promises, policies, authQueries, blastTarget, blastAction, allResources, substrate, volumes }

def evalRequest (req : OracleRequest) : Json :=
  let scopeValid := isScopeValid req.promises
  let authResults := req.authQueries.map (fun q => isAuthorized req.policies q.principal q.action q.resource)
  let blastIds := (blastRadius req.policies req.blastTarget req.blastAction req.allResources).map (·.id)
  let stateValid := allVolumesValid req.substrate req.volumes
  Json.mkObj [
    ("scopeValid", toJson scopeValid),
    ("authResults", toJson authResults),
    ("blastRadius", toJson blastIds),
    ("stateValid", toJson stateValid)
  ]

def main : IO Unit := do
  let stdin ← IO.getStdin
  let raw ← stdin.readToEnd
  -- Supports NDJSON batch mode (1 JSON request per line) for high-throughput Rust DRT!
  for line in raw.splitOn "\n" do
    let trimmed := line.trimAscii.toString
    if !trimmed.isEmpty then
      match Json.parse trimmed >>= fromJson? with
      | Except.ok (req : OracleRequest) =>
        IO.println (evalRequest req).compress
      | Except.error err =>
        IO.eprintln s!"oracle parse error: {err}"
        IO.Process.exit 1
