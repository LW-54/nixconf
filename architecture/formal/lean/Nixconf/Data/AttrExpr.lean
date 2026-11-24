/-
  Nixconf.Data.AttrExpr — Layer 0 Shared Algebraic Primitive
  Boolean Set-Algebra Predicate Lattice (∪, ∩, \, ¬, ⊤, ⊥) over open SST `EXPRESSES` tags.
  Shared uniformly by:
    1. L3+ Cedar-style Authorization & Capability Caveats (`Nixconf.Spec.Authority`)
    2. B3 Partitioned Provider Routing (`Nixconf.Spec.Binding`)
    3. S2+ Open Composable State Trait Policies (`Nixconf.Spec.StateSafety`)
-/

namespace Nixconf.Data

inductive AttrExpr where
  | atom  (tag : String)              -- x ∈ tag
  | union (e1 e2 : AttrExpr)          -- e1 ∪ e2 (OR)
  | inter (e1 e2 : AttrExpr)          -- e1 ∩ e2 (AND)
  | diff  (e1 e2 : AttrExpr)          -- e1 \ e2 (Inclusion with Exclusion)
  | compl (e : AttrExpr)              -- ¬e (Complement)
  | any                               -- ⊤ (Universal match)
  | none                              -- ⊥ (Empty match)
  deriving Repr, DecidableEq, BEq

def AttrExpr.eval (tags : List String) : AttrExpr -> Bool
  | AttrExpr.atom t      => tags.contains t
  | AttrExpr.union e1 e2 => e1.eval tags || e2.eval tags
  | AttrExpr.inter e1 e2 => e1.eval tags && e2.eval tags
  | AttrExpr.diff e1 e2  => e1.eval tags && !(e2.eval tags)
  | AttrExpr.compl e     => !(e.eval tags)
  | AttrExpr.any         => true
  | AttrExpr.none        => false

/-- True iff two predicates overlap on a given tag set (used for B3 Partition disjointness). -/
def AttrExpr.overlapsOn (e1 e2 : AttrExpr) (tags : List String) : Bool :=
  e1.eval tags && e2.eval tags

end Nixconf.Data
