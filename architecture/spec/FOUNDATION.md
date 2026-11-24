---
id: SPEC-FOUNDATION
title: Nixconf v2 Master Theoretical Foundation Specification (Promise Theory + Semantic Spacetime + Hard Enforcement)
type: spec
status: active
created: 2026-11-23
updated: 2026-11-24
domain: foundations
tags: [spec, constitution, promise-theory, semantic-spacetime, hard-enforcement, lean4, quint, aws-cedar, tuf, calm, adr-0002, adr-0003, adr-0004, adr-0005, adr-0006, adr-0007]
assumptions: [A-001, A-002, A-004, A-005, A-006, A-011, A-013]
summary: Single-page master architectural constitution synthesizing ADR-0002..ADR-0007 — backed by 22 machine-checked Lean 4 theorems, 8 exhaustively TLC-verified Quint invariants, AWS Cedar VGD differential testing (2,004 fleets, 0 divergences), and PAPER-FOUNDATION.
---

<!-- abstract:start -->
## Executive Abstract

The ratified, implementation-agnostic **Theoretical Constitution** of `nixconf` v2 (Phase 2 output), unifying **Mark Burgess & Jan Bergstra's Promise Theory**, **Burgess & Couch's Semantic Spacetime ($\gamma(3,4)$)**, **Eelco Dolstra's Hard Immutable Closures**, **Butler Lampson's Cryptographic Protection**, and **CAP/FLP Realism** across five ratified ADRs ([`ADR-0002`](../adrs/ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md)–[`ADR-0006`](../adrs/ADR-0006-foundational-corollaries-lifecycle-stratification-and-budgets.md)). Every concrete tooling, language, networking, GitOps, storage, observability, and documentation RFD in Phase 3 MUST satisfy these laws mechanically.
<!-- abstract:end -->

# Nixconf v2: Master Theoretical Foundation (`SPEC-FOUNDATION`)

> **Priority Order** ([`CHARTER.md`](../CHARTER.md)): **Operational Reliability (`B`) > Capability Richness (`E`) > Low Maintenance & Dependency Risk (`D`) > Mathematical Elegance (`A`, reconciling the above) > Iteration Speed (`C`)**.
> **Implementation Neutrality**: This specification locks *architectural laws and invariants*, never premature languages, file formats, frameworks, or vendor tools.

---

## 1. Space & Agency (`ADR-0002`, `ADR-0006` C2/C3/C5/C6)

1. **Fractal Uniform Agency**: One universal structural unit across every scale (wrapped binary, service daemon, capability stack, OS substrate, host, standalone target, fleet, human, AI agent, external platform):
   $$A = \bigl\langle \Sigma_A,\; \Pi_{\text{ext}}(A),\; \text{Interior}(A) \bigr\rangle$$
2. **Recursive Dressed Superagents (`CONTAINS`)**:
   $$S = \bigl\langle \{A_1, \dots, A_n\},\; \Pi_{\text{int}}(S),\; \Pi_{\text{ext}}(S) \bigr\rangle$$
   Atomic agents carry opaque interiors with zero superagent ceremony.
3. **Operational Non-Piercing & Boundary-First Stratification ($\Sigma$)**:
   - External functional dependencies may observe **only** $\Pi_{\text{ext}}(S)$ — never $\{A_i\}$ or $\Pi_{\text{int}}(S)$.
   - **Boundary-First Stratification ($\Pi_{\text{ext}}(S) \perp \text{Interior}(S)$)**: $\Pi_{\text{ext}}(S)$ MUST be evaluable strictly *without* evaluating $\text{Interior}(S)$; evaluating $\text{Interior}(S)$ verifies strict conformance against $\Pi_{\text{ext}}(S)$.
   - **Authorized Epistemic Zoom**: Humans and `L3+`-authorized diagnostic AI may perform strictly read-only, secret-redacted, progressive-disclosure `CONTAINS` inspection without introducing reverse build dependencies.
4. **Scope-Emergent Portability & Substrate Polymorphism**:
   - **Standalone Portability (`X4`)**: An Agent is standalone (`nix run` anywhere) *iff* all mandatory `-b` promises close inside the minimal store-only `Standalone` Superagent. User-space tools/environments decouple cleanly from OS session wiring (`C6`).
   - **Substrate Polymorphism**: Heterogeneous targets (`astrolabe` VPS, `x240`, ZenBook Duo, TUF dGPU, Chromebook tablet, `aarch64` RPi, `NixOS-WSL`, `Live-ISO`, `TestVM`) are Superagents containing distinct Substrate Agents emitting each target's real hardware/OS `+b` promises.
