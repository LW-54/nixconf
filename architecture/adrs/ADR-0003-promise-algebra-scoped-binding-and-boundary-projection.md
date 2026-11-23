---
id: ADR-0003
title: Adopt Unified Hard/Soft Promise Algebra, Cardinality-Checked Scoped Binding (B3) & Dual Boundary Projection (P-Dual)
type: adr
status: accepted
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [adr, decision-2, promise-algebra, hard-promises, soft-promises, conditional-promises, binding, cardinality, boundary-projection, stratification, commutativity]
rfd: RFD-0001
assumptions: [A-002]
supersedes: ADR-0001
superseded_by: null
summary: Ratifies Decision 2 on top of ADR-0002: unified Hard/Soft Conditional Promise anatomy, B3 Peer-Blind Scoped Binding with Typed Cardinality & Superagent Disambiguation, P-Dual (strict P-Explicit Dressed Superagents vs Transparent Profiles), and static compilation soundness laws, formally subsuming and superseding ADR-0001.
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Decision 2** of the `nixconf` v2 theoretical foundation on top of [`ADR-0002`](ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md) (Fractal Uniform Agency), and **formally supersedes [`ADR-0001`](ADR-0001-effect-handler-composability.md)** (Effect–Handler Composability) by subsuming all of its guarantees as the `Hard` interior-binding special case of a richer, unified Promise Theory algebra. Establishes four binding laws: (1) **Unified Promise Anatomy** carrying both `Hard` (build/closure-verified) and `Soft` Conditional ($+b \mid C$ with explicit condition dependency `-C`, bounded degraded behavior, and runtime assessment hook $\alpha$) strength directly on promises; (2) **Interior Binding Topology `B3`** — peer-blind scoped binding with formal per-type **Cardinality** (`Exclusive` 1:1, `Broadcast` 1:N, `Partitioned Fan-In` N:K) and explicit Superagent-level disambiguation (zero silent conflicts); (3) **Boundary Projection `P-Dual`** — strict `P-Explicit` Non-Piercing on both `+b` and `-b` for **Dressed Superagents ($\Sigma_S$)** paired with zero-ceremony **Transparent Profiles** (flat reusable agent sets); and (4) **Static Compilation Soundness** (Strict Stratification & Commutative Keyed Aggregation). All concrete encodings (languages, file formats, module frameworks) remain explicitly open.
<!-- abstract:end -->

# ADR-0003: Unified Promise Algebra, Scoped Binding (`B3`) & Dual Boundary Projection (`P-Dual`)

## 1. Context & Problem Statement
[`ADR-0002`](ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md) established **Model A (Fractal Uniform Agency)**: a single recursive entity $A = \langle \Sigma, \Pi_{\text{ext}}, \text{Interior} \rangle$ composing into Dressed Superagents $S = \langle \{A_i\}, \Pi_{\text{int}}, \Pi_{\text{ext}} \rangle$. To preserve operational reliability (`B`), capability richness (`E`), and zero-ceremony elegance (`A`) without bifurcating Agents into separate static vs. runtime entity types, Decision 2 (`RES-0008`) derived the formal laws governing:
1. Promise anatomy (Hard vs. Soft/Conditional semantics),
2. Interior sibling binding ($\Pi_{\text{int}}$: `B1` vs. `B2` vs. `B3`),
3. Nested boundary projection ($\Pi_{\text{int}} \to \Pi_{\text{ext}}$: `P-Explicit` vs. `P-Bubble` vs. `P-Dual`), and
4. Static compilation soundness into immutable closures.

## 2. Considered Options (`RES-0008`)
- **Fork 2a (Interior Binding Topology)**:
  - *B1 (Explicit Point-to-Point Wiring — Rejected)*: Zero ambiguity, but causes $O(N \times M)$ manual switchboard wiring across cross-cutting concerns.
  - *B2 (Pure Implicit Scoped Broadcast — Rejected)*: Achieves $O(N + M)$, but suffers silent ambiguity/precedence hazards when multiple exclusive providers exist.
  - *B3 (Peer-Blind Scoped Binding + Typed Cardinality + Superagent Disambiguation — Accepted)*: Preserves $O(N + M)$ peer-blindness while eliminating silent ambiguity via formal cardinality and explicit Superagent routing.
- **Fork 2b (Nested Superagent Boundary Projection)**:
  - *P-Explicit Everywhere (Rejected)*: Enforces Non-Piercing uniformly, but imposes heavy forwarding boilerplate on simple convenience groupings (e.g., `WaylandDesktop`, `CoreCliTools`).
  - *P-Bubble (Rejected)*: Lowers boilerplate, but weakens Non-Piercing on interior dependencies (`-b`), allowing interior swaps to silently inject new host requirements.
  - *P-Dual (Opaque Dressed Superagents = `P-Explicit`; Transparent Profiles = Flat Agent Sets — Accepted)*: Preserves 100% strict Non-Piercing everywhere encapsulation matters while keeping reusable agent groupings completely ceremony-free.

