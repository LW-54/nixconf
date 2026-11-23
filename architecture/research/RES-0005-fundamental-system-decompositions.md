---
id: RES-0005
title: Research Dossier — Classical Systems-Theory Decompositions (Saltzer-Kaashoek, Promise Theory, Lampson)
type: research
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [research, saltzer-kaashoek, promise-theory, mark-burgess, lampson, ocap, acl, taxonomy, systems-theory]
assumptions: []
summary: Grounds the choice of remaining foundational primitive axes in primary computer-science systems theory (Saltzer & Kaashoek, Burgess Promise Theory, Lampson Access Matrix) and compares three candidate meta-taxonomies objectively.
---

<!-- abstract:start -->
## Executive Abstract

Steps back after ratifying Pillar 1 (`ADR-0001` — Effect–Handler Composability) to rigorously derive *which* orthogonal foundational axes remain to be designed, rather than reverse-mapping a feature wishlist. Surveys three canonical systems-theory frameworks: (1) **Saltzer & Kaashoek** (MIT 6.033: *Memory*, *Interpreters*, *Communication Links* + *Naming* + *Protection*); (2) **Mark Burgess's Promise Theory** (*Autonomous Agents*, *Voluntary Promises (`+b`/`-b`)* — mathematically dual to Effects & Handlers!, *Local Convergence*, *Continuous Assessment*); and (3) **Butler Lampson's Access Matrix & Hints** (the column/row duality between **ACLs** and **Object Capabilities** across distributed systems). Critiques our earlier ad-hoc 5-axis draft (which artificially split Identity from Authority and Assessment from Convergence) and synthesizes **three grounded candidate Coordinate Systems (A: Saltzer-Kaashoek, B: Promise Theory + Cybernetics, C: Space × Time × Authority × Truth)** for user alignment before exploring Pillar 2.
<!-- abstract:end -->

# RES-0005: Classical Systems-Theory Decompositions

## 1. Honest Self-Critique of Our First Ad-Hoc Axis List
In an earlier turn, five remaining axes were proposed without derivation (*State/Identity*, *Trust/Authority*, *Topology/Failure*, *Convergence/Execution*, *Epistemics*). Scrutinizing that list against first-principles CS theory reveals it was largely a reverse-mapping of concrete wishlist items (backups, SOPS, Tailscale, GitOps, monitoring) and contained three hidden coupling leaks:
1. **Identity was placed under State instead of Naming/Authority**: In cryptographic distributed systems, a node's enduring identity *is* its cryptographic keypair — simultaneously its Name and its Trust Anchor.
2. **Convergence was separated from Assessment/Observation**: In control theory and Promise Theory, convergence *is* the feedback loop `Assess(Reality, Promise) → Actuate`.
3. **State was separated from Space/Failure Domains**: Distributed state semantics (durability, consistency, caching, replication) sit at the intersection of Time (Memory) and Space (Communication/Partitions).

---

## 2. Three Canonical Foundations from Systems Literature

### 2.1 Saltzer & Kaashoek — *Principles of Computer System Design* (MIT 6.033)
Every computing system reduces to **3 operational primitives** + **2 organizing primitives**:
- **Memory** *(information across time)*: persistence, volatility, durability, consistency.
- **Interpreters** *(active execution)*: executing specs, runtimes, standalone invocations, convergence loops.
- **Communication Links** *(information across space)*: topology, routing, latency, network partitions.
- **Naming** *(binding across contexts)*: identifiers, addresses, versions, cryptographic names, discovery.
- **Protection** *(runtime modularity & least privilege)*: isolating faults and limiting blast radius across trust boundaries.

### 2.2 Mark Burgess — *Promise Theory* (Formal Theory of Autonomous Distributed Systems)
- **Fundamental Axiom**: *An autonomous agent can only promise its own behavior; it cannot coerce another agent.*
- **Four Core Primitives**:
  1. **Autonomous Agents**: Nodes, services, humans, AI agents, standalone shells.
  2. **Promises (`+b` offers / `-b` use-promises)**: Remarkably, this is **mathematically isomorphic to Pillar 1 (`ADR-0001`)** — Effects correspond to `-b` (requirements) and Handlers correspond to `+b` (offers/interpretations)!
  3. **Local Convergence**: Agents independently repair drift toward their own promises without fragile global command-and-control (explains why pull-based convergence & graceful offline degradation are *corollaries of autonomy*, not bolt-ons!).
  4. **Continuous Assessment**: Every agent observes and verifies compliance against its own promises — unifying pre-deploy verification, runtime observability, and self-knowledge.

