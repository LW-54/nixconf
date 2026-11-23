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

Live status dashboard for the `nixconf` ground-up architectural redesign on branch `design/v2`. **Current Phase**: **Phase 2 (`RFD-0001` in `discussion`)** — completed broad manifold research (`RES-0003`), empirical multi-provider prototype (`EXP-0001`: 175ms, zero recursion, validating `A-002`), and drafted `RFD-0001` deriving 5 irreducible primitive categories and 3 Pareto candidates awaiting user co-design decisions.
<!-- abstract:end -->

# Redesign Program Status

- **Active Branch**: `design/v2` (branched from `main` at `90c0b02`)
- **Current Phase**: **Phase 2 — Core Foundations (`RFD-0001` in active `discussion`)**
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

- **Ratified Decisions**:
  - **`ADR-0001` (`accepted`)**: Pillar 1 — Effect–Handler Composability (strictly implementation-agnostic; syntax/language/serialization like M1 vs M2 explicitly deferred).
- **Current Decision Step (Meta-Primitives — Coordinate System)**:
  - Choosing the cleanest, literature-grounded coordinate system for the remaining abstract foundational pillars before exploring Pillar 2 (`RES-0005` compares **A: Saltzer & Kaashoek**, **B: Promise Theory + Cybernetics**, **C: Space × Time × Authority × Truth**).
- **Next After `RFD-0001` Ratification**: Crystallize `ADR-0001` (+ `ADR-0002` for pinning/standalone if split), then launch `RFD-0002` (Structural Invariants & Verification) and `RFD-0003` (Auxiliary Tooling & Pure Rust Integration).

---

## Assumptions Tracker Snapshot
- Total logged: **13** (`A-001` .. `A-013`)
- Validated: **2** (`A-002` via `EXP-0001`, `A-011` via `RES-0001`)
- Experimenting: **1** (`A-001` via `EXP-0001`)
- Unverified: **10** (`A-003` .. `A-010`, `A-012`, `A-013`)
- Falsified: **0**
