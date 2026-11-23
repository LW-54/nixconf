---
id: RES-0008
title: Decision 2 Analysis — Promise Algebra, Scoped Binding, Boundary Projection & Hard/Soft Semantics
type: research
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [research, decision-2, promise-algebra, binding, cardinality, boundary-projection, hard-promises, soft-promises, conditional-promises, stratification, commutativity]
assumptions: [A-002]
summary: Derives the formal mechanics of Decision 2 on top of ADR-0002 (Fractal Uniform Agency): (2a) Interior Binding Topology (B1 vs B2 vs B3), (2b) Superagent Boundary Projection (P-Explicit vs P-Bubble vs P-Dual), Hard vs Soft/Conditional Promise Law, and static compilation soundness laws superseding ADR-0001.
---

<!-- abstract:start -->
## Executive Abstract

Builds directly on **Decision 1 ([`ADR-0002`](../adrs/ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md): Fractal Uniform Agency & Non-Piercing Boundaries)** to derive **Decision 2 — Promise Algebra, Binding & Boundary Projection**. Formally analyzes the exact mechanics governing a Dressed Superagent $S = \langle \{A_i\}, \Pi_{\text{int}}, \Pi_{\text{ext}} \rangle$: (1) **Promise Anatomy** integrating **Hard Structural** vs. **Soft Conditional ($+b \mid C$)** enforcement directly on promises (so one uniform agent can emit both immutable closure invariants and gracefully degrading runtime promises); (2) **Fork 2a — Interior Binding Topology** comparing Explicit Point-to-Point Wiring (**B1**), Pure Implicit Scoped Broadcast (**B2**), and Peer-Blind Scoped Binding with Typed Cardinality & Superagent Disambiguation (**B3**); (3) **Fork 2b — Superagent Boundary Projection ($\Pi_{\text{int}} \to \Pi_{\text{ext}}$)** comparing Strict Explicit Projection (**P-Explicit**), Implicit Requirement Bubbling (**P-Bubble**), and Dual Opaque Superagents vs. Transparent Agent Profiles (**P-Dual**); and (4) **Static Compilation Soundness Laws** (Strict Stratification & Commutative Keyed Aggregation from `EXP-0002`/`EXP-0003`) that formally subsume and generalize `ADR-0001`.
<!-- abstract:end -->

# RES-0008: Promise Algebra, Scoped Binding & Boundary Projection (Decision 2)

---

## 1. Why This Is the Exact Next Logical Step

`ADR-0002` established the universal node & container ontology:
$$A = \langle \Sigma_A,\; \Pi_{\text{ext}}(A),\; \text{Interior}(A) \rangle \qquad\text{and}\qquad S = \langle \{A_1, \dots, A_n\},\; \Pi_{\text{int}}(S),\; \Pi_{\text{ext}}(S) \rangle$$

Because `ADR-0002` intentionally avoided bifurcating Agents into separate "static" vs. "runtime" entity kinds, the **Promise Algebra** itself must carry the exact mathematical precision required for reliability (`B`), capability richness (`E`), and zero-ceremony elegance (`A`). Specifically, Decision 2 must define:
1. **What a Promise carries** (including Hard vs. Soft/Conditional semantics),
2. **Fork 2a**: How sibling promises bind inside $\Pi_{\text{int}}(S)$,
3. **Fork 2b**: How promises cross a nested Superagent boundary $\Sigma_S$ ($\Pi_{\text{int}} \to \Pi_{\text{ext}}$), and
4. **What soundness invariants** guarantee deterministic compilation into immutable closures.

---

## 2. Formal Promise Anatomy (Hard & Soft Unified Under Model A)

Every promise emitted on an agent's boundary $\Sigma_A$ has the formal shape:
$$\pi \;=\; \bigl(A \xrightarrow{\;\pm b : \tau \;\mid\; C\;} \sigma,\;\; \text{strength} \in \{\text{Hard}, \text{Soft}\}\bigr)$$

