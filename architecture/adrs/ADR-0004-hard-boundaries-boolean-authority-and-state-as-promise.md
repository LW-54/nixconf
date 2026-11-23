---
id: ADR-0004
title: Adopt Dual-Layer Cryptographic Authority with Boolean Group/Attribute Algebra (L3+) & Open State-As-Promise (S2+)
type: adr
status: accepted
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [adr, decision-3, identity, lampson, capabilities, boolean-lattice, authorization, state-as-promise, cap-flp, proper-time]
rfd: null
assumptions: [A-004, A-005]
supersedes: null
superseded_by: null
summary: Ratifies Decision 3 on top of ADR-0002 + ADR-0003: (1) L3+ Offline Cryptographic Root Identity + Attenuated Capabilities + Boolean Set-Algebra Authorization Policies (union, intersection, inclusion, exclusion over agent attributes/groups instead of a rigid hierarchy), and (2) S2+ Mandatory Agent-Declared State-As-Promise using open, composable state traits rather than a rigid closed class enum.
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Decision 3** of the `nixconf` v2 theoretical foundation on top of [`ADR-0002`](ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md) and [`ADR-0003`](ADR-0003-promise-algebra-scoped-binding-and-boundary-projection.md), securing Agent boundaries $\Sigma$ against adversarial threats (`T2`) and CAP/FLP state hazards (`T4`). Incorporates two crucial user refinements that make the mathematics strictly more general and orthogonal:
1. **Authority (`L3+`)**: Offline-capable cryptographic Root Identities (minimal bootstrap ACLs only) paired with narrow, revocable **Attenuated Capabilities** for all active delegation (AI agents, CI, bots, ephemeral onboarding, per-service boundaries), governed statically by a **Boolean Set Algebra / Attribute-Predicate Lattice** ($\cup, \cap, \in, \setminus$ — union, intersection, inclusion, exclusion over agent groups & expressed attributes) rather than a rigid linear trust hierarchy.
2. **State Ownership (`S2+`)**: **Mandatory Agent-Declared State-As-Promise** forbidding invisible/implicit non-reconstructible mutable state, expressed via **open, orthogonal, composable behavioral traits** (reconstructibility, retention/lifecycle, writer/CAP consistency semantics, replication/backup policy, ownership) rather than a prematurely locked closed enum of state classes.
<!-- abstract:end -->

# ADR-0004: Hard Boundaries — Boolean-Lattice Authority (`L3+`) & Open State-As-Promise (`S2+`)

## 1. Context & Problem Statement
Decisions 1–2 (`ADR-0002`, `ADR-0003`) defined cooperative Agency and Promise composition. Decision 3 (`RES-0009`) confronted the two physical walls where pure voluntary promises break:
- **Constraint T2 (Adversarial / Byzantine Boundaries)**: Stolen devices, compromised edge services, rogue PRs, or leaked tokens do not honor soft promises; Promise Theory's Imposition Law ($!x$) requires hard cryptographic & kernel enforcement (Lampson's Access Matrix).
- **Constraint T4 (CAP / FLP & Irreplaceable State Over Proper Time)**: Everything in `/nix/store` is reconstructible from Git; only root private keys and mutable stateful data survive across proper time (`FOLLOWS`) and risk irreversible loss or split-brain corruption.

## 2. Considered Options & Key Refinements (`RES-0009`)
- **Fork 3a (Authority Model)**:
  - *L1 (Pure Static Identity ACLs — Rejected)*: Offline-capable, but broad ambient blast radius and clumsy ephemeral delegation.
  - *L2 (Pure Dynamic Capabilities / Online Mint — Rejected)*: Minimal blast radius, but breaks offline boot/rescue self-sufficiency (`T4`, `QA-07`) and adds high HA maintenance burden (`D`).
  - *L3 → Refined to `L3+` (Accepted)*: Offline Root Identity + Attenuated Capabilities, **upgraded from rigid linear Trust Tiers (`T0..T4`) to a Boolean Set Algebra over Groups & Attributes**. *Why*: Security domains in a real heterogeneous fleet are mathematically **incomparable** (a public-exposed 24/7 VPS like `astrolabe` and a physically stealable personal laptop like `x240` are neither strictly "above" nor "below" each other — they occupy distinct intersections/exclusions of exposure, custody, and role!). A Boolean lattice ($\cup, \cap, \in, \setminus$) captures arbitrary multi-dimensional security policies cleanly and aligns directly with SST `EXPRESSES` attributes and `ADR-0003`'s `B3` attribute predicates.
