# Architecture Redesign Knowledge Index (Layer 0)

> **Routing Rule**: Read this index + [`STATUS.md`](STATUS.md) first. Before opening any large document, inspect its Layer-1 YAML frontmatter and `<!-- abstract:start/end -->` block (lines 1–45). Archived files (`status: archived`) are preserved for lineage and skipped unless investigating history.

## Core Control Plane (Layers 0 & 2)

| ID | Path | Type | Status | Domain | Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ARCH-METHODOLOGY` | [`README.md`](README.md) | methodology | `active` | meta | Formal redesign methodology, 5-layer progressive-disclosure knowledge architecture, lifecycles, and append-only rules. |
| `ARCH-STATUS` | [`STATUS.md`](STATUS.md) | status | `active` | meta | Live dashboard of current phase, progress table, open decisions, and immediate next actions. |
| `ARCH-CHARTER` | [`CHARTER.md`](CHARTER.md) | charter | `active` | foundations | Bias-free fundamental mission, 6 mathematical design axioms (`X1`–`X6`), ATAM scenarios (`QA-01`–`QA-08`), and fleet/capability horizon. |
| `ARCH-ASSUMPTIONS` | [`ASSUMPTIONS.md`](ASSUMPTIONS.md) | ledger | `active` | foundations | Explicit falsifiable Assumptions Ledger (`A-001`–`A-012`) tracking validation status and linked evidence. |
| `SPEC-FOUNDATION` | [`spec/FOUNDATION.md`](spec/FOUNDATION.md) | spec | `active` | foundations | Ratified Phase 2 Master Theoretical Constitution unifying Promise Theory, Semantic Spacetime, and Hard Enforcement (`ADR-0002`..`ADR-0007`), backed by Lean 4 + Quint/TLC + Rust DRT. |
| `PAPER-FOUNDATION` | [`paper/FOUNDATION-PAPER.md`](paper/FOUNDATION-PAPER.md) | paper | `active` | foundations | Publication-grade formal mathematical specification & verification paper (*Promised Spacetime* v2.0) cross-linked to all 35 Lean 4 theorems, 11 Quint/TLC invariants + 8 tests, and modular DRT benchmarks. |
| `FORMAL-README` | [`formal/README.md`](formal/README.md) | spec | `active` | foundations | Production 4-layer Lean 4 (`cedar-lean` `Data`/`Spec`/`Thm`/`Oracle`), modular Informal Systems Quint, and 1:1 Rust DRT architecture & verification guide. |

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
| `ADR-0001` | [`adrs/ADR-0001-effect-handler-composability.md`](adrs/ADR-0001-effect-handler-composability.md) | adr | `superseded` | foundations | Superseded by `ADR-0003` — originally ratified Pillar 1 Effect–Handler Composability; strictly subsumed as the Hard interior-binding case of Promise Theory. |
| `ADR-0002` | [`adrs/ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md`](adrs/ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md) | adr | `accepted` | foundations | Ratifies Decision 1 (Model A): Fractal Uniform Agency ($A = \langle \Sigma, \Pi_{\text{ext}}, \text{Interior} \rangle$), recursive Dressed Superagents, Non-Piercing Boundaries $\Sigma$, and scope-emergent standalone/substrate polymorphism. |
| `ADR-0003` | [`adrs/ADR-0003-promise-algebra-scoped-binding-and-boundary-projection.md`](adrs/ADR-0003-promise-algebra-scoped-binding-and-boundary-projection.md) | adr | `accepted` | foundations | Ratifies Decision 2 (superseding `ADR-0001`): Unified Hard/Soft Conditional Promise algebra, `B3` Cardinality-Checked Scoped Binding, `P-Dual` Opaque Superagents vs Transparent Profiles, and Stratification + Commutativity. |
| `ADR-0004` | [`adrs/ADR-0004-hard-boundaries-boolean-authority-and-state-as-promise.md`](adrs/ADR-0004-hard-boundaries-boolean-authority-and-state-as-promise.md) | adr | `accepted` | foundations | Ratifies Decision 3: `L3+` Offline Root Identity + Attenuated Capabilities + Boolean Set-Algebra Authorization ($\cup,\cap,\in,\setminus$ over agent attributes/groups) and `S2+` Mandatory Agent-Declared State-As-Promise with open composable traits. |
| `ADR-0005` | [`adrs/ADR-0005-triadic-calibrated-pull-and-sst-epistemic-spine.md`](adrs/ADR-0005-triadic-calibrated-pull-and-sst-epistemic-spine.md) | adr | `accepted` | foundations | Ratifies Decision 4: `C3` Triadic Calibrated Autonomous Pull with self-assessing atomic transitions & auto-rollback, and `E3` Semantic Spacetime $\gamma(3,4)$ universal epistemic spine over specialized bulk telemetry & trust-budgeted assessment. |
| `ADR-0006` | [`adrs/ADR-0006-foundational-corollaries-lifecycle-stratification-and-budgets.md`](adrs/ADR-0006-foundational-corollaries-lifecycle-stratification-and-budgets.md) | adr | `accepted` | foundations | Ratifies 7 foundational corollaries from `RES-0011` (Genesis/Revocation/Break-Glass, Boundary-First Stratification, Ousterhout/Foreign Wrapping, Budgeted Capacity, Epistemic Zoom, Portable User-Space, Tri-Purpose Probes), completing Phase 2A. |
| `ADR-0007` | [`adrs/ADR-0007-formal-verification-cedar-vgd-and-tuf-calm-upgrades.md`](adrs/ADR-0007-formal-verification-cedar-vgd-and-tuf-calm-upgrades.md) | adr | `accepted` | foundations | Ratifies Phase 2B `F3-b` AWS Cedar VGD (Lean 4 verified oracle + Quint/TLC distributed models + Rust engine + DRT) and folds Cedar `forbid`-dominance, Biscuit attenuation, TUF anti-downgrade/freeze defense, and CALM monotonicity into `SPEC-FOUNDATION`. |
| `ADR-0008` | [`adrs/ADR-0008-authoring-medium-toml-boundaries-nix-interiors-and-zero-artifact-seam.md`](adrs/ADR-0008-authoring-medium-toml-boundaries-nix-interiors-and-zero-artifact-seam.md) | adr | `accepted` | foundations | Ratifies Stage `3A.1` project identity **Antikythera (`aky`)**, Authoring Medium `A2` (`*.toml` boundaries + `interior.nix` + keyed instances), and Zero-Artifact Nix↔Rust Seam `S1` (Zero-IFD `builtins.fromTOML` + CI equivalence check; no C++/`builtins.wasm` lock-in). |

## Experiments & Benchmarks (`experiments/`)

| ID | Path | Type | Status | Domain | Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `TEMPLATE` | [`experiments/TEMPLATE.md`](experiments/TEMPLATE.md) | template | `active` | meta | Standardized reproducible experiment & empirical benchmark report template. |
| `EXP-0001` | [`experiments/EXP-0001-intent-sync-multi-provider-algebra.md`](experiments/EXP-0001-intent-sync-multi-provider-algebra.md) | experiment | `completed` | foundations | Validated ~120-LOC `lib.evalModules` Intent+Sync multi-provider core across VPS, test-mock, and WSL substrates in 175ms with zero recursion (`A-002` validated). |
| `EXP-0002` | [`experiments/EXP-0002-comparative-paradigm-torture-test.md`](experiments/EXP-0002-comparative-paradigm-torture-test.md) | experiment | `completed` | foundations | Head-to-head torture test of Functors (P2), Stratified Intent+Sync (P3), and Rust Typed IR (P4) on feedback loops, type errors, port conflicts, and list-order bugs. |
| `EXP-0003` | [`experiments/EXP-0003-rust-nix-seam-and-ux-comparison.md`](experiments/EXP-0003-rust-nix-seam-and-ux-comparison.md) | experiment | `completed` | foundations | Benchmarked M1–M4 Rust↔Nix authoring seams and verified commutative P5 handlers via pure zero-IFD `builtins.fromTOML` (264ms Nix eval, 4ms Rust validation vs 556ms recompile). |
| `EXP-0004` | [`experiments/EXP-0004-m1-nix-vs-m2-toml-topology.md`](experiments/EXP-0004-m1-nix-vs-m2-toml-topology.md) | experiment | `completed` | foundations | Measured M1 (`fleet.nix` 66ms standalone vs 830ms flake) vs M2 (`fleet.toml` 72ms Nix / 4ms Rust / 260ms pre-Nix CI) and isolated 5 structural differentiators (S0 purity, `toml_edit` onboarding, zero-Nix consumers, IDE schema vs single-syntax). |
| `EXP-0005` | [`experiments/EXP-0005-lean4-quint-cedar-vgd-verification.md`](experiments/EXP-0005-lean4-quint-cedar-vgd-verification.md) | experiment | `completed` | foundations | Empirically verified 35 Lean 4.35.0 theorems (7.27s cold, 0 sorryAx), exhaustively TLC-checked 3 modular Quint 0.33.1 protocols (1.87M + 54 + 77 transitions + 8 tests), and passed 2,005-fleet modular Rust↔Lean4 DRT with 0 divergences (Rust 12.74ms / 157.3k fleets/s vs Lean 1,708.8ms). |
| `EXP-0006` | [`experiments/EXP-0006-authoring-medium-and-nix-rust-seam.md`](experiments/EXP-0006-authoring-medium-and-nix-rust-seam.md) | experiment | `completed` | foundations | Stage 3A.1 head-to-head benchmark of A1 (Pure Single-File Nix), A2 (Split TOML Boundary + Pure Nix Interior), and A3 (Hybrid) against Lean-verified Rust core & real pinned nixpkgs: A2 runs in 5.79ms at 48 agents/8 hosts with zero Nix (14x faster than A1-direct 79.2ms), bit-for-bit identical .drv hashes, 0 cache busts, and mechanical non-piercing leak blocking. |

## Deep Research Dossiers — Layer 3 (`research/`)

| ID | Path | Type | Status | Domain | Summary |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `RES-0001` | [`research/RES-0001-methodology-and-knowledge-architecture.md`](research/RES-0001-methodology-and-knowledge-architecture.md) | research | `active` | meta | Phase 0 meta-research dossier: Parnas, Ousterhout, Brooks, Jackson, Zwicky GMA, ATAM, Oxide RFDs, MADR, arc42, and Progressive Disclosure vs Vector RAG (validates `A-011`). |
| `RES-0002` | [`research/RES-0002-nixos-composition-initial-notes.md`](research/RES-0002-nixos-composition-initial-notes.md) | research | `active` | foundations | Non-binding initial survey notes on NixOS Dendritic & `flake-parts` patterns (one point in the RFD-0001 manifold). |
| `RES-0003` | [`research/RES-0003-core-primitives-and-composition-manifold.md`](research/RES-0003-core-primitives-and-composition-manifold.md) | research | `active` | foundations | Expansive Phase 2 survey: Nickel/CUE/Nix/Rust seam, Tvix/Snix/Harmonia, `clan-core` tradeoffs, `nix-wrapper-modules`, `flake-parts` partitions, `blueprint`, `npins`, `.tack`. |
| `RES-0004` | [`research/RES-0004-paradigms-theory-and-nix-semantics.md`](research/RES-0004-paradigms-theory-and-nix-semantics.md) | research | `active` | foundations | Theoretical analysis of 5 foundational paradigms (Mixin Lattice, ML Functors, Concepts+Sync, Algebraic Effects, Typed Compiler IR), Dolstra `evalModules` fixed-point limits, and Divnix/Paisano/Haumea lessons. |
| `RES-0005` | [`research/RES-0005-fundamental-system-decompositions.md`](research/RES-0005-fundamental-system-decompositions.md) | research | `active` | foundations | Grounds remaining foundational axes in Saltzer & Kaashoek, Burgess Promise Theory, and Lampson Access Matrix; compares three candidate Coordinate Systems (A, B, C). |
| `RES-0006` | [`research/RES-0006-promise-theory-and-semantic-spacetime.md`](research/RES-0006-promise-theory-and-semantic-spacetime.md) | research | `active` | foundations | Deep mathematical & practical study of Promise Theory (+b/-b, conditional promises, Dressed Superagents, Trust/Assessment), Semantic Spacetime (4-link graph), real-world deployments (CFEngine/OpFlex/K8s/mgmt), and its 3 hard limits (closures, Lampson security, CAP/FLP). |
| `RES-0007` | [`research/RES-0007-promise-theory-sst-formal-derivation.md`](research/RES-0007-promise-theory-sst-formal-derivation.md) | research | `active` | foundations | Formal first-principles derivation of nixconf v2 from Promise Theory & Semantic Spacetime collided with 5 physical constraints (T1–T5), re-evaluating ADR-0001 without assumptions and framing Decision 1 (Models A, B, C). |
| `RES-0008` | [`research/RES-0008-promise-algebra-binding-and-projection.md`](research/RES-0008-promise-algebra-binding-and-projection.md) | research | `active` | foundations | Decision 2 formal analysis on top of ADR-0002: Hard vs Soft/Conditional Promise anatomy, Interior Binding Topology (B1 vs B2 vs B3), Boundary Projection (P-Explicit vs P-Bubble vs P-Dual), and compilation soundness laws. |
| `RES-0009` | [`research/RES-0009-hard-boundaries-identity-authority-and-state.md`](research/RES-0009-hard-boundaries-identity-authority-and-state.md) | research | `active` | foundations | Decision 3 formal analysis on top of ADR-0002 + ADR-0003: Fork 3a Cryptographic Identity & Lampson Authority (L1 vs L2 vs L3 + Trust Tiers) and Fork 3b Proper-Time State Ownership & CAP/FLP (S1 vs S2 vs S3). |
| `RES-0010` | [`research/RES-0010-spacetime-dynamics-calibration-and-sst-epistemics.md`](research/RES-0010-spacetime-dynamics-calibration-and-sst-epistemics.md) | research | `active` | foundations | Decision 4 formal analysis (final foundational step): Fork 4a Proper-Time Calibration & Pull Convergence (C1 vs C2 vs C3) and Fork 4b Unified Semantic Spacetime ($\gamma(3,4)$) Epistemic Spine & Trust-Budgeted Assessment (E1 vs E2 vs E3). |
| `RES-0011` | [`research/RES-0011-foundational-red-team-audit-and-refinements.md`](research/RES-0011-foundational-red-team-audit-and-refinements.md) | research | `active` | foundations | Adversarial cross-consistency red-team audit of ADR-0002..ADR-0005 surfacing 4 genuine gaps (Lifecycle Genesis/Revocation/Recovery, Boundary-First Stratification, Ousterhout/Foreign Wrapping, Budgeted Capacity), 1 paradox fix (Operational Non-Piercing vs Epistemic Zoom), and 2 unification opportunities (Portable User-Space, Tri-Purpose Assessment Probes). |
| `RES-0012` | [`research/RES-0012-formalization-methods-and-production-verification.md`](research/RES-0012-formalization-methods-and-production-verification.md) | research | `active` | foundations | Phase 2B rigor audit & formalization strategy evaluating Formal Paper, Lean 4 (4.35.0), Quint (0.33.1)/TLA+, Z3, and AWS Cedar Verification-Guided Development across Levels F1–F4 for design-time proofs and production CI. |
| `RES-0013` | [`research/RES-0013-rival-theory-comparative-audit-and-cedar-vgd.md`](research/RES-0013-rival-theory-comparative-audit-and-cedar-vgd.md) | research | `active` | foundations | Deep rival-theory comparative audit (AWS Cedar, Biscuit/Macaroons, TUF/in-toto, CALM Theorem, Operads, Provenance Semirings) closing a real TUF downgrade/freeze vulnerability in C3 and establishing the Cedar VGD Lean4+Rust DRT blueprint. |
| `RES-0014` | [`research/RES-0014-phase3-realization-methodology-and-dsm.md`](research/RES-0014-phase3-realization-methodology-and-dsm.md) | research | `active` | meta | Ratified Phase 3 realization methodology (ADD 3.0, DSM partitioning, Risk-Driven SBCE, Reversibility matrix, `W1` Walking Skeleton Gate, and `M1-Sunset` Zero-Carry-Forward Safe Migration). |

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
