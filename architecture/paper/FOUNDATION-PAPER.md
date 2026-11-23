---
id: PAPER-FOUNDATION
title: "Promised Spacetime: A Formally Verified, Promise-Theoretic Architecture for Heterogeneous Declarative Infrastructure"
type: paper
status: active
created: 2026-11-24
updated: 2026-11-24
domain: foundations
tags: [paper, formal-specification, promise-theory, semantic-spacetime, lean4, quint, tlc, aws-cedar, tuf, calm, operads, provenance-semirings]
assumptions: [A-001, A-002, A-004, A-005, A-006, A-011, A-013]
summary: Publication-grade formal mathematical specification and verification paper for nixconf v2 — presenting exact formal syntax, judgment rules, 22 Lean 4 machine-checked theorems (zero sorryAx), 8 exhaustively TLC-verified Quint invariants, AWS Cedar VGD differential testing results (2,004 fleets, 0 divergences), rival-theory comparisons, and formal contracts for Phase 3 realization.
---

<!-- abstract:start -->
## Abstract

Declarative infrastructure systems (such as NixOS fleets) commonly suffer from architectural entanglement: static module composition, cross-host evaluation coupling, cryptographic access control, mutable state persistence, asynchronous updates, and observability evolve as ad-hoc silos with incompatible mental models. We present **Promised Spacetime**, the formally verified theoretical foundation for `nixconf` v2, derived from first principles by uniting **Bergstra & Burgess's Promise Theory** and **Burgess & Couch's Semantic Spacetime ($\gamma(3,4)$)** with **Dolstra's immutable cryptographic closures**, **Lampson / AWS Cedar / Biscuit authorization**, **TUF supply-chain calibration**, and **Hellerstein's CALM monotonicity theorem**. We formalize the entire foundation using the **AWS Cedar Verification-Guided Development (`F3-b`)** methodology: (i) **22 unbounded theorems** machine-checked in pure-core **Lean 4.35.0** (zero Mathlib, zero `sorryAx`, `3.34 s` cold build); (ii) **8 temporal safety invariants** exhaustively model-checked via **Quint 0.33.1 / TLC** (`165,376` transitions / `62,732` distinct states for Triadic Pull + TUF defense in `3.17 s`, plus `241` transitions for Zero-Trust Genesis & Conditional Degradation in `1.60 s`, with intentional TUF downgrade fault-injection caught in `64 ms`); and (iii) **Differential Randomized Testing (DRT)** proving **0 divergences** across `2,004` fleets between our Lean 4 verified oracle (`1,085 ms`) and an idiomatic Rust production engine (`6.27 ms`, `319.8k fleets/s`).
<!-- abstract:end -->

# Promised Spacetime: A Formally Verified, Promise-Theoretic Architecture for Heterogeneous Declarative Infrastructure

**Version**: 1.0 (Phase 2B Ratified Baseline)  
**Date**: 2026-11-24  
**Verified Artifacts**:
- Lean 4 Proof Suite (`lean4 4.35.0`, zero Mathlib): [`architecture/formal/lean/`](../formal/lean/)
- Quint / TLA+ Protocol Models (`quint 0.33.1` + TLC): [`architecture/formal/quint/`](../formal/quint/)
- Rust Production Verifier & DRT Harness (`rustc 1.99.0`): [`architecture/formal/drt/main.rs`](../formal/drt/main.rs)
- Empirical Benchmark Report: [`EXP-0005`](../experiments/EXP-0005-lean4-quint-cedar-vgd-verification.md)

---

## 1. Introduction & Problem Statement

Modern personal and small-fleet infrastructure spans violently heterogeneous targets: 24/7 public VPSes (`astrolabe`, 11 GiB RAM, impermanent root), roaming laptops (`x240`, dual-OLED ZenBook Duo, hybrid-GPU TUF laptop), stealable touch tablets (Chromebook), low-RAM `aarch64` SBCs (Raspberry Pi), kernel-less Windows interop (`NixOS-WSL`), ephemeral read-only media (`Live-ISO`), standalone non-NixOS execution (`nix run`), and autonomous AI agents (`agy`).