### 2.3 Butler Lampson — *Protection* (1971), *Hints* (1983) & *Distributed Access Control*
- **The Access Control Matrix** ($\text{Subjects} \times \text{Objects} \to \text{Rights}$) has two fundamental dual representations:
  - **Column slice → ACLs** (attached to objects/resources): Easy centralized revocation and auditing; requires server-side lookup; vulnerable to the *Confused Deputy* problem.
  - **Row slice → Object Capabilities** (held by subjects as unforgeable tokens/keys): Possession = authority; zero Confused Deputy; fluid delegation; works cleanly offline/decentralized; harder revocation (requires expiry, indirection, or rotation).
- **Direct relevance**: Every real system mixes both duals purposefully (e.g., scoped deploy keys & bearer tokens are Capabilities; firewall/mesh rules, SSO policies, and branch protections are ACLs).

---

## 3. Three Candidate Coordinate Systems for Our Remaining Foundational Pillars

Having already ratified **Pillar 1 — Composition (`ADR-0001`: Effect–Handler Composability)**, here are three genuinely distinct, literature-backed ways to organize the remaining foundational design space:

### Coordinate System A — Saltzer & Kaashoek (Classic MIT Systems Physics — 5 Remaining Axes)
1. **Naming & Identity** (how nodes, versions, artifacts, and secrets are uniquely identified and resolved)
2. **Memory & State** (information across time: pure, ephemeral, durable, backed-up, replicated, external)
3. **Communication & Topology** (information across space: connectivity, locality, partitions, graceful degradation)
4. **Protection & Authority** (Lampson Access Matrix: ACLs vs Capabilities, least privilege, trust roots & revocation)
5. **Execution, Convergence & Assessment** (interpreters: standalone runs, managed convergence/rollback, verification & telemetry)
- **Pros**: Battle-tested across 50 years of OS/distributed systems; concrete, unmistakable boundaries; zero conflation.
- **Cons**: 6 total pillars (more steps); slightly separates *Naming* from *Protection* even when cryptographic keys serve both roles.

### Coordinate System B — Promise Theory + Cybernetics (Autonomous-Agent Minimalism — 3 Remaining Axes)
*(Builds directly on Pillar 1, since Effects/Handlers $\cong$ Promise Theory `-b`/`+b`!)*
1. **Autonomy, Actors & Space** (who the autonomous agents are — nodes, standalone invocations, humans, AI — their substrates, connectivity, and local self-sufficiency under partitions)
2. **Identity, Authority & State** (cryptographic identity, Lampson ACLs vs Capabilities, and state durability/lifecycle owned by each autonomous agent)
3. **The Cybernetic Loop: Converge & Assess** (unifying execution/convergence/rollback, pre-deploy verification, runtime observability, and human/AI introspection into ONE closed feedback loop)
- **Pros**: Radically minimal (only **4 total pillars**!); extraordinary philosophical unity with Pillar 1 (`ADR-0001`), graceful degradation, GitOps autonomy, and autonomous AI agents.
- **Cons**: Pillar B2 ("Identity + Authority + State") packs a lot into one pillar and will still need clean internal sub-steps to avoid glossing over state vs security nuances.

### Coordinate System C — Orthogonal Mathematical Dualities (Space × Time × Authority × Truth — 4 Remaining Axes)
1. **Space & Locality** *(Where)*: Substrates, standalone vs fleet nodes, connectivity fabric, failure domains & graceful degradation.
2. **Time & Lifecycle** *(When & What Persists)*: State taxonomy (pure, ephemeral, durable, external), state transitions, convergence, atomic updates & rollbacks.
3. **Identity & Authority** *(Who & May)*: Cryptographic naming/identity unified with Lampson's Access Matrix (ACLs vs Capabilities, trust roots, onboarding, revocation, human/AI/CI/host boundaries).
4. **Truth & Epistemics** *(How We Know)*: Pre-deploy verification (proofs/checks), runtime observability (measurement), and self-knowledge (human + AI introspection).
- **Pros**: Cleanest mathematical orthogonality (**5 total pillars**: *Composition*, *Space*, *Time*, *Authority*, *Truth*); keeps tightly coupled pairs united (*Identity + Authority*, *State + Time/Convergence*, *Verification + Observability + Knowledge*) without overloading any single axis.
- **Cons**: Slightly more abstract framing than Saltzer & Kaashoek; requires grounding each abstract axis carefully in concrete system realities.

---

## 4. Sources Consulted (2026-11-23)
- Saltzer, J. H. & Kaashoek, M. F. (2009). *Principles of Computer System Design: An Introduction* (Ch. 2: Elements of Computer System Design, MIT 6.033).
- Burgess, M. (2015). *Thinking in Promises: Designing Systems for Cooperation* (O'Reilly) & Promise Theory mathematical foundations (`markburgess.org`).
- Lampson, B. W. (1971/1974). *Protection*; (1983) *Hints for Computer System Design*; (1992) *Authentication in Distributed Systems: Theory and Practice*.
