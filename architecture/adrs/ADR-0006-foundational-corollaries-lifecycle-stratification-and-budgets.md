---
id: ADR-0006
title: Adopt Seven Foundational Corollaries from Adversarial Red-Team Audit (Lifecycle, Boundary-First Stratification, Foreign Wrapping, Resource Budgets, Epistemic Zoom, Portable User-Space, Tri-Purpose Probes)
type: adr
status: accepted
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [adr, corollaries, genesis, revocation, break-glass, boundary-first-stratification, ousterhout, resource-budgets, epistemic-zoom, user-space, assessment-probes]
rfd: null
assumptions: [A-001, A-002, A-004, A-005, A-006, A-013]
supersedes: null
superseded_by: null
summary: Ratifies seven foundational corollaries discovered during the RES-0011 adversarial red-team audit of ADR-0002..ADR-0005, closing all identified theoretical and practical gaps before transitioning from Phase 2 (Theoretical Foundation) to Phase 3 (Concrete Realization RFDs).
---

<!-- abstract:start -->
## Executive Abstract

Ratifies the seven corollaries identified by the adversarial Cross-Consistency Assessment ([`RES-0011`](../research/RES-0011-foundational-red-team-audit-and-refinements.md)) of [`ADR-0002`](ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md)–[`ADR-0005`](ADR-0005-triadic-calibrated-pull-and-sst-epistemic-spine.md), completing the **Phase 2 Theoretical Foundation** of `nixconf` v2:
1. **Agent Lifecycle Boundary Transitions**: Zero-Trust Genesis ($t=0$, no master keys on ephemeral installer ISO), Mechanical Blast-Radius Revocation from `L3+` Boolean policies, and Zero-Infrastructure Break-Glass Recovery.
2. **Boundary-First Stratification Theorem ($\Pi_{\text{ext}}(S) \perp \text{Interior}(S)$)**: Exterior promise surfaces MUST be evaluable without evaluating interiors, closing fleet-scale mutual recursion and binary-cache invalidation.
3. **Ousterhout Boundary Discipline & Foreign-Agent Wrapping**: Only cross-agent interactions earn typed Promise Contracts; one-off hardware quirks remain in atomic Substrate interiors, and upstream modules are wrapped with audited boundary side-effect declarations.
4. **Budgeted Capacity & Dynamic Physical Conditions**: Adds additive conservation (`∑ demands ≤ supply` + priority tiering) as a 4th binding semantics and promotes dynamic power/thermal/idle state to first-class Conditions $C$ in `Soft` promises.
5. **Operational Non-Piercing vs. Authorized Epistemic Zoom**: Preserves strict non-piercing on operational dependencies while permitting read-only, secret-redacted, progressive-disclosure `CONTAINS` inspection for humans and diagnostic AI.
6. **Portable User-Space Boundary**: Decouples standalone-first wrapped user tools/environments from optional OS graphical/session wiring (`X4`).
7. **Tri-Purpose Assessment Probes ($\alpha$)**: One unified declaration of assessment & conditional-degradation probes powers pre-merge VM/fault-injection tests, `C3` auto-rollback gates, and `E3` live observability.
<!-- abstract:end -->

# ADR-0006: Foundational Corollaries Completing the Theoretical Baseline

## 1. Context & Problem Statement
Following ratification of Decisions 1–4 (`ADR-0002`..`ADR-0005`), an adversarial red-team audit ([`RES-0011`](../research/RES-0011-foundational-red-team-audit-and-refinements.md)) tested the four ADRs for cross-consistency conflicts, hidden evaluation cycles, security/lifecycle blind spots, and alignment with all fleet and capability constraints in [`CHARTER.md`](../CHARTER.md). While zero fatal contradictions were found, seven high-leverage corollaries proved necessary to make the theoretical baseline airtight before entering Phase 3 realization RFDs.

## 2. Decision Outcome — Seven Binding Corollaries

1. **Corollary C1 — Agent Lifecycle Boundary Transitions (`Genesis`, `Revocation`, `Break-Glass`)**:
   - *Zero-Trust Genesis ($t=0$)*: Ephemeral installer media (`Live-ISO`) never carries offline root keys or production secrets. New situated Agents generate private key material locally, verify custody with an authorized operator or single-use attenuated enrollment capability, register their public identity & attributes into Git (`C3` calibrated reference), and converge to generation $g_0$.
   - *Mechanical Blast-Radius Revocation*: Revoking a compromised/stolen Agent removes it from future authorization AND mechanically computes its exact historical **Blast-Radius Rotation Set** from the `L3+` Boolean policy graph (every secret/capability it was authorized to access).
   - *Zero-Infrastructure Break-Glass*: The fleet must always remain resurrectable from total simultaneous loss of live VPS + primary Git host using solely offline human root key material, an async off-platform Git mirror/clone, and encrypted off-host durable backups.

