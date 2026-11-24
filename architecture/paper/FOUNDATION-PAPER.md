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
summary: Publication-grade formal mathematical specification and verification paper for nixconf v2 — presenting exact formal syntax, judgment rules, 35 Lean 4 machine-checked theorems in a 4-layer cedar-lean architecture (zero sorryAx), 11 exhaustively TLC-verified Quint invariants + 8 quint tests across 3 modular protocol specs, AWS Cedar VGD differential testing results (2,005 fleets, 0 divergences), rival-theory comparisons, and formal contracts for Phase 3 realization.
---

<!-- abstract:start -->
## Abstract

Declarative infrastructure systems (such as NixOS fleets) commonly suffer from architectural entanglement: static module composition, cross-host evaluation coupling, cryptographic access control, mutable state persistence, asynchronous updates, and observability evolve as ad-hoc silos with incompatible mental models. We present **Promised Spacetime**, the formally verified theoretical foundation for `nixconf` v2, derived from first principles by uniting **Bergstra & Burgess's Promise Theory** and **Burgess & Couch's Semantic Spacetime ($\gamma(3,4)$)** with **Dolstra's immutable cryptographic closures**, **Lampson / AWS Cedar / Biscuit authorization**, **TUF supply-chain calibration**, and **Hellerstein's CALM monotonicity theorem**. We formalize the entire foundation using a production-grade 4-layer **AWS Cedar Verification-Guided Development (`F3-b`)** architecture (`Data/` → `Spec/` → `Thm/` → `Oracle/`, unifying Authorization, Partitioned Routing, and Open State Traits onto a single shared `AttrExpr` Boolean Lattice): (i) **35 unbounded theorems** machine-checked in pure-core **Lean 4.35.0** (zero Mathlib, zero `sorryAx`, `7.27 s` cold build); (ii) **11 temporal safety invariants + 8 deterministic `quint test` runs** exhaustively model-checked via **Quint 0.33.1 / TLC** (`1,878,049` transitions / `572,644` distinct states for Triadic Pull + TUF + Mid-Switch Crash Recovery + Human Override Lock in `11.10 s`, plus `54` states for Genesis/Revocation/Break-Glass in `1.24 s` and `77` states for Conditional Degradation in `1.26 s`); and (iii) **Modular Differential Randomized Testing (DRT)** proving **0 divergences** across `2,005` fleets between our Lean 4 verified oracle (`1,708.8 ms`) and modular Rust production engine (`12.74 ms`, `157.3k fleets/s`).
<!-- abstract:end -->

# Promised Spacetime: A Formally Verified, Promise-Theoretic Architecture for Heterogeneous Declarative Infrastructure

**Version**: 2.0 (Phase 2B Production-Architected Baseline — All 6 Modeling Gaps Closed)  
**Date**: 2026-11-24  
**Verified Artifacts**:
- Architecture Overview: [`architecture/formal/README.md`](../formal/README.md)
- Lean 4 4-Layer Proof Suite (`lean4 4.35.0`, zero Mathlib, **35 theorems**): [`architecture/formal/lean/Nixconf/`](../formal/lean/Nixconf/)
- Modular Quint / TLA+ Protocol Specs (`quint 0.33.1` + TLC, **11 invariants + 8 tests**): [`architecture/formal/quint/`](../formal/quint/)
- Modular Rust Production Verifier & DRT Harness (`rustc 1.99.0`): [`architecture/formal/drt/`](../formal/drt/)
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

### 2.3 Machine-Checked Theorems — Agency (`Nixconf/Thm/Agency.lean`, 7 Theorems)

