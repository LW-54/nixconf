/-
  Aky — Root Library Export (AWS cedar-lean 4-Layer Architecture, 100% Usage-Agnostic Core)
    Layer 0: Aky.Data.*   (Shared AttrExpr Boolean Lattice + Permutation Lemmas)
    Layer 1: Aky.Spec.*   (Pure, domain-agnostic executable operational semantics — NO PROOFS)
    Layer 2: Aky.Thm.*    (1:1 Machine-checked unbounded proofs — ZERO `sorry`)
    Layer 3: Aky.Oracle.* (Thin JSON interchange boundary for Rust DRT)
-/

import Aky.Data.AttrExpr
import Aky.Data.ListLemmas
import Aky.Spec.Agency
import Aky.Spec.Invariants
import Aky.Spec.Binding
import Aky.Spec.Authority
import Aky.Spec.Spacetime
import Aky.Thm.Agency
import Aky.Thm.Invariants
import Aky.Thm.Binding
import Aky.Thm.Authority
import Aky.Thm.Spacetime
import Aky.Oracle.Protocol
