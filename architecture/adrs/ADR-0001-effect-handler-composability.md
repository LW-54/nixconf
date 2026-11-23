---
id: ADR-0001
title: Adopt Effect–Handler Composability as Foundational Pillar 1 (Implementation-Agnostic)
type: adr
status: accepted
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [adr, pillar-1, composability, algebraic-effects, handlers, polymorphism, stratification, commutativity]
rfd: RFD-0001
assumptions: [A-002]
supersedes: null
superseded_by: null
summary: Ratifies Effect–Handler Composability (abstract Effects, open multi-instance/sub-component Handlers, O(N+M) mediation, strict stratification, commutative composition) as Pillar 1 while keeping all syntax, language, and encoding details explicitly open.
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Effect–Handler Composability** (Paradigm P5) as the first foundational architectural pillar of `nixconf` v2 at a purely abstract, implementation-independent level. Components declare provider-agnostic typed **Effects** (requirements and offers); outer contexts compose **open, multi-instantiable, hierarchically decomposable Handlers** to interpret them across heterogeneous targets (VPS, laptop, SBC, WSL, Live ISO, mock test, standalone). Guarantees $O(N+M)$ coordination and enforces two formal soundness invariants: **Strict Stratification (acyclic dependency DAG)** and **Commutative / Keyed Composition** (order-independent merging across concurrent handlers). All concrete encodings (authoring languages, file formats, module frameworks, directory layouts, pinning tools) remain explicitly open.
<!-- abstract:end -->

# ADR-0001: Adopt Effect–Handler Composability as Foundational Pillar 1

## 1. Context & Problem Statement
Phase 1 (`AUD-0001`) empirically demonstrated that `nixconf` v1 suffered from $O(N \times M)$ manual glue across services, global singleton 1:1 implementation lock-in, 226 untyped global backchannels, provider leakage into abstract contracts, and fixed-point recursion hazards. Theoretical analysis (`RES-0003`, `RES-0004`) and comparative torture tests (`EXP-0001`, `EXP-0002`, `EXP-0003`) evaluated five foundational paradigms: Mixin Lattice (P1), Explicit ML Functors (P2), Blackboard Concepts & Synchronizations (P3), Typed Compiler IR (P4), and Algebraic Effects & Handlers (P5).

## 2. Decision Drivers
- Priority order: **Reliability (`B`) > Capability Richness (`E`) > Low Maintenance/Dep Risk (`D`) > Elegance (`A`, reconciling the above) > Speed (`C`)**.
- Axioms `X1` (Minimality & Orthogonality), `X2` (Ousterhout Depth), `X3` (Parnas Information Hiding & Polymorphism), `X4` (Standalone Portability).
- Ability to swap sub-components, run $0..N$ concurrent providers on one target, and project the exact same component cleanly onto heterogeneous substrates without $O(N \times M)$ glue or circular dependencies.

## 3. Considered Options
1. **P1 (Vanilla Mixin Lattice)**: Too entangled; encourages singletons and substrate leakage.
2. **P2 (Untyped Explicit Functors)**: Fails type safety in dynamic languages (`EXP-0002`), $O(N \times M)$ plumbing.
3. **P3 (Blackboard Intent + Sync)**: Solves $O(N+M)$ and feedback loops, but leaves standalone/context polymorphism disconnected unless framed via context handlers.
4. **P4 (Full Compiled Typed IR → JSON)**: Strongest compile-time types, but introduces JSON serialization tax, loss of laziness, dual-type drift against upstream OS options, and custom DSL maintenance risk.
5. **P5 (Algebraic Effects & Handlers — Chosen)**: Unifies P3's $O(N+M)$ typed declarations with P2's explicitly scoped, composable context handlers across *all* targets (hosts, VMs, tests, standalone).

## 4. Decision Outcome
Adopt **Effect–Handler Composability** with five implementation-agnostic axioms:
1. **Effects vs. Handlers**: Components declare typed, provider-agnostic Effects (requirements/offers); outer execution contexts compose Handlers to interpret them.
2. **Open, Multi-Instance, Decomposable Polymorphism**: Handlers are open (no closed central driver registry), multi-instantiable ($0, 1,$ or $N$ concurrent named handlers per effect class), and decomposable into independent sub-capabilities.
3. **$O(N + M)$ Decoupled Mediation**: Cross-cutting capabilities mediate declaratively over Effects, eliminating $O(N \times M)$ manual component-to-provider wiring.
4. **Formal Soundness Invariants**:
   - *Strict Stratification*: Dependencies flow strictly forward across an acyclic DAG of strata (*Static Facts $\to$ Declared Effects $\to$ Handler Interpretations $\to$ Concrete Outputs*).
   - *Commutative / Keyed Composition*: Concurrent handler outputs combine via explicitly keyed, order-independent structures (never order-dependent flat lists).
5. **Implementation Openness**: Syntax, authoring language(s), serialization format(s) (e.g., `M1` vs `M2`), module framework, and layout are explicitly deferred until all foundational pillars are established.

### Consequences
- **Positive**: Multi-provider execution, sub-component swapping, substrate polymorphism (VPS/WSL/ISO/SBC/Standalone), and secretless test mocking all emerge from one unified mechanism.
- **Negative / Discipline Required**: Any concrete encoding selected later MUST mechanically enforce Strict Stratification and Commutative Merge Keys (as demonstrated by the list-order bug caught in `EXP-0002` and fixed in `EXP-0003`).

## 5. Links
- Research: `../research/RES-0003-core-primitives-and-composition-manifold.md`, `../research/RES-0004-paradigms-theory-and-nix-semantics.md`
- Experiments: `../experiments/EXP-0001-intent-sync-multi-provider-algebra.md`, `../experiments/EXP-0002-comparative-paradigm-torture-test.md`, `../experiments/EXP-0003-rust-nix-seam-and-ux-comparison.md`
- Source RFD: `../rfds/RFD-0001-fundamental-primitives-and-composition-algebra.md`
