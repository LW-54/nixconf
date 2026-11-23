---
id: RES-0010
title: Decision 4 Analysis — Spacetime Dynamics: Triadic Calibration, Pull Convergence & the Semantic Spacetime (γ(3,4)) Epistemic Spine
type: research
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [research, decision-4, semantic-spacetime, proper-time, calibration, convergence, gitops, rollback, assessment, trust, observability, llm-context]
assumptions: [A-006, A-008, A-011]
summary: Derives Decision 4 (final foundational decision) on top of ADR-0002..0004: Fork 4a Proper-Time Convergence & Calibration (C1 Push Imposition vs C2 Blind Local Pull vs C3 Triadic Calibrated Autonomous Pull with Self-Assessing Atomic Transitions) and Fork 4b Epistemic Architecture (E1 Siloed Tools vs E2 Monolithic Live SST DB vs E3 Unified SST γ(3,4) Semantic Spine over Specialized Storage & Trust-Budgeted Assessment).
---

<!-- abstract:start -->
## Executive Abstract

Derives **Decision 4** — the final foundational step completing the `nixconf` v2 theoretical architecture on top of [`ADR-0002`](../adrs/ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md) (Fractal Agency), [`ADR-0003`](../adrs/ADR-0003-promise-algebra-scoped-binding-and-boundary-projection.md) (Promise Algebra), and [`ADR-0004`](../adrs/ADR-0004-hard-boundaries-boolean-authority-and-state-as-promise.md) (Hard Boundaries). Applies **Semantic Spacetime's proper-time `FOLLOWS` causality**, **Burgess's $N=3$ Triadic Calibration**, **$\gamma(3,4)$ graph algebra (`CONTAINS`, `FOLLOWS`, `EXPRESSES`, `NEAR`)**, and **Operational Trust (*"policy for inattentiveness"*)** to resolve two final foundational forks:
1. **Fork 4a — Proper-Time Convergence & Calibration**: Imperative Push Imposition (**C1**) vs. Uncoordinated Blind Local Pull (**C2**) vs. **Triadic Calibrated Autonomous Pull with Self-Assessing Atomic Transitions & Rollback (C3)**.
2. **Fork 4b — Epistemic Substrate (Observability, Provenance, Topology & Human/AI Knowledge)**: Siloed Standard Tools (**E1**) vs. Monolithic Live SST Graph DB (**E2**) vs. **Unified Semantic Spacetime ($\gamma(3,4)$) Spine over Specialized Storage & Trust-Budgeted Assessment (E3)**.
<!-- abstract:end -->

# RES-0010: Spacetime Dynamics — Calibration, Convergence & the SST Epistemic Spine (Decision 4)

---

## 1. Completing the Theoretical Foundation

Decisions 1–3 established the structural, compositional, and protective laws of `nixconf` v2:
- **`ADR-0002` (Space & Scale)**: Fractal Uniform Agency ($A = \langle \Sigma, \Pi_{\text{ext}}, \text{Interior} \rangle$) + recursive Dressed Superagents + Non-Piercing Boundaries $\Sigma$.
- **`ADR-0003` (Intent & Composition)**: Unified `Hard` vs. `Soft` Conditional Promise algebra ($+b \mid C$), `B3` Cardinality-Checked Scoped Binding, `P-Dual` Boundary Projection, Stratification & Commutativity.
- **`ADR-0004` (Protection & Durable State)**: `L3+` Offline Root Identity + Attenuated Capabilities + Boolean Set-Algebra Authorization ($\cup, \cap, \in, \setminus$), and `S2+` Mandatory Agent-Declared State-As-Promise with open composable state traits.

What remains to complete the baseline foundation is **Dynamics Across Proper Time & Epistemic Truth**:
1. How autonomous Agents safely **evolve across proper time (`FOLLOWS`)** (GitOps, security updates like Vaultwarden, multi-arch builds, atomic switches, automatic rollback) without centralized coercion or root push keys (**Fork 4a**).
2. How the entire system **knows, verifies, observes, and explains itself** to both Humans and AI Agents within tight VPS RAM/disk limits without v1's fragmented silos (**Fork 4b**).

---

## 2. Fork 4a — Proper-Time Convergence & Calibration Model

In Semantic Spacetime, there is **no global continuum clock** synchronizing a VPS (`astrolabe`), roaming laptops (`x240`, ZenBook, Chromebook), a NAT'd `aarch64` Raspberry Pi, a sleeping `NixOS-WSL` instance, and an ephemeral `Live-ISO`. Each situated Agent advances along its own **local proper-time lineage (`FOLLOWS`)** of immutable hard-promise generations:
$$g_0 \xrightarrow{\text{FOLLOWS}} g_1 \xrightarrow{\text{FOLLOWS}} g_2 \xrightarrow{\text{FOLLOWS}} \dots$$

