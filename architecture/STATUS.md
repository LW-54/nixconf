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

Live status dashboard for the `nixconf` ground-up architectural redesign on branch `design/v2`. **Current Phase**: **Phase 2 — Foundational Architecture Derivation (Decision 1 ratified in `ADR-0002`; Decision 2 in `discussion` via `RES-0008`)**. Decision 1 adopted **Model A (Fractal Uniform Agency & Non-Piercing Boundaries)**, proving standalone portability and substrate polymorphism emerge purely from ambient Superagent scope without entity bifurcation. Now deciding **Decision 2 (Promise Algebra, Scoped Binding & Boundary Projection)**.
<!-- abstract:end -->

# Redesign Program Status

- **Active Branch**: `design/v2` (branched from `main` at `90c0b02`)
- **Current Phase**: **Phase 2 — Foundational Architecture Derivation (Decision 2 in `discussion`)**
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

- **Ratified Foundational Decisions**:
  - **`ADR-0002` (`accepted`) — Decision 1**: Fractal Uniform Agency (Model A) & Non-Piercing Superagent Boundaries ($\Sigma$). Standalone portability and substrate heterogeneity emerge from ambient Superagent scope; Hard-vs-Soft enforcement and Lampson guards attach to Promises and Boundaries.
  - *(`ADR-0001` remains preserved in lineage and will be formally superseded upon Decision 2 ratification.)*
- **Current Decision Step — Decision 2 (Promise Algebra, Scoped Binding & Boundary Projection)**:
  - Formal analysis completed in `RES-0008` covering Hard vs. Soft/Conditional promise anatomy, **Fork 2a** (Binding Topology: `B1` Explicit Wiring vs. `B2` Pure Broadcast vs. `B3` Cardinality-Checked Scoped Binding + Superagent Disambiguation), **Fork 2b** (Boundary Projection: `P-Explicit` vs. `P-Bubble` vs. `P-Dual`), and static compilation soundness (Stratification + Commutativity).
- **Ordered Next Decisions (One at a Time)**:
  - Decision 3: Hard Boundaries — Cryptographic Identity, Lampson Authority & Proper-Time State Ownership.
  - Decision 4: Spacetime Dynamics — Calibration, Convergence, Assessment & the $\gamma(3,4)$ SST Graph.

---

## Assumptions Tracker Snapshot
- Total logged: **13** (`A-001` .. `A-013`)
- Validated: **2** (`A-002` via `EXP-0001`, `A-011` via `RES-0001`)
- Experimenting: **1** (`A-001` via `EXP-0001`)
- Unverified: **10** (`A-003` .. `A-010`, `A-012`, `A-013`)
- Falsified: **0**
