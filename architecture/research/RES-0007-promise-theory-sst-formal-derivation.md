---
id: RES-0007
title: Formal First-Principles Derivation of nixconf v2 from Promise Theory, Semantic Spacetime & Physical Constraints
type: research
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [research, promise-theory, semantic-spacetime, bergstra, burgess, sttypes, superagent, boundary, hard-promises, lampson, cap-flp, ontology, decision-1]
assumptions: [A-001, A-002, A-013]
summary: Rigorous primary-literature derivation of the nixconf v2 baseline foundation from Bergstra & Burgess Promise Theory and Burgess & Couch Semantic Spacetime collided against five physical/technical constraints (Nix closures, Lampson security, substrate heterogeneity, CAP/FLP, cache locality), re-evaluating ADR-0001 without assumptions and framing Decision 1 (Ontology of Agency, Scale & Boundaries).
---

<!-- abstract:start -->
## Executive Abstract

This dossier derives the foundational architecture of `nixconf` v2 **from scratch** by colliding the formal axioms of **Promise Theory** (Bergstra & Burgess) and **Semantic Spacetime** (Burgess & Couch, including `arXiv:2506.07756` and `SSTorytime`) against five physical engineering constraints of our target domain (`AUD-0001`–`AUD-0004`, `CHARTER.md`). Crucially, it **does not assume `ADR-0001` (Effect–Handler Composability)** or rigid "distinct pillar" buckets: instead, it proves that Effect–Handler composition emerges naturally as a *special case* (the compile-time, hard-closed interior projection of complementary promises inside a Dressed Superagent), while exposing four critical dimensions `ADR-0001` lacked (Scope & Non-Piercing Boundaries $\Sigma$, Conditional Promises $+b \mid C$, Hard-vs-Soft / Lampson Enforcement, and Proper-Time Semantic Spacetime). It establishes the logically irreducible **Decision 1 — Ontology of Agency, Scale & Boundaries ($\Sigma$)** and evaluates three competing models (**Model A: Fractal Uniform Agency**, **Model B: Stratified Two-Regime Domains**, **Model C: Scale-Unified Agents with Typed Boundary Modalities**).
<!-- abstract:end -->

# RES-0007: Formal Derivation from Promise Theory, Semantic Spacetime & Physical Constraints

---

## 1. The Formal Theoretical Apparatus (Primary Literature)

Rather than treating Promise Theory as loose vocabulary, we anchor every design derivation in the formal structures established by **Mark Burgess**, **Jan A. Bergstra**, and **Alva Couch**.

### 1.1 Promise Theory Formal Mechanics (Bergstra & Burgess)

1. **Autonomous Agents ($A \in \mathcal{A}$) & Boundary ($\Sigma_A$)**:
   - Every agent occupies a bounded region separated into an **Interior** (private mechanism/state), a **Boundary surface ($\Sigma_A$)**, and an **Exterior** (everything outside direct causal control).
   - **Axiom of Autonomy**: An agent can *only* make credible promises about its own behavior on or across $\Sigma_A$; no agent can directly command or promise the internal state of another autonomous agent.
2. **Formal Promise Anatomy**:
   $$\pi \;=\; \bigl(A \xrightarrow{\;\pm b \;\mid\; C\;} Y\bigr)_{\sigma}$$
   - **Body ($b$)**: The concrete behavior, resource, state, or invariant offered or accepted, classified by a **Type** ($\tau$).
   - **Polarity ($\pm$)**:
     - **Give / Offer ($+b$)**: $A$ commits to making $b$ available.
     - **Use / Acceptance ($-b$, also written $U(b)$)**: $Y$ commits to accepting or relying on $b$.
   - **Constraint / Condition ($C$)**: Preconditions limiting when or how $b$ applies.
   - **Scope ($\sigma$)**: The bounded neighborhood of agents that can observe, assess, and bind to $\pi$.
3. **Binding Law (Cooperation Nexus)**:
   - Meaningful cooperation occurs *if and only if* complementary promises align inside a shared scope $\sigma$:
     $$(A \xrightarrow{+b} Y)_{\sigma} \;\land\; (Y \xrightarrow{-b} A)_{\sigma}$$