- **Polarity**: $+b$ (offer / capability / assertion) vs. $-b$ (use / requirement / acceptance).
- **Typed Body ($b : \tau$)**: Structured, schema-validated payload whose type $\tau$ defines its **binding cardinality** (`1:1`, `1:N`, `N:1`) and **commutative merge key** (preventing order-dependent list bugs, `EXP-0002`–`EXP-0003`).
- **Scope ($\sigma$)**: The enclosing Superagent boundary within which $\pi$ is visible and bindable.
- **Strength & Conditional Law** *(resolving Constraint `T1` without splitting Agent kinds)*:
  - **`Hard` Promise**: Structurally or cryptographically guaranteed at build/check/activation time (e.g., Nix store closure hash, typed option contract, systemd sandbox invariant, port uniqueness). **Rule**: An unfulfilled mandatory `Hard` `-b` promise inside a closed root Superagent is a **build-time failure** (binary calibration: intact or rejected).
  - **`Soft` (Conditional) Promise ($+b \mid C$)**: Runtime/probabilistic guarantee whose precondition $C$ can fluctuate over proper time (network partition, sleeping laptop, remote cache/storage unreachable, OOM, upstream API failure). **Conditional Promise Law**: Every `Soft` promise MUST explicitly declare:
    1. Its **condition dependency** (`-C`: how $A$ observes/acquires $C$),
    2. Its **degraded invariant** (exact bounded behavior when $C$ is false — e.g., *fail closed*, *serve stale cache*, *pause sync without blocking boot*, *fallback locally*), and
    3. Its **assessment hook** ($\alpha$: how runtime observers measure whether $\pi$ is currently kept or degraded).

> **Why this is deeper than Model C**: A single situated Agent like `astrolabe` simultaneously emits `Hard` promises (*"my `/nix/store` closure hash is H"*, *"systemd isolates `agy` with `NoNewPrivileges`"*) AND `Soft` promises (*"Vaultwarden responds HTTP 200 within 500ms"*, *"remote Restic repo synced within 24h | wan-up"*). And a standalone Agent like `foot` simply emits only `Hard` promises whose `-b` set closes inside the minimal `Standalone` Superagent scope!

---

## 3. Fork 2a — Interior Binding Topology (How Siblings Wire Inside $\Pi_{\text{int}}(S)$)

Suppose Superagent $S$ contains sub-agents $\{A_1, \dots, A_n\}$ — for example, `astrolabe` containing `vaultwarden`, `copyparty`, `caddy-public`, `caddy-mesh`, `sops-host`, `alloy`, and `restic`. How do complementary promises $(+b, -b)$ bind?

### Option B1 — Explicit Point-to-Point Wiring (Named Peers)
- **Mechanics**: Every binding is explicitly wired by name ($A.\text{use} \leftrightarrow B.\text{offer}$), either inside $A$ or in a manual wiring table in $S$ (analogous to ML Functors / explicit dependency injection).
- **Pros**: 100% explicit; zero hidden matching rules; trivial to disambiguate multiple providers (`caddy-public` vs. `caddy-mesh`).
- **Cons**: **$O(N \times M)$ wiring explosion**. With 20 services × 7 cross-cutting concerns (ingress, auth, secrets, backup, telemetry, persistence, cgroups), every host Superagent turns into a ~140-wire manual switchboard. Adding one new cross-cutting agent (e.g., a new audit collector or backup target) requires editing every service's wiring!