Empirical analysis of `nixconf` v1 (`AUD-0001`–`AUD-0004`, ~50k LOC) exposed five structural failure modes endemic to conventional NixOS module repositories:
1. **Boundary Piercing & Cache Coupling**: Reading peer host `nixosConfigurations` and 226 untyped global `internal.*` backchannels coupled evaluation and invalidated Nix binary caches across unrelated hosts.
2. **1:1 Implementation Lock-In & List-Order Fragility**: Static singletons prevented multi-instance providers and sub-component swapping, while unkeyed list merges introduced import-order sensitivity (`EXP-0002`).
3. **Siloed Security & State Drift**: Implicit `/var/lib` writes decoupled from impermanence/backup lists created silent data-loss hazards, while coarse host-key ACLs blurred incomparable threat postures.
4. **Imposition-Driven Operations & Supply-Chain Gaps**: Push-based deployment fails on NAT'd/roaming hosts and grants excessive inbound root privilege; naive pull lacks TUF anti-downgrade/freeze defense and health-gated rollback.
5. **Epistemic Fragmentation**: Observability (`1.59 GiB` RAM — 5.5× all core services), 5.3k LOC of ad-hoc pure-Nix graph code, partial docs blind to 15k LOC of tooling/Rust, and unstructured LLM navigation lived in four disconnected worlds.

**Thesis**: All five failure modes dissolve simultaneously when the entire system — from a wrapped CLI binary up to a multi-host fleet, CI, humans, and AI agents — is grounded in a **single formally verified calculus**: *Fractal Promise Theory* bounded by *Hard Structural/Cryptographic Enforcement* and unified epistemically by *Semantic Spacetime ($\gamma(3,4)$)*.

---

## 2. Formal Algebra of Fractal Agency & Non-Piercing Boundaries

### 2.1 Syntax (Operadic Fractal Agency with `P-Dual`)

Let $\mathcal{T}$ be the open set of Promise Types, $\mathcal{K}$ the set of commutative merge/partition keys, and $\mathcal{G}$ the set of factual attribute/group tags.

$$\begin{aligned}
\text{Polarity } \rho &::=\; + \;\mid\; - \\
\text{Strength } \varsigma &::=\; \mathsf{Hard} \;\mid\; \mathsf{Soft}(c_{\text{ref}}, d_{\text{deg}}, \alpha_{\text{probe}}) \\
\text{Cardinality } \kappa &::=\; \mathsf{Exclusive} \;\mid\; \mathsf{Broadcast} \;\mid\; \mathsf{Partitioned} \;\mid\; \mathsf{Budgeted}(q \in \mathbb{N}) \\
\text{Promise } \pi &::=\; \langle \text{id},\; \tau \in \mathcal{T},\; k \in \mathcal{K},\; \rho,\; \varsigma,\; \kappa,\; \text{mandatory} \in \mathbb{B} \rangle \\
\text{Exterior Surface } \Pi_{\text{ext}} &::=\; \langle \text{agentId},\; \text{promises} : [\pi],\; \text{attrs} : [\mathcal{G}] \rangle \\
\text{Agent } A &::=\; \mathsf{Atomic}(\Pi_{\text{ext}}, h_{\text{int}}) \;\mid\; \mathsf{Superagent}(\Pi_{\text{ext}}, [A_1, \dots, A_n]) \;\mid\; \mathsf{Profile}([A_1, \dots, A_k])
\end{aligned}$$

Notice the exact **`P-Dual`** distinction (`ADR-0003`):
- $\mathsf{Superagent}(\Pi_{\text{ext}}, \vec{A})$ defines an **opaque encapsulation boundary $\Sigma_S$** (`P-Explicit`: neither interior $+b$ offers nor unfulfilled interior $-b$ requirements cross $\Sigma_S$ unless explicitly declared in $\Pi_{\text{ext}}$).
- $\mathsf{Profile}(\vec{A})$ is **not** a boundary $\Sigma$ — mathematically a transparent set flattened directly into the enclosing Superagent's interior ($\mathsf{flattenScope}$), yielding zero boilerplate for convenience bundles (e.g., `CoreCliTools`, `WaylandDesktop`).

### 2.2 Operational View vs. Authorized Epistemic Zoom

