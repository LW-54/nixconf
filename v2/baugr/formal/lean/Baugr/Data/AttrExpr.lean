/-
  Baugr.Data.AttrExpr — Layer 0 Shared Algebraic Primitive
  Boolean Set-Algebra Predicate Lattice (∪, ∩, \, ¬, ⊤, ⊥) over open SST `EXPRESSES` tags.
-/

namespace Baugr.Data

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

/-- True iff two predicates overlap on a given tag set. -/
def AttrExpr.overlapsOn (e1 e2 : AttrExpr) (tags : List String) : Bool :=
  e1.eval tags && e2.eval tags

/-- Conjunction requiring all tags in `tags` to be present. -/
def exactTagsExpr (tags : List String) : AttrExpr :=
  tags.foldl (fun acc t => AttrExpr.inter acc (AttrExpr.atom t)) AttrExpr.any

end Baugr.Data