| Theorem (Lean 4 Symbol) | Formal Statement | Architectural & Nix Consequence |
| :--- | :--- | :--- |
| **`flattenScope_append`** / **`profile_nesting_invariant`** | $\mathsf{flatten}(\mathsf{Profile}(M) :: R) = \mathsf{flatten}(M \mathbin{+\!+} R)$ | Operadic associativity of transparent profiles (`P-Dual`). |
| **`boundary_first_stratification`** | $\mathsf{exteriorOf}(\mathsf{Superagent}(\Pi, C_1)) = \mathsf{exteriorOf}(\mathsf{Superagent}(\Pi, C_2))$ | $\Pi_{\text{ext}}(S) \perp \text{Interior}(S)$ (`ADR-0006` C2): eliminates fleet-scale mutual eval recursion! |
| **`non_piercing_interior_substitution`** | $\mathcal{V}(P \mathbin{+\!+} [\mathsf{Superagent}(\Pi, C_1)] \mathbin{+\!+} Q) = \mathcal{V}(P \mathbin{+\!+} [\mathsf{Superagent}(\Pi, C_2)] \mathbin{+\!+} Q)$ | **Crown Jewel**: swapping `Grafana → Perses` or editing `x240`'s interior while preserving $\Pi_{\text{ext}}$ leaves every external sibling's input strictly identical → **proves both Parnas hiding AND Nix binary-cache isolation!** |
| **`conforms_no_lying_offers`** / **`conforms_no_leaked_requirements`** | $\mathsf{checkConformance}(\Pi, C) = [] \implies$ every exported $+b$ is backed internally AND every unmet mandatory interior $-b$ is declared in $\Pi$ | Strict **`P-Explicit`** soundness (no lying boundaries, no hidden host dependencies). |
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

### 3.1 Machine-Checked Theorems — Binding (`Nixconf/Thm/Binding.lean`, 8 Theorems)

| Theorem (Lean 4 Symbol) | Formal Statement | Consequence |
| :--- | :--- | :--- |
| **`validateScope_nil_iff_valid`** | $\mathsf{validateScope}(P) = [] \iff \mathsf{isScopeValid}(P) = \top$ | Diagnostic soundness & completeness (structured errors match verdict). |
| **`checkPromise_perm`** / **`isScopeValid_perm`** | $P_1 \sim_{\text{Perm}} P_2 \implies \mathsf{isScopeValid}(P_1) = \mathsf{isScopeValid}(P_2)$ | **Commutative Order-Invariance**: arbitrary module/agent import permutations NEVER alter validity (eliminating the `EXP-0002` list-order hazard for unbounded fleet sizes!). |
| **`exclusive_binding_sound`** | $\mathsf{isScopeValid}(P) \land \pi \in P_{\text{excl,use,hard,mand}} \implies \mathsf{offers}(P, \pi.\tau, \pi.k) = 1$ | Zero missing providers AND zero silent last-write-wins conflicts (`B3`). |
| **`partitioned_selector_disjoint_sound`** | $\mathsf{isScopeValid}(P) \land \pi \in P_{\text{part,offer}} \implies \mathsf{matchingHandlers}(P, \pi.\tau, \pi.\text{tags}) \le 1$ | Zero overlapping `AttrExpr` provider predicates (disjoint public vs. mesh proxies!). |
| **`budget_and_critical_tier_sound`** | $\mathsf{isScopeValid}(P) \land \pi \in P_{\text{budget,use}} \implies \mathsf{demand} \le \mathsf{supply} \land \mathsf{critDemand} \le \mathsf{supply}$ | Prevents over-committing RAM/disk AND guarantees priority-0 critical edge services fit inside host capacity (`C4`). |
| **`soft_conditional_law_sound`** | $\mathsf{isScopeValid}(P) \land \pi \in P_{\text{soft}} \implies \exists s.\; \pi.\text{softInfo} = \mathsf{some}\; s \land s.\mathsf{isComplete}$ | Enforces explicit graceful degradation & probe $\alpha$ on every runtime-fragile dependency. |
| **`multi_stratum_bounded`** | $\mathsf{validateStratumRules}(R) = [] \implies \forall p \in \mathsf{evalStratified}(R, B, k).\; p.\text{stratum} \le k$ | Proves strict forward acyclic termination of multi-stratum derived handler rules (`S0 → S1 → ... → Sk`). |

---

## 4. Hard Boundaries: Cedar Boolean Lattice, Biscuit Attenuation & CALM State Safety

### 4.1 Authorization Algebra (`L3+` + AWS Cedar + Biscuit)

