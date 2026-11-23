---
id: RES-0006
title: Deep Research Dossier — Mark Burgess's Promise Theory, Semantic Spacetime, Practical Implementations & Theoretical Limits
type: research
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [research, promise-theory, mark-burgess, jan-bergstra, semantic-spacetime, superagent, cfengine, opflex, kubernetes, mgmt, hard-enforcement, lampson]
assumptions: []
summary: Comprehensive mathematical and practical investigation of Promise Theory and Semantic Spacetime (formal calculus, superagents, trust/assessment, industrial deployments, and the three hard theoretical limits requiring hard closures and cryptographic enforcement).
---

<!-- abstract:start -->
## Executive Abstract

In-depth mathematical and engineering investigation of Mark Burgess & Jan Bergstra's **Promise Theory** and Burgess's derivative **Semantic Spacetime (SST)** framework to evaluate whether it can serve as the unifying theoretical backbone for `nixconf` v2. Covers: (1) **Formal Calculus** — autonomous agents, complementary give/use promises ($+b$/$-b$, isomorphic to `ADR-0001` Effects & Handlers), conditional promises ($C \Rightarrow A \xrightarrow{+b} Y$, formalizing graceful degradation), Dressed Superagents ($\langle \{A_i\}, \Pi_{\text{int}}, \Pi_{\text{ext}} \rangle$, formalizing hierarchical encapsulation and sub-component swapping), operational Trust ("policy for inattentiveness"), and $N=3$ triad calibration; (2) **Semantic Spacetime** — reducing system/knowledge graphs to 3 node kinds and 4 spacetime links (`CONTAINS`, `LEADS-TO`, `EXPRESSES`, `NEAR`) directly relevant to topology, telemetry, and AI reasoning; (3) **Real-World Implementations** — CFEngine 3, Cisco ACI/OpFlex, Kubernetes controllers, and `mgmt` (`mgmtconfig`); and (4) **Three Hard Theoretical Limits** where pure Promise Theory fails — *Soft vs. Hard Enforcement* (reconciliation lag vs Nix immutable closures), *Byzantine/Malicious Security* (requires Lampson ACLs/Capabilities + cryptography), and *Strong Distributed Consensus* (CAP/FLP). Concludes with a crisp synthesis pairing Promise Theory (outer multi-agent cooperation) with Hard Structural Closures & Cryptographic Enforcement (inner agent/security boundaries).
<!-- abstract:end -->

# RES-0006: Promise Theory, Semantic Spacetime & Practical Systems Synthesis

## 1. Formal Mathematical Foundations (Burgess & Bergstra)

### 1.1 Core Axiom of Autonomy
An autonomous agent $A_i$ can **only** make credible promises about its own behavior — never coerce or promise the internal state of another agent $A_j$ ($i \neq j$). Top-down commands / impositions ($A_1 \xrightarrow{!b} A_2$) are fundamentally unreliable in distributed systems because $A_2$ retains physical autonomy (it can be offline, out of resources, partitioned, or refuse).

### 1.2 The Complementary Promise Calculus ($+b$ and $-b$)
- **Give / Offer Promise ($+b$)**: $A_1 \xrightarrow{+b} A_2$ — $A_1$ voluntarily declares it will provide behavior/state/resource $b$ to scope/audience $A_2$.
- **Use / Acceptance Promise ($-b$)**: $A_2 \xrightarrow{-b} A_1$ — $A_2$ voluntarily declares it will accept/depend upon $b$ from $A_1$.
- **Cooperation Nexus (Effective Binding)**: Meaningful interaction occurs **if and only if** both complementary promises align:
  $$(A_1 \xrightarrow{+b} A_2) \;\land\; (A_2 \xrightarrow{-b} A_1)$$
- **Exact Structural Isomorphism with `ADR-0001` (Pillar 1)**:
  - An **Effect** declared by a component (*"I require secret $S$ / I expose endpoint $E$"*) is a use/offer promise (`-b`/`+b`).
  - A **Handler** (*"Caddy routes `public` endpoints"*, *"SOPS provides secrets"*) is the complementary promise closing the nexus.

### 1.3 Conditional Promises & Graceful Degradation
$$C \;\Rightarrow\; A \xrightarrow{+b} Y \qquad \text{(written } A \xrightarrow{+b \mid C} Y \text{)}$$
- **Conditional Promise Law**: A conditional promise alone is *incomplete* unless $A$ also explicitly accounts for acquiring/assessing condition $C$ ($A \xrightarrow{-C} Z$).
- **Architectural consequence**: Forces every cross-host or fragile dependency (e.g., remote Nix builder, mesh storage mount, upstream telemetry hub) to declare its condition $C$ and fallback behavior explicitly — formalizing **graceful degradation** mathematically!