### Option C1 — Central Push / Imperative Orchestrator *(Imposition-Driven)*
- **Mechanics**: A central controller (CI runner or deployment tool) SSHes into hosts and pushes switches ($Orchestrator \xrightarrow{!switch} Host$).
- **Pros**: Immediate synchronous feedback for always-on reachable servers.
- **Cons**: **Fails across heterogeneous intermittent fleets (`T3`, `T4`, `QA-06`, `QA-07`) and violates `ADR-0004` (`L3+`)!** Roaming laptops, NAT'd RPi, and sleeping WSL are unreachable during CI; requires granting CI/orchestrators ambient inbound root-push capability to every host (massive blast radius!); if a bad network/mesh change drops connectivity mid-switch, the central orchestrator is permanently locked out.

### Option C2 — Uncoordinated Blind Local Pull *(Naive Cron / Blind `autoUpgrade`)*
- **Mechanics**: Every host blindly runs a periodic timer pulling `main`, evaluating/building locally, and switching.
- **Pros**: 100% pull-based, works behind NAT and offline, zero inbound root push capability.
- **Cons**: **Violates `B` (Reliability) & `X7` (Resource Constraints)!** Low-RAM/ARM nodes (`rpi`, Chromebook, 11 GiB VPS) get OOM-crushed compiling heavy updates locally; unverified commits or broken builds trigger blind switches without pre-switch verification or post-switch health-gated rollback.

### Option C3 — Triadic Calibrated Autonomous Pull with Self-Assessing Atomic Transitions *(Recommended)*
- **Mechanics**: Direct application of **Burgess's $N=3$ Triadic Calibration** + **Imposition-Free Pull** + **Hard Closure Atomicity**:
  1. **Calibrated Signed References (Zero Inbound Push Root)**: Changes from Humans, AI Agents, and Automated Security Update Bots enter as **PR impositions** gated by verification Agents (static boundary/policy checks, VM tests, multi-arch builds) and land into **calibrated reference artifacts**:
     - **Source Reference**: Git `main` commit (+ async self-hosted mirror per `ADR-0004` `S2+`, eliminating GitHub SPOF), and
     - **Signed Binary Closure Reference**: Prebuilt, cryptographically signed closures in binary cache(s).
  2. **Voluntary Host-Side Pull on Local Proper Time**: Each host pulls strictly on its own policy/schedule (`astrolabe` on timely security cadence; `x240` on AC/Wi-Fi or manual trigger; `rpi` waiting until a signed `aarch64` closure exists in cache — never burning SD/RAM compiling locally unless explicitly opted in). A host refuses any target commit failing cryptographic/calibration verification.
  3. **Atomic Self-Assessing Transition ($\text{Switch} \to \text{Assess }\alpha \to \text{Commit or Auto-Rollback}$)**:
     - Transitioning $g_n \xrightarrow{\text{FOLLOWS}} g_{n+1}$ runs a bounded **local self-assessment gate** verifying critical `Hard` and core `Soft` promises (critical systemd units, local auth/ingress, mesh reachability within grace window).
     - If assessment $\alpha$ fails the host's survival invariant → **autonomous automatic rollback to $g_n$**, recording the failed transition event in `FOLLOWS` lineage for alerting & AI root-cause analysis (zero SSH lockout!).
  4. **Explicit Interactive Override**: Hosts may hold an explicit `L3+` human-authorized acceptance promise for direct manual switches (`just switch`) during interactive work/rescue — never extending inbound push-root to CI or autonomous bots.

---

## 3. Fork 4b — The Unified Epistemic Substrate (Observability, Provenance, Topology & Human/AI Knowledge)

`AUD-0001`–`AUD-0003` showed that `nixconf` v1 split knowledge into **four disconnected silos**: 5,327 LOC of pure-Nix `meta/graph/`, partial generated `docs/` blind to 15k LOC of `meta/` & Rust, **1.59 GiB RAM** of heavy observability (`grafana`+`alloy`+`victoriametrics`+`victorialogs`+`alertmanager` — 5.5× all core services!), and ad-hoc LLM context.

### Option E1 — Siloed Standard Tools *(Conventional DevOps)*
- **Mechanics**: Separate static docs, separate monitoring/logging stack, separate Git/CI logs, separate LLM prompt files.
- **Pros**: Independent off-the-shelf tool adoption; zero shared graph contract.
- **Cons**: **Reproduces v1's fragmentation and AI blindness!** When a runtime alert fires or an autonomous analysis agent investigates an anomaly, there is no formal causal path linking *broken runtime promise $\alpha$* $\leftarrow$ *generation switch (`FOLLOWS`)* $\leftarrow$ *PR/commit* $\leftarrow$ *owning Agent boundary (`CONTAINS`)* $\leftarrow$ *architectural intent/degraded invariant (`EXPRESSES`)*.

