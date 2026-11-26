/-
  Baugr.Engine.Invariants — Generic Declarative `AttrExpr` Promise Invariants
  Domain laws (e.g. CALM monotonicity, disjoint zone policies) emerge purely as data instances!
-/

import Baugr.Data.AttrExpr
import Baugr.Theory.Promise

namespace Baugr.Engine

open Baugr.Data
open Baugr.Theory

/-- A declarative invariant forbidding any promise of `ptype` (or `"*"`) whose tags satisfy `forbidTags`. -/
structure PromiseInvariant where
  id         : String
  ptype      : String
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

end Baugr.Engine