### 1.4 Dressed Superagents (Hierarchical Scaling & Sub-Component Swapping)
$$A_{\text{super}} = \langle \{A_1, \dots, A_n\},\; \Pi_{\text{int}},\; \Pi_{\text{ext}} \rangle$$
- A set of internal autonomous agents $\{A_i\}$ wired by internal promises $\Pi_{\text{int}}$ presents a unified exterior promise boundary $\Pi_{\text{ext}}$ to external observers.
- **Architectural consequence**: Directly formalizes **encapsulation (Parnas)** and **sub-component swapping**:
  - A `Telemetry` stack is a Superagent whose internal agents are `{Collector, MetricsStore, LogStore, AlertRouter, Visualizer}`; swapping `Grafana → Perses` changes only one agent inside $\Pi_{\text{int}}$ while $\Pi_{\text{ext}}$ remains unchanged.
  - A `Host` is a Superagent of services/handlers; the `Fleet` is a Superagent of hosts.

### 1.5 Trust, Assessment, Monitoring & Calibration
- **Assessment** $\alpha_i(\pi) \in [0, 1]$: An agent's local empirical measurement of whether promise $\pi$ is actually being kept in reality.
- **Trust as an Economic Policy**: Formally defined by Burgess & Bergstra as *"a policy for inattentiveness"* — monitoring costs finite RAM/CPU/storage/attention. High historical integrity allows lower-frequency verification; broken assessments trigger heightened inspection, alerting, or self-healing.
- **Triadic Calibration ($N=3$)**: Independent autonomous agents (e.g., `Host` + `Human/AI Agent` + `Git Source of Truth / Binary Cache`) calibrate alignment against a shared third reference point rather than relying on fragile pairwise coercion.

---

## 2. Derivative Work: Semantic Spacetime (SST, 2015–2025)

Mark Burgess extended Promise Theory into a general discrete spacetime model for distributed systems, data analytics, and AI/LLM graph reasoning (including 2025 paper *"Agent Semantics, Semantic Spacetime, and Graphical Reasoning"*, `arXiv:2506.07756`).

