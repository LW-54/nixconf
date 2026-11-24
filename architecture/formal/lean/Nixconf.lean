/-
  Nixconf — Root Library Export (AWS cedar-lean 4-Layer Architecture)
    Layer 0: Nixconf.Data.*   (Shared AttrExpr Boolean Lattice + Permutation Lemmas)
    Layer 1: Nixconf.Spec.*   (Pure, readable, executable operational semantics — NO PROOFS)
    Layer 2: Nixconf.Thm.*    (1:1 Machine-checked unbounded proofs — ZERO `sorry`)
    Layer 3: Nixconf.Oracle.* (Thin JSON interchange boundary for Rust DRT)
-/

import Nixconf.Data.AttrExpr
import Nixconf.Data.ListLemmas
import Nixconf.Spec.Agency
import Nixconf.Spec.Binding
import Nixconf.Spec.Authority
import Nixconf.Spec.StateSafety
import Nixconf.Spec.Spacetime
import Nixconf.Thm.Agency
import Nixconf.Thm.Binding
import Nixconf.Thm.Authority
import Nixconf.Thm.StateSafety
import Nixconf.Thm.Spacetime
import Nixconf.Oracle.Protocol
