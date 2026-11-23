---
id: RES-0013
title: Deep Rival-Theory Comparative Audit & AWS Cedar Verification-Guided Development Blueprint (Phase 2B)
type: research
status: active
created: 2026-11-24
updated: 2026-11-24
domain: foundations
tags: [research, phase-2b, aws-cedar, cedar-spec, biscuit, macaroons, tuf, in-toto, calm-theorem, crdt, provenance-semirings, operads, differential-testing, lean4, quint]
assumptions: [A-001, A-002, A-004, A-005, A-006]
summary: Deep primary-literature comparative audit testing ADR-0002..ADR-0006 against rival formal frameworks (AWS Cedar, Biscuit/Macaroons, TUF/in-toto, Hellerstein's CALM Theorem, Spivak/Fong Operads, Green/Tannen Provenance Semirings) — uncovering 4 major theoretical upgrades (Cedar forbid-dominates-permit, Biscuit offline public-key attenuation, TUF rollback/freeze/mix-and-match defense closing a real C3 hole, and CALM logical monotonicity iff boundary).
---

<!-- abstract:start -->
## Executive Abstract

Executes **Workstream 2B-1** of Phase 2B: a rigorous comparative audit pitting our Promise Theory + Semantic Spacetime baseline ([`ADR-0002`](../adrs/ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md)–[`ADR-0006`](../adrs/ADR-0006-foundational-corollaries-lifecycle-stratification-and-budgets.md)) against six landmark formal-methods and distributed-systems frameworks, plus a deep architectural study of **AWS Cedar's `cedar-spec` Verification-Guided Development (VGD)** methodology (OOPSLA 2024). This comparative audit directly uncovered **four high-impact mathematical upgrades** (including one genuine security vulnerability in `ADR-0005` `C3`!):
1. **AWS Cedar (`cedar-spec`) + Biscuit → Upgrading `L3+` (`ADR-0004`)**: Adopt Cedar's **Default-Deny + `forbid`-overrides-`permit` + Order-Invariance** semantics over our Boolean attribute/group lattice (so global safety forbids can never be overridden by local permits) AND Biscuit's **Offline-Verifiable Monotonic Public-Key Attenuation** law for decentralized capabilities.
2. **TUF (The Update Framework) + in-toto → Closing a Real Security Hole in `C3` (`ADR-0005`)**: Pure signature checks on Git + cache are still vulnerable to **Rollback (Downgrade)**, **Freeze**, and **Mix-and-Match** attacks from a compromised mirror! Upgrading `C3` with monotonic local epoch counters, freshness staleness bounds, and signed snapshot/closure roots closes all three attacks.
3. **Hellerstein & Alvaro's CALM Theorem → Exact Mathematical Criterion for `S2+` (`ADR-0004`)**: Grounding coordination-free vs. coordinated state in **Logical Monotonicity (Join-Semilattices)** gives a provable *if-and-only-if* law separating monotonic state (caches, backup chunks, append-only `FOLLOWS` events) from non-monotonic state (Vaultwarden DB, Git `main` ref) requiring single-writer serialization or explicit conflict-preserving lattices.
4. **Spivak & Fong Operads + Green/Tannen Provenance Semirings → Formalizing `ADR-0002`/`E3`**: Identifies Dressed Superagents + Boundary-First Stratification as an **Operad of Nested Wiring Diagrams** (guaranteeing associative interior substitution) and grounds SST $\gamma(3,4)$ weak-transitivity queries in **Provenance Semirings / Stratified Datalog** (enabling exact *Why-Provenance* without recursive blowup).
<!-- abstract:end -->

# RES-0013: Rival-Theory Comparative Audit & AWS Cedar VGD Blueprint

---

## 1. AWS Cedar (`cedar-spec`, OOPSLA 2024) — Exact Verification-Guided Development Architecture

Study of `cedar-policy/cedar-spec` establishes our exact blueprint for **F3-b** (*Lean 4 Verified Oracle + Rust Production Engine + Differential Testing*):

1. **Minimal Pure Definitional Model (`Lean 4`, zero Mathlib)**:
   - Lean 4 contains the clean, executable mathematical semantics (~10× smaller than production Rust), proving core unbounded meta-theorems (soundness, order-invariance, `forbid`-dominance, non-escalation, Blast-Radius completeness, non-piercing substitution).
2. **High-Performance Idiomatic Production Engine (`Rust`)**:
   - Rust implements the production CLI, parsers, SST query engine, onboarding, and fast repo checks with full ecosystem ergonomics.
3. **Bridging Spec ↔ Implementation via Differential Randomized Testing (DRT)**:
   - Rust property/fuzz generators (`arbitrary` / randomized fleet & policy generators) produce thousands of valid + adversarial fleets, policies, and graphs.
   - Each test vector is serialized cleanly (JSON or Protobuf) and executed through **both** the compiled Lean 4 definitional model and the Rust production engine.
   - **Equivalence Assertion**: Any single divergence between Lean 4 and Rust immediately fails CI — locking the production engine mathematically to the proved specification without hand-proving every line of Rust IO/CLI code!
4. **Automated Reasoning / SMT Integration**:
   - Because the policy algebra is decidable and bounded, equivalence/non-escalation checks on policy refactorings can be discharged mechanically (directly in Lean 4 or via `z3` SMT!).

---

## 2. Comparative Audit Against Five Rival Formal Frameworks

### 2.1 Authorization & Capabilities: `L3+` vs. AWS Cedar, Biscuit & Macaroons

| System | Paradigm | Strengths | Lesson / Upgrade Folded Into `nixconf` v2 (`L3+`) |
| :--- | :--- | :--- | :--- |
| **AWS Cedar** | Server/Static ABAC (`permit` / `forbid` + Default-Deny) | Mathematically analyzable; **`forbid` strictly overrides `permit`**; proved order-independent in Lean 4. | **UPGRADE 1a**: Formalize `L3+` Boolean Set-Algebra policies as **`Default-Deny` + `permit` + `forbid`-overrides-`permit`**! Global safety guards (e.g., `forbid (posture:roaming-stealable ∪ actor:ai-agent ∪ posture:ephemeral)` on production-core secrets) can **never** be bypassed by any stray local `permit`! |
| **Biscuit** | Decentralized Ed25519 + Datalog Capability Token | **Offline public-key verification** + **cryptographically monotonic offline attenuation** (append-only restricting blocks; never widens authority). | **UPGRADE 1b**: Formalize `L3+` delegated capabilities with the **Monotonic Offline-Verifiable Attenuation Law**: any holder may narrow a capability offline without contacting a central mint, and verification needs only public keys (preserving offline survivability `T4`!). |
| **Macaroons** | Symmetric Chained-HMAC Capability Token | Lightweight caveats, fast symmetric crypto. | **Rejected as primary multi-party model**: Requires shared symmetric root secret for verification (weaker multi-party isolation than asymmetric public-key Biscuit-style attenuation). |

---

### 2.2 Supply-Chain & Update Security: `C3` vs. TUF & in-toto *(CLOSES A REAL SECURITY HOLE!)*

| Attack Vector | Naive `C3` (Signed Git + Signed Cache Only) | TUF + in-toto Defense | Upgrade Folded Into `C3` (`ADR-0005`) |
| :--- | :--- | :--- | :--- |
| **Rollback / Downgrade Attack** | **VULNERABLE!** Compromised mirror serves an *older* validly signed commit with a known Vaultwarden CVE! | Monotonic version/epoch counter tracked locally by client (`reject epoch < local_epoch`). | **UPGRADE 2a**: Hosts maintain a local **monotonic calibrated epoch counter**; automated `C3` pull rejects any target with `epoch < current_epoch` (explicit local auto-rollback on failed self-assessment of a *newly tried* $g_{n+1}$ remains valid, and explicit signed human break-glass override is auditable). |
| **Freeze Attack** | **VULNERABLE!** Compromised mirror/MITM indefinitely replays yesterday's valid commit so security patches never arrive! | Short-lived signed `Timestamp` / freshness expiration window. | **UPGRADE 2b**: `C3` calibration includes a **freshness / max-staleness window ($\Delta t$)** assessed by `E3` ($\alpha$ alerts loudly if no fresh signed calibration heartbeat arrives within $\Delta t$, even if existing services stay up!). |
| **Mix-and-Match Attack** | Partially mitigated by Nix derivation hashes, unless top-level closure mapping is unsigned. | Signed `Snapshot` binding exact version → exact cryptographic hashes of all targets. | **UPGRADE 2c**: Calibrated Reference binds a single **signed Snapshot Manifest** (`commit + monotonic epoch + timestamp → exact per-host Nix closure store paths`). |
| **Compromised Builder** | Relies solely on trusted CI runner key. | **in-toto** step attestations + reproducible builds. | **Note for Phase 3**: Track per-step provenance (`PR → Check → Build → Cache`) in SST `FOLLOWS` edges and support reproducible/independent verification where critical. |

---

### 2.3 Distributed State Consistency: `S2+` vs. CALM Theorem & CRDTs

Hellerstein & Alvaro's **CALM Theorem** (*Consistency As Logical Monotonicity*) proves:
> *A distributed program has a consistent, coordination-free implementation **if and only if** it is logically monotonic (forms a join-semilattice $(L, \sqcup)$: commutative, associative, idempotent).*

- **UPGRADE 3 (Grounding `S2+` in CALM)**:
  - Gives our open composable state traits a **sharp mathematical iff boundary**:
    1. **Monotonic / Join-Semilattice State** (Nix binary caches, content-addressed backup chunks, append-only SST `FOLLOWS` logs) → **provably safe for coordination-free multi-agent replication across arbitrary partitions**!
    2. **Non-Monotonic State** (mutations/deletions in Vaultwarden SQLite, Git `main` ref updates, exclusive mounts/ports) → **provably requires coordination**, resolved in our intermittent fleet via either **Single-Authoritative-Writer serialization** (`astrolabe` owns Vaultwarden DB; GitHub `main` owns canonical branch ref) OR **Explicit Conflict-Preserving Lattices** (e.g., Syncthing conflict copies turning concurrent edits into a monotonic set of sibling versions!).

---

### 2.4 Composition & Provenance: Promise Theory / SST vs. Operads & Provenance Semirings

1. **Operads & Wiring Diagrams (Spivak & Fong)**:
   - Mathematically confirms that our **Dressed Superagents (`ADR-0002`) + Boundary-First Stratification (`C2`) + `P-Dual` (`ADR-0003`)** form a **Typed Operad of Nested Wiring Diagrams** — directly justifying our Lean 4 **Operadic Interior Substitution Theorem** (substituting an interior sub-diagram while preserving boundary types $\Pi_{\text{ext}}$ is strictly associative and externally invariant!).
2. **Provenance Semirings (Green, Karvounarakis, Tannen 2007) & Stratified Datalog**:
   - Grounds **SST $\gamma(3,4)$ Weak-Transitivity (`E3`)** in positive relational algebra over commutative semirings $(K, +, \cdot, 0, 1)$, giving mathematically sound **Why-Provenance** (*exact minimal explanation of why a host rebuilds, why an alert traces to a commit, or why a policy denied access*) with guaranteed termination over finite graphs!

---

## 3. Summary of Phase 2B Formalization Plan (Moving Immediately to `EXP-0005`)

1. **Workstream 2B-1 *(Complete in `RES-0013`)*:** Rival-theory comparative audit + AWS Cedar VGD blueprint.
2. **Workstream 2B-2 *(Next — `EXP-0005`)*:** Empirical micro-benchmark of `lean4 4.35.0` (pure zero-Mathlib proof + native binary build & runtime), `quint 0.33.1` (distributed `C3` + TUF rollback-attack model checking), and **Rust ↔ Lean 4 Differential Testing** in `/tmp`!
3. **Workstream 2B-3:** Complete **Lean 4 formal library & machine-checked proofs** + **Quint/TLA+ distributed protocol models** + **Rust Differential Reference Harness** committed cleanly under `architecture/formal/`.
4. **Workstream 2B-4:** Publication-grade **Formal Mathematical Paper** (`architecture/paper/FOUNDATION-PAPER.md`) unifying all definitions, theorems (cross-linked to Lean 4 & Quint), rival-theory comparisons, corollaries, and Phase 3 engineering contracts!