4. **Imposition ($A \xrightarrow{!b} Y$) vs. Voluntary Subordination**:
   - An uninvited push/command ($!b$) fails or destroys predictability unless $Y$ already holds a prior acceptance promise ($Y \xrightarrow{-b \mid \text{guard}} A$) agreeing to accept that class of event.
   - Hierarchy (**Subordination**) is never fundamental coercion — it is an *emergent pattern* where agents voluntarily rely on upstream promises because doing so lowers their own transactional cost.
5. **Conditional Promise Law**:
   - A conditional promise $A \xrightarrow{+b \mid d} Y$ is **formally incomplete/invalid** unless $A$ also explicitly accounts for acquiring or assessing prerequisite $d$ ($A \xrightarrow{-d} Z$) — and specifies what happens when $d$ is absent.
6. **Dressed Superagents & The Non-Piercing Coarse-Graining Theorem**:
   $$S \;=\; \bigl\langle \{A_1, \dots, A_n\},\; \Pi_{\text{int}},\; \Pi_{\text{ext}} \bigr\rangle$$
   - A set of internal agents $\{A_i\}$ cooperating via interior promises $\Pi_{\text{int}}$ coalesces behind a superagent boundary $\Sigma_S$ to project exterior promises $\Pi_{\text{ext}}$ at a coarser scale.
   - **Coarse-Graining / Boundary-Piercing Rule**: A superagent's exterior promises cannot be summed naively from its interior; they rely on second-order conditional interior cooperation. **If an external promise pierces $\Sigma_S$ directly into an interior sub-agent $A_k$, coarse-graining breaks**: external observers can no longer tell which boundary holds responsibility, and $A_k$ can no longer be swapped without cascading external breakage.
7. **Canonical Structural Patterns**:
   - **Delegation**: $A$ relies on $B$ voluntarily promising $+b$ while $A$ promises $-b$.
   - **Proxy / Assisted Promise**: An intermediary $P$ bridges two agents across a boundary gap without piercing either agent's interior.
   - **Coordination**: Emergent mutual alignment through interlocking promises (never fragile centralized command).
   - **Calibration**: Autonomous agents align state/standards independently against a shared reference point (avoiding centralized active bottlenecks).
8. **Assessment ($\alpha$), Trust & Hard vs. Soft Promises**:
   - **Assessment** $\alpha_Y(\pi) \in [0, 1]$: Observer $Y$'s local empirical measurement of whether $\pi$ holds.
   - **Trust**: Formally *"a policy for inattentiveness"* — economizing finite verification resources based on historical promise integrity.
   - **Hard Promises vs. Soft Promises**:
     - *Soft promises* are probabilistic, runtime-negotiable, and prone to drift (requiring continuous polling/reconciliation).
     - *Hard promises* are deterministic, invariant guarantees tied to absolute boundary conditions (e.g., cryptographic hashes, immutable closures) — collapsing runtime calibration from costly heuristic repair into **binary verification** (intact vs. untrusted/replace).

---

### 1.2 Semantic Spacetime Formal Mechanics (Burgess & Couch, 2015–2025)

In *Spacetimes with Semantics*, *On the Scale Dependence and Spacetime Dimension of the Internet with Causal Sets*, and *Agent Semantics, Semantic Spacetime, and Graphical Reasoning* (`arXiv:2506.07756`, June 2025; implemented in `SSTorytime` over PostgreSQL), Burgess extends Promise Theory into a discrete spacetime graph model avoiding ad-hoc ontology bloat:

1. **The $\gamma(3, 4)$ Finite Representation**:
   - **3 Node Roles**:
     - *Things / Snapshots* (spacelike durable/static entities),
     - *Events / Processes* (timelike state transitions bridging snapshots),
     - *Concepts / Roles* (invariants stabilized under repeated observation).
   - **4 Irreducible Spacetime Link Meta-Types (`STTypes`)**:
     | STType | Physical Analogue | Directionality | What It Encodes |
     | :--- | :--- | :--- | :--- |
     | **`CONTAINS`** | Space-like / Polar vector / Fractal scale | Directed (container $\to$ part) | Superagent boundaries $\Sigma$, hierarchical encapsulation, ownership. |
     | **`FOLLOWS`** | Time-like / Causal precedence / Proper time | Directed (cause/prev $\to$ effect/next) | Sequential state transitions, builds, deploys, rollbacks, causal cones. |
     | **`EXPRESSES`** | Scalar / Local attribute | Directed (entity $\to$ attribute/promise) | Local properties, roles, emitted promises $+b / -b$ on boundary $\Sigma$. |
     | **`NEAR`** | Non-causal proximity / Wormhole | Symmetric / Associative | Contextual similarity, sibling traits, shared failure modes, narrative recall. |

