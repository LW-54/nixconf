---
id: ARCH-STATUS
title: Redesign Program Live Status Dashboard
type: status
status: active
created: 2026-11-23
updated: 2026-11-24
domain: meta
tags: [status, dashboard, roadmap]
summary: Single-page live operational state of the nixconf v2 architectural redesign on branch design/v2.
---

<!-- abstract:start -->
## Executive Abstract

Live status dashboard for the `nixconf` ground-up architectural redesign on branch `design/v2`. **Current Phase**: **Phase 2 (2A + 2B v2.0) COMPLETE & FORMALLY VERIFIED → Entering Phase 3 (Risk-Driven Realization & Walking Skeleton, `RES-0014`)**. Phase 3 follows a DSM-partitioned 4-stage plan (`3A` Structural Kernel → Mandatory **`W1` Walking Skeleton Gate** → `3B` Trust/Mesh/Convergence Plane → `3C` Pluggable Capability Domains → `3D` CCA & **`M1-Sunset`** Zero-Carry-Forward Safe Migration), starting with **Stage `3A.1`: Authoring Medium, Boundary-First Engine & Nix↔Rust Seam**.
<!-- abstract:end -->

# Redesign Program Status

- **Active Branch**: `design/v2` (branched from `main` at `90c0b02`)
- **Current Phase**: **Phase 3 — Stage 3A.1 Launching (`RES-0014` Methodology Ratified: `W1` + `M1-Sunset`)**
- **Last Updated**: 2026-11-24

---

## Phase Progress

| Phase | Name | Status | Key Outputs |
| :---: | :--- | :--- | :--- |
| **0** | Methodology, Knowledge System & Calibrated Charter | **Complete** | `README.md`, `INDEX.md`, `CHARTER.md` (`B > E > D > A > C`), `ASSUMPTIONS.md`, `RES-0001`, `RES-0002`, templates, `archive/ARC-0001..0002`, `journal/` |
| **1** | Empirical Current-State Audit & Boundary-Constraint Harvest | **Complete** | `AUD-0001`..`AUD-0004` (50k LOC census, live `astrolabe` baseline, fleet boundary matrix) |
| **2A** | Foundational Decisions & Red-Team Synthesis | **Complete** | `RES-0003`..`RES-0011`, `EXP-0001`..`EXP-0004`, `ADR-0002`..`ADR-0006` (`ADR-0001` superseded), `spec/FOUNDATION.md` |
| **2B** | Formal Mathematical Specification, Rival-Theory Audit & Production Verification | **Complete** | `RES-0012`..`RES-0013`, `EXP-0005` (v0.2), `ADR-0007`, **`PAPER-FOUNDATION` v2.0**, `architecture/formal/` (**35 Lean 4 theorems**, **11 TLC invariants + 8 tests**, **2,005-fleet 1:1 modular Rust↔Lean4 DRT**) |
| **3** | Concrete Realization, Risk Burn-Down & Walking Skeleton (`RES-0014`) | **Active (`3A.1`)** | **3A** Structural Kernel → **`W1` Walking Skeleton Gate** → **3B** Trust/Mesh/Convergence → **3C** Pluggable Capabilities → **3D** CCA & `M1-Sunset` Cutover Plan |
| **4** | Full v2 Implementation & `M1-Sunset` Cutover (`x240` → `astrolabe`) | Queued | Production build on top of Walking Skeleton + zero-carry-forward live cutover & legacy deletion |

---

## Active & Open Items

- **Ratified Foundational Decisions**:
  - **`ADR-0002` (`accepted`) — Decision 1**: Fractal Uniform Agency (Model A) & Non-Piercing Superagent Boundaries ($\Sigma$).
  - **`ADR-0003` (`accepted`, supersedes `ADR-0001`) — Decision 2**: Unified Hard/Soft Conditional Promise Algebra, `B3` Cardinality-Checked Scoped Binding, `P-Dual` (Strict `P-Explicit` Dressed Superagents + Transparent Profiles), and Strict Stratification + Commutative Keyed Aggregation.
  - **`ADR-0004` (`accepted`) — Decision 3**: `L3+` Offline Root Identity + Attenuated Capabilities + **Boolean Set-Algebra Authorization** ($\cup, \cap, \in, \setminus$ over agent attributes/groups) and `S2+` **Mandatory Agent-Declared State-As-Promise** with open composable traits.
  - **`ADR-0005` (`accepted`) — Decision 4**: `C3` Triadic Calibrated Autonomous Pull with self-assessing atomic switches & auto-rollback, and `E3` Semantic Spacetime $\gamma(3,4)$ universal epistemic spine over specialized bulk telemetry & trust-budgeted assessment.
  - **`ADR-0006` (`accepted`) — Foundational Corollaries**: 7 red-team corollaries (`C1`–`C7`) closing lifecycle genesis/revocation/break-glass, Boundary-First Stratification, Ousterhout/foreign wrapping, Budgeted Capacity, epistemic zoom, portable user-space, and tri-purpose probes.
  - **`ADR-0007` (`accepted`) — Phase 2B Formal Verification (`F3-b`)**: AWS Cedar VGD (Lean 4 verified oracle + Quint/TLC models + Rust production engine + DRT) + 4 formal upgrades (Cedar `forbid`-dominance, Biscuit offline attenuation, TUF downgrade/freeze/mix-and-match defense on `C3`, CALM monotonicity on `S2+`).
  - **Verified Constitution & Paper**: [`spec/FOUNDATION.md`](spec/FOUNDATION.md) + [`paper/FOUNDATION-PAPER.md`](paper/FOUNDATION-PAPER.md) (**Phase 2A + 2B COMPLETE**).
- **Next Step — Phase 3 Launch (`RES-0014` — `W1` Walking Skeleton + `M1-Sunset`)**:
  - Begin **Stage `3A.1` — Core Authoring Medium, Boundary-First Engine & Nix↔Rust Seam** strictly governed by the machine-verified contracts of `PAPER-FOUNDATION` & `ADR-0002`..`ADR-0007` (and optionally settle permanent project naming before crate/CLI names crystallize).

---

## Assumptions Tracker Snapshot
- Total logged: **13** (`A-001` .. `A-013`)
- Validated: **2** (`A-002` via `EXP-0001`, `A-011` via `RES-0001`)
- Experimenting: **1** (`A-001` via `EXP-0001`)
- Unverified: **10** (`A-003` .. `A-010`, `A-012`, `A-013`)
- Falsified: **0**
