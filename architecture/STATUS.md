---
id: ARCH-STATUS
title: Redesign Program Live Status Dashboard
type: status
status: active
created: 2026-11-23
updated: 2026-11-23
domain: meta
tags: [status, dashboard, roadmap]
summary: Single-page live operational state of the nixconf v2 architectural redesign on branch design/v2.
---

<!-- abstract:start -->
## Executive Abstract

Live status dashboard for the `nixconf` ground-up architectural redesign on branch `design/v2`. **Current Phase**: **Phase 2B — Rigorous Formalization, Rival-Theory Comparative Audit & Machine-Checked Proofs (`RES-0012`)**. Re-opened Phase 2 honestly after recognizing that `ADR-0002`..`ADR-0006` + `spec/FOUNDATION.md` are still structured prose rather than mathematically formalized & machine-verified theorems. Evaluating Formalization & Production-Verification architectures (`F1`–`F4`) using pinned `lean4 4.35.0`, `quint 0.33.1`/`tlaplus 1.7.4`, and `z3 5.3.2` (grounded in AWS Cedar OOPSLA 2024).
<!-- abstract:end -->

# Redesign Program Status

- **Active Branch**: `design/v2` (branched from `main` at `90c0b02`)
- **Current Phase**: **Phase 2B — Formalization & Machine-Checked Verification Strategy (`RES-0012` in `discussion`)**
- **Last Updated**: 2026-11-24

---

## Phase Progress

| Phase | Name | Status | Key Outputs |
| :---: | :--- | :--- | :--- |
| **0** | Methodology, Knowledge System & Calibrated Charter | **Complete** | `README.md`, `INDEX.md`, `CHARTER.md` (`B > E > D > A > C`), `ASSUMPTIONS.md`, `RES-0001`, `RES-0002`, templates, `archive/ARC-0001..0002`, `journal/` |
| **1** | Empirical Current-State Audit & Boundary-Constraint Harvest | **Complete** | `AUD-0001`..`AUD-0004` (50k LOC census, live `astrolabe` baseline, fleet boundary matrix) |
| **2A** | Foundational Decisions & Red-Team Synthesis | **Complete** | `RES-0003`..`RES-0011`, `EXP-0001`..`EXP-0004`, `ADR-0002`..`ADR-0006` (`ADR-0001` superseded), `spec/FOUNDATION.md` (prose baseline) |
| **2B** | Formal Mathematical Specification, Rival-Theory Audit & Proofs | **In Progress** | `RES-0012` (`F1`–`F4` formalization strategy: Lean 4 + Quint/TLA+ + Formal Paper + production CI verification) |
| **3** | Concrete Realization & Domain RFDs (`R1`–`R7`) | **Queued (After 2B)** | `R1` Medium/Engine/Nix↔Rust → `R2` Pinning/Rust/Standalone → `R3` Mesh/Secrets/Onboarding → `R4` GitOps/Cache/Mirror → `R5` Storage/Compute → `R6` Observability/AI → `R7` SST/Docs/UX |
| **4** | Cross-Consistency Assessment & ADR Crystallization | Queued | Cross-RFD CCA matrix, `adrs/ADR-0001..N` |
| **5** | Formal v2 Specification & Migration Plan | Queued | `spec/` + staged migration plan |

---

## Active & Open Items

- **Ratified Foundational Decisions**:
  - **`ADR-0002` (`accepted`) — Decision 1**: Fractal Uniform Agency (Model A) & Non-Piercing Superagent Boundaries ($\Sigma$).
  - **`ADR-0003` (`accepted`, supersedes `ADR-0001`) — Decision 2**: Unified Hard/Soft Conditional Promise Algebra, `B3` Cardinality-Checked Scoped Binding, `P-Dual` (Strict `P-Explicit` Dressed Superagents + Transparent Profiles), and Strict Stratification + Commutative Keyed Aggregation.
  - **`ADR-0004` (`accepted`) — Decision 3**: `L3+` Offline Root Identity + Attenuated Capabilities + **Boolean Set-Algebra Authorization** ($\cup, \cap, \in, \setminus$ over agent attributes/groups) and `S2+` **Mandatory Agent-Declared State-As-Promise** with open composable traits.
  - **`ADR-0005` (`accepted`) — Decision 4**: `C3` Triadic Calibrated Autonomous Pull with self-assessing atomic switches & auto-rollback, and `E3` Semantic Spacetime $\gamma(3,4)$ universal epistemic spine over specialized bulk telemetry & trust-budgeted assessment.
  - **`ADR-0006` (`accepted`) — Foundational Corollaries**: 7 red-team corollaries (`C1`–`C7`) closing lifecycle genesis/revocation/break-glass, Boundary-First Stratification, Ousterhout/foreign wrapping, Budgeted Capacity, epistemic zoom, portable user-space, and tri-purpose probes.
  - **Draft Prose Constitution**: [`spec/FOUNDATION.md`](spec/FOUNDATION.md) — **Phase 2A complete; Phase 2B formalization now active**.
- **Current Step — Phase 2B Formalization Strategy (`RES-0012`)**:
  - Verified pinned `nixpkgs` ships `lean4 4.35.0`, `quint 0.33.1`, `tlaplus 1.7.4`, `z3 5.3.2`, `souffle 2.5`, `alloy 5.1.0`.
  - Awaiting user choice on Formalization Depth & Production Integration (`F1` Paper only vs. `F2` Design-time Lean 4 + Quint + Paper vs. `F3-a` Lean 4 Native Verified CI Checker vs. `F3-b` AWS Cedar Lean 4 Oracle + Rust Production Engine + Differential Testing), plus approval to run empirical toolchain benchmark (`EXP-0005`) and deep rival-theory comparative audit for Decisions 3–4.

---

## Assumptions Tracker Snapshot
- Total logged: **13** (`A-001` .. `A-013`)
- Validated: **2** (`A-002` via `EXP-0001`, `A-011` via `RES-0001`)
- Experimenting: **1** (`A-001` via `EXP-0001`)
- Unverified: **10** (`A-003` .. `A-010`, `A-012`, `A-013`)
- Falsified: **0**