Define the **Boundary-First Exterior Projection** $\mathsf{exteriorOf}(A)$ which extracts $\Pi_{\text{ext}}$ **without inspecting interior children of any $\mathsf{Superagent}$**:
$$\mathsf{exteriorOf}(\mathsf{Atomic}(\Pi, \_)) = [\Pi], \qquad \mathsf{exteriorOf}(\mathsf{Superagent}(\Pi, \_)) = [\Pi], \qquad \mathsf{exteriorOf}(\mathsf{Profile}(\vec{A})) = \bigoplus_{a \in \vec{A}} \mathsf{exteriorOf}(a)$$
and the operational sibling view $\mathcal{V}(\vec{S}) = \bigoplus_{s \in \vec{S}} \mathsf{exteriorOf}(s)$.

### 2.3 Machine-Checked Theorems — Agency (`NixconfFoundation/Agency.lean`)

| Theorem (Lean 4 Symbol) | Formal Statement | Architectural & Nix Consequence |
| :--- | :--- | :--- |
| **`flattenScope_append`** / **`profile_nesting_invariant`** | $\mathsf{flatten}(\mathsf{Profile}(M) :: R) = \mathsf{flatten}(M \mathbin{+\!+} R)$ | Operadic associativity of transparent profiles (`P-Dual`). |
| **`boundary_first_stratification`** | $\mathsf{exteriorOf}(\mathsf{Superagent}(\Pi, C_1)) = \mathsf{exteriorOf}(\mathsf{Superagent}(\Pi, C_2))$ | $\Pi_{\text{ext}}(S) \perp \text{Interior}(S)$ (`ADR-0006` C2): eliminates fleet-scale mutual eval recursion! |
| **`non_piercing_interior_substitution`** | $\mathcal{V}(P \mathbin{+\!+} [\mathsf{Superagent}(\Pi, C_1)] \mathbin{+\!+} Q) = \mathcal{V}(P \mathbin{+\!+} [\mathsf{Superagent}(\Pi, C_2)] \mathbin{+\!+} Q)$ | **Crown Jewel**: swapping `Grafana → Perses` or editing `x240`'s interior while preserving $\Pi_{\text{ext}}$ leaves every external sibling's input strictly identical → **proves both Parnas hiding AND Nix binary-cache isolation!** |
| **`checkStandalone_sound_and_complete`** | $\mathsf{checkStandalone}(\Pi) = \top \iff \forall \pi \in \Pi.\; \mathsf{mandHardUse}(\pi) \to \pi.\tau = \text{"store-pkg"}$ | Proves Standalone Portability (`X4`) emerges from minimal store-only scope — zero special entity kind needed! |

---

## 3. Unified Promise Binding, Conservation & Compilation Soundness

Inside any scope multiset $P = \bigoplus_{\Pi \in \mathcal{V}(\vec{S})} \Pi.\text{promises}$, define:
- $\mathsf{offers}(P, \tau, k) = |\{\pi \in P \mid \pi.\rho = + \land \pi.\tau = \tau \land \pi.k = k\}|$,
- $\mathsf{supply}(P, \tau) = \sum_{\pi \in P,\; \pi.\rho = +,\; \pi.\kappa = \mathsf{Budgeted}(q),\; \pi.\tau = \tau} q$,
- $\mathsf{demand}(P, \tau) = \sum_{\pi \in P,\; \pi.\rho = -,\; \pi.\kappa = \mathsf{Budgeted}(q),\; \pi.\tau = \tau} q$.

A scope $P$ satisfies $\mathsf{isScopeValid}(P)$ iff every $\pi \in P$ obeys:
1. **Conditional Promise Law**: If $\pi.\varsigma = \mathsf{Soft}(c, d, \alpha)$, then $c, d, \alpha$ are all explicitly populated (non-empty).
2. **`Exclusive` (`1:1`)**: Mandatory hard uses require $\mathsf{offers}(P, \tau, k) = 1$; offers forbid $\mathsf{offers}(P, \tau, k) > 1$.
3. **`Partitioned` (`N:K`)**: Offers forbid overlapping route keys ($\mathsf{offers}(P, \tau, k) \le 1$).
4. **`Broadcast` (`1:N`)**: $0..N$ observers permitted commutatively.
5. **`Budgeted Capacity` (`C4`)**: Every budgeted demand requires $\mathsf{demand}(P, \tau) \le \mathsf{supply}(P, \tau)$.