2. **Proper Time (No Global Continuum Clock)**:
   - Time is strictly **local proper time** — countable state transitions observed by an autonomous agent (analogous to Lamport causal precedence). Flattening causal history into a global wall-clock timeline destroys true provenance; preserving `FOLLOWS` edges retains exact causal cones for impact analysis and debugging.
3. **Weak-Transitivity Algebra & Boundary Absorbing States**:
   - **Homogeneous Transitivity**: Pure chains preserve framing ($A \xrightarrow{\text{CONTAINS}} B \xrightarrow{\text{CONTAINS}} C \implies A \xrightarrow{\text{CONTAINS}} C$; causal chains compose along `FOLLOWS`).
   - **Heterogeneous Weak Transitivity** (Burgess & Couch): Rules of the form $X \xrightarrow{r} Y \land Y \xrightarrow{s} Z \implies X \xrightarrow{t} Z$ enable predictable multi-scale inference (e.g., scaling attributes/promises across `CONTAINS` boundaries without unrestricted ontology explosion).
   - **Damping & Absorbing States (`arXiv:2506.07756`)**: Partial graphs naturally contain sinks/boundaries where information stops or changes context; SST treats boundaries explicitly as places where *intentionality is injected* rather than letting graph traversal silently leak across contexts.

---

## 2. Collision Against Five Hard Physical & Technical Constraints (`nixconf`)

A rigorous foundation emerges only where pure theory meets hard engineering reality (`AUD-0001`–`AUD-0004`, `CHARTER.md`):

| Constraint | Physical / Engineering Reality | What Breaks Under Naive Promise Theory | Exact Theoretical Resolution |
| :--- | :--- | :--- | :--- |
| **T1 — Dual Physical Regimes (Hard vs. Soft)** | `nixconf` spans both **timeless immutable closures** (Nix derivations, Rust binaries, static types, kernel sandboxes) and **noisy runtime actors** (WAN outages, OOM, roaming laptops, CVEs, humans, AI agents). | Treating everything like CFEngine soft promises throws away Nix's zero-drift immutability; treating everything as static Nix modules ignores runtime failures, partitions, and updates. | Separate **Hard Structural Promises** (verified once by types/hashes/sandboxes; binary calibration) from **Soft Runtime Promises** (conditional $+b \mid C$, continuously assessed $\alpha$, self-healing/rollback). |
| **T2 — Adversarial / Byzantine Boundaries** | Stolen Chromebook/laptop, compromised public service on `astrolabe`, rogue PR or leaked token. Attackers do *not* politely honor promises. | Pure PT assumes imperfect-but-cooperative agents; operational trust ("inattentiveness") cannot stop an adversary. | Pair PT's **Imposition Rule** ($!x$ rejected unless prior $-x$) with **Cryptographic Identity** (public key = name), **Lampson's Access Matrix** (ACLs + least-privilege Object Capabilities), and kernel isolation at every exposed boundary $\Sigma$. |
| **T3 — Substrate Heterogeneity & Standalone (`X4`)** | Targets span pure standalone `nix run` (no OS, no systemd, no root), `NixOS-WSL` (no kernel/bootloader/`disko`), Live USB ISO (ephemeral squashfs), `aarch64` RPi, hybrid-GPU TUF, dual-screen ZenBook, touch Chromebook, and 24/7 VPS. | Hardcoding "Host" or "NixOS" as the atomic primitive breaks standalone `nix run` and forces conditional hacks across WSL/ISO/RPi. | Make **Substrate** an explicit interior agent/boundary provider — never an implicit universal assumption! Standalone pure closures require zero OS substrate. |
| **T4 — CAP / FLP & State Ownership Over Proper Time** | Intermittent/mobile fleet (`x240`, tablet, WSL, RPi behind NAT). Synchronous multi-node quorum across the fleet will deadlock core operations. | Naive distributed promises ignore split-brain writes on stateful databases (e.g., Vaultwarden) or Git `main`. | Zero synchronous cross-host consensus for core vitality (`QA-07`); every mutable durable state has an explicit **single authoritative owner agent** (or explicit append-only/CRDT/snapshot semantics) tracked via `FOLLOWS` proper-time lineage. |
| **T5 — Nix Evaluation & Binary Cache Physics** | Reading another host's full NixOS `config` (`self.nixosConfigurations` in v1's `hub.nix`) or interpolating `${self}` (`rclone/mounts.nix`) couples evaluation and busts binary caches globally. | Arbitrary cross-node reads pierce superagent boundaries and cause quadratic rebuilds + giant LLM contexts. | **Boundary Non-Piercing Theorem ($\Sigma$)**: External agents may ONLY read another agent's tiny, pure **Exterior Promise Surface ($\Pi_{\text{ext}}$)**, NEVER its interior! One mathematical invariant simultaneously enforces Parnas hiding, PT coarse-graining, Nix cache isolation, security isolation, and compact AI context. |

