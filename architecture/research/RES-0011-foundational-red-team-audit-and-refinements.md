---
id: RES-0011
title: Adversarial Cross-Consistency Red-Team Audit of the Foundational Architecture (ADR-0002..ADR-0005)
type: research
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [research, red-team, cross-consistency, cca, gaps, opportunities, genesis, stratification, resource-budgets, verification, user-space, epistemic-zoom]
assumptions: [A-001, A-002, A-004, A-005, A-006, A-013]
summary: Brutal adversarial red-team audit across ADR-0002..ADR-0005 identifying 4 genuine architectural gaps (Agent Genesis/Revocation/Break-Glass Lifecycle, Boundary-First Stratification at Fleet scale, Ousterhout/Foreign-Agent Wrapping Discipline, Quantitative Budgeted Capacity & Power Conditions), 1 subtle paradox resolution (Operational Non-Piercing vs Authorized Epistemic Zoom), and 2 major unification opportunities (Portable User-Space Boundary, Unified Assessment Probes = Tests + Rollback Gate + Live Observability).
---

<!-- abstract:start -->
## Executive Abstract

Conducts an adversarial Cross-Consistency Assessment (CCA) and stress-test across the four ratified foundational decisions ([`ADR-0002`](../adrs/ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md)–[`ADR-0005`](../adrs/ADR-0005-triadic-calibrated-pull-and-sst-epistemic-spine.md)) against every constraint in [`CHARTER.md`](../CHARTER.md) and [`AUD-0001`](../audit/AUD-0001-primitives-modules-entanglement.md)–[`AUD-0004`](../audit/AUD-0004-fleet-and-capability-constraints.md). Surfaces **7 concrete, non-trivial findings** before entering Phase 3:
- **4 Genuine Gaps**: **(1) Agent Lifecycle Boundary Transitions** (Genesis $t=0$ enrollment from untrusted `Live-ISO`, post-compromise revocation/rotation for stolen devices, zero-infra break-glass recovery); **(2) Boundary-First Stratification Theorem** ($\Pi_{\text{ext}}(S) \perp \text{Interior}(S)$ closing a hidden mutual-recursion & Nix cache-busting trap at `Fleet` scale); **(3) Ousterhout Promise-Depth & Foreign-Agent Wrapping Rule** (handling hardware quirks like ZenBook OLED / TUF NVIDIA PRIME and messy upstream NixOS modules without shallow wrapper DSL bloat); and **(4) Quantitative Resource Envelopes & Budgeted/Additive Capacity** (4th binding semantics for finite RAM/CPU/disk + dynamic power/thermal conditions enabling safe RPi/VPS caps and opportunistic TUF laptop builds).
- **1 Logical Paradox Resolved**: **(5) Operational Non-Piercing vs. Authorized Epistemic Zoom** (reconciling `ADR-0002` strict boundary opacity with `E3` human/AI debugging across `CONTAINS`).
- **2 High-Leverage Unification Opportunities**: **(6) Portable User-Space Boundary** (decoupling user CLI/apps/env from OS host wiring so `nix run` anywhere, headless servers, and desktops unify cleanly); and **(7) Tri-Purpose Assessment Probes ($\alpha$)** (declaring assessment & conditional-degradation probes *once* to power pre-merge VM/fault-injection tests, `C3` auto-rollback gates, and `E3` live observability simultaneously).
<!-- abstract:end -->

# RES-0011: Adversarial Red-Team Audit of `ADR-0002`..`ADR-0005`

---

## 1. Purpose of This Audit
Before freezing our Promise Theory + Semantic Spacetime baseline and entering Phase 3 (concrete engineering RFDs), we attempted to **break** our own four ADRs against:
1. Cross-ADR consistency (CCA: do any two ADRs contradict or create hidden recursion?),
2. Physical realities of Nix evaluation, Linux kernels, CAP/FLP, and adversarial compromise, and
3. Every fleet target and capability in `CHARTER.md` (VPS, `x240`, ZenBook Duo, TUF dGPU, Chromebook tablet, `aarch64` RPi, WSL, Live ISO, standalone `nix run`, mesh, GitOps + mirror, distributed storage/compute, bounded-RAM observability, Rust tooling, Human+AI docs).

