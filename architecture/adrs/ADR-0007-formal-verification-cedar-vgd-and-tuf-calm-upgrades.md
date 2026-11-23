---
id: ADR-0007
title: Adopt AWS Cedar Verification-Guided Development (F3-b) & Formal Phase 2B Upgrades (Cedar Forbid-Dominance, Biscuit Attenuation, TUF Supply-Chain Defense, CALM Monotonicity)
type: adr
status: accepted
created: 2026-11-24
updated: 2026-11-24
domain: foundations
tags: [adr, phase-2b, formal-verification, lean4, quint, tlc, rust, aws-cedar, drt, biscuit, tuf, calm]
rfd: null
assumptions: [A-001, A-002, A-004, A-005, A-006]
supersedes: null
superseded_by: null
summary: Ratifies F3-b (AWS Cedar Verification-Guided Development: pure-core Lean 4 verified oracle + Quint/TLC distributed models + idiomatic Rust production engine + continuous Differential Randomized Testing) and folds four formally verified Phase 2B upgrades into SPEC-FOUNDATION (Cedar forbid-dominates-permit, Biscuit monotonic offline attenuation, TUF downgrade/freeze/mix-and-match defense on C3, and CALM logical monotonicity on S2+).
---

<!-- abstract:start -->
## Executive Abstract

Ratifies the **Phase 2B Formalization & Production Verification Architecture (`F3-b`: AWS Cedar Verification-Guided Development)** alongside four formal upgrades uncovered by our rival-theory comparative audit ([`RES-0013`](../research/RES-0013-rival-theory-comparative-audit-and-cedar-vgd.md)) and machine-verified in [`EXP-0005`](../experiments/EXP-0005-lean4-quint-cedar-vgd-verification.md):
1. **Production Verification Architecture (`F3-b`)**: Pure-core **Lean 4** (`architecture/formal/lean/`, zero Mathlib, 22 zero-`sorryAx` theorems verified in `3.34 s` cold) serves as the authoritative executable mathematical specification & oracle; **Quint / TLC** (`architecture/formal/quint/`) exhaustively verifies asynchronous distributed protocols in `< 5 s`; idiomatic **Rust** implements the fast production engine (`319k fleets/s`); and CI enforces bit-for-bit equivalence via **Differential Randomized Testing (DRT)** (`0` divergences across `2,004` fleets).
2. **Upgrades Folded Into `SPEC-FOUNDATION`**:
   - **Cedar `Default-Deny` + `forbid`-overrides-`permit` + Order-Invariance** on `L3+` (`ADR-0004`);
   - **Biscuit Offline-Verifiable Monotonic Attenuation** on delegated capabilities (`ADR-0004`);
   - **TUF Rollback (Monotonic Epoch), Freeze (Freshness Window $\Delta t$), and Mix-and-Match (Signed Snapshot Manifest) Defense** closing a real downgrade vulnerability in `C3` (`ADR-0005`);
   - **Hellerstein's CALM Theorem (Logical Monotonicity)** formalizing the exact *iff* consistency law for `S2+` (`ADR-0004`).
<!-- abstract:end -->

# ADR-0007: AWS Cedar VGD (`F3-b`) & Formal Phase 2B Upgrades

## 1. Context & Problem Statement
Re-examining `ADR-0002`..`ADR-0006` revealed that prose specifications alone cannot guarantee the absence of subtle security, concurrency, or algebraic bugs (`RES-0012`). Comparative research (`RES-0013`) and live formal verification (`EXP-0005`) both uncovered a genuine supply-chain downgrade/freeze hole in `C3` and proved that AWS Cedar's **Verification-Guided Development** architecture runs cleanly and rapidly on our pinned Nix toolchain (`lean4 4.35.0`, `quint 0.33.1`, `rustc 1.99.0`).

## 2. Decision Outcome
1. **Adopt `F3-b` (AWS Cedar Verification-Guided Development)** as a permanent production verification pillar of `nixconf` v2:
   - Maintain a minimal, zero-Mathlib **Lean 4 definitional model & proof suite** proving unbounded algebraic, binding, policy, state, and SST invariants (`#print axioms` audited in CI for zero `sorryAx`).
   - Maintain **Quint / TLC** distributed state-machine specifications exhaustively model-checking async pull, rollback, genesis, and partition degradation protocols.
   - Implement production CLI/UX/verification in idiomatic **Rust**, continuously locked to the proved Lean 4 oracle via **Differential Randomized Testing (DRT)** on both real `nixconf` fleet manifests and thousands of fuzzed fleets.
2. **Formal Upgrades Amending `ADR-0004` & `ADR-0005`**:
   - **`L3+` Authorization (`ADR-0004`)**: Policies obey **Default-Deny**, **`forbid`-overrides-`permit`**, and **Order-Invariance** over the Boolean Attribute/Group Lattice; delegated capabilities obey **Offline-Verifiable Monotonic Attenuation**.
   - **`S2+` Distributed State (`ADR-0004`)**: Multi-writer state without a single authoritative writer MUST be logically **monotonic** (CALM join-semilattice or explicit conflict-preserving lattice).
   - **`C3` Triadic Calibrated Pull (`ADR-0005`)**: Calibration enforces **TUF-grade** protection — local **monotonic epoch counters** (anti-rollback/downgrade), **freshness staleness windows $\Delta t$** assessed by `E3` (anti-freeze), and **signed Snapshot Manifests** mapping `commit + epoch + timestamp → exact host Nix closure hashes` (anti-mix-and-match).

## 3. Links
- Research: [`RES-0012`](../research/RES-0012-formalization-methods-and-production-verification.md), [`RES-0013`](../research/RES-0013-rival-theory-comparative-audit-and-cedar-vgd.md)
- Empirical Benchmark & Proof Audit: [`EXP-0005`](../experiments/EXP-0005-lean4-quint-cedar-vgd-verification.md)
- Formal Artifacts: `architecture/formal/lean/`, `architecture/formal/quint/`, `architecture/formal/drt/`
- Formal Mathematical Paper: [`FOUNDATION-PAPER.md`](../paper/FOUNDATION-PAPER.md)