### 3.1 Machine-Checked Theorems — Binding (`NixconfFoundation/Binding.lean`)

| Theorem (Lean 4 Symbol) | Formal Statement | Consequence |
| :--- | :--- | :--- |
| **`checkPromise_perm`** / **`isScopeValid_perm`** | $P_1 \sim_{\text{Perm}} P_2 \implies \mathsf{isScopeValid}(P_1) = \mathsf{isScopeValid}(P_2)$ | **Commutative Order-Invariance**: arbitrary module/agent import permutations NEVER alter validity (eliminating the `EXP-0002` list-order hazard for unbounded fleet sizes!). |
| **`exclusive_binding_sound`** | $\mathsf{isScopeValid}(P) \land \pi \in P_{\text{excl,use,hard,mand}} \implies \mathsf{offers}(P, \pi.\tau, \pi.k) = 1$ | Zero missing providers AND zero silent last-write-wins conflicts (`B3`). |
| **`budget_conservation_sound`** | $\mathsf{isScopeValid}(P) \land \pi \in P_{\text{budget,use}} \implies \mathsf{demand}(P, \pi.\tau) \le \mathsf{supply}(P, \pi.\tau)$ | Prevents statically over-committing RAM/disk on `astrolabe`, `rpi`, or `chromebook` (`C4`). |
| **`soft_conditional_law_sound`** | $\mathsf{isScopeValid}(P) \land \pi \in P_{\text{soft}} \implies \exists s.\; \pi.\text{softInfo} = \mathsf{some}\; s \land s.\mathsf{isComplete}$ | Enforces explicit graceful degradation & probe $\alpha$ on every runtime-fragile dependency. |

---

## 4. Hard Boundaries: Cedar Boolean Lattice, Biscuit Attenuation & CALM State Safety

### 4.1 Authorization Algebra (`L3+` + AWS Cedar + Biscuit)

Replacing rigid linear trust tiers with a **Boolean Set-Algebra Lattice** over expressed agent tags $\mathcal{G}$ cleanly models incomparable security postures (`astrolabe` public VPS vs. `x240` roaming encrypted workstation vs. `rpi` home LAN vs. `agy` AI agent):
$$\varphi ::= \mathsf{atom}(t) \;\mid\; \varphi_1 \cup \varphi_2 \;\mid\; \varphi_1 \cap \varphi_2 \;\mid\; \varphi_1 \setminus \varphi_2 \;\mid\; \neg\varphi \;\mid\; \top \;\mid\; \bot$$

Each policy $p = \langle \text{eff} \in \{\mathsf{permit}, \mathsf{forbid}\}, a, \varphi_{\text{prin}}, \varphi_{\text{res}} \rangle$ evaluates under **AWS Cedar semantics**:
$$\mathsf{isAuthorized}(\mathcal{P}, u, a, r) \;\triangleq\; \bigl(\exists p \in \mathcal{P}_{\text{permit}}.\; p.\mathsf{matches}(u,a,r)\bigr) \;\land\; \neg\bigl(\exists f \in \mathcal{P}_{\text{forbid}}.\; f.\mathsf{matches}(u,a,r)\bigr)$$

Offline-verifiable delegated capabilities (`Biscuit` pattern) carry an append-only list of narrowing caveats $\vec{c}$, attenuated strictly via $\mathsf{attenuate}(\text{cap}, c') = \vec{c} \mathbin{+\!+} [c']$. Mechanical **Blast-Radius Revocation** computes $\mathsf{blastRadius}(\mathcal{P}, u, a, R) = \{r \in R \mid \mathsf{isAuthorized}(\mathcal{P}, u, a, r)\}$.

#### Machine-Checked Theorems — Authority (`NixconfFoundation/Authority.lean`)