---

## 2. Four Genuine Architectural Gaps Discovered

### Gap 1 — Agent Lifecycle Boundary Transitions: Genesis ($t=0$), Revocation & Zero-Infra Break-Glass Recovery
- **The Hole**: `ADR-0004` (`L3+`) and `ADR-0005` (`C3`) govern **steady-state** agents brilliantly — assuming each situated host already holds a cryptographic keypair, mesh identity, Boolean group membership, and access to calibrated Git + binary caches. Three critical lifecycle transitions sit *outside* steady state:
  1. **Genesis / Enrollment ($t=0$)**: Onboarding a fresh Raspberry Pi or ZenBook Duo from an untrusted `Live-ISO` (`posture:ephemeral`). By `L3+`, the ISO cannot hold master keys or production secrets — how does a brand-new Agent safely generate its root keypair, prove custody to a human operator, get registered into Git/ACLs/mesh, and transition into generation $g_0$?
  2. **Compromise Revocation & Post-Compromise Rotation ($t=\text{breach}$)**: Removing a stolen Chromebook or laptop from a Boolean group prevents *future* secret decryption, **not** secrets it already cached/decrypted before theft! Our `L3+` Boolean policy graph can compute the exact **Blast-Radius Set** (*"which secrets/capabilities was `chromebook` ever authorized to read?"*) — giving an exact mechanical rotation checklist!
  3. **Zero-Infrastructure Break-Glass Recovery ($t=\text{disaster}$)**: If both `astrolabe` (total VPS loss) and GitHub (account outage) fail simultaneously, what is the minimal offline recovery invariant (`offline-human-root` + async Git mirror + encrypted backups) guaranteeing full fleet resurrection from scratch?
- **Why Fix Now**: Trivial host onboarding (`CHARTER.md` §3.2) and operational reliability (`B`) depend directly on formalizing these three lifecycle state transitions (`Genesis`, `Revocation/Blast-Radius`, `Break-Glass`) at the foundation level.

### Gap 2 — The Boundary-First Stratification Theorem ($\Pi_{\text{ext}}(S) \perp \text{Interior}(S)$) *(Hidden Fleet-Scale Recursion & Cache-Busting Trap!)*
- **The Hole**: `ADR-0002` enforces Non-Piercing ($\Sigma$) and `ADR-0003` enforces Strict Stratification *inside* a Superagent. Now trace **two sibling Hosts inside `Fleet`** (`astrolabe` reading $\Pi_{\text{ext}}(\text{x240})$ and `x240` reading $\Pi_{\text{ext}}(\text{astrolabe})$):
  - If computing $\Pi_{\text{ext}}(\text{astrolabe})$ requires evaluating `astrolabe`'s *interior* NixOS closure, and `astrolabe`'s interior reads $\Pi_{\text{ext}}(\text{x240})$, and `x240`'s interior reads $\Pi_{\text{ext}}(\text{astrolabe})$ → **mutual infinite recursion AND quadratic Nix binary-cache invalidation**!
- **The Exact Formal Fix**: Add one crisp theorem completing `ADR-0002` + `ADR-0003`:
  > **Boundary-First Stratification Theorem ($\Pi_{\text{ext}} \perp \text{Interior}$)**: For every Dressed Superagent $S$, its exterior promise surface $\Pi_{\text{ext}}(S)$ MUST be evaluable at the **boundary stratum strictly *without* evaluating $\text{Interior}(S)$**. Conversely, evaluating $\text{Interior}(S)$ mechanically verifies conformance against $\Pi_{\text{ext}}(S)$ (strict `P-Explicit`).
  - Furthermore, prefer **runtime discovery** (e.g., mesh DNS / dynamic peer discovery) over baking volatile peer coordinates into static build-time `/etc` files whenever possible, shrinking cross-host rebuild coupling toward zero!