5. **Ousterhout Boundary Discipline & Foreign-Agent Wrapping (`C3`)**:
   - Mint typed global Promise Contracts ($\tau$) *only* for cross-agent interactions; keep one-off hardware quirks private inside atomic Hardware/Substrate Agents.
   - Wrap upstream NixOS modules/binaries as Atomic Agents whose boundary $\Sigma$ explicitly lifts cross-cutting side effects (secrets, state volumes, endpoints, resource envelopes, probes $\alpha$), verified by inspection/VM audits.

---

## 2. Promise Algebra, Binding & Projection (`ADR-0003`, `ADR-0006` C4)

1. **Unified Promise Anatomy**:
   $$\pi = \bigl(A \xrightarrow{\;\pm b : \tau \;\mid\; C\;} \sigma,\;\; \text{strength} \in \{\text{Hard}, \text{Soft}\}\bigr)$$
   - **`Hard` Promises**: Structurally/cryptographically enforced at build/check/activation time (binary calibration; unfulfilled mandatory `Hard` `-b` in a closed root = hard failure).
   - **`Soft` (Conditional) Promises ($+b \mid C$)**: Governed by the **Conditional Promise Law** — MUST declare (a) condition dependency `-C` (including dynamic physical posture like `power:ac-plugged`, `mesh-reachable`), (b) bounded degraded behavior when $C$ is false, and (c) runtime assessment hook $\alpha$.
2. **Interior Binding Topology (`B3` + `C4`)**:
   - Atomic agents are 100% peer-blind; every Promise Type $\tau$ declares formal **Binding Semantics** and a unique **Commutative Key**:
     1. **`Exclusive` (`1:1`)**: 0 matching `+b` for mandatory `-b` → hard error; $>1$ without explicit Superagent disambiguation → hard conflict error.
     2. **`Broadcast` (`1:N`)**: $0..N$ observers bind concurrently and commutatively.
     3. **`Partitioned Fan-In` (`N:K`)**: Providers accept disjoint attribute predicates; overlapping route keys → hard conflict error.
     4. **`Budgeted Capacity` (`∑ demands ≤ supply` + Priority Tiering)**: Quantitative conservation for finite RAM, disk, CPU/IO, and storage quotas, enforced statically and via runtime kernel isolation/cgroups.
3. **Dual Boundary Projection (`P-Dual`)**:
   - **Dressed Superagents ($\Sigma_S$)**: Strict `P-Explicit` Non-Piercing on *both* `+b` offers and `-b` requirements.
   - **Transparent Profiles (`{A_1, ..., A_k}`)**: Flat reusable sets of sibling Agents with zero boundary forwarding ceremony.
4. **Static Compilation Soundness (`EXP-0002`, `EXP-0003`)**:
   - **Strict Stratification**: Hard interior binding flows strictly forward across an acyclic DAG.
   - **Commutative Keyed Aggregation**: Multi-provider collections combine via keyed maps/sets, never order-dependent flat lists.

---

## 3. Hard Boundaries: Authority, State & Lifecycle (`ADR-0004`, `ADR-0006` C1)

1. **Dual-Layer Cryptographic Authority (`L3+`)**:
   - **Layer 1 (Offline Root Identity)**: Long-lived situated boundaries hold cryptographic keypairs; static offline ACLs cover *strictly* the irreducible offline/bootstrap core (own boot/runtime secrets, mesh identity, offline human recovery).
   - **Layer 2 (Attenuated Capabilities)**: All active delegation across $\Sigma$ (AI agents, CI cache writers, PR-only bots, Live ISO onboarding, per-service boundaries) uses narrow, revocable, least-privilege Capabilities + kernel isolation.
   - **Boolean Set-Algebra Authorization (`Cedar` Semantics: $\cup, \cap, \in, \setminus$)**: Agents express factual groups & security/posture attributes; policies obey **Default-Deny**, **`forbid`-overrides-`permit`**, and **Order-Invariance** (proved in `Authority.lean`). Delegated capabilities obey **Offline-Verifiable Monotonic Attenuation** (`Biscuit` pattern, `attenuation_monotonic`).
2. **Mandatory Agent-Declared State-As-Promise (`S2+` + `CALM` Monotonicity)**:
   - Zero invisible non-reconstructible mutable state. Every stateful Agent declares state volumes/stores via typed promises with **Owner Boundary** and **open, orthogonal, composable traits** (reconstructibility, retention, CAP/FLP writer & consistency semantics, backup/replication policy, external ownership).
   - **CALM Theorem Law (`StateSafety.lean`)**: Multi-agent state crossing partitions without a single authoritative writer MUST be logically **monotonic** (join-semilattice / content-addressed / conflict-preserving lattice), forbidding silent split-brain.