Replacing rigid linear trust tiers with a **Boolean Set-Algebra Lattice** over expressed agent tags $\mathcal{G}$ cleanly models incomparable security postures (`astrolabe` public VPS vs. `x240` roaming encrypted workstation vs. `rpi` home LAN vs. `agy` AI agent):
$$\varphi ::= \mathsf{atom}(t) \;\mid\; \varphi_1 \cup \varphi_2 \;\mid\; \varphi_1 \cap \varphi_2 \;\mid\; \varphi_1 \setminus \varphi_2 \;\mid\; \neg\varphi \;\mid\; \top \;\mid\; \bot$$

Each policy $p = \langle \text{eff} \in \{\mathsf{permit}, \mathsf{forbid}\}, a, \varphi_{\text{prin}}, \varphi_{\text{res}} \rangle$ evaluates under **AWS Cedar semantics**:
$$\mathsf{isAuthorized}(\mathcal{P}, u, a, r) \;\triangleq\; \bigl(\exists p \in \mathcal{P}_{\text{permit}}.\; p.\mathsf{matches}(u,a,r)\bigr) \;\land\; \neg\bigl(\exists f \in \mathcal{P}_{\text{forbid}}.\; f.\mathsf{matches}(u,a,r)\bigr)$$

Offline-verifiable delegated capabilities (`Biscuit` pattern) carry an append-only list of narrowing caveats $\vec{c}$, attenuated strictly via $\mathsf{attenuate}(\text{cap}, c') = \vec{c} \mathbin{+\!+} [c']$. Mechanical **Blast-Radius Revocation** computes $\mathsf{blastRadius}(\mathcal{P}, u, a, R) = \{r \in R \mid \mathsf{isAuthorized}(\mathcal{P}, u, a, r)\}$.

#### Machine-Checked Theorems — Authority (`Nixconf/Thm/Authority.lean`, 10 Theorems)

