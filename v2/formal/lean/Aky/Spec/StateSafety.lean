/-
  Aky.Spec.StateSafety — Layer 1 Executable Specification (NO PROOFS)
  S2+ Mandatory Agent-Declared State-As-Promise using OPEN composable trait tags
  evaluated via shared `Aky.Data.AttrExpr` (Gap #3 CLOSED — ZERO closed 7-field struct!)
  + Hellerstein's CALM Logical Monotonicity Law.
-/

import Aky.Data.AttrExpr

namespace Aky.Spec

open Aky.Data

/-- Open State Volume declaration: arbitrary extensible trait tags (no closed enum or fixed struct!). -/
structure StateVolume where
  id     : String
  owner  : String
  traits : List String -- e.g. ["survives-reboot", "single-auth-writer", "backup-required"]
  deriving Repr, DecidableEq, BEq

structure SubstrateCapabilities where
  providesDurableStorage : Bool -- false on ephemeral Live-ISO
  backupProviderCount    : Nat  -- Broadcast 1:N backup observers bound to host
  deriving Repr, DecidableEq, BEq

inductive StateError where
  | durableStateOnEphemeralSubstrate (volumeId : String)
  | calmNonMonotonicMultiWriter      (volumeId : String)
  | unbackedRequiredVolume           (volumeId : String)
  deriving Repr, DecidableEq, BEq

/-- Canonical Open Trait Predicates expressed in the shared `AttrExpr` Boolean Lattice! -/
def predNeedsLocalPersistence : AttrExpr :=
  AttrExpr.diff
    (AttrExpr.atom "survives-reboot")
    (AttrExpr.union (AttrExpr.atom "reconstructible") (AttrExpr.atom "external-owned"))

def predCalmSafe : AttrExpr :=
  AttrExpr.union
    (AttrExpr.compl (AttrExpr.atom "multi-writer"))
    (AttrExpr.union (AttrExpr.atom "monotonic") (AttrExpr.atom "single-auth-writer"))

def predBackupRequired : AttrExpr :=
  AttrExpr.atom "backup-required"

def checkVolume (sub : SubstrateCapabilities) (v : StateVolume) : List StateError :=
  let e1 :=
    if predNeedsLocalPersistence.eval v.traits && !sub.providesDurableStorage then
      [StateError.durableStateOnEphemeralSubstrate v.id]
    else []
  let e2 :=
    if !predCalmSafe.eval v.traits then
      [StateError.calmNonMonotonicMultiWriter v.id]
    else []
  let e3 :=
    if predBackupRequired.eval v.traits && sub.backupProviderCount == 0 then
      [StateError.unbackedRequiredVolume v.id]
    else []
  e1 ++ e2 ++ e3

def validateVolumes (sub : SubstrateCapabilities) (vs : List StateVolume) : List StateError :=
  vs.flatMap (checkVolume sub)

def allVolumesValid (sub : SubstrateCapabilities) (vs : List StateVolume) : Bool :=
  vs.all (fun v => (checkVolume sub v).isEmpty)

end Aky.Spec