- **Fork 3b (Proper-Time State Ownership)**:
  - *S1 (Implicit Host-Owned Filesystem — Rejected)*: Guarantees drift, forgotten impermanence mounts/backups, and silent data loss on ephemeral media (`B` failure).
  - *S3 (Pure Stateless / Externalized DB Clusters — Rejected)*: Violates resource efficiency (`AUD-0003`/`AUD-0004`) and low maintenance (`D`) for local-first services.
  - *S2 → Refined to `S2+` (Accepted)*: Mandatory Agent-Declared State-As-Promise, **upgraded from a locked 4-class enum to open, orthogonal, composable state traits**. *Why*: Real volumes exhibit orthogonal trait combinations that break rigid buckets (e.g., TSDB metrics are *persistent across reboot* yet *loss-tolerable / non-backed-up*; binary caches are *persistent + monotonic + reconstructible*; WSL Windows-interop mounts are *persistent + externally owned*). Keeping traits open and composable lets exact taxonomies evolve cleanly in Phase 3 without weakening static safety.

## 3. Decision Outcome

1. **Dual-Layer Cryptographic Authority (`L3+`)**:
   - **Layer 1 — Offline Cryptographic Root Identity (Minimal Bootstrap Core Only)**: Every long-lived situated boundary (Host, Human Admin, Repo/Mirror) holds a cryptographic keypair as its immutable Name. Static offline ACLs exist *strictly* for the irreducible offline/bootstrap core (own boot/runtime secrets, mesh identity, offline human recovery) — never ambient fleet-wide root.
   - **Layer 2 — Attenuated Capabilities for All Active Delegation**: Delegating authority across $\Sigma$ (AI agents, CI cache writers, PR-only update bots, Live ISO single-host onboarding, per-service credentials) MUST cross as a narrow, revocable, least-privilege Capability paired with kernel isolation where co-located.
   - **Boolean Set-Algebra Policy Enforcement ($\cup, \cap, \in, \setminus$)**: Agents express factual group memberships & security/posture attributes (e.g., `role:edge-server`, `posture:public-exposed`, `posture:roaming-stealable`, `posture:disk-encrypted`, `posture:ephemeral`, `actor:human`, `actor:ai-agent`, `location:home-lan`). Every secret, ACL, and capability guard declares its authorized audience via **Boolean set expressions** (union, intersection, inclusion, exclusion). Violating a policy predicate (e.g., granting a secret excluding `posture:roaming-stealable ∪ actor:ai-agent` to a Chromebook or AI agent) is a **hard static check error**.
2. **Mandatory Agent-Declared State-As-Promise (`S2+`)**:
   - **Zero Invisible Durable State**: Every Agent owning non-reconstructible mutable state MUST declare each state volume/store explicitly as a typed promise carrying its **Owner Boundary** and **composable behavioral traits** (e.g., reconstructibility/loss-tolerance, retention/lifecycle, writer/CAP consistency semantics, backup/replication requirements, external ownership).
   - **Exact Trait Schema Left Open**: Concrete trait vocabularies are refined empirically during Phase 3 (Storage, Persistence, Observability, WSL/ISO RFDs) — while locking in the structural invariant *now* that persistence, backup, quota, and ephemeral-substrate compatibility (`Live-ISO`, impermanence) bind mechanically via `ADR-0003` over declared state promises rather than manual parallel host path lists.
   - **CAP/FLP Honesty**: Any state spanning multiple Agents across network partitions MUST explicitly declare its distributed consistency semantics (e.g., single-primary + async mirror/replica, monotonic content-addressed/append-only, or eventual sync with conflict surfacing) — forbidding silent split-brain assumptions.

## 4. Consequences
- **Positive**: Cleanly handles incomparable security postures (`astrolabe` vs. `x240` vs. `rpi` vs. `chromebook` vs. `agy` vs. `live-iso`); works 100% offline during cold boot/rescue; eliminates forgotten impermanence/backup drift; avoids premature enum lock-in for nuanced storage workloads (TSDB, binary caches, WSL interop).
- **Obligations Imposed on Phase 3 Verification**: Wrapping stateful upstream NixOS modules requires an inspection/VM audit catching undeclared persistent writes outside declared state promises; Boolean authorization policies require clear human/AI explainability tooling (*"why is X allowed/denied Y?"*).

## 5. Links
- Builds on: [`ADR-0002`](ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md), [`ADR-0003`](ADR-0003-promise-algebra-scoped-binding-and-boundary-projection.md)
- Analysis: [`RES-0009`](../research/RES-0009-hard-boundaries-identity-authority-and-state.md)
- Next Decision Analysis: [`RES-0010`](../research/RES-0010-spacetime-dynamics-calibration-and-sst-epistemics.md)