### Option E2 — Monolithic Live SST Graph Database *(Everything Inside One Runtime Graph DB, e.g., `SSTorytime`/Postgres)*
- **Mechanics**: Store all static declarations, every metric sample, every log line, every deployment event, and every doc directly inside one centralized live graph database.
- **Pros**: Purest literal single-database implementation of `SSTorytime`.
- **Cons**: **Violates `B` (Reliability), `X7` (RAM/disk bounds on 11 GiB VPS), and `T3`/`T4` (Offline/Pure Evaluation)!** Storing high-volume raw time-series/logs in a graph/relational DB destroys compression and explodes RAM/disk; coupling static build/repo introspection to a live centralized DB breaks offline evaluation and standalone tools.

### Option E3 — Semantic Spacetime ($\gamma(3,4)$) as the Universal *Semantic Spine* Over Specialized Storage & Trust-Budgeted Assessment *(Recommended)*
- **Mechanics**: Uses **Semantic Spacetime's $\gamma(3,4)$ graph** as a **lightweight, universal structural & causal spine** unifying *all* epistemic layers without misusing a graph DB as a raw telemetry dump:
  1. **One Minimal 4-Link Graph Algebra (Replaces Ad-Hoc Ontologies)**:
     - **`CONTAINS`**: Fractal Agent / Superagent hierarchy (`Fleet → Host → Superagent → Sub-Agent → State Volume`).
     - **`FOLLOWS`**: Proper-time causal lineages (`PR → Verification → Signed Closure → Generation g_n → g_{n+1} → Assessment α / Rollback / Incident`).
     - **`EXPRESSES`**: Boundary surfaces $\Pi_{\text{ext}}$ (Hard & Soft promises, `L3+` attributes/groups, `S2+` state traits, human/LLM summaries, live assessment state $\alpha \in \{\text{kept}, \text{degraded}, \text{broken}\}$).
     - **`NEAR`**: Non-causal contextual proximity (shared substrates, sibling services, related ADRs/runbooks, recurring failure patterns).
     - Weak-transitivity rules (`RES-0007`) allow predictable multi-scale impact analysis (*"if I edit Agent X, what minimal set of closures/hosts/tests are affected?"*) while respecting **Non-Piercing Absorbing Boundaries ($\Sigma$)**!
  2. **Strict Separation of *Semantic Spine* vs. *Bulk Telemetry Storage***:
     - High-volume raw metrics/logs/traces stay in compact, purpose-built, storage-bounded engines (benchmarked empirically in Phase 3!).
     - Only **structural boundaries, causal transitions (`FOLLOWS`), promise assessments ($\alpha$), anomalies, and pointers into bulk telemetry** populate the SST spine — keeping it tiny, offline-inspectable at static time, and ultra-token-efficient for Humans and AI Agents!
  3. **Operational Trust as Assessment Budgeting (Burgess's *"Policy for Inattentiveness"*)**:
     - **`Hard` Promises** cost **zero continuous runtime RAM** (verified once by types/hashes/sandboxes → binary calibration!).
     - **`Soft` Promises** spend finite runtime monitoring RAM/disk strictly proportional to **criticality × uncertainty**: core vitality and irreplaceable backups receive tight assessment $\alpha$; stable low-risk agents receive lightweight/event-driven probes; **degraded/broken assessments dynamically escalate inspection** (including periodic or anomaly-triggered autonomous AI analysis navigating the exact bounded SST causal cone instead of scanning 50k LOC or millions of raw log lines!).
  4. **Uniform Structural Coverage Across All Layers (`QA-04`, `QA-10`)**: Because every entity — including auxiliary Rust tools, CI pipelines, substrates, and docs — is an **Agent** (`ADR-0002`) expressing its boundary $\Pi_{\text{ext}}$ into the same SST spine, undocumented or unverified layers cannot silently hide outside the check boundary!

---

## 4. What Ratifying Decision 4 Achieves

With Decisions 1–4 complete (`ADR-0002`, `ADR-0003`, `ADR-0004`, and `ADR-0005`), **Phase 2 (Theoretical Foundation Architecture) is 100% complete** — yielding one unified, mathematically airtight, implementation-agnostic foundation derived rigorously from Promise Theory + Semantic Spacetime + Physical Constraints (`T1`–`T5`).

Only **after** Decision 4 is ratified do we cross cleanly into **Phase 3 — Realization & Concrete Engineering RFDs** (Authoring Medium & Nix↔Rust Seam, Pure Rust Build Strategy, Pinning & Standalone Entrypoints, Mesh Fabric, GitOps & Mirroring, Distributed Storage/Compute, Bounded-RAM Observability Benchmarks, and Human+LLM Knowledge Tooling) — where every concrete tool choice is scored mechanically against `ADR-0002`..`ADR-0005` and real benchmarks!