### Option B2 — Pure Implicit Scoped Broadcast (Open Discovery)
- **Mechanics**: Agents are completely peer-blind and emit typed promises into scope $\sigma$. Any matching $+b$ and $-b$ of type $\tau$ inside $S$ automatically bind.
- **Pros**: True **$O(N + M)$** scaling; adding/removing/swapping any agent touches zero siblings.
- **Cons**: **Silent Ambiguity & Precedence Hazards (`B` Reliability Risk)**.
  - What happens when *two* secret providers (`sops` + `bitwarden`) both emit `+b: secret` inside `astrolabe`? Silent last-write-wins causes catastrophic non-determinism!
  - What happens when `vaultwarden` emits `+b: metrics-endpoint` and *zero* monitoring agents are enabled (e.g., in a minimal test)? Is an unbound `+b` an error or harmless?
  - What happens when two ingress proxies (`caddy-public` + `caddy-mesh`) both accept `-b: http-endpoint`?

### Option B3 — Peer-Blind Scoped Binding with Typed Cardinality & Superagent Disambiguation *(Recommended)*
- **Mechanics**: Preserves B2's pure $O(N + M)$ peer-blindness inside atomic agents (`vaultwarden` NEVER mentions `caddy`, `sops`, or `alloy`), while closing every ambiguity mechanically at the **Promise Type** and **Superagent** level:
  1. **Formal Cardinality per Promise Type ($\tau$)**:
     - **`Exclusive` (`1:1` / unique owner)** — e.g., `secret(id)`, `mount(path)`, `tcp-port(port)`:
       - 0 matching `+b` for a mandatory `-b` → **hard error** (missing provider).
       - $>1$ matching `+b` without disambiguation → **hard conflict error** (never silent override!).
     - **`Broadcast` (`1:N` / multi-observer)** — e.g., `metrics-endpoint`, `log-stream`, `backup-source`:
       - $0, 1,$ or $N$ consumers may observe the same `+b` offer concurrently and **commutatively** (0 observers is valid — e.g., running `vaultwarden` in a minimal VM without Prometheus!).
     - **`Partitioned Fan-In` (`N:1` or `N:K` via typed attributes)** — e.g., `http-endpoint(visibility = "public" | "mesh")`:
       - Multiple services offer `+b: http-endpoint`; multiple routers accept disjoint attribute predicates (`visibility == "public"` vs. `visibility == "mesh"`). Overlapping predicates on the same route key trigger a **hard conflict error**!
  2. **Superagent-Level Disambiguation**: When $S$ intentionally hosts multiple providers of an `Exclusive` type (e.g., two secret backends `sops` and `vault`), $S$ disambiguates explicitly via **attribute selectors** (e.g., `provider-class` / scope partition) or **sub-superagent scoping** — never by fragile hidden priority numbers!
  3. **Implied Static Soundness Laws (from `EXP-0002` & `EXP-0003`)**:
     - **Strict Stratification**: Hard interior promise binding flows strictly forward across an acyclic DAG (*Static Facts → Emitted Promises → Cardinality-Checked Binding → Realized Closure*), forbidding infinite fixed-point cycles.
     - **Commutative Keyed Aggregation**: All `N:1` and `1:N` promise collections aggregate by explicit unique keys (maps/sets), NEVER order-dependent flat lists — guaranteeing import-order invariance!

---

## 4. Fork 2b — Nested Superagent Boundary Projection ($\Pi_{\text{int}} \to \Pi_{\text{ext}}$)

Suppose we group multiple sub-agents — for example:
- Case 1: **`Observability`** = `{alloy, victoriametrics, victorialogs, alertmanager, grafana}` (an encapsulated subsystem whose interior we want to swap freely: `grafana → perses`).
- Case 2: **`CoreCliTools`** = `{git, micro, fd, rg, jq}` or **`WaylandDesktop`** = `{labwc, foot, noctalia, fonts}` (a convenient reusable bundle of sibling tools/apps we want on `x240`, `zenbook`, and `live-iso`).

What should happen when an interior agent $A_k$ inside $S$ emits a promise (`+b` or `-b`)?

