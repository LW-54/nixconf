---
id: FORMAL-README
title: Production Verification Architecture — 4-Layer Lean 4 (cedar-lean), Modular Quint & Rust DRT
type: spec
status: active
created: 2026-11-24
updated: 2026-11-24
domain: foundations
tags: [formal-verification, lean4, cedar-lean, quint, rust, drt, architecture]
summary: Documents the production-grade modular organization of architecture/formal/ modeled directly on AWS cedar-spec (Data -> Spec -> Thm -> Oracle), Informal Systems modular single-record Quint specs, and 1:1 modular Rust DRT engine.
---

<!-- abstract:start -->
## Executive Abstract

Documents the researched, production-ready architecture of `architecture/formal/` designed to live permanently inside `nixconf` v2 under **AWS Cedar Verification-Guided Development (`F3-b`, `ADR-0007`)**:
1. **Lean 4 (`lean/`, modeled on `cedar-policy/cedar-spec`)**: Strict 4-layer acyclic hierarchy — **`Nixconf/Data/`** (shared `AttrExpr` Boolean Lattice + permutation lemmas) → **`Nixconf/Spec/`** (tiny, proof-free executable semantics returning structured diagnostics) → **`Nixconf/Thm/`** (1:1 mirror containing **35 machine-checked theorems**, zero `sorryAx`, isolated so proof edits never recompile `Spec` or `Oracle`) → **`Nixconf/Oracle/`** (thin JSON boundary for DRT).
2. **Quint (`quint/`, modeled on Informal Systems best practices)**: Shared pure `types.qnt` + 3 cohesive single-record protocol modules (`triadic_pull.qnt`, `lifecycle_recovery.qnt`, `conditional_degradation.qnt`) with **8 executable `quint test` runs** and **100% exhaustive TLC BFS proofs** (`1,878,049` + `54` + `77` transitions, `0` remaining).
3. **Rust DRT (`drt/`)**: Modular `engine/{attr_expr,agency,binding,authority,state}.rs` mirroring `Nixconf/Spec/` 1:1 (ready to promote directly into Phase 3's `nixconf-core` Cargo crate), verified bit-for-bit against Lean 4 across `2,005` fleets (`0` divergences).
<!-- abstract:end -->

# Formal Verification Suite Architecture (`architecture/formal/`)

## 1. Directory Layout & Dependency DAG

```text
architecture/formal/
├── lean/                            # Pure Lean 4.35.0 core (ZERO Mathlib, 7.27s cold)
│   ├── lakefile.toml
│   ├── Nixconf.lean                 # Root library export
│   └── Nixconf/
│       ├── Data/                    # Layer 0 — Shared Algebraic Primitives
│       │   ├── AttrExpr.lean        #   Boolean Lattice (∪, ∩, \, ¬) shared by Authority, Binding & StateSafety!
│       │   └── ListLemmas.lean      #   Reusable permutation / foldl / all / any proof lemmas
│       ├── Spec/                    # Layer 1 — Pure Readable Executable Semantics (ZERO PROOFS!)
│       │   ├── Agency.lean          #   Fractal Agents, P-Dual, Boundary-First, P-Explicit Conformance, Standalone
│       │   ├── Binding.lean         #   B3 (Exclusive/Broadcast/Partitioned-AttrExpr/Budget+Priority), Multi-Stratum
│       │   ├── Authority.lean       #   Cedar AuthResponse (forbid-dominates), Biscuit Attenuation, Combined Delegation
│       │   ├── StateSafety.lean     #   Open AttrExpr State-As-Promise + CALM Logical Monotonicity
│       │   └── Spacetime.lean       #   SST γ(3,4) + Full 4×4 Burgess & Couch Weak-Transitivity Table
│       ├── Thm/                     # Layer 2 — 35 Machine-Checked Theorems (1:1 mirror of Spec/, ZERO sorry!)
│       │   ├── Agency.lean          #   7 theorems (Non-Piercing, No-Lying-Offers, No-Leaked-Uses, Standalone iff)
│       │   ├── Binding.lean         #   8 theorems (Perm Order-Invariance, Partition Disjointness, Priority, Multi-Stratum)
│       │   ├── Authority.lean       #   10 theorems (Default-Deny, Forbid, Perm, Attenuation, Combined Delegation, Blast-Radius)
│       │   ├── StateSafety.lean     #   4 theorems (Open-Trait Live-ISO Impossibility, CALM, Backup Coverage)
│       │   └── Spacetime.lean       #   6 theorems (Acyclicity, Zero-Impact, Epistemic Zoom, 4×4 Associativity & Non-Forging)
│       ├── Oracle/                  # Layer 3 — Thin JSON Interchange Boundary (isolated from Spec & Thm)
│       │   ├── Protocol.lean
│       │   └── Main.lean            #   Native NDJSON oracle executable (`nixconf-oracle`)
│       └── Audit.lean               # `#print axioms` verification of all 35 theorems (0 sorryAx!)
│
├── quint/                           # Modular Informal Systems Single-Record Quint 0.33.1 Specs
│   ├── types.qnt                    #   Shared pure domain types & helpers
│   ├── triadic_pull.qnt             #   C3 + TUF + Mid-Switch Crash Recovery + Human Lock Serialization (3 tests + TLC)
│   ├── lifecycle_recovery.qnt       #   C1 Genesis t=0 + Revocation/Rotation + Zero-Infra Break-Glass (3 tests + TLC)
│   └── conditional_degradation.qnt  #   Soft +b|C + C4 Dynamic Power/Thermal Opportunistic Compute (2 tests + TLC)
│
└── drt/                             # Modular Rust Production Verifier + AWS Cedar DRT Harness
    ├── engine/                      #   1:1 mirror of Nixconf/Spec/ (promotes cleanly to Phase 3 `nixconf-core`!)
    │   ├── mod.rs
    │   ├── attr_expr.rs
    │   ├── agency.rs
    │   ├── binding.rs
    │   ├── authority.rs
    │   └── state.rs
    ├── wire.rs                      #   JSON wire protocol mirroring Nixconf/Oracle/Protocol.lean
    ├── gen.rs                       #   5 concrete fleet regression scenarios + 2,000-fleet DRT fuzzer
    └── main.rs                      #   Differential runner comparing Rust engine vs Lean 4 oracle
```

## 2. Reproducible Verification Commands
1. **Lean 4 Proofs & Axiom Audit** *(requires `pkgs.lean4` + matching `stdenv.cc`)*:
   - `lake --dir=architecture/formal/lean build`
   - `lake --dir=architecture/formal/lean env lean architecture/formal/lean/Nixconf/Audit.lean`
2. **Quint Unit Tests & Exhaustive TLC Verification** *(requires `pkgs.quint`)*:
   - `quint test architecture/formal/quint/{triadic_pull,lifecycle_recovery,conditional_degradation}.qnt`
   - `quint verify --backend=tlc --invariant=allInvariants architecture/formal/quint/<module>.qnt`
3. **Rust ↔ Lean 4 Differential Randomized Testing**:
   - `rustc -O architecture/formal/drt/main.rs -o /tmp/nixconf-drt && /tmp/nixconf-drt architecture/formal/lean/.lake/build/bin/nixconf-oracle`