### The $\gamma(3, 4)$ Graph Reduction
Instead of bloated ad-hoc ontologies (like v1's 5,327-LOC `meta/graph/` CPG), SST proves that causal and structural knowledge reduces to **3 node types** (*events/processes*, *things/snapshots*, *concepts/roles*) and **4 irreducible spacetime link types**:
1. **`CONTAINS`** *(Spatial aggregation / Superagent hierarchy)*: e.g., `Fleet → Host → Service → StateDir`.
2. **`LEADS-TO` (`FOLLOWS`)** *(Causal / Temporal process)*: e.g., `PR → CI Check → Attic Cache → Host Switch → Health Assessment`.
3. **`EXPRESSES`** *(Properties / Roles / Emitted Promises)*: e.g., `astrolabe EXPRESSES role:edge`, `vaultwarden EXPRESSES endpoint:public`.
4. **`NEAR`** *(Contextual similarity / semantic proximity)*: e.g., shared substrate traits, sibling hosts, related failure modes.

**Significance for `nixconf` v2**: Offers a mathematically minimal, universal graph model connecting **Fleet Topology**, **Dependency/Impact Slicing**, **Observability/Causal Tracing**, and **Human + LLM Knowledge/Memory**!

---

## 3. Practical Industrial Implementations

| System | Domain | How Promise Theory Operates in Practice | Key Lesson for `nixconf` |
| :--- | :--- | :--- | :--- |
| **CFEngine 3** | Host Config Mgmt | `cf-agent` evaluates local file/package/service promises idempotently on a continuous polling loop; scales to 10k+ nodes with tiny footprint. | Local autonomous convergence scales effortlessly — **but** imperative file-patching suffers drift & reconciliation lag compared to NixOS immutable closures. |
| **Cisco ACI & OpFlex** | Data-Center SDN | APIC publishes declarative policy promises; leaf switches locally accept/refuse based on capacity and asynchronously report telemetry/compliance. | Separating *published intent* from *local node realization & health reporting* prevents single-node failures from crashing the control plane. |
| **Kubernetes Controllers / Operators** | Container Orchestration | Desired-state API specs + autonomous reconciliation loops ($\text{Observe} \to \text{Analyze} \to \text{Converge}$). | Composable independent controllers per resource/effect cleanly mirror our P5 Handlers — while warning against over-centralizing everything in an always-on `etcd` cluster. |
| **`mgmt` (`mgmtconfig`)** | Event-Driven Config | Live promise graph reacting immediately to kernel events (`inotify`/netlink) + inter-node conditional promises via Raft. | Event-driven reactivity + explicit conditional cross-node promises are powerful, though embedding Raft introduces heavy quorum complexity unsuitable for intermittent laptops. |

---

## 4. Three Hard Theoretical Limits of Pure Promise Theory (Critical Reality Check!)

Before adopting Promise Theory as a universal foundation, we MUST recognize the **three exact boundaries where pure Promise Theory is insufficient**:

### Limit 1 — Soft Enforcement vs. Hard Structural Enforcement
- Promise Theory is inherently **soft enforcement**: an agent *promises* a state, detects drift after the fact via assessment, and converges back (leaving a **reconciliation lag window**).
- **NixOS immutable closures**, cryptographic store hashes, static type systems, and kernel sandboxes (`NoNewPrivileges`, `ProtectSystem=strict`) deliver **hard structural enforcement** — making illegal configurations or runtime library drift *physically unrepresentable* with zero runtime convergence cost.

### Limit 2 — Malicious / Byzantine Actors & Hard Security Boundaries
- Promise Theory models cooperative, imperfectly reliable agents (crashes, partitions, bugs) — **NOT** adversarial/Byzantine attackers (a stolen Chromebook or compromised public endpoint does not politely keep promises!).
- Operational trust ("inattentiveness") cannot replace **cryptographic identity**, **Lampson's Access Control Matrix (ACLs + Object Capabilities)**, and kernel/network isolation.

### Limit 3 — Strong Synchronous Distributed Consensus (CAP / FLP)
- Voluntary local promises naturally yield **eventual consistency and partition resilience**, NOT strict linearizability (Raft/Paxos) across partitions.
- For our asymmetric, mostly-intermittent fleet (VPS + home RPi + roaming laptops/tablets + WSL + Live USB), this is actually a **strength**: avoiding synchronous multi-node consensus for core host operation aligns directly with CAP/FLP, while explicitly designating single authoritative owners for stateful databases (e.g., Vaultwarden) or Git `main`.

---

## 5. The Resulting Architectural Synthesis: Two-Tier Theoretical Core

Combining Promise Theory + Semantic Spacetime with the exact mechanisms that close its three limits yields a strikingly complete, unified mathematical framework:

1. **Across Autonomous Boundaries *(Multi-Agent Cooperation & Spacetime)*** → **Promise Theory + Semantic Spacetime**
   - Autonomous Agents (Hosts, Workloads, Standalone Runs, Humans, AI Agents, External APIs)
   - Complementary Promises (`+b` Handlers $\leftrightarrow$ `-b` Effects — unifying `ADR-0001`)
   - Conditional Promises ($C \Rightarrow +b$ — formalizing graceful degradation under partitions)
   - Dressed Superagents ($\langle \{A_i\}, \Pi_{\text{int}}, \Pi_{\text{ext}} \rangle$ — formalizing sub-component swapping & hierarchical composition)
   - Local Pull Convergence + Continuous Assessment + Triadic Calibration (GitOps, rollback, observability, autonomous AI analysis)
   - Semantic Spacetime 4-link graph (`CONTAINS`, `LEADS-TO`, `EXPRESSES`, `NEAR` — unifying topology, impact analysis, causality, and LLM/human knowledge)
2. **Inside Agent & Security Boundaries *(Where Soft Promises Stop)*** → **Hard Structural Enforcement**
   - **Immutable Cryptographic Closures & Static Typing** (Dolstra / Nix / Rust — zero internal drift, atomic generation swaps)
   - **Cryptographic Identity & Lampson Access Matrix** (ACLs + Object Capabilities + Kernel Isolation — defense against malicious/Byzantine failures and stolen devices)

---

## 6. Sources Consulted (2026-11-23)
- Burgess, M. & Bergstra, J. A. *Promise Theory: Principles and Applications* / *A Treatise on Systems* (`markburgess.org`, arXiv).
- Burgess, M. *Thinking in Promises* (O'Reilly, 2015); *In Search of Certainty* (2013); *Semantic Spacetime* & *"Agent Semantics, Semantic Spacetime, and Graphical Reasoning"* (`arXiv:2506.07756`, 2025).
- CFEngine 3 Architecture (`cfengine.com`); Cisco ACI / OpFlex IETF draft & policy model; Kubernetes Controller pattern; James Shubin's `mgmt` (`mgmtconfig`).
- Distributed systems limits: Fischer-Lynch-Paterson (FLP, 1985), Gilbert & Lynch (CAP, 2002), Dolstra (2006) immutable closures, Lampson (1971) Access Matrix.
