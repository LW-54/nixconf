---
id: ADR-0002
title: Adopt Fractal Uniform Agency (Model A) & Non-Piercing Superagent Boundaries as Foundational Ontology
type: adr
status: accepted
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [adr, decision-1, ontology, promise-theory, fractal-agency, dressed-superagent, non-piercing-boundary, standalone, substrates]
rfd: null
assumptions: [A-001, A-013]
supersedes: null
superseded_by: null
summary: Ratifies Model A (Fractal Uniform Agency): one universal entity (Agent = <Σ, Π_ext, Interior>) composing recursively into Dressed Superagents governed by the Non-Piercing Coarse-Graining Theorem, with standalone portability and substrate heterogeneity emerging purely from ambient Superagent scope rather than separate entity ontologies.
---

<!-- abstract:start -->
## Executive Abstract

Ratifies **Decision 1 — Model A (Fractal Uniform Agency)** as the root ontological bedrock of `nixconf` v2, derived from Bergstra & Burgess's Promise Theory and Burgess & Couch's Semantic Spacetime (`RES-0007`). There is **one** universal structural unit across every scale of the system — an **Agent** $A = \langle \Sigma, \Pi_{\text{ext}}, \text{Interior} \rangle$ — composing recursively via `CONTAINS` into **Dressed Superagents** $S = \langle \{A_i\}, \Pi_{\text{int}}, \Pi_{\text{ext}} \rangle$ governed by the **Non-Piercing Coarse-Graining Theorem**. Rather than splitting entities into static artifacts vs. live actors (Model B) or stamping redundant modality tags onto agents (Model C), standalone portability (`X4`), heterogeneous OS substrates (`T3`), and interior-vs-exterior separation emerge directly from **ambient Superagent scope ($\sigma$) and `CONTAINS` topology**, while **Hard vs. Soft enforcement** and **Lampson security guards** attach to **Promises and Boundaries** (Decisions 2 & 3).
<!-- abstract:end -->

# ADR-0002: Fractal Uniform Agency & Non-Piercing Boundaries ($\Sigma$)

## 1. Context & Problem Statement
Following the decision to build `nixconf` v2 rigorously from **Promise Theory** and **Semantic Spacetime** collided with five physical constraints (`T1`–`T5` in `RES-0007`), the logically irreducible first decision was defining the root ontology of Agency, Scale, and Boundaries ($\Sigma$) without assuming earlier "distinct pillars" or `ADR-0001`.

## 2. Considered Options (`RES-0007`)
1. **Pure Event-Sourcing / Process-First Ontology *(Rejected)***: Fails theoretically (events have no boundary $\Sigma$ or voluntary agency in PT) and technically (Nix converges to deterministic immutable closures, not imperative event replay).
2. **Model B — Stratified Two-Regime Domains *(Rejected)***: Hard split between timeless Hard Artifacts (Regime 1) and live Runtime Actors (Regime 2). Physically explicit, but introduces a recurring two-world vocabulary seam for services that exist both as testable declarative blueprints and live distributed actors.
3. **Model C — Scale-Unified Agents with Typed Boundary Modalities *(Rejected as Redundant)***: Unified agent grammar plus explicit binary tags (`Pure`/`Situated`, `Interior`/`Exterior`). On closer formal inspection, both tags proved redundant with Model A's native topology and promise signatures, and falsely implied that situated hosts do not also emit Hard Promises (immutable closures/sandboxes).
4. **Model A — Fractal Uniform Agency *(Accepted)***: One scale-free entity $A = \langle \Sigma, \Pi_{\text{ext}}, \text{Interior} \rangle$ composing recursively into Dressed Superagents $S = \langle \{A_i\}, \Pi_{\text{int}}, \Pi_{\text{ext}} \rangle$.

## 3. Decision Outcome
Adopt **Model A (Fractal Uniform Agency)** governed by four core ontological invariants:

1. **Single Universal Unit of Agency**: Every entity at every scale — an atomic wrapped CLI (`foot`, `nixprof`), a service daemon (`vaultwarden`), a capability stack (`observability`), an OS substrate (`nixos-vps`, `nixos-wsl`, `live-iso`), a host (`astrolabe`, `x240`, `rpi`), the fleet, a human operator, an AI agent, or an external platform (GitHub, binary cache) — is modeled as an **Agent** $A = \langle \Sigma, \Pi_{\text{ext}}, \text{Interior} \rangle$.
2. **Recursive Dressed Superagents (`CONTAINS`)**: Composite systems are **Dressed Superagents** $S = \langle \{A_i\}, \Pi_{\text{int}}, \Pi_{\text{ext}} \rangle$ whose interior agents cooperate via $\Pi_{\text{int}}$ to project exterior promises $\Pi_{\text{ext}}$ across boundary $\Sigma_S$. Atomic agents carry opaque interiors with zero superagent ceremony.
3. **Non-Piercing Coarse-Graining Law ($\Sigma$)**: Every Superagent boundary $\Sigma_S$ is strictly opaque from outside. External agents may observe and bind **only** to $\Pi_{\text{ext}}(S)$ — never into $\{A_i\}$ or $\Pi_{\text{int}}(S)$. This single law simultaneously enforces:
   - Parnas Information Hiding (interior sub-component swapping without external cascade),
   - Promise Theory Coarse-Graining (traceable responsibility at each scale),
   - Nix Evaluation & Binary Cache Isolation (no cross-host `nixosConfigurations` piercing),
   - Security Containment (no exterior inspection of interior secrets), and
   - Bounded Human & LLM Context (reasoning over $\Pi_{\text{ext}}$ instead of full interiors).
4. **Emergent Properties Without Entity Bifurcation**:
   - **Standalone Portability (`X4`)** is an *emergent theorem*: an agent is standalone (`nix run` anywhere) *iff* all its mandatory use-promises ($-b$) are satisfied inside the minimal store-only ambient Superagent scope (no `Pure` entity tag required).
   - **Substrate Heterogeneity (`T3`)** is *ambient promise polymorphism*: `astrolabe`, `x240`, `wsl`, `live-iso`, `rpi`, `vm-test`, and `standalone` are simply Superagents containing different Substrate Agents emitting that target's real hardware/OS `+b` promises.
   - **Hard vs. Soft Enforcement (`T1`)** and **Adversarial Protection (`T2`)** belong to **Promises and Boundaries** (Decisions 2 & 3), allowing *any* Agent (including a situated host) to emit both Hard Structural Promises (immutable closure hashes, kernel sandboxes) and Soft Runtime Promises (uptime, network reachability, telemetry health).

## 4. Consequences
- **Positive**: Maximum minimality (`X1`) and scale symmetry (`X2`); zero static/runtime vocabulary split; zero artificial walls between packages, features, implementations, hosts, and fleet; strict Nix cache isolation falls directly out of $\Sigma$ opacity.
- **Obligations Imposed on Decisions 2 & 3**: Because Model A refuses to separate "static" vs. "networked" entities at the agent-kind level, **Decision 2** (Promise Algebra) MUST rigorously distinguish **Hard vs. Soft/Conditional promises** and enforce **Zero Silent Ambiguity** & **Non-Piercing Boundary Projection**, and **Decision 3** MUST attach **Cryptographic Identity & Lampson Imposition Guards** cleanly to exposed boundaries $\Sigma$.

## 5. Links
- Derivation: `../research/RES-0007-promise-theory-sst-formal-derivation.md`
- Next Decision Analysis: `../research/RES-0008-promise-algebra-binding-and-projection.md`