### Option P-Explicit — Strict Non-Piercing on Both `+b` and `-b` Everywhere
- **Mechanics**: EVERY nested grouping is an opaque boundary $\Sigma_S$. Interior `+b` offers are private unless explicitly re-promised in $\Pi_{\text{ext}}(S)$, AND interior `-b` requirements must either be satisfied inside $S$ or explicitly declared in $\Pi_{\text{ext}}(S)$ (no silent upward leaking!).
- **Pros**: 100% strict Parnas & Promise Theory Coarse-Graining everywhere; reading $\Sigma_S$ alone always tells humans and LLMs *everything* $S$ requires and provides; interior edits can never secretly introduce a new host dependency.
- **Cons**: Heavy ceremony for simple convenience groupings! Wrapping 10 desktop tools in a `WaylandDesktop` Superagent would force manually re-declaring every forwarded `-b` (audio, fonts, wayland session, user home, dbus) on the wrapper boundary.

### Option P-Bubble — Private `+b` Offers, Implicitly Bubbling `-b` Requirements
- **Mechanics**: Interior `+b` offers stay private unless explicitly exported in $\Pi_{\text{ext}}(S)$, *but* any unsatisfied interior `-b` requirement automatically bubbles upward to the enclosing Superagent until satisfied (or failing at the closed root).
- **Pros**: Very low boilerplate for bundles and subsystems; still completely safe at closed roots (`astrolabe`, `wsl`, `standalone`).
- **Cons**: Weakens strict Non-Piercing on *dependencies* (`-b`) for encapsulated subsystems — swapping `grafana → perses` inside `Observability` could silently inject a brand-new host requirement (`-b: postgresql`) into `astrolabe` without touching `Observability`'s boundary signature!

### Option P-Dual — Opaque Superagents (`P-Explicit`) + Transparent Agent Sets/Profiles *(Recommended)*
- **Mechanics**: Draws a crystal-clear formal distinction between **encapsulation** and **convenience grouping** (no new agent kind — just distinguishing a *Boundary $\Sigma$* from a *Set of Agents*!):
  1. **Dressed Superagent (`Boundary Σ`)** — e.g., `Observability`, `AuthStack`, `Host`, `Fleet`: **100% strict `P-Explicit`**! Neither `+b` nor `-b` can silently pierce $\Sigma_S$. Swapping `grafana → perses` inside `Observability` is mechanically verified against $\Sigma_{\text{Observability}}$!
  2. **Transparent Profile / Agent Set (`{A_1, ..., A_k}`)** — e.g., `CoreCliTools`, `WaylandDesktop`: **NOT a boundary $\Sigma$** — mathematically just a named finite set of Agents flattened directly into the enclosing Superagent's $\{A_i\}$! Zero forwarding boilerplate, because it makes *no* claim of encapsulation!
- **Pros**: Gives **100% strict Non-Piercing discipline** everywhere encapsulation matters (`Observability`, `AuthStack`, `Host`, `Standalone`, `Fleet`) with **zero boilerplate** for convenience tool/desktop collections (`CoreCliTools`, `WaylandDesktop`)!

---

## 5. Relationship to `ADR-0001`

If Decision 2 ratifies **B3** + **P-Dual** + **Hard/Soft Conditional Promise Semantics** + **Stratification & Commutativity**, then `ADR-0001` (*Effect–Handler Composability*) is **formally subsumed and generalized**:
- Every theorem of `ADR-0001` (open multi-instance handlers, $O(N+M)$ mediation, strict stratification, commutative merge, implementation openness) is **strictly preserved** as the `Hard` interior binding case of Promise Theory;
- AND four crucial missing mechanisms are gained in the exact same algebra: **Scoped Non-Piercing Boundaries ($\Sigma$)**, **Formal Cardinality (`Exclusive`/`Broadcast`/`Fan-In`)**, **Conditional Soft Promises ($+b \mid C$ + degradation + $\alpha$)**, and **Explicit Boundary Projection (`P-Dual`)**.
- Upon user ratification of Decision 2, we will record `ADR-0003` and mark `ADR-0001` as `superseded_by: ADR-0003` (append-only lineage preserved intact).