2. **Corollary C2 — Boundary-First Stratification Theorem ($\Pi_{\text{ext}}(S) \perp \text{Interior}(S)$)**:
   - For every Dressed Superagent $S$, its exterior promise surface $\Pi_{\text{ext}}(S)$ MUST be evaluable strictly at the **boundary stratum without evaluating $\text{Interior}(S)$**; evaluating $\text{Interior}(S)$ mechanically checks conformance against $\Pi_{\text{ext}}(S)$ (`P-Explicit`).
   - Across hosts, prefer **runtime discovery** (e.g., mesh DNS/peer state) over baking volatile peer coordinates into static `/etc` closures whenever possible, minimizing cross-host rebuild coupling toward zero.

3. **Corollary C3 — Ousterhout Boundary Discipline & Foreign-Agent Wrapping Law**:
   - Mint typed global Promise Contracts ($\tau$) *only* for interactions that are cross-agent, swappable, multi-instantiable, `L3+`-authorized, `S2+`-durable, resource-budgeted, or `E3`-assessed. One-off hardware quirks (dual OLED ACPI, hybrid GPU PRIME, audio firmware, device-tree) live privately inside an atomic Hardware/Quirk Agent's interior bound to `-b: substrate(...)`.
   - Upstream NixOS modules and external binaries are wrapped as Atomic Agents whose boundary $\Sigma$ explicitly declares their cross-cutting side effects (secrets, `S2+` state volumes, endpoints, resource envelope, probes $\alpha$), verified by inspection/VM audits catching undeclared persistent writes or listeners.

4. **Corollary C4 — Quantitative Resource Envelopes (`Budgeted Capacity`) & Dynamic Physical Conditions**:
   - Extends `ADR-0003`'s `B3` binding cardinalities with a **4th quantitative semantics — `Budgeted Capacity` (`∑ demands ≤ supply` + Priority Tiering)** over finite resources (RAM, disk, CPU/IO, storage quotas), checked statically against host capacity limits and enforced at runtime via kernel isolation/cgroups.
   - Promotes dynamic physical posture (`power:ac-plugged`, `thermal:nominal`, `network:unmetered`, `host:idle`) to first-class Conditions $C$ in `Soft` conditional promises, enabling opportunistic distributed workloads (e.g., plugged-in laptop Nix builders) that pause cleanly when physical conditions shift.

5. **Corollary C5 — Operational Non-Piercing vs. Authorized Epistemic Zoom**:
   - **Operational Dependency Edges** (build/runtime bindings between functional Agents) remain **100% strictly Non-Piercing** (`ADR-0002`).
   - **Epistemic Zoom** (Humans or `L3+`-authorized diagnostic AI traversing `CONTAINS` in `E3`) is **strictly read-only, secret-redacted, zero-reverse-build-dependency**, and progressive-disclosure by default (starting at coarse-grained $\Pi_{\text{ext}}$ and zooming into interiors only on demand).

6. **Corollary C6 — Portable User-Space Boundary (`X4` Standalone Unification)**:
   - Decouple standalone-first wrapped user tools/environments (requiring store packages only) from optional OS-integrated session Agents (requiring `-b: user-home` or `-b: linux-graphical-session`), allowing identical user Agents to execute standalone via `nix run` anywhere, on headless servers/WSL, and on full graphical desktops without NixOS/Home-Manager/Standalone duplication.

7. **Corollary C7 — Tri-Purpose Assessment Probes ($\alpha$)**:
   - Test environments (`eval`, `inspect`, `vm`, `install`) are modeled as **Simulated Superagent Scopes** substituting real exterior providers with deterministic mocks (`mock-secrets`, `fault-injectable-network`, `virtual-disko`).
   - Assessment probes ($\alpha$) and `Soft` conditional degradation contracts (`+b | C`) are declared **once** on each Agent and reused mechanically across: (1) pre-merge CI & fault-injection QEMU tests, (2) `C3` post-switch local auto-rollback gates, and (3) `E3` live runtime observability & AI diagnosis.

## 3. Consequences
- **Positive**: Completes Phase 2 with a cohesive, mathematically airtight, implementation-agnostic theoretical constitution (`spec/FOUNDATION.md`) ready to govern all Phase 3 realization RFDs.
- **Negative**: Concrete realization designs in Phase 3 must explicitly demonstrate compliance with **Boundary-First Stratification (C2)**, **Boolean Authorization explainability (`ADR-0004`)**, and **Tri-Purpose Probe reuse (C7)**.

## 4. Links
- Source Audit: [`RES-0011`](../research/RES-0011-foundational-red-team-audit-and-refinements.md)
- Master Foundation Spec: [`FOUNDATION.md`](../spec/FOUNDATION.md)
- Companion ADRs: [`ADR-0002`](ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md), [`ADR-0003`](ADR-0003-promise-algebra-scoped-binding-and-boundary-projection.md), [`ADR-0004`](ADR-0004-hard-boundaries-boolean-authority-and-state-as-promise.md), [`ADR-0005`](ADR-0005-triadic-calibrated-pull-and-sst-epistemic-spine.md)