3. **Lifecycle Transitions (`C1`)**:
   - *Zero-Trust Genesis ($t=0$)*: Ephemeral installer media never holds master keys or production secrets; new Agents generate local keys, verify custody, register public identity/attributes into Git, and converge to $g_0$.
   - *Mechanical Blast-Radius Revocation*: Revoking a compromised Agent blocks future access and computes the exact historical secret/capability rotation set from the `L3+` Boolean policy graph.
   - *Zero-Infrastructure Break-Glass*: Full resurrection guaranteed from simultaneous VPS + GitHub loss using offline human root keys, async Git mirror/clone, and encrypted off-host backups.

---

## 4. Spacetime Dynamics & Epistemics (`ADR-0005`, `ADR-0006` C7)

1. **Triadic Calibrated Autonomous Pull (`C3` + `TUF` Supply-Chain Defense)**:
   - Changes enter via PR impositions gated by verification Agents into **calibrated signed Snapshot Manifests** (`commit + monotonic epoch + timestamp → exact host Nix closure hashes` across Git `main` + async self-hosted mirror + signed prebuilt multi-arch binary caches — defeating **mix-and-match attacks**).
   - Hosts pull autonomously on local proper time (`FOLLOWS`: $g_n \to g_{n+1}$), enforcing **local monotonic epoch counters** (defeating **TUF rollback/downgrade attacks**) and **freshness staleness windows $\Delta t$** assessed by `E3` (detecting **TUF freeze attacks**), while avoiding forced local compilation on constrained/ARM nodes. Zero inbound CI push-root.
   - Atomic transitions run a local self-assessment gate ($\alpha$) with **automatic rollback to $g_n$** on survival failure (retaining explicit `L3+` human-authorized interactive switches).
2. **Semantic Spacetime ($\gamma(3,4)$) Epistemic Spine (`E3`) & Tri-Purpose Probes (`C7`)**:
   - All layers (hosts, services, substrates, Rust tools, CI, docs, generations, assessments) project onto **one minimal 4-link schema**: `CONTAINS`, `FOLLOWS`, `EXPRESSES`, `NEAR` (replacing ad-hoc CPG ontologies and eliminating all-layer doc/check blind spots).
   - **Spine vs. Bulk Telemetry Split**: High-volume metrics/logs live in compact specialized engines; only boundaries, causal transitions, assessments ($\alpha$), anomalies, and pointers populate the offline-queryable, token-efficient SST spine.
   - **Trust-Budgeted Assessment (*"Policy for Inattentiveness"*)**: `Hard` promises cost zero runtime RAM; `Soft` promises budget monitoring proportional to criticality × uncertainty, escalating deep inspection (including autonomous AI causal-cone analysis) upon degradation.
   - **Tri-Purpose Probes (`C7`)**: Assessment probes ($\alpha$) and degradation contracts (`+b | C`) declared once drive: (1) pre-merge CI & simulated fault-injection VM tests, (2) `C3` local auto-rollback gates, and (3) `E3` live observability.

---

## 5. Machine-Checked Verification Pillar (`ADR-0007` — AWS Cedar VGD `F3-b`)

- **4-Layer Lean 4 Architecture (`Data` → `Spec` → `Thm` → `Oracle`)**: [`architecture/formal/lean/Nixconf/`](../formal/lean/Nixconf/) (`lean4 4.35.0`, zero Mathlib, modeled on `cedar-policy/cedar-spec`) — **35 theorems** verified cold in `7.27 s` with zero `sorryAx` (`Nixconf/Audit.lean`), unifying Authorization, Partitioned Routing, and Open State Traits onto one shared `Data/AttrExpr` Boolean Lattice.
- **Modular Exhaustive Distributed Model Checking**: [`architecture/formal/quint/`](../formal/quint/) (`quint 0.33.1` + TLC, single-record Informal Systems style) — **11 safety invariants + 8 `quint test` runs** exhaustively verified across `1,878,049` (`triadic_pull`) + `54` (`lifecycle_recovery`) + `77` (`conditional_degradation`) transitions with `0` remaining.
- **Modular Production Engine Equivalence**: [`architecture/formal/drt/`](../formal/drt/) (`engine/*` mirroring `Nixconf/Spec/` 1:1) — Rust production verifier (`157k fleets/s`) continuously locked to the proved Lean 4 oracle via Differential Randomized Testing (`2,005 / 2,005` fleets, `0` divergences).
- **Architecture & Complete Mathematical Treatise**: [`formal/README.md`](../formal/README.md) + [`PAPER-FOUNDATION`](../paper/FOUNDATION-PAPER.md).
