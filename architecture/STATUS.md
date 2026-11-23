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

Live status dashboard for the `nixconf` ground-up architectural redesign on branch `design/v2`. **Current Phase**: **Phase 2 — Foundational Architecture Derivation (Decisions 1–2 ratified in `ADR-0002` & `ADR-0003`, superseding `ADR-0001`; Decision 3 in `discussion` via `RES-0009`)**. Now deciding **Decision 3 — Hard Boundaries: Cryptographic Identity, Lampson Authority (`L1`/`L2`/`L3`) & Proper-Time State Ownership (`S1`/`S2`/`S3`)**.
<!-- abstract:end -->

# Redesign Program Status

- **Active Branch**: `design/v2` (branched from `main` at `90c0b02`)
- **Current Phase**: **Phase 2 — Foundational Architecture Derivation (Decision 3 in `discussion`)**
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
  - **`ADR-0002` (`accepted`) — Decision 1**: Fractal Uniform Agency (Model A) & Non-Piercing Superagent Boundaries ($\Sigma$).
  - **`ADR-0003` (`accepted`, supersedes `ADR-0001`) — Decision 2**: Unified Hard/Soft Conditional Promise Algebra, `B3` Cardinality-Checked Scoped Binding, `P-Dual` (Strict `P-Explicit` Dressed Superagents + Transparent Profiles), and Strict Stratification + Commutative Keyed Aggregation.
- **Current Decision Step — Decision 3 (Hard Boundaries: Cryptographic Identity, Lampson Authority & Proper-Time State Ownership)**:
  - Formal analysis completed in `RES-0009` covering **Fork 3a** (Authority: `L1` Static Identity ACLs vs. `L2` Pure Dynamic Capabilities vs. `L3` Offline Root Identity + Attenuated Capabilities + Mechanical Compromise Trust Tiers) and **Fork 3b** (Proper-Time State Ownership & CAP/FLP: `S1` Implicit Host Filesystems vs. `S2` Mandatory Agent-Declared State-As-Promise Taxonomy vs. `S3` Pure Externalized Statelessness).
- **Ordered Next Decision**:
  - Decision 4 (Final Foundational Step): Spacetime Dynamics — Calibration, Convergence, Assessment & the $\gamma(3,4)$ SST Graph.

---

## Assumptions Tracker Snapshot
- Total logged: **13** (`A-001` .. `A-013`)
- Validated: **2** (`A-002` via `EXP-0001`, `A-011` via `RES-0001`)
- Experimenting: **1** (`A-001` via `EXP-0001`)
- Unverified: **10** (`A-003` .. `A-010`, `A-012`, `A-013`)
- Falsified: **0**