| Theorem (Lean 4 Symbol) | Formal Statement | Consequence |
| :--- | :--- | :--- |
| **`default_deny_empty`** | $\mathsf{isAuthorized}([], u, a, r) = \bot$ | Secure fail-closed default. |
| **`forbid_overrides_permit`** | $f \in \mathcal{P}_{\text{forbid}} \land f.\mathsf{matches}(u,a,r) \implies \mathsf{isAuthorized}(\mathcal{P}, u, a, r) = \bot$ | Global safety guards (e.g. `forbid (roaming ∪ ai-agent ∪ ephemeral)` on `prod-core`) can **never** be bypassed by any stray local `permit`! |
| **`policy_order_invariance`** | $\mathcal{P}_1 \sim_{\text{Perm}} \mathcal{P}_2 \implies \mathsf{isAuthorized}(\mathcal{P}_1, u, a, r) = \mathsf{isAuthorized}(\mathcal{P}_2, u, a, r)$ | Policy declaration order is strictly irrelevant. |
| **`attenuation_monotonic`** | $(\text{cap}.\mathsf{attenuate}\; c').\mathsf{allows}(a, r) \implies \text{cap}.\mathsf{allows}(a, r)$ | **Non-Escalation**: offline delegation can only shrink authority, never widen it. |
| **`blast_radius_sound_and_complete`** | $r \in R \implies (r \in \mathsf{blastRadius}(\mathcal{P}, u, a, R) \iff \mathsf{isAuthorized}(\mathcal{P}, u, a, r))$ | Exact zero-miss rotation checklist if a roaming device is stolen (`C1`). |
| **`attr_diff_excludes`** | $\llbracket \varphi_1 \setminus \varphi_2 \rrbracket_T \iff \llbracket \varphi_1 \rrbracket_T \land \neg \llbracket \varphi_2 \rrbracket_T$ | Sound set-difference exclusion. |

### 4.2 Open State-As-Promise & CALM Logical Monotonicity (`S2+`)

Rather than a closed enum, each declared state volume carries open orthogonal traits (`reconstructible`, `survivesReboot`, `monotonic`, `multiWriter`, `singleAuthWriter`, `backupRequired`, `externalOwned`). Let $\mathsf{needsPersist}(v) \triangleq v.\text{survivesReboot} \land \neg v.\text{reconstructible} \land \neg v.\text{externalOwned}$ and $\mathsf{calmValid}(v) \triangleq \neg v.\text{multiWriter} \lor v.\text{monotonic} \lor v.\text{singleAuthWriter}$.

#### Machine-Checked Theorems — State Safety (`NixconfFoundation/StateSafety.lean`)

| Theorem (Lean 4 Symbol) | Formal Statement | Consequence |
| :--- | :--- | :--- |
| **`ephemeral_substrate_durable_impossibility`** | $\neg \text{sub}.\text{durable} \land v \in V \land \mathsf{needsPersist}(v) \implies \neg \mathsf{allVolumesValid}(\text{sub}, V)$ | Mechanically forbids deploying durable state (e.g., Vaultwarden) onto ephemeral `Live-ISO`. |
| **`calm_multiwriter_requires_monotonic`** | $\mathsf{allVolumesValid} \land v.\text{multiWriter} \land \neg v.\text{singleAuthWriter} \implies v.\text{monotonic}$ | Enforces Hellerstein's **CALM Theorem** statically (zero silent split-brain!). |
| **`backup_coverage_soundness`** | $\mathsf{allVolumesValid} \land v.\text{backupRequired} \implies \text{sub}.\text{backupProviders} > 0$ | Guarantees no irreplaceable backup-flagged volume runs unbacked-up. |

---

## 5. Semantic Spacetime ($\gamma(3,4)$) & Asynchronous Protocol Verification

### 5.1 Semantic Spacetime Graph Algebra (`NixconfFoundation/Spacetime.lean`)

Every structural, causal, attributive, and associative relation projects onto the 4 irreducible `STTypes` ($\mathsf{CONTAINS}, \mathsf{FOLLOWS}, \mathsf{EXPRESSES}, \mathsf{NEAR}$).

| Theorem (Lean 4 Symbol) | Formal Statement | Consequence |
| :--- | :--- | :--- |
| **`ranked_sst_acyclic`** | $\mathsf{strictlyRanked}(G, \text{ty}, \text{rank}) \implies \neg \mathsf{STPath}(G, \text{ty}, u, u)$ | Guarantees acyclicity of proper-time causality (`FOLLOWS`) and scale containment (`CONTAINS`). |
| **`absorbing_boundary_zero_external_impact`** | $\mathsf{opDeps}(G, x) = [] \implies \forall k.\; \mathsf{impactCone}(G, k, [x]) = [x]$ | Formalizes Burgess's absorbing boundary (`arXiv:2506.07756`): interior edits preserving $\Pi_{\text{ext}}$ have empty external impact cones! |
| **`epistemic_edges_preserve_operational_deps`** | $e.\text{sttype} \neq \mathsf{FOLLOWS} \implies \mathsf{opDeps}(e :: G, n) = \mathsf{opDeps}(G, n)$ | Reconciles `ADR-0002` Non-Piercing with `E3` Epistemic Zoom (`C5`): adding read-only `CONTAINS`/`NEAR` edges introduces zero reverse build dependencies! |

**Kernel Axiom Audit (`AxiomAudit.lean`)**: All **22 theorems** depend *solely* on Lean 4's trusted core axioms (`propext`, `Quot.sound`, `Classical.choice`) — **zero `sorryAx`**, **zero Mathlib**, compiled cold from scratch in **`3.34 s`**.

### 5.2 Exhaustive Temporal Model Checking — Quint `0.33.1` / TLC (`architecture/formal/quint/`)

Because asynchronous crashes, network partitions, and adversarial mirrors involve unbounded interleavings of time, we model-checked our two dynamic protocols exhaustively with Quint → Apalache → TLC2 (`EXP-0005`):

1. **`triadic_pull_c3.qnt` (`ADR-0005` `C3` + `RES-0013` TUF Defense)**:
   - Models Git `main`, compromised/frozen mirror injecting forged mix-and-match closures, missing cache artifacts, unhealthy runtime closures triggering autonomous rollback, and TUF monotonic epoch + freshness staleness alerts.
   - **Exhaustive TLC Proof**: **165,376 transitions / 62,732 distinct states (depth 18, 0 states remaining)** verified in **`3.17 s`** — proving `invNeverActivatesForged`, `invCommittedAlwaysHealthy`, `invMonotonicHealthyLineage`, and `invNeverActivatesUncached`!
   - **Active Fault-Injection Proof**: Removing the TUF monotonic epoch guard (`snap.epoch > h.maxSeenEpoch` → `!= activeEpoch`) triggered a downgrade-attack violation in **`64 ms`** (trace #4), empirically proving the model detects real supply-chain attacks!
2. **`genesis_and_degradation.qnt` (`ADR-0006` C1 Zero-Trust Genesis + `Soft` $+b \mid C$ Degradation)**:
   - Models `Live-ISO` local keygen, human custody verification, mid-onboarding power crashes, WAN/mesh outages, and TUF laptop unplugging mid-remote-build (`power:ac-plugged` condition).
   - **Exhaustive TLC Proof**: **241 transitions / 50 distinct states (depth 8, 0 states remaining)** verified in **`1.60 s`** — proving `invIsoNeverHoldsProdSecrets`, `invNoOrphanedGenesisIdentity`, `invCoreVitalitySurvivesPartitions`, and `invOpportunisticComputeSound`!

---

## 6. Closing the Spec-to-Code Gap: AWS Cedar VGD Differential Testing

Following **AWS Cedar (OOPSLA 2024)** (`F3-b`, [`ADR-0007`](../adrs/ADR-0007-formal-verification-cedar-vgd-and-tuf-calm-upgrades.md)), we compiled the exact proved Lean 4 modules into a native oracle (`nixconf-oracle`) and implemented an idiomatic, zero-dependency Rust production evaluator ([`architecture/formal/drt/main.rs`](../formal/drt/main.rs)).

- **Coverage**: 4 concrete `nixconf` fleet scenarios (`astrolabe-healthy`, `rpi-budget-exceeded`, `live-iso-durable-rejected`, `calm-non-monotonic-multiwriter-rejected`) + **2,000 randomized fuzzed fleets** (random promises, conflicts, budgets, nested Boolean ASTs, `permit`/`forbid` policies, state traits).
- **Result**: **2,004 / 2,004 bit-for-bit identical verdicts — 0 divergences!**
- **Performance**: **Rust = `6.27 ms` (`319,761 fleets/s`)** vs. **Lean 4 native oracle = `1,085.29 ms` (`1,847 fleets/s`)** — delivering ~3 µs production verification speed locked mathematically to a machine-proved Lean 4 oracle!

---

## 7. Rival-Theory Comparative Synthesis (`RES-0013`)

| Architectural Layer | Rival Frameworks Studied | Exact Synthesis Adopted |
| :--- | :--- | :--- |
| **Composition & Scaling** | Mixin Lattices, ML Functors, Algebraic Effects, **Spivak/Fong Operads** | Fractal Promise Theory (`ADR-0002`, `ADR-0003`) formalizing Dressed Superagents as an Operad of Non-Piercing Wiring Diagrams (`non_piercing_interior_substitution`). |
| **Authorization & Capabilities** | Static ACLs, Online SPIFFE/Vault, Macaroons, **AWS Cedar**, **Biscuit** | `L3+` (`ADR-0004`, `ADR-0007`): Offline Root Identity + **Cedar** Default-Deny/`forbid`-dominates Boolean Lattice + **Biscuit** Offline Monotonic Attenuation + Mechanical Blast-Radius. |
| **State & Consistency** | Implicit Host FS, Cloud-Native External DBs, **Hellerstein CALM / CRDTs** | `S2+` (`ADR-0004`, `ADR-0007`): Open Composable State-As-Promise grounded in **CALM Logical Monotonicity** (`calm_multiwriter_requires_monotonic`). |
| **Updates & Supply Chain** | Push Deployers, Blind `autoUpgrade`, **TUF**, **in-toto** | `C3` (`ADR-0005`, `ADR-0007`): Triadic Calibrated Autonomous Pull + **TUF** Rollback/Freeze/Mix-and-Match Defense + Atomic Self-Assessing Auto-Rollback. |
| **Epistemics & Observability** | Siloed DevOps, Monolithic Graph DB, **Provenance Semirings / Datalog** | `E3` (`ADR-0005`): Lightweight **SST $\gamma(3,4)$ Spine** over specialized bulk telemetry + Trust-Budgeted Assessment + **Tri-Purpose Probes ($\alpha$)** (`C7`). |

---

## 8. Formal Contracts Passed Forward to Phase 3 (`R1`–`R7`)

Every concrete engineering RFD in Phase 3 MUST realize and preserve these machine-verified invariants:
1. **`R1` (Medium, Boundary Engine & Nix↔Rust Seam)**: Must physically enforce **Boundary-First Stratification ($\Pi_{\text{ext}} \perp \text{Interior}$)** and expose a clean boundary manifest consumable by the **F3-b Rust + Lean 4 DRT verifier** without evaluating NixOS interiors!
2. **`R2` (Pinning, Standalone & Pure Rust/Lean Integration)**: Must package `lean4` proofs, `quint` specs, and Rust production binaries reproducibly with strict cache isolation and zero NixOS host leakage into `Standalone` closures (`checkStandalone_sound_and_complete`).
3. **`R3` (Mesh, Secrets & Onboarding)**: Must realize **Cedar `forbid`-dominates Boolean policies**, **Blast-Radius revocation**, **Biscuit-style attenuated capabilities**, and **`genesis_and_degradation.qnt`'s Zero-Trust Genesis sequence** (registering pubkeys *only* after custody verification & install, zero secrets on `Live-ISO`).
4. **`R4` (GitOps, Cache & Mirroring)**: Must realize **`triadic_pull_c3.qnt`** — signed Snapshot Manifests, host-local monotonic epoch counters (anti-downgrade), freshness staleness alerting (anti-freeze), prebuilt multi-arch cache gating, and atomic self-assessing rollback.
5. **`R5` (Storage & Opportunistic Compute)**: Must realize **`S2+` State-As-Promise** (impermanence/backup bound mechanically, CALM-compliant replication) and **`C4` dynamic power conditions** (`power:ac-plugged` on TUF laptop).
6. **`R6` & `R7` (Observability, AI Analysis & All-Layer Docs)**: Must keep raw telemetry compact/bounded while projecting boundaries, `FOLLOWS` transitions, Tri-Purpose Probes ($\alpha$), and all-layer docs onto the lightweight **SST $\gamma(3,4)$ Spine** (`E3`).
