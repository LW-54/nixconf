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
- **Project Identity**: **Antikythera (`aky`)** *(ratified in `ADR-0008`)*
- **Current Phase**: **Phase 3 — `W1` Walking Skeleton Gate PASSED (`v2/`, `EXP-0009`) → Ready for Stage `3B` (Trust, Mesh & Convergence Plane)!**
- **Last Updated**: 2026-11-24

---

## Phase Progress

| Phase | Name | Status | Key Outputs |
| :---: | :--- | :--- | :--- |
| **0** | Methodology, Knowledge System & Calibrated Charter | **Complete** | `README.md`, `INDEX.md`, `CHARTER.md` (`B > E > D > A > C`), `ASSUMPTIONS.md`, `RES-0001`, `RES-0002`, templates, `archive/ARC-0001..0002`, `journal/` |
| **1** | Empirical Current-State Audit & Boundary-Constraint Harvest | **Complete** | `AUD-0001`..`AUD-0004` (50k LOC census, live `astrolabe` baseline, fleet boundary matrix) |
| **2A** | Foundational Decisions & Red-Team Synthesis | **Complete** | `RES-0003`..`RES-0011`, `EXP-0001`..`EXP-0004`, `ADR-0002`..`ADR-0006` (`ADR-0001` superseded), `spec/FOUNDATION.md` |
| **2B** | Formal Mathematical Specification, Rival-Theory Audit & Production Verification | **Complete** | `RES-0012`..`RES-0013`, `EXP-0005` (v0.2), `ADR-0007`, **`PAPER-FOUNDATION` v2.0**, `architecture/formal/` (**35 Lean 4 theorems**, **11 TLC invariants + 8 tests**, **2,005-fleet 1:1 modular Rust↔Lean4 DRT**) |
| **3** | Concrete Realization, Risk Burn-Down & Walking Skeleton (`RES-0014`) | **Active (`3B.1`)** | **3A** Structural Kernel ✅ (`ADR-0008`..`ADR-0010`) → **`W1` Walking Skeleton ✅ (`v2/`, `EXP-0009`)** → **3B** Trust/Mesh/Convergence (NEXT) → **3C** Pluggable Capabilities → **3D** CCA & `M1-Sunset` Cutover Plan |
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
  - **`ADR-0008` (`accepted`) — Stage `3A.1` (`Antikythera` / `aky`, `A2` + `S1`)**: Split `*.toml` Boundaries Everywhere + Pure `interior.nix` + Zero-Artifact Parallel Read (`builtins.fromTOML`, zero IFD, `5.79 ms` zero-Nix verification, Three-Tier Power Stratification).
  - **`ADR-0009` (`accepted`) — Stage `3A.2` (`P1` + `W-Std` + `R-Crane` + `F-Hermetic`)**: Plain `flake.nix` + `flake.lock` (~45 LOC), zero-dep pure `nixpkgs` standalone wrappers, single `crane` Cargo workspace + unified 4-language quality gates (`LW-54/rust-env` + `unsafe_code = "forbid"` + `cargo-deny`), and offline hermetic Lean/Quint Nix sandboxes.
  - **`ADR-0010` (`accepted`) — Stage `3A.3` (`Open Orthogonal Substrates` + `I1` + `H2`)**: Arbitrary-axis composable Substrate Agents (zero fixed axis count / zero inheritance), sealed `impermanence` auto-consuming `[state.*]`, and sealed standalone-capable `feel-co/hjem`.
- **Walking Skeleton Gate (`W1`) + `F1` Core TCB/Boundary Closure PASSED (`v2/`, `EXP-0009`)**:
  - Live runnable pure Model-A Antikythera flake (`4` inputs, 0 `home-manager`), **41 machine-checked Lean 4 theorems (0 `sorryAx`)** verifying full recursive `Agent` trees (`checkAgentTree_substitution_invariant`), zero interior piercing for budgets & state, dynamic `Partitioned` `AttrExpr` routing (`caddy` ↔ `vaultwarden`), private scoped `ch.offers` wrappers, and NixOS `{ config, ... }:` backdoor blocking (`assertNonPiercingNixos`).
  - `7/7` hermetic checks passing, `7/7` unit tests, **`2,003/2,003` recursive-tree Rust↔Lean DRT (0 divergences)**, bit-for-bit `S1` Rust==Nix equivalence, `2.01 ms` zero-Nix `aky check`, and 0 cache busts.
- **Next Step — Stage `3B` (One-Way Door Cluster B: Trust, Mesh & Convergence Plane)**:
  - Begin **Stage `3B.1` — Cryptographic Root Identity, Secrets, Attenuated Capabilities & Zero-Trust Genesis/Break-Glass (`L3+` + `C1`)** (designed cohesively with `3B.2` Mesh Fabric and `3B.3` Triadic TUF Pull/GitOps/Mirror!).

---

## Assumptions Tracker Snapshot
- Total logged: **13** (`A-001` .. `A-013`)
- Validated: **8** (`A-001`, `A-002`, `A-003`, `A-004`, `A-005`, `A-007`, `A-011`, `A-013`)
- Experimenting: **0**
- Unverified: **5** (`A-006`, `A-008`, `A-009`, `A-010`, `A-012`)
- Falsified: **0**