## 3. Decision Outcome

1. **Unified Promise Anatomy (Hard & Soft/Conditional)**:
   $$\pi \;=\; \bigl(A \xrightarrow{\;\pm b : \tau \;\mid\; C\;} \sigma,\;\; \text{strength} \in \{\text{Hard}, \text{Soft}\}\bigr)$$
   - **`Hard` Promises**: Verified structurally or cryptographically at build/check/activation time (binary calibration). Unfulfilled mandatory `Hard` `-b` in a closed root Superagent is a hard build/check failure.
   - **`Soft` (Conditional) Promises ($+b \mid C$)**: Governed by the **Conditional Promise Law** — every `Soft` promise MUST explicitly declare (a) its condition dependency `-C`, (b) its bounded degraded behavior when $C$ is false, and (c) its runtime assessment hook $\alpha$.
2. **Interior Binding Topology (`B3`)**:
   - Atomic agents remain strictly peer-blind and emit typed promises into enclosing scope $\sigma$.
   - Every Promise Type $\tau$ declares formal **Cardinality** and a unique **Commutative Key**:
     - **`Exclusive` (`1:1`)**: 0 matching `+b` for mandatory `-b` → hard error; $>1$ matching without explicit Superagent disambiguation → hard conflict error (never silent override).
     - **`Broadcast` (`1:N`)**: $0, 1,$ or $N$ observers bind concurrently and commutatively.
     - **`Partitioned Fan-In` (`N:K`)**: Multiple providers accept disjoint attribute predicates; overlapping route keys → hard conflict error.
   - When a Superagent intentionally hosts multiple providers of an `Exclusive` type, the Superagent explicitly disambiguates via scoped attribute predicates or nested sub-superagents.
3. **Boundary Projection (`P-Dual`)**:
   - **Dressed Superagent ($\Sigma_S$)**: Enforces strict **`P-Explicit`** Non-Piercing — neither interior `+b` offers nor unfulfilled interior `-b` requirements cross $\Sigma_S$ unless explicitly declared in $\Pi_{\text{ext}}(S)$.
   - **Transparent Profile (`{A_1, ..., A_k}`)**: Not an encapsulation boundary $\Sigma$; mathematically a flat reusable set of sibling Agents added directly into the enclosing Superagent's $\{A_i\}$.
4. **Static Compilation Soundness Laws (from `EXP-0002` & `EXP-0003`)**:
   - **Strict Stratification**: Hard interior binding flows forward across an acyclic dependency DAG (forbidding cyclic fixed-point evaluation).
   - **Commutative Keyed Aggregation**: All multi-provider fan-in/fan-out collections merge via keyed maps/sets, never order-dependent flat lists.
5. **Superseding `ADR-0001`**:
   - [`ADR-0001`](ADR-0001-effect-handler-composability.md) is formally marked `superseded` by `ADR-0003`. Every guarantee of `ADR-0001` (open multi-instance handlers, $O(N+M)$ mediation, strict stratification, commutative composition, implementation openness) is strictly preserved as the `Hard` interior-binding projection of this algebra, now unified with Non-Piercing Scope, Formal Cardinality, Hard/Soft Conditional Degradation, and `P-Dual` Boundary Projection.

## 4. Consequences
- **Positive**: One cohesive mathematical algebra governs standalone tools, local host composition, multi-instance providers, sub-component swapping, VM mocks, and cross-host conditional services with zero silent conflicts and zero boilerplate for simple toolsets.
- **Obligations Imposed on Decisions 3 & 4**: Concrete encoding choices remain deferred until Decision 3 (Hard Boundaries: Cryptographic Identity, Lampson Authority & Proper-Time State Ownership) and Decision 4 (Spacetime Dynamics: Calibration, Convergence, Assessment & $\gamma(3,4)$ SST Graph) are ratified.

## 5. Links
- Supersedes: [`ADR-0001`](ADR-0001-effect-handler-composability.md)
- Builds on: [`ADR-0002`](ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md)
- Analysis: [`RES-0008`](../research/RES-0008-promise-algebra-binding-and-projection.md), [`EXP-0002`](../experiments/EXP-0002-comparative-paradigm-torture-test.md), [`EXP-0003`](../experiments/EXP-0003-rust-nix-seam-and-ux-comparison.md)