- **Impact**: Eliminates cross-host evaluation recursion, guarantees cache isolation (`T5` / `QA-05`), and allows instant offline fleet-topology/SST inspection without evaluating heavy OS closures!

### Gap 3 — Ousterhout Boundary Discipline & Foreign-Agent Wrapping Rule
- **The Hole**: Our fleet includes gnarly one-off hardware quirks (ZenBook Duo dual OLED/touch ACPI, TUF hybrid NVIDIA PRIME, Chromebook audio firmware, RPi device-tree) AND hundreds of upstream `nixpkgs` NixOS modules (`services.*`) that implicitly write to `/var/lib/...` or open sockets. If every single hardware flag or upstream option forced inventing a typed global Promise Type $\tau$, our Promise Algebra would bloat into a shallow custom DSL over all of NixOS — violating `X2` (Ousterhout Depth) and `D` (Low Maintenance)!
- **The Exact Formal Fix**: Add two sharp discipline laws:
  1. **When to Mint a Promise Type ($\tau$)**: Only interactions that are *shared across agents, swappable/multi-instantiable, governed by `L3+` authority, durable under `S2+`, resource-budgeted, or assessed under `E3`* warrant a typed Promise Contract. One-off substrate/hardware quirks live cleanly inside an atomic Hardware/Quirk Agent's **private Interior** (binding to `-b: substrate(...)`), never polluting the global promise vocabulary.
  2. **Foreign-Agent Wrapping Law**: Upstream NixOS modules / third-party binaries are encapsulated as **Atomic Agents** whose boundary $\Sigma$ explicitly lifts their *cross-cutting side effects* (required secrets, declared `S2+` state volumes, exposed ports/endpoints, resource envelope, and assessment hooks $\alpha$), backed by inspection/VM audits catching undeclared persistent writes or stray listeners!

### Gap 4 — Quantitative Resource Envelopes & Budgeted/Additive Capacity (`4th Binding Semantics` + Dynamic Conditions)
- **The Hole**: `ADR-0003` (`B3`) defined three qualitative binding cardinalities (`Exclusive 1:1`, `Broadcast 1:N`, `Partitioned Fan-In N:K`). Yet finite physical resources — **RAM (11 GiB VPS, 1–4 GiB RPi/Chromebook), Disk space (100 GiB VPS, SD wear), CPU/IO weights, and Power/Thermal envelopes** — obey **quantitative conservation (additive budgeting)**, NOT just `1:1` or `1:N`!
- **The Exact Formal Fix**:
  1. Recognize **`Budgeted Capacity` (`∑ demands ≤ supply` + Priority Tiering)** as a first-class promise binding law on finite resources (enforced statically against host capacity limits AND at runtime via kernel isolation/cgroups — guaranteeing `critical-edge` / Vaultwarden can never be OOM-killed by builds, observability, or AI agents!).
  2. Treat **dynamic physical posture** (`power:ac-plugged`, `thermal:nominal`, `network:unmetered`, `host:idle`) as first-class Conditions $C$ in `Soft` conditional promises — naturally unlocking **opportunistic distributed compute/builds** on the TUF gaming laptop (active only when plugged in + idle + mesh-reachable, gracefully pausing on battery!).

---

## 3. One Logical Paradox Resolved

### Finding 5 — Reconciling Operational Non-Piercing (`ADR-0002`) with Global SST Introspection (`ADR-0005` `E3`)
- **The Apparent Paradox**: `ADR-0002` forbids external agents from piercing $\Sigma_S$ to read interior sub-agents, yet `E3` lets Humans and diagnostic AI traverse `CONTAINS` across the whole system to trace root causes!
- **The Clean Resolution**: Separate **Operational Dependency Edges** from **Authorized Epistemic Zoom**:
  1. **Operational Dependencies** (build-time or runtime binding between functional Agents) are **100% strictly Non-Piercing** (only $\Pi_{\text{ext}}$ is visible — preserving swappability, security, and Nix cache isolation).
  2. **Epistemic Zoom (`CONTAINS` traversal)** by a Human or `L3+`-authorized diagnostic AI is **strictly read-only, secret-redacted, and carries zero reverse build dependency**. Better yet, starting at coarse-grained $\Pi_{\text{ext}}$ and zooming into a specific $\Sigma_S$ *only on demand* mathematically unifies Semantic Spacetime coarse-graining with our **Progressive Disclosure LLM architecture (`RES-0001`, `QA-10`)**!

