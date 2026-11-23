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

Live status dashboard for the `nixconf` ground-up architectural redesign on branch `design/v2`. **Current Phase**: **Phase 2 — Ground-Up Foundational Derivation from Promise Theory + Semantic Spacetime (`RES-0007`)**. Following user direction not to assume `ADR-0001` or rigid "pillar" buckets, we derived the unified PT+SST+Hard-Enforcement theoretical bedrock against 5 physical constraints (`T1`–`T5`) and isolated **Decision 1 (Ontology of Agency, Scale & Boundaries $\Sigma$)** comparing Models A, B, and C.
<!-- abstract:end -->

# Redesign Program Status

- **Active Branch**: `design/v2` (branched from `main` at `90c0b02`)
- **Current Phase**: **Phase 2 — Foundational Architecture Derivation (Decision 1 in `discussion`)**
- **Last Updated**: 2026-11-23

---

## Phase Progress

| Phase | Name | Status | Key Outputs |
| :---: | :--- | :--- | :--- |
| **0** | Methodology, Knowledge System & Calibrated Charter | **Complete** | `README.md`, `INDEX.md`, `CHARTER.md` (`B > E > D > A > C`), `ASSUMPTIONS.md`, `RES-0001`, `RES-0002`, templates, `archive/ARC-0001..0002`, `journal/` |
| **1** | Empirical Current-State Audit & Boundary-Constraint Harvest | **Complete** | `AUD-0001`..`AUD-0004` (50k LOC census, live `astrolabe` baseline, fleet boundary matrix) |
| **2** | Core Foundations (Blank-Sheet RFDs) | **In Progress** | `RES-0003`, `EXP-0001` (completed), **`RFD-0001` (`discussion`)**; queued: `RFD-0002`, `RFD-0003` |
| **3** | Domain Architectures (Morphological DSE + Benchmarks) | Queued | `RFD-0004`..`RFD-0008` |
| **4** | Cross-Consistency Assessment & ADR Crystallization | Queued | Cross-RFD CCA matrix, `adrs/ADR-0001..N` |
| **5** | Formal v2 Specification & Migration Plan | Queued | `spec/` + staged migration plan |

---

## Active & Open Items

- **Previous Working Record (Under Re-Derivation, Not Assumed)**:
  - **`ADR-0001` (`accepted`, subject to superseding)**: Effect–Handler Composability — re-evaluated from scratch in `RES-0007` and shown to emerge as a special case (hard-closed interior binding) of Promise Theory's complementary promises inside a Dressed Superagent, while missing scope/non-piercing, conditional degradation, hard-vs-soft enforcement, and SST proper time.
- **Current Decision Step — Decision 1 (Ontology of Agency, Scale & Boundaries $\Sigma$)**:
  - Formal derivation completed in `RES-0007` colliding Bergstra & Burgess Promise Theory + Burgess & Couch Semantic Spacetime (`arXiv:2506.07756`, `SSTorytime`) against 5 hard engineering constraints (`T1`–`T5`).
  - Awaiting user decision on **Decision 1** among three ontologies: **Model A** (Fractal Uniform Agency), **Model B** (Stratified Two-Regime Domains), or **Model C** (Scale-Unified Agents with Typed Boundary Modalities).
- **Ordered Next Decisions (One at a Time)**:
  - Decision 2: Promise Algebra, Scope, Non-Piercing Superagents & Compilation Soundness (formally superseding/refining `ADR-0001`).
  - Decision 3: Hard Boundaries — Cryptographic Identity, Lampson Authority & Proper-Time State Ownership.
  - Decision 4: Spacetime Dynamics — Calibration, Convergence, Assessment & the $\gamma(3,4)$ SST Graph.

---

## Assumptions Tracker Snapshot
- Total logged: **13** (`A-001` .. `A-013`)
- Validated: **2** (`A-002` via `EXP-0001`, `A-011` via `RES-0001`)
- Experimenting: **1** (`A-001` via `EXP-0001`)
- Unverified: **10** (`A-003` .. `A-010`, `A-012`, `A-013`)
- Falsified: **0**