---

## 3. Honest Re-Evaluation of `ADR-0001` (Nothing Assumed!)

Following the user's explicit instruction **not to assume Pillar 1 (`ADR-0001`: Effect–Handler Composability)**, we re-derived composition strictly from PT + SST + T1–T5:

1. **What `ADR-0001` got right — now *derived as a theorem*, not assumed as an axiom**:
   - Inside a **Hard-Closed / Co-located Superagent** (e.g., compiling a NixOS host or a test VM closure), complementary promises $(A \xrightarrow{-b} S) \land (H \xrightarrow{+b} S)$ **mathematically recover Effect–Handler composition**:
     - An interior workload's `-b` / `+b` declarations are its "Effects";
     - Peer providers' complementary `+b` / `-b` promises inside $\Pi_{\text{int}}$ are the "Handlers" (naturally open, $0..N$ multi-instantiable, and $O(N+M)$ mediated);
     - Sub-component swapping (e.g., `Grafana → Perses` inside `Observability`) is literally a **Dressed Superagent** preserving $\Pi_{\text{ext}}$ while altering $\{A_i\}, \Pi_{\text{int}}$;
     - Our empirical `EXP-0002` / `EXP-0003` soundness invariants (**Strict Stratification** and **Commutative Keyed Merge**) are the exact physical compilation constraints required to lower interior promises $\Pi_{\text{int}}$ into a deterministic Nix fixed-point closure without cycles or import-order bugs.
2. **Four major blind spots in `ADR-0001` exposed immediately by PT + SST**:
   - **No Scope ($\sigma$) or Boundary Non-Piercing ($\Sigma$)**: `ADR-0001` could not distinguish an interior co-located handler from a cross-host dependency, nor formalize why `astrolabe` must not pierce `x240`'s interior (cache & security isolation).
   - **No Conditional Promises ($+b \mid C$)**: `ADR-0001` had no native mathematical model for runtime degradation when a promised resource (remote builder, mesh storage, upstream API) becomes temporarily unavailable.
   - **No Hard-vs-Soft or Adversarial Distinction**: `ADR-0001` only described static compile-time composition; it did not cover runtime drift, cryptographic imposition guards, or continuous calibration ($\alpha$).
   - **No Proper-Time Spacetime Graph (`FOLLOWS`, `CONTAINS`, `EXPRESSES`, `NEAR`)**: `ADR-0001` was purely static/spatial and disconnected from GitOps lifecycles, rollbacks, observability causality, and human/AI memory.

**Verdict**: Rather than preserving a fragmented set of "5 distinct pillars" where `ADR-0001` sits off to the side, **Promise Theory + Semantic Spacetime + Hard Structural/Cryptographic Enforcement** forms a **single unified baseline foundation** that cleanly subsumes and generalizes `ADR-0001` (once ratified through our step-by-step decisions, we will formally supersede `ADR-0001` via append-only ADR lineage).

---

## 4. Decision Roadmap (Derived Strictly by Logical Dependency — No Bundling!)

Instead of imposing arbitrary "pillar" labels, each foundational decision unlocks the next strictly by mathematical necessity:

1. **Decision 1 *(NOW)* — Ontology of Agency, Scale & Boundaries ($\Sigma$)**: *What are the fundamental autonomous entities, how do pure standalone artifacts relate to situated runtime actors, and what physical regimes does a boundary $\Sigma$ enforce?*
2. **Decision 2 *(Next)* — Promise Algebra, Scope & Binding Laws**: *Formal structure of $+b$, $-b$, conditional $+b \mid C$, Dressed Superagent non-piercing projection ($\Pi_{\text{int}} \to \Pi_{\text{ext}}$), and static compilation soundness (stratification + commutativity).*
3. **Decision 3 — Hard Boundaries: Cryptographic Identity, Lampson Authority & Proper-Time State Ownership**: *How identity, ACLs/capabilities, imposition guards, and single-writer/replicated state lifetimes attach to Boundaries $\Sigma$.*
4. **Decision 4 — Spacetime Dynamics: Calibration, Convergence, Assessment & the $\gamma(3,4)$ SST Graph**: *How `CONTAINS`, `FOLLOWS`, `EXPRESSES`, `NEAR` and weak-transitivity unify fleet topology, GitOps/rollback proper time, bounded-RAM observability, and human/AI reasoning.*
5. **Phase 3 (Only After Foundation Is Ratified)** — Concrete Realization & Engineering RFDs (Authoring medium / Nix↔Rust seam, Pure Rust builds, Pinning, Mesh, GitOps, Distributed Storage/Compute, Observability stack, Docs/LLM interfaces).

---

## 5. Deep Analysis for Decision 1 — Ontology of Agency, Scale & Boundaries ($\Sigma$)

In Promise Theory, you cannot define a single promise or SST edge until you define **what counts as an Agent ($A$) and what a Boundary ($\Sigma$) means physically**.

*(Note on rejected alternative — **Pure Event-Centric / Event-Sourcing Ontology**: Making `FOLLOWS` events primary fails both theoretically and practically: in Promise Theory only an autonomous Agent with a boundary $\Sigma$ can own intent/state, and in Nix declarative infrastructure systems converge to immutable state closures rather than replaying imperative mutation event logs. Events remain first-class `FOLLOWS` bridge nodes in SST, not the root unit of agency.)*

Three genuinely distinct, mathematically rigorous ontologies emerge from PT + SST + Constraints `T1`–`T5`:

### Model A — Fractal Uniform Agency (Pure Scale-Free Recursive Superagents)
- **Structure**: **One** universal structural entity: `Agent = ⟨Σ, Π_ext, Interior⟩`. Atomic agents wrap opaque primitives (binaries, daemons, hardware, humans, AI agents, external APIs); Composite agents (**Dressed Superagents**) combine sub-agents via `CONTAINS` + interior promises $\Pi_{\text{int}}$.
- **How `nixconf` maps**:
  - `foot` / `nixprof` = an Agent whose `-b` requirements are satisfied purely by build-time store inputs (hence runnable standalone via `nix run`).
  - `vaultwarden` = an Agent declaring `-b` (secret, storage, port) and `+b` (HTTP service).
  - `observability` = a Superagent wrapping `{collector, metrics, logs, alerts, ui}`.
  - `astrolabe` / `x240` / `wsl` / `live-iso` = Superagents containing a Substrate Agent + Workloads + Providers.
  - `Fleet` = Superagent of Hosts + Mesh + Git + Binary Cache + Humans + AI.
- **Strengths**: Peak minimality (`X1`); total scale symmetry — zero artificial walls between package, feature, implementation, host, and fleet.
- **Intricacies & Risks**: **Physics Blur (`B` Reliability Risk)**. A pure timeless binary (`foot`), a running Linux host (`astrolabe`), and an adversarial network peer (`GitHub` / roaming Chromebook) obey radically different physical laws. Without explicit structural distinction, either simple standalone tools get dragged into heavy superagent ceremony, OR cross-network/security boundaries accidentally blur with static local merges.

### Model B — Stratified Two-Regime Domains (Hard Artifacts vs. Live Spacetime Agents)
- **Structure**: Hard architectural split directly mirroring **Constraint T1**:
  1. **Regime 1 — Hard-Promise Artifacts *(Timeless / Immutable Space)***: Pure content-addressed closures, wrapped apps/CLIs, libraries, schemas, and *service blueprints* — zero runtime identity, zero mutable state, zero convergence loop. Inherently standalone (`nix run` anywhere).
  2. **Regime 2 — Situated Runtime Agents *(Live Spacetime Actors)***: Entities occupying physical spacetime with cryptographic identity, proper-time mutable state, security boundaries, and soft assessment/convergence loops (Hosts of any substrate, Stateful Services, External APIs, Humans, AI Agents, CI).
  - Connected by **Instantiation** (a Runtime Agent realizes Artifacts across its Substrate) and unified in metadata by the **SST $\gamma(3,4)$ graph**.
