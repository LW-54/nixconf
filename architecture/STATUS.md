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

Live status dashboard for the `nixconf` ground-up architectural redesign on branch `design/v2`. **Current Phase**: Phase 0 complete (Methodology, Charter, Assumptions Ledger, Templates, and Phase 0 Meta-Research archived and committed); **Ready to begin Phase 1** (Objective Empirical Current-State Audit of `nixconf` + Hard Boundary-Constraint Harvest across all planned hosts and capabilities).
<!-- abstract:end -->

# Redesign Program Status

- **Active Branch**: `design/v2` (branched from `main` at `90c0b02`)
- **Current Phase**: **Phase 0 Complete → Starting Phase 1 (Empirical Current-State Audit & Constraint Harvest)**
- **Last Updated**: 2026-11-23

---

## Phase Progress

| Phase | Name | Status | Key Outputs |
| :---: | :--- | :--- | :--- |
| **0** | Methodology, Knowledge System & Charter | **Complete** | `README.md`, `INDEX.md`, `CHARTER.md`, `ASSUMPTIONS.md`, `RES-0001`, `RES-0002`, templates, `archive/`, `journal/` |
| **1** | Empirical Current-State Audit & Boundary-Constraint Harvest | **Next** | `audit/AUD-0001..0004` (Primitives/Modules, Meta/Tooling/Rust, Perf/CI/Docs/Secrets, Planned Fleet/Capability Constraints) |
| **2** | Core Foundations (First-Principles RFDs) | Queued | `RFD-0001` (Primitives & Composition), `RFD-0002` (Invariants & Verification), `RFD-0003` (Tooling & Pure Rust) |
| **3** | Domain Architectures (Morphological DSE + Benchmarks) | Queued | `RFD-0004` (Mesh & Fleet), `RFD-0005` (GitOps & Updates), `RFD-0006` (Distributed Storage/Compute), `RFD-0007` (Observability & Analysis), `RFD-0008` (Docs & LLM Context) |
| **4** | Cross-Consistency Assessment & ADR Crystallization | Queued | Cross-RFD CCA matrix, `adrs/ADR-0001..N`, validation experiments |
| **5** | Formal v2 Specification & Migration Plan | Queued | `spec/` (arc42-inspired formal blueprint) + staged migration plan |

---

## Active & Open Items

- **Open Decisions**: None blocking Phase 1; Phase 0 methodology, dedicated branch (`design/v2`), zero-bias framing, and append-only progressive-disclosure knowledge system are ratified.
- **Immediate Next Step (Phase 1)**:
  1. `AUD-0001`: Audit current `primitives/` & `modules/` (contracts, implementations, features, hosts) — separate genuine primitives from accidental complexity/shallow wrappers.
  2. `AUD-0002`: Audit current `meta/`, Rust codebases, CLI tools, docs enforcement gaps, and redundancies.
  3. `AUD-0003`: Audit current build/eval performance, cache isolation, testing tiers, CI, secrets, and monitoring baseline (with live numbers from `astrolabe`).
  4. `AUD-0004`: Harvest hard problem-domain constraints from all planned hosts (`x86_64`, `aarch64` RPi, WSL, Live USB ISO, ZenBook Duo, TUF laptop, Chromebook tablet) and planned capabilities — strictly requirement-level, zero tool bias.

---

## Assumptions Tracker Snapshot
- Total logged: **12** (`A-001` .. `A-012`)
- Validated: **1** (`A-011` — Progressive Disclosure vs Vector RAG)
- Unverified: **11** (`A-001` .. `A-010`, `A-012`)
- Falsified: **0**
