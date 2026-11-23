# Architecture Redesign Knowledge Index (Layer 0)

> **Routing Rule**: Read this index + [`STATUS.md`](STATUS.md) first. Before opening any large document, inspect its Layer-1 YAML frontmatter and `<!-- abstract:start/end -->` block (lines 1–45). Archived files (`status: archived`) are preserved for lineage and skipped unless investigating history.

## Core Control Plane (Layers 0 & 2)

| ID | Path | Type | Status | Domain | Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ARCH-METHODOLOGY` | [`README.md`](README.md) | methodology | `active` | meta | Formal redesign methodology, 5-layer progressive-disclosure knowledge architecture, lifecycles, and append-only rules. |
| `ARCH-STATUS` | [`STATUS.md`](STATUS.md) | status | `active` | meta | Live dashboard of current phase, progress table, open decisions, and immediate next actions. |
| `ARCH-CHARTER` | [`CHARTER.md`](CHARTER.md) | charter | `active` | foundations | Bias-free fundamental mission, 6 mathematical design axioms (`X1`–`X6`), ATAM scenarios (`QA-01`–`QA-08`), and fleet/capability horizon. |
| `ARCH-ASSUMPTIONS` | [`ASSUMPTIONS.md`](ASSUMPTIONS.md) | ledger | `active` | foundations | Explicit falsifiable Assumptions Ledger (`A-001`–`A-012`) tracking validation status and linked evidence. |

## Empirical Audit — Phase 1 (`audit/`)

| ID | Path | Type | Status | Domain | Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `AUD-0001` | [`audit/AUD-0001-primitives-modules-entanglement.md`](audit/AUD-0001-primitives-modules-entanglement.md) | audit | `active` | foundations | Audits `primitives/` & `modules/`: 3-pass compiler overhead, 226 `internal.*` backchannels, 1:1 impl lock-in, Grafana/SOPS leaks in contracts, cross-host eval coupling, and standalone portability gaps. |
| `AUD-0002` | [`audit/AUD-0002-meta-tooling-rust-deps.md`](audit/AUD-0002-meta-tooling-rust-deps.md) | audit | `active` | tooling | Audits 15k LOC `meta/`, `Justfile`, `.githooks/`, 5.3k LOC fragmented Rust, 5.3k LOC `meta/graph/`, doc enforcement blind spots, and 15 global `.tack/` inputs. |
| `AUD-0003` | [`audit/AUD-0003-testing-ci-secrets-ops.md`](audit/AUD-0003-testing-ci-secrets-ops.md) | audit | `active` | verification | Audits 4-tier testing, CI/Attic cache isolation (plus residual `${self}` leak in `rclone`), SOPS/Bitwarden trust boundaries, and live `astrolabe` RAM/disk baselines (~1.59 GiB obs vs ~291 MiB core services). |
| `AUD-0004` | [`audit/AUD-0004-fleet-and-capability-constraints.md`](audit/AUD-0004-fleet-and-capability-constraints.md) | audit | `active` | networking-fleet | Harvests non-negotiable technical constraints across VPS, laptops, ZenBook Duo, TUF dGPU, Chromebook tablet, `aarch64` RPi, `NixOS-WSL`, Live ISO, standalone `nix run`, mesh, GitOps, and distributed workloads. |

## Requests for Discussion — Phases 2–3 (`rfds/`)

| ID | Path | Type | Status | Domain | Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `TEMPLATE` | [`rfds/TEMPLATE.md`](rfds/TEMPLATE.md) | template | `active` | meta | Standardized bias-free RFD template with Zwicky GMA box, CCA, ATAM trade-off matrix, and abstract block. |
| `RFD-0001` | [`rfds/RFD-0001-fundamental-primitives-and-composition-algebra.md`](rfds/RFD-0001-fundamental-primitives-and-composition-algebra.md) | rfd | `discussion` | foundations | First-principles derivation of 5 irreducible primitive categories + 6-dimension Zwicky DSE comparing Lean Native Algebra+Rust, Partitioned flake-parts, and Vanilla NixOS. |

## Architecture Decision Records — Phase 4 (`adrs/`)

| ID | Path | Type | Status | Domain | Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `TEMPLATE` | [`adrs/TEMPLATE.md`](adrs/TEMPLATE.md) | template | `active` | meta | Standardized immutable MADR decision record template. |
| `ADR-0001` | [`adrs/ADR-0001-effect-handler-composability.md`](adrs/ADR-0001-effect-handler-composability.md) | adr | `accepted` | foundations | Ratifies Pillar 1: implementation-agnostic Effect–Handler Composability (open multi-instance handlers, $O(N+M)$ mediation, strict stratification, commutative composition). |

## Experiments & Benchmarks (`experiments/`)

| ID | Path | Type | Status | Domain | Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `TEMPLATE` | [`experiments/TEMPLATE.md`](experiments/TEMPLATE.md) | template | `active` | meta | Standardized reproducible experiment & empirical benchmark report template. |
| `EXP-0001` | [`experiments/EXP-0001-intent-sync-multi-provider-algebra.md`](experiments/EXP-0001-intent-sync-multi-provider-algebra.md) | experiment | `completed` | foundations | Validated ~120-LOC `lib.evalModules` Intent+Sync multi-provider core across VPS, test-mock, and WSL substrates in 175ms with zero recursion (`A-002` validated). |
| `EXP-0002` | [`experiments/EXP-0002-comparative-paradigm-torture-test.md`](experiments/EXP-0002-comparative-paradigm-torture-test.md) | experiment | `completed` | foundations | Head-to-head torture test of Functors (P2), Stratified Intent+Sync (P3), and Rust Typed IR (P4) on feedback loops, type errors, port conflicts, and list-order bugs. |
| `EXP-0003` | [`experiments/EXP-0003-rust-nix-seam-and-ux-comparison.md`](experiments/EXP-0003-rust-nix-seam-and-ux-comparison.md) | experiment | `completed` | foundations | Benchmarked M1–M4 Rust↔Nix authoring seams and verified commutative P5 handlers via pure zero-IFD `builtins.fromTOML` (264ms Nix eval, 4ms Rust validation vs 556ms recompile). |
| `EXP-0004` | [`experiments/EXP-0004-m1-nix-vs-m2-toml-topology.md`](experiments/EXP-0004-m1-nix-vs-m2-toml-topology.md) | experiment | `completed` | foundations | Measured M1 (`fleet.nix` 66ms standalone vs 830ms flake) vs M2 (`fleet.toml` 72ms Nix / 4ms Rust / 260ms pre-Nix CI) and isolated 5 structural differentiators (S0 purity, `toml_edit` onboarding, zero-Nix consumers, IDE schema vs single-syntax). |

## Deep Research Dossiers — Layer 3 (`research/`)

| ID | Path | Type | Status | Domain | Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `RES-0001` | [`research/RES-0001-methodology-and-knowledge-architecture.md`](research/RES-0001-methodology-and-knowledge-architecture.md) | research | `active` | meta | Phase 0 meta-research dossier: Parnas, Ousterhout, Brooks, Jackson, Zwicky GMA, ATAM, Oxide RFDs, MADR, arc42, and Progressive Disclosure vs Vector RAG (validates `A-011`). |
| `RES-0002` | [`research/RES-0002-nixos-composition-initial-notes.md`](research/RES-0002-nixos-composition-initial-notes.md) | research | `active` | foundations | Non-binding initial survey notes on NixOS Dendritic & `flake-parts` patterns (one point in the RFD-0001 manifold). |
| `RES-0003` | [`research/RES-0003-core-primitives-and-composition-manifold.md`](research/RES-0003-core-primitives-and-composition-manifold.md) | research | `active` | foundations | Expansive Phase 2 survey: Nickel/CUE/Nix/Rust seam, Tvix/Snix/Harmonia, `clan-core` tradeoffs, `nix-wrapper-modules`, `flake-parts` partitions, `blueprint`, `npins`, `.tack`. |
| `RES-0004` | [`research/RES-0004-paradigms-theory-and-nix-semantics.md`](research/RES-0004-paradigms-theory-and-nix-semantics.md) | research | `active` | foundations | Theoretical analysis of 5 foundational paradigms (Mixin Lattice, ML Functors, Concepts+Sync, Algebraic Effects, Typed Compiler IR), Dolstra `evalModules` fixed-point limits, and Divnix/Paisano/Haumea lessons. |
| `RES-0005` | [`research/RES-0005-fundamental-system-decompositions.md`](research/RES-0005-fundamental-system-decompositions.md) | research | `active` | foundations | Grounds remaining foundational axes in Saltzer & Kaashoek, Burgess Promise Theory, and Lampson Access Matrix; compares three candidate Coordinate Systems (A, B, C). |

## Session Lineage — Layer 4 (`journal/`)

| ID | Path | Type | Status | Domain | Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `SES-0001` | [`journal/2026-11-23-session-01.md`](journal/2026-11-23-session-01.md) | journal | `active` | meta | Session 01 kickoff, Phase 0 meta-research, user bias-corrections, and initialization of `design/v2`. |

## Append-Only Archive — Layer 4 (`archive/`)

| ID | Path | Type | Status | Domain | Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ARCH-ARCHIVE-POLICY` | [`archive/README.md`](archive/README.md) | archive | `active` | meta | Append-only archival rules (never silently overwrite or delete historical drafts). |
| `ARC-0001` | [`archive/2026-11-23-phase0-initial-roadmap-draft.md`](archive/2026-11-23-phase0-initial-roadmap-draft.md) | archive | `archived` | meta | Archived first Phase 0 roadmap draft before removing current-repo bias (`meta/`, Dendritic) and moving to `design/v2`. |
| `ARC-0002` | [`archive/2026-11-23-charter-v0-pre-calibration.md`](archive/2026-11-23-charter-v0-pre-calibration.md) | archive | `archived` | foundations | Archived pre-calibration Charter snapshot before locking user priorities (standalone `nix run`, reliability-first, graceful degradation, language-agnostic primitives). |