- **Strengths**: Crystal-clear physical honesty (`B` Reliability + `X4` Standalone). Impossible to confuse a static package with a stateful networked actor; standalone tools enjoy zero runtime tax; cryptographic identity & CAP/FLP ownership attach strictly to Regime 2.
- **Intricacies & Risks**: **The Two-World Seam**. A service like `vaultwarden` exists simultaneously as a Regime-1 blueprint (authored declaratively, testable in mocks) AND a Regime-2 live actor (holding persistent SQLite state, serving Caddy locally, and accessible to `x240` over the mesh). If Regime 1 and Regime 2 diverge in how they express promises, boundaries, or composition, you risk duplicating vocabularies across the static/runtime seam (which breeds boilerplate and cognitive friction).

### Model C — Scale-Unified Agents with Typed Boundary Modalities (Hardness × Permeability)
- **Structure**: Keeps Model A's **single unified PT+SST Agent & Promise grammar** (zero vocabulary split between static blueprints and live actors), **while** eliminating Model A's physics blur by making every Boundary $\Sigma$ carry **two orthogonal formal invariants (modalities)** derived directly from `T1` + `T2` + `T3`:
  1. **Agency Modality *(Pure vs. Situated)***:
     - **`Pure` (Hard-Closed)**: Zero mutable proper-time state, zero cryptographic identity, zero OS/substrate requirement — fully determined by cryptographic closure + static types. **Mechanically guarantees `X4` Standalone Portability** (`nix run` works everywhere; referencing a `Situated` substrate inside a `Pure` agent is a static type error!).
     - **`Situated` (Spacetime-Anchored)**: Occupies spacetime; explicitly declares its **Substrate** requirement (e.g., `linux-systemd`, `wsl`, `ephemeral-iso`, `human`, `ai-runtime`, `external-saas`), its **Identity**, and its **State Lifetime** (ephemeral vs. durable).
  2. **Binding Modality *(Interior Hard-Bound vs. Exterior Spacetime-Bound)***:
     - **`Interior` (Within one Superagent $\Sigma_S$)**: Compiled into a single atomic hard closure (zero runtime network drift, strictly stratified, commutative merge; binary calibration).
     - **`Exterior` (Across distinct Boundaries $\Sigma_A \leftrightarrow \Sigma_B$)**: Physically crosses a process, privilege, or network boundary. **Mechanically enforces**: (a) Non-Piercing (may read ONLY $\Pi_{\text{ext}}$, protecting Nix cache isolation & Parnas hiding), (b) Conditional Promise Law ($+b \mid C$ + explicit degradation behavior), (c) Lampson Cryptographic Guard on any imposition, and (d) Runtime Assessment ($\alpha$).
- **Strengths**: Reconciles Model A's mathematical unity (`X1`, `X2`) with Model B's physical rigor (`B`, `X4`, `X5`). One single promise grammar spans standalone tools, local host wiring, VM mocks, cross-host mesh services, GitOps, and AI agents — *yet* the boundary modalities mechanically forbid standalone contamination, cross-host cache leaks, silent unconditional remote coupling, and unauthenticated impositions!
- **Intricacies & Risks**: Discipline required to keep the modality algebra **strictly minimal** (the 2 orthogonal binary invariants above, never letting it metastasize into a baroque type-system zoo). Also requires care that defining a simple `Pure` standalone tool (`foot`, `micro`) stays lightweight with near-zero boilerplate.

---

## 6. Sources Consulted (2026-11-23)
- Bergstra, J. A. & Burgess, M. *A Static Theory of Promises* (`uva.nl`, `arXiv`); *Promise Theory: Principles and Applications* / *A Treatise on Systems* (`markburgess.org`).
- Burgess, M. *Thinking in Promises* (O'Reilly, 2015); *Spacetimes with Semantics* (`arXiv`); *On the Scale Dependence and Spacetime Dimension of the Internet with Causal Sets* (`arXiv`); *Agent Semantics, Semantic Spacetime, and Graphical Reasoning* (`arXiv:2506.07756`, June 2025); `SSTorytime` open-source Semantic Spacetime graph library (GitHub).
- Burgess, M. & Couch, A. Weak transitivity / quasi-transitivity in Semantic Spacetime graphs (`ResearchGate`, `arXiv`).
- Dolstra, E. (2006) *The Purely Functional Software Deployment Model*; Lampson, B. (1971) *Protection*; Fischer, Lynch & Paterson (1985); Gilbert & Lynch (2002).
