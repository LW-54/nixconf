---
id: ADR-0005
title: Adopt Triadic Calibrated Autonomous Pull (C3) & Unified Semantic Spacetime Epistemic Spine (E3)
type: adr
status: accepted
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [adr, decision-4, calibration, pull-convergence, gitops, rollback, semantic-spacetime, gamma-3-4, observability, trust-budget, llm-context]
rfd: null
assumptions: [A-006, A-008, A-011]
supersedes: null
superseded_by: null
summary: Ratifies Decision 4 on top of ADR-0002..0004: (1) C3 Triadic Calibrated Autonomous Pull with signed source+binary references, local proper-time pull, and self-assessing atomic generation switches with auto-rollback; and (2) E3 Semantic Spacetime γ(3,4) as the universal lightweight semantic/causal spine over specialized bulk telemetry storage and trust-budgeted assessment.
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Decision 4** of the `nixconf` v2 theoretical foundation on top of [`ADR-0002`](ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md), [`ADR-0003`](ADR-0003-promise-algebra-scoped-binding-and-boundary-projection.md), and [`ADR-0004`](ADR-0004-hard-boundaries-boolean-authority-and-state-as-promise.md), establishing the dynamic convergence and epistemic laws of the architecture:
1. **Proper-Time Convergence & Calibration (`C3`)**: Changes from humans, AI agents, and automated security-update bots enter via PR impositions gated by verification Agents into **calibrated signed references** (Git `main` + async self-hosted mirror, plus signed prebuilt binary cache closures). Each situated host autonomously pulls on its own proper-time schedule/conditions (zero inbound CI push-root; zero forced local compilation on low-RAM/ARM targets), executing atomic $g_n \xrightarrow{\text{FOLLOWS}} g_{n+1}$ switches guarded by local self-assessment ($\alpha$) with automatic rollback on survival failure (while retaining explicit `L3+` human-authorized interactive switch overrides).
2. **Unified Epistemic Substrate (`E3`)**: **Semantic Spacetime's $\gamma(3,4)$ graph (`CONTAINS`, `FOLLOWS`, `EXPRESSES`, `NEAR`)** serves as the lightweight, universal structural and causal spine across *all* layers (including Rust tooling, CI, docs, and runtime assessments), strictly separated from specialized compact bulk telemetry storage, with **Operational Trust (*"policy for inattentiveness"*)** budgeting runtime assessment overhead proportional to criticality × uncertainty (`Hard` promises cost zero continuous runtime RAM).
<!-- abstract:end -->

# ADR-0005: Triadic Calibrated Pull Convergence (`C3`) & Semantic Spacetime Epistemic Spine (`E3`)