---

## 4. Two High-Leverage Unification Opportunities Discovered

### Opportunity 6 — The Portable User-Space Boundary (`X4` Standalone Unification)
- **The Insight**: Where does the **Human User's environment** (CLI tools, editor, terminal, shell, git, dev tools, desktop apps) live in the `CONTAINS` tree?
- If modeled as **standalone-first wrapped Agents** (requiring *only* store packages in their base form) cleanly separated from optional **OS-integrated graphical/session Agents** (requiring `-b: linux-graphical-session` or `-b: user-home`):
  - **Random non-NixOS Linux / rescue shell**: `Standalone` Superagent supplies store packages → `nix run .#foot`, `nix run .#zed`, `nix run .#shell`, `nix run .#nixprof` work identically anywhere!
  - **Headless servers / WSL (`astrolabe`, `rpi`, `wsl`)**: Host supplies `user-home` (no graphical session) → exact same CLI/shell/editor tools cleanly attached!
  - **Graphical laptops/tablets (`x240`, ZenBook, TUF, Chromebook)**: Host also supplies `graphical-session` → full desktop + exact same wrapped apps, zero NixOS vs. Home-Manager vs. Standalone duplication!

### Opportunity 7 — Tri-Purpose Assessment Probes ($\alpha$): One Declaration Powers Tests, Auto-Rollback & Live Observability!
- **The Insight**: In `nixconf` v1, VM tests and runtime health/monitoring checks were written separately — and **degraded behavior under network/peer loss** was rarely tested.
- Under `ADR-0003` + `ADR-0005`:
  - A **Test Environment (`eval`, `inspect`, `vm`, `install`)** is simply a **Simulated Superagent Scope** swapping real exterior providers for deterministic mocks (`mock-secrets`, `fault-injectable-network`, `virtual-disko`)!
  - Therefore, the **EXACT SAME Assessment Probes ($\alpha$) and Conditional Degradation Contracts (`+b | C`)** declared on an Agent serve **three critical roles from ONE single source of truth**:
    1. **Pre-merge CI & Fault-Injection Verification**: Cut the simulated network / stop a mock peer in QEMU to *prove* degraded invariants and rollback work before merging to `main`;
    2. **Post-switch Local Auto-Rollback Gate (`C3`)**: Host evaluates the exact same survival probes $\alpha$ during $g_n \to g_{n+1}$;
    3. **Live Runtime Observability & AI Diagnosis (`E3`)**: Live assessment status feeds directly into the SST spine!

---

## 5. Verdict & Recommended Path Forward

The core 4-ADR foundation (`ADR-0002`..`ADR-0005`) is **remarkably coherent — zero fatal contradictions found!** Every single one of the 7 findings above *refines and strengthens* the existing laws without overturning any of Decisions 1–4.

Suggested clean next step before entering **Phase 3 (Concrete Realization RFDs)**:
1. Review these 7 findings with the user and ratify which ones to crystallize as **Foundational Corollary / Amendment (`ADR-0006`)** (note: Gap #1 Genesis/Revocation/Recovery and Gap #4 Resource Budgets may warrant 1–2 quick targeted clarifying choices!).
2. Once locked, compile a single crisp, self-contained **Master Theoretical Foundation Specification (`spec/FOUNDATION.md`)** summarizing the complete baseline, and transition cleanly into **Phase 3 — Engineering Realization RFDs** (starting with the highest-leverage engineering seam: Authoring Medium / Nix↔Rust Architecture & Pinning/Standalone Layout!).
