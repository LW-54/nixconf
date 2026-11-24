/-
  Aky.Spec.Invariants — Layer 1 Executable Specification (100% Usage-Agnostic, NO PROOFS)
  Generic Declarative `AttrExpr` Promise Invariants.
  Domain laws (such as Hellerstein's CALM monotonicity, security posture bans, or compliance
  constraints) emerge purely as data instances of `PromiseInvariant` — zero domain strings in core!
-/

import Aky.Data.AttrExpr
import Aky.Spec.Agency

namespace Aky.Spec

open Aky.Data

/-- A declarative invariant forbidding any promise of `ptype` (or `"*"`) whose tags satisfy `forbidTags`. -/
structure PromiseInvariant where
  id         : String
  ptype      : String   -- Exact promise type, or `"*"` for all promises
  forbidTags : AttrExpr
  deriving Repr, DecidableEq, BEq

inductive InvariantError where
  | violated (invariantId promiseId ptype : String)
  deriving Repr, DecidableEq, BEq

def invariantApplies (inv : PromiseInvariant) (p : Promise) : Bool :=
  inv.ptype == "*" || inv.ptype == p.ptype

def checkInvariant (ps : List Promise) (inv : PromiseInvariant) : List InvariantError :=
  ps.filterMap fun p =>
    if invariantApplies inv p && inv.forbidTags.eval p.tags then
      some (InvariantError.violated inv.id p.id p.ptype)
    else none

def validateInvariants (invs : List PromiseInvariant) (ps : List Promise) : List InvariantError :=
  invs.flatMap (checkInvariant ps)

def allInvariantsHold (invs : List PromiseInvariant) (ps : List Promise) : Bool :=
  invs.all (fun inv => (checkInvariant ps inv).isEmpty)

end Aky.Spec
