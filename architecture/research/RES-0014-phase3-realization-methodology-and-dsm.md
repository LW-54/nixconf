---
id: RES-0014
title: Phase 3 Realization Methodology — ADD 3.0, DSM Partitioning, Risk-Driven SBCE & Walking Skeleton
type: research
status: active
created: 2026-11-24
updated: 2026-11-24
domain: meta
tags: [methodology, phase-3, add-3.0, dsm, sbce, risk-driven, walking-skeleton, strangler-fig, reversibility]
assumptions: [A-001, A-002, A-003, A-004, A-005, A-006, A-007, A-008, A-009, A-010, A-012, A-013]
summary: Derives the methodical Phase 3 realization structure from SEI ADD 3.0, DSM dependency partitioning, Fairbanks Risk-Driven Architecture, Toyota SBCE, Bezos Reversibility, Cockburn Walking Skeleton (W1), and Zero-Carry-Forward Safe Migration (M1-Sunset) — replacing the naive 7-RFD paper waterfall.
---

<!-- abstract:start -->
## Executive Abstract

Establishes the ratified **Phase 3 Concrete Realization & Risk Burn-Down** methodology bridging our machine-verified Phase 2 foundation (`SPEC-FOUNDATION`, `PAPER-FOUNDATION`, `ADR-0002`..`ADR-0007`) into concrete technologies and live implementation. Rejects a naive 7-RFD Big-Design-Up-Front waterfall (`R1`–`R7` on paper) in favor of a **Design Structure Matrix (DSM)**-partitioned, **Reversibility × Blast-Radius**-weighted 4-stage program:
1. **Stage 3A — Structural Kernel (One-Way Door Cluster A)**: Authoring Medium & Nix↔Rust Seam → Entrypoints, Pinning, Standalone `nix run` & Rust/Lean CI → Heterogeneous Substrate Realization.
2. **Mandatory Empirical Gate (`W1` — Walking Skeleton)**: Minimal runnable end-to-end slice on `design/v2` (`nixconf-core` + 1 standalone `nix run` tool + 2 contrasting substrates + 1 wrapped NixOS service) benchmarked *before* designing 3B/3C.
3. **Stage 3B — Trust, Mesh & Convergence Plane (One-Way Door Cluster B)**: Cryptographic Identity/Secrets/Genesis/Break-Glass + Mesh Network Fabric + Triadic TUF Pull/Multi-Arch Cache/Git Mirror (solved together as one DSM cluster, plus targeted VM verification).
4. **Stage 3C — Pluggable Capability Domains (Contract-Heavy, Two-Way Backends)**: State/Storage/Compute, Bounded-RAM Observability/SST/AI, and Unified Human CLI/Docs/LLM Surfaces behind strict Non-Piercing Promise Contracts (`τ`).
5. **Stage 3D — Cross-Consistency Assessment (CCA), ATAM Stress-Test & `M1-Sunset` Migration Plan**: Explicit zero-carry-forward safe cutover strategy for live `astrolabe` and `x240` whose temporary adapters are 100% deleted post-migration.
<!-- abstract:end -->

# RES-0014: Phase 3 Realization Methodology & Design Structure Matrix

## 1. Literature Synthesis: Why Naive Paper Waterfalls Fail

Bridging a formally verified abstract specification (`SPEC-FOUNDATION`) into a real multi-host infrastructure system fails predictably when teams execute a flat sequence of paper RFDs:

1. **SEI Attribute-Driven Design (ADD 3.0, Cervantes & Kazman):** Concrete frameworks, languages, and infrastructure tools are *first-class architectural design concepts* chosen iteratively against Architecturally Significant Requirements (ASRs / ATAM `QA-01`–`QA-10`), documented across Module, Component-and-Connector, and Allocation views.
2. **Design Structure Matrix (DSM) Partitioning & Tearing:** Decisions with mutual feedback loops form tightly coupled clusters that *cannot* be solved cleanly in arbitrary linear order; they must be grouped into clusters (or torn explicitly with empirical prototypes).
3. **Fairbanks' Risk-Driven Model & Bezos Reversibility × Blast Radius:** Governance depth must scale with `(Irreversibility × Blast Radius)`. **One-Way Doors** (authoring medium, root crypto, trust/convergence topology) demand deep primary research, empirical benchmarks, and immutable ADRs; **Two-Way Doors** (swappable backends behind our Phase 2 Non-Piercing Superagent boundaries `Σ`) demand strict contract interfaces (`τ`) and pragmatic, low-ceremony initial backend choices.
4. **Toyota Set-Based Concurrent Engineering (SBCE):** Keep 2–4 distinct candidates alive concurrently (always including a boring/minimal baseline) and prune options *only* via empirical trade-off data against our calibrated priority order (**`B > E > D > A > C`**).
5. **Fred Brooks' Second-System Effect & Alistair Cockburn's Walking Skeleton:** Designing every subsystem on paper atop an unvalidated authoring kernel invites over-abstraction. Inserting a **Walking Skeleton Gate (`W1`)** immediately after locking the Structural Kernel tests real Nix/Rust/systemd/substrate friction while changes are still cheap.
6. **Zero-Carry-Forward Safe Migration (`M1-Sunset`):** Live production hosts (`astrolabe` running Vaultwarden, `x240`) require safe incremental cutover and atomic NixOS rollback — *without* polluting v2 core primitives with permanent legacy compatibility shims. Any migration adapter lives in a strictly time-boxed, isolated transition layer and is **100% deleted** once cutover stabilizes.

