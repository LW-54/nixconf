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

Live status dashboard for the `nixconf` ground-up architectural redesign on branch `design/v2`. **Current Phase**: **Phase 1 Complete** (`AUD-0001` through `AUD-0004` finished with full quantitative metrics, live `astrolabe` baselines, and fleet boundary constraints); **Ready to begin Phase 2 — First-Principles Core Foundations (`RFD-0001`: Fundamental Ontology, Primitives & Composition Algebra)**.
<!-- abstract:end -->

# Redesign Program Status

- **Active Branch**: `design/v2` (branched from `main` at `90c0b02`)
- **Current Phase**: **Phase 1 Complete → Transitioning to Phase 2 (`RFD-0001`: First-Principles Core Foundations)**
- **Last Updated**: 2026-11-23

---

## Phase Progress

| Phase | Name | Status | Key Outputs |
| :---: | :--- | :--- | :--- |
| **0** | Methodology, Knowledge System & Calibrated Charter | **Complete** | `README.md`, `INDEX.md`, `CHARTER.md` (calibrated), `ASSUMPTIONS.md`, `RES-0001`, `RES-0002`, templates, `archive/ARC-0001..0002`, `journal/` |
| **1** | Empirical Current-State Audit & Boundary-Constraint Harvest | **Complete** | `AUD-0001` (Primitives & Entanglement), `AUD-0002` (Meta, Tooling, Rust & Deps), `AUD-0003` (Testing, CI, Secrets & Ops), `AUD-0004` (Fleet & Capability Constraints) |
| **2** | Core Foundations (Blank-Sheet RFDs) | **Next** | `RFD-0001` (Fundamental Primitives & Composition across any layer/medium), `RFD-0002` (Structural Invariants & Verification), `RFD-0003` (Tooling & Pure Native/Rust) |
| **3** | Domain Architectures (Morphological DSE + Benchmarks) | Queued | `RFD-0004` (Mesh & Fleet), `RFD-0005` (GitOps & Updates), `RFD-0006` (Distributed Storage/Compute), `RFD-0007` (Observability & Analysis), `RFD-0008` (Docs & LLM Context) |
| **4** | Cross-Consistency Assessment & ADR Crystallization | Queued | Cross-RFD CCA matrix, `adrs/ADR-0001..N`, validation experiments |
| **5** | Formal v2 Specification & Migration Plan | Queued | `spec/` (arc42-inspired formal blueprint) + staged migration plan |

---

## Active & Open Items

- **Phase 1 Key Empirical Takeaways**:
  - ~50k LOC total: hosts = 506 LOC (1%), features = 7.1k LOC (14%), while `primitives/` (4.9k), `contracts/` (14.1k incl. 7.3k Grafana JSON!), and `meta/` (15.0k incl. 5.3k Nix CPG!) account for ~78%.
  - Confirmed root causes of entanglement/fragility: 226 untyped `internal.*` globals, 1:1 implementation lock-in (`noConflict = length <= 1`), fragile `tryEval`/`_file` string-scraping, 6× manual `mkOption`/`mkConfig` per service, cross-host `self.nixosConfigurations` eval coupling in `hub.nix` & `storage/cli.nix`, zero enforcement on `meta/` docs or Rust tests, 3 disconnected Rust codebases, non-standard `.tack/` lockfile, residual `${self}` leak in `rclone/mounts.nix:132`, and only 9/34 features usable standalone via `nix run`.
  - Live `astrolabe` RAM baseline: observability uses ~1.59 GiB (Grafana 513M + Alloy 458M + VM 436M + VL 83M + Alertmanager/vmalert 96M) vs ~291 MiB for all edge/auth/app services combined.
- **Immediate Next Step (Phase 2)**:
  - Launch **`RFD-0001`** from a complete blank sheet — exploring the full manifold of fundamental primitives across all categories (authoring language/medium, composition algebra, concept↔backend polymorphism, multi-instance & sub-component swapping, standalone vs OS stratification, dependency/pinning boundary).

---

## Assumptions Tracker Snapshot
- Total logged: **13** (`A-001` .. `A-013`)
- Validated: **1** (`A-011` — Progressive Disclosure vs Vector RAG)
- Unverified: **12** (`A-001` .. `A-010`, `A-012`, `A-013`)
- Falsified: **0**
