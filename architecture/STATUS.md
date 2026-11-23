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

Live status dashboard for the `nixconf` ground-up architectural redesign on branch `design/v2`. **Current Phase**: **Phase 2 — Foundational Architecture Red-Team Review (Decisions 1–4 ratified in `ADR-0002`..`ADR-0005`; adversarial CCA red-team audit completed in `RES-0011`)**. Reviewing 7 high-signal gaps & unification opportunities surfaced by `RES-0011` before finalizing the Theoretical Foundation baseline and entering Phase 3 (Concrete Realization RFDs).
<!-- abstract:end -->

# Redesign Program Status

- **Active Branch**: `design/v2` (branched from `main` at `90c0b02`)
- **Current Phase**: **Phase 2 — Cross-Consistency Red-Team Review (`RES-0011` in `discussion`)**
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
  - **`ADR-0004` (`accepted`) — Decision 3**: `L3+` Offline Root Identity + Attenuated Capabilities + **Boolean Set-Algebra Authorization** ($\cup, \cap, \in, \setminus$ over agent attributes/groups) and `S2+` **Mandatory Agent-Declared State-As-Promise** with open composable traits.
  - **`ADR-0005` (`accepted`) — Decision 4**: `C3` Triadic Calibrated Autonomous Pull with self-assessing atomic switches & auto-rollback, and `E3` Semantic Spacetime $\gamma(3,4)$ universal epistemic spine over specialized bulk telemetry & trust-budgeted assessment.
- **Current Step — Adversarial Red-Team Review (`RES-0011`)**:
  - Audited `ADR-0002`..`ADR-0005` end-to-end against `CHARTER.md` and `AUD-0001`..`AUD-0004`. Found zero fatal contradictions, **4 genuine gaps** (Lifecycle Genesis/Revocation/Break-Glass, Boundary-First Stratification $\Pi_{\text{ext}} \perp \text{Interior}$, Ousterhout/Foreign-Agent Wrapping Discipline, Quantitative Budgeted Capacity & Power Conditions), **1 paradox fix** (Operational Non-Piercing vs. Authorized Epistemic Zoom), and **2 high-leverage unification opportunities** (Portable User-Space Boundary, Tri-Purpose Assessment Probes $\alpha$).
- **Next After Red-Team Resolution**: Crystallize foundational corollaries (`ADR-0006` + Master Theoretical Foundation spec), then enter **Phase 3 — Concrete Realization & Engineering RFDs**.

---

## Assumptions Tracker Snapshot
- Total logged: **13** (`A-001` .. `A-013`)
- Validated: **2** (`A-002` via `EXP-0001`, `A-011` via `RES-0001`)
- Experimenting: **1** (`A-001` via `EXP-0001`)
- Unverified: **10** (`A-003` .. `A-010`, `A-012`, `A-013`)
- Falsified: **0**