## 1. Context & Problem Statement
Decisions 1–3 (`ADR-0002`..`ADR-0004`) defined fractal Agency, Promise Algebra, and Hard Boundaries. Decision 4 (`RES-0010`) resolved how autonomous heterogeneous Agents (24/7 VPS, roaming laptops, NAT'd `aarch64` RPi, WSL, Live ISO) safely converge over proper time without centralized coercion or root push keys, and how the entire repository and live fleet remain observable, verifiable, and intelligible to both Humans and AI Agents within tight VPS RAM/disk bounds.

## 2. Considered Options (`RES-0010`)
- **Fork 4a (Convergence & Calibration)**:
  - *C1 (Central Push / Imperative Orchestrator — Rejected)*: Fails on roaming/NAT/sleeping targets, requires high-privilege inbound CI push-root (`L3+` violation), risks remote lockout on bad network transitions.
  - *C2 (Uncoordinated Blind Local Pull — Rejected)*: OOM-crushes constrained/ARM hosts with local compilation and switches blindly without calibration or health-gated rollback.
  - *C3 (Triadic Calibrated Autonomous Pull with Self-Assessing Atomic Transitions — Accepted)*: Aligns with Burgess's $N=3$ Triadic Calibration, Hard Closures, intermittent fleet realities, and least-privilege security.
- **Fork 4b (Unified Epistemic Substrate)**:
  - *E1 (Siloed Standard Tools — Rejected)*: Reproduces v1's fragmented silos (5.3k LOC ad-hoc `meta/graph/`, doc blind spots across `meta/` & Rust, disconnected observability and AI context).
  - *E2 (Monolithic Live SST Graph DB — Rejected)*: Blows VPS RAM/disk budgets storing raw metrics/logs in a graph DB and breaks offline/pure evaluation & standalone tools.
  - *E3 (Semantic Spacetime $\gamma(3,4)$ Spine over Specialized Storage & Trust-Budgeted Assessment — Accepted)*: Unifies topology, provenance, docs, verification, observability, and AI causal-cone navigation behind one minimal 4-edge schema while keeping raw telemetry compact and static evaluation 100% offline.

## 3. Decision Outcome

1. **Triadic Calibrated Autonomous Pull (`C3`)**:
   - **Calibrated Signed References**: All automated/bot/AI/human updates enter as PR impositions gated by verification Agents and publish to calibrated references: Git `main` (+ async self-hosted mirror for GitHub resilience) AND signed prebuilt multi-arch binary caches.
   - **Autonomous Proper-Time Pull**: Each host pulls voluntarily according to its own cadence and local conditions (e.g., security cadence on VPS, AC/Wi-Fi or manual on laptops, cache-hit-required on low-RAM/ARM nodes). No CI runner or update bot ever holds inbound root-push credentials onto hosts.
   - **Atomic Self-Assessing Transitions & Auto-Rollback**: Switching $g_n \xrightarrow{\text{FOLLOWS}} g_{n+1}$ runs a bounded local self-assessment gate ($\alpha$); failing core survival promises triggers autonomous rollback to $g_n$ and logs the transition in `FOLLOWS` provenance.
   - **Explicit Human Interactive Override**: Hosts may hold an explicit `L3+` human-authorized acceptance promise for manual interactive switches (`just switch`) during active operations or rescue.
2. **Semantic Spacetime ($\gamma(3,4)$) Epistemic Spine (`E3`)**:
   - **Four-Edge Universal Spine**: All layers (hosts, services, substrates, Rust tools, CI pipelines, docs, generations, runtime assessments) project onto one minimal schema: `CONTAINS` (fractal hierarchy), `FOLLOWS` (proper-time causal cones), `EXPRESSES` (exterior promise surfaces $\Pi_{\text{ext}}$, `L3+` attributes, `S2+` state traits, docs, live $\alpha$ status), and `NEAR` (contextual shortcuts / related ADRs & failure patterns).
   - **Spine vs. Bulk Telemetry Separation**: Raw time-series metrics, logs, and traces reside in compact specialized storage engines; the SST spine stores lightweight boundaries, transitions, assessment summaries, anomalies, and pointers — remaining offline-queryable at static time and token-efficient for Humans and AI Agents.
   - **Trust-Budgeted Assessment (*"Policy for Inattentiveness"*)**: `Hard` promises consume zero continuous runtime RAM (verified via binary hash/type/sandbox calibration); `Soft` promises allocate monitoring budget proportional to criticality × uncertainty, escalating deep inspection (including autonomous AI causal-cone analysis) upon degradation or anomaly.
   - **Uniform All-Layer Enforcement**: Because auxiliary tooling, Rust crates, CI, and documentation are themselves Agents projecting into the SST spine, undocumented or unchecked layers are mechanically caught across the entire repository.

## 4. Consequences
- **Positive**: Completes the core four-part Promise Theory + Semantic Spacetime baseline (`ADR-0002`..`ADR-0005`), unifying reliability, graceful degradation, multi-arch GitOps, bounded-RAM observability, and AI-first causal reasoning behind clean human interfaces.
- **Follow-Up Audit**: Subjected immediately to an adversarial cross-ADR red-team audit (`RES-0011`) before freezing the baseline and entering Phase 3 realization RFDs.

## 5. Links
- Builds on: [`ADR-0002`](ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md), [`ADR-0003`](ADR-0003-promise-algebra-scoped-binding-and-boundary-projection.md), [`ADR-0004`](ADR-0004-hard-boundaries-boolean-authority-and-state-as-promise.md)
- Analysis: [`RES-0010`](../research/RES-0010-spacetime-dynamics-calibration-and-sst-epistemics.md)
- Red-Team Audit: [`RES-0011`](../research/RES-0011-foundational-red-team-audit-and-refinements.md)