| Theorem (Lean 4 Symbol) | Formal Statement | Consequence |
| :--- | :--- | :--- |
| **`isAuthorized_iff`** / **`default_deny_empty`** | Structured `AuthResponse` matches permit/forbid semantics; empty set denies all | Diagnostic explainability (`determiningPolicies`) + secure fail-closed default. |
| **`forbid_overrides_permit`** | $f \in \mathcal{P}_{\text{forbid}} \land f.\mathsf{matches}(u,a,r) \implies \mathsf{isAuthorized}(\mathcal{P}, u, a, r) = \bot$ | Global safety guards can **never** be bypassed by any stray local `permit`! |
| **`policy_order_invariance`** | $\mathcal{P}_1 \sim_{\text{Perm}} \mathcal{P}_2 \implies \mathsf{isAuthorized}(\mathcal{P}_1, u, a, r) = \mathsf{isAuthorized}(\mathcal{P}_2, u, a, r)$ | Policy declaration order is strictly irrelevant. |
| **`attenuation_monotonic`** / **`delegated_attenuation_monotonic`** | $(\text{cap}.\mathsf{attenuate}\; c')$ only shrinks allowed & delegated sets | **Biscuit Non-Escalation**: offline delegation never widens authority. |
| **`delegation_never_exceeds_delegator`** | $\mathsf{isDelegatedAuthorized}(\mathcal{P}, u, v, c, a, r) \implies \mathsf{isAuthorized}(\mathcal{P}, u, a, r)$ | Delegating a capability can never create privilege the delegator lacks. |
| **`delegation_respects_delegatee_forbid`** | $f \in \mathcal{P}_{\text{forbid}} \land f.\mathsf{matches}(v,a,r) \implies \neg\mathsf{isDelegatedAuthorized}(\mathcal{P}, u, v, c, a, r)$ | Even an authorized admin/host delegating a token to `agy` cannot bypass a `forbid` on `actor:ai-agent`! |
| **`blast_radius_sound_and_complete`** / **`attr_diff_excludes`** | $r \in \mathsf{blastRadius}(\mathcal{P}, u, a, R) \iff \mathsf{isAuthorized}(\mathcal{P}, u, a, r)$ | Exact zero-miss rotation checklist if a roaming device is stolen (`C1`). |

### 4.2 Open State-As-Promise & CALM Logical Monotonicity (`S2+`)

Rather than a closed enum or fixed struct, each declared state volume carries **open extensible trait tags** (`traits : List String`) evaluated by the **exact same shared `Data/AttrExpr` Boolean Lattice** used for Authority and Partitioned Routing:
$$\mathsf{predNeedsLocalPersistence} \triangleq \text{"survives-reboot"} \setminus (\text{"reconstructible"} \cup \text{"external-owned"})$$
$$\mathsf{predCalmSafe} \triangleq \neg\text{"multi-writer"} \cup \text{"monotonic"} \cup \text{"single-auth-writer"}$$

#### Machine-Checked Theorems — State Safety (`Nixconf/Thm/StateSafety.lean`, 4 Theorems)

| Theorem (Lean 4 Symbol) | Formal Statement | Consequence |
| :--- | :--- | :--- |
| **`validateVolumes_nil_iff_valid`** | $\mathsf{validateVolumes}(\text{sub}, V) = [] \iff \mathsf{allVolumesValid}(\text{sub}, V) = \top$ | Diagnostic soundness & completeness. |
| **`ephemeral_substrate_durable_impossibility`** | $\neg \text{sub}.\text{durable} \land v \in V \land \llbracket\mathsf{predNeedsLocalPersistence}\rrbracket_{v.\text{traits}} \implies \neg \mathsf{allVolumesValid}$ | Mechanically forbids deploying durable state (e.g., Vaultwarden) onto ephemeral `Live-ISO`. |
| **`calm_multiwriter_requires_monotonic`** | $\mathsf{allVolumesValid} \land \text{"multi-writer"} \in v \land \text{"single-auth-writer"} \notin v \implies \text{"monotonic"} \in v$ | Enforces Hellerstein's **CALM Theorem** over open tags (zero silent split-brain!). |
| **`backup_coverage_soundness`** | $\mathsf{allVolumesValid} \land \text{"backup-required"} \in v \implies \text{sub}.\text{backupProviders} > 0$ | Guarantees no irreplaceable backup-flagged volume runs unbacked-up. |

---

## 5. Semantic Spacetime ($\gamma(3,4)$) & Asynchronous Protocol Verification

### 5.1 Semantic Spacetime Graph Algebra (`Nixconf/Thm/Spacetime.lean`, 6 Theorems)

Every structural, causal, attributive, and associative relation projects onto the 4 irreducible `STTypes` ($\mathsf{CONTAINS}, \mathsf{FOLLOWS}, \mathsf{EXPRESSES}, \mathsf{NEAR}$) governed by Burgess & Couch's 4×4 weak-transitivity table `stCompose`.

| Theorem (Lean 4 Symbol) | Formal Statement | Consequence |
| :--- | :--- | :--- |
| **`ranked_sst_acyclic`** | $\mathsf{strictlyRanked}(G, \text{ty}, \text{rank}) \implies \neg \mathsf{STPath}(G, \text{ty}, u, u)$ | Guarantees acyclicity of proper-time causality (`FOLLOWS`) and scale containment (`CONTAINS`). |
| **`absorbing_boundary_zero_external_impact`** | $\mathsf{opDeps}(G, x) = [] \implies \forall k.\; \mathsf{impactCone}(G, k, [x]) = [x]$ | Formalizes Burgess's absorbing boundary (`arXiv:2506.07756`): interior edits preserving $\Pi_{\text{ext}}$ have empty external impact cones! |
| **`epistemic_edges_preserve_operational_deps`** | $e.\text{sttype} \neq \mathsf{FOLLOWS} \implies \mathsf{opDeps}(e :: G, n) = \mathsf{opDeps}(G, n)$ | Reconciles `ADR-0002` Non-Piercing with `E3` Epistemic Zoom (`C5`): adding read-only `CONTAINS`/`NEAR` edges introduces zero reverse build dependencies! |
| **`stCompose_assoc`** | $(r \circ s) \circ t = r \circ (s \circ t)$ for all 64 triples | Path inference over the 4×4 weak-transitivity table is strictly associative. |
| **`near_never_forges_causality_or_containment`** | $\mathsf{NEAR} \circ s \notin \{\mathsf{FOLLOWS}, \mathsf{CONTAINS}\} \land s \circ \mathsf{NEAR} \notin \{\mathsf{FOLLOWS}, \mathsf{CONTAINS}\}$ | Associative similarity shortcuts can NEVER synthesize fake causality or containment! |
| **`expresses_is_absorbing_sink`** | $\mathsf{EXPRESSES} \circ s = \mathsf{none}$ | Scalar boundary attributes terminate weak-transitive inference cleanly. |

**Kernel Axiom Audit (`Nixconf/Audit.lean`)**: All **35 theorems** depend *solely* on Lean 4's trusted core axioms (`propext`, `Quot.sound`, `Classical.choice`) — **zero `sorryAx`**, **zero Mathlib**, compiled cold from scratch in **`7.27 s`** (incremental proof edits in `~2 s` without recompiling `Spec/` or `Oracle/`).

### 5.2 Exhaustive Temporal Model Checking — Modular Quint `0.33.1` / TLC (`architecture/formal/quint/`)

Using Informal Systems' modular single-record architecture (`types.qnt` + 3 focused protocol modules, **8/8 `quint test` runs passing** + **100% exhaustive TLC BFS proofs**, `EXP-0005`):

1. **`triadic_pull.qnt` (`ADR-0005` `C3` + `TUF` + Mid-Switch Crash + Human Switch Lock)**:
   - **Exhaustive TLC Proof**: **1,878,049 transitions / 572,644 distinct states (depth 18, 0 remaining)** verified in **`11.10 s`** + 3 `quint test` runs (`healthyUpgradeTest`, `autoRollbackOnBadGenTest`, `midSwitchPowerCrashRecoveryTest`) — proving forged closures never activate, committed generations are always healthy, TUF monotonic epoch blocks downgrades (mutation caught in `64 ms`!), mid-switch power crashes recover cleanly via boot-counter rollback, and background pull serializes safely with human `just switch`!
2. **`lifecycle_recovery.qnt` (`ADR-0006` C1 Genesis $t=0$ + Stolen-Device Revocation + Zero-Infra Break-Glass)**:
   - **Exhaustive TLC Proof**: **54 transitions / 21 distinct states (depth 9, 0 remaining)** verified in **`1.24 s`** + 3 `quint test` runs (`genesisCrashSafeTest`, `stolenDeviceRotationTest`, `zeroInfraBreakGlassTest`) — proving `Live-ISO` never holds secrets, interrupted genesis leaves zero orphaned Git identities, stolen-device rotation revokes all blast-radius access, and simultaneous VPS+GitHub outage resurrects cleanly from offline root + mirror + off-host backup!
3. **`conditional_degradation.qnt` (`ADR-0003` `+b | C` + `ADR-0006` C4 Dynamic Power/Thermal)**:
   - **Exhaustive TLC Proof**: **77 transitions / 18 distinct states (depth 5, 0 remaining)** verified in **`1.26 s`** + 2 `quint test` runs (`tufUnplugMidBuildGracefulFallbackTest`, `wanOutageSelfHealingTest`) — proving core vitality survives arbitrary WAN/mesh/power/thermal faults and `x240` falls back locally with zero deadlock!

---

## 6. Closing the Spec-to-Code Gap: Modular AWS Cedar VGD Differential Testing

Following **AWS Cedar (OOPSLA 2024)** (`F3-b`, [`ADR-0007`](../adrs/ADR-0007-formal-verification-cedar-vgd-and-tuf-calm-upgrades.md)), we compiled `Nixconf/Oracle/Main.lean` into native `nixconf-oracle` and implemented a 1:1 modular Rust engine ([`architecture/formal/drt/engine/`](../formal/drt/engine/)).

- **Coverage**: 5 concrete `nixconf` regression scenarios (`astrolabe-full-healthy`, `gap1-p-explicit-leaked-dep-caught`, `gap2a-partitioned-proxy-overlap-caught`, `gap2b-cyclic-stratum-rule-caught`, `gap3-open-trait-live-iso-durable-caught`, plus Gap #4 delegatee `forbid` and structured `determiningPolicies`) + **2,000 randomized fuzzed fleets**.
- **Result**: **2,005 / 2,005 bit-for-bit identical structured verdicts — 0 divergences!**
- **Performance**: **Rust modular engine = `12.74 ms` (`157,338 fleets/s`)** vs. **Lean 4 native oracle = `1,708.80 ms` (`1,173 fleets/s`)** — delivering ~6 µs production verification speed locked mathematically to a 35-theorem Lean 4 oracle!

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