---

## 2. Design Structure Matrix (DSM) & Cluster Partitioning

Mapping directional dependencies across all remaining realization concerns yields two tight **One-Way Door** clusters followed by three **Contract-Driven / Two-Way Door** capability domains:

| Stage / Cluster | Realization Scope | Reversibility × Blast Radius | DSM Coupling Rationale |
| :--- | :--- | :--- | :--- |
| **Stage 3A: Structural Kernel** | `3A.1` Authoring Medium, Boundary-First Engine & Nix↔Rust Seam<br>`3A.2` Entrypoints, Pinning, Standalone `nix run` & Rust/Lean CI<br>`3A.3` Heterogeneous Substrate Realization (VPS/Desktop/RPi/WSL/ISO) | **One-Way Door × Fleet-Wide** | Medium ergonomics cannot be validated independently of standalone `nix run` packaging and heterogeneous substrate polymorphism. |
| **Gate `W1`: Walking Skeleton** | Minimal runnable end-to-end slice on `design/v2` (`nixconf-core` + Lean DRT + 1 standalone tool + 2 contrasting substrates + 1 wrapped NixOS service) | **Empirical Risk Gate** | Measures real eval time, cache isolation, error diagnostics, and authoring UX before 3B/3C build on top of 3A. |
| **Stage 3B: Trust, Mesh & Convergence Plane** | `3B.1` Cryptographic Identity, Secrets, Attenuated Capabilities & Genesis/Break-Glass (`L3+`/`C1`)<br>`3B.2` Mesh Network Fabric (`A-006`)<br>`3B.3` Triadic TUF Pull, Multi-Arch Cache, Git Mirror & Auto-Rollback (`C3`/`A-008`) | **One-Way Door × Security / Uptime-Critical** | Live-ISO Genesis (`t=0`), offline root keys, Zero-Infra Break-Glass, private cache reachability, and stolen-device revocation share one coupled trust boundary. |
| **Stage 3C: Pluggable Capability Domains** | `3C.1` State-As-Promise, Backups, Storage & Opportunistic Compute (`S2+`/`CALM`/`C4`)<br>`3C.2` Bounded-RAM Observability, Tri-Purpose Probes, SST Spine & AI Ops (`E3`/`C7`)<br>`3C.3` Unified Human CLI, All-Layer Enforced Docs & LLM Surfaces (`QA-04`/`QA-10`) | **Contract `τ` = Semi-Irreversible**;<br>**Backends = Two-Way Doors** | Non-Piercing Superagent boundaries (`ADR-0002` + `ADR-0003`) isolate concrete tools (VictoriaMetrics, Restic, Syncthing, Perses, etc.) as swappable providers. |
| **Stage 3D: CCA & `M1-Sunset` Cutover Plan** | Full Zwicky Cross-Consistency Assessment against `QA-01`..`QA-10` & `A-001`..`A-013` + time-boxed zero-carry-forward migration blueprint for `x240` → `astrolabe` | **Integration & Cutover Gate** | Ensures zero hidden cross-stage contradictions and zero lockout risk on live production hosts, while guaranteeing zero legacy bloat survives into v2. |

---

## 3. Standardized 5-Step Per-Decision Protocol

Every decision inside Stages `3A`, `3B`, and `3C` executes one disciplined loop calibrated to its Reversibility × Blast Radius:

1. **Frame Drivers & Reversibility:** Declare exact `SPEC-FOUNDATION` laws, `CHARTER` ATAM scenarios, and `ASSUMPTIONS` (`A-*`) governed; classify One-Way vs. Two-Way elements explicitly.
2. **Primary Ecosystem Research (2025–2026 Reality):** Audit actively maintained upstream tools, dependency risk (`D`), NixOS module maturity, and memory/operational footprint.
3. **Set-Based Morphological Comparison (SBCE):** Compare 2–4 distinct candidates (always including a minimal/boring baseline) scored strictly on **`B > E > D > A > C`**.
4. **Empirical Benchmark / Spike (Mandatory for One-Way Doors):** Run reproducible measurements on `astrolabe` (eval latency, cache isolation, RAM, ergonomic diff, or VM/Quint check) logged in `experiments/EXP-*`.
5. **Interactive Decision-by-Decision Ratification:** Present a self-contained trade-off analysis directly to the user, decide one coherent fork at a time, and freeze the decision into an immutable `ADR-*` (plus `ASSUMPTIONS.md`, `INDEX.md`, `STATUS.md`).

---

## 4. Ratified Calibration Parameters (2026-11-24)

- **`W1` (Interleaved Walking Skeleton Gate):** Ratified. Pause after Stage 3A to implement and benchmark the minimal runnable skeleton on `design/v2` before designing Stage 3B or 3C.
- **`M1-Sunset` (Zero-Carry-Forward Safe Migration):** Ratified. Migration safety for live `astrolabe` and `x240` is an explicit design input (zero downtime / atomic rollback / canary-first cutover), implemented exclusively via isolated, temporary transition helpers that are **100% deleted** post-cutover so zero v1 legacy bloat enters v2 core.
