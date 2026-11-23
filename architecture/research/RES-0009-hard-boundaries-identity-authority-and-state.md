---
id: RES-0009
title: Decision 3 Analysis — Hard Boundaries: Cryptographic Identity, Lampson Authority & Proper-Time State Ownership
type: research
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [research, decision-3, identity, authority, lampson, capabilities, acl, trust-tiers, imposition, state-ownership, cap-flp, impermanence, proper-time]
assumptions: [A-004, A-005]
summary: Derives Decision 3 on top of ADR-0002 + ADR-0003 by colliding Promise Theory's Imposition Law and Proper Time against adversarial security (T2) and CAP/FLP state durability (T4), analyzing Fork 3a (L1 Static ACLs vs L2 Pure Capabilities vs L3 Dual-Layer Root Identity + Attenuated Capabilities + Trust Tiers) and Fork 3b (S1 Implicit Filesystem vs S2 Mandatory State-As-Promise Taxonomy vs S3 Pure Stateless).
---

<!-- abstract:start -->
## Executive Abstract

Derives **Decision 3 — Hard Boundaries: Cryptographic Identity, Lampson Authority & Proper-Time State Ownership** on top of [`ADR-0002`](../adrs/ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md) and [`ADR-0003`](../adrs/ADR-0003-promise-algebra-scoped-binding-and-boundary-projection.md). Demonstrates why Identity, Authority, and Durable State form a single coupled physical layer at any exposed Agent boundary $\Sigma$: the *only* parts of `nixconf` not reconstructible from Git are (1) root cryptographic private keys and (2) mutable stateful data surviving across proper time (`FOLLOWS`). Evaluates **Fork 3a (Authority Across Boundaries $\Sigma$)** comparing Pure Static Identity ACLs (**L1**), Pure Dynamic Object Capabilities (**L2**), and Dual-Layer Offline Root Identity + Scoped Attenuated Capabilities + Mechanical Compromise Trust Tiers (**L3**); and **Fork 3b (Proper-Time State Ownership & CAP/FLP)** comparing Implicit Host Filesystems (**S1**), Mandatory Agent-Declared State-As-Promise Taxonomy (**S2**: `Reconstructible`, `Ephemeral`, `Durable-Local` single-writer, `Shared` with explicit distributed consistency class), and Pure Externalized Statelessness (**S3**).
<!-- abstract:end -->

# RES-0009: Hard Boundaries — Identity, Authority & Proper-Time State Ownership (Decision 3)

---

## 1. Why Identity, Authority & State Ownership Are One Unified Problem at Boundary $\Sigma$

Under [`ADR-0002`](../adrs/ADR-0002-fractal-uniform-agency-and-non-piercing-boundaries.md) and [`ADR-0003`](../adrs/ADR-0003-promise-algebra-scoped-binding-and-boundary-projection.md), Promise Theory governs voluntary cooperation across fractal boundaries $\Sigma$. Now we collide that model against the two remaining physical walls from `RES-0007`:
- **Constraint T2 (Adversarial / Byzantine Reality)**: Stolen roaming devices (`x240`, Chromebook tablet), compromised public edge services (`astrolabe`), rogue PRs, or leaked tokens do *not* politely obey promises.
- **Constraint T4 (CAP / FLP & State Over Proper Time)**: Almost everything in `/nix/store` is timeless and bit-for-bit reconstructible from Git. The **only two irreplaceable things** that persist across an agent's proper time (`FOLLOWS`) are:
  1. **Cryptographic Root Identity** (private keys proving who owns boundary $\Sigma_A$), and
  2. **Mutable Stateful Data** (databases, user files, backup repositories, external SaaS state).

In Promise Theory, an uninvited exterior action is an **Imposition ($E \xrightarrow{!x} A$)**, which is rejected unless $A$ holds an explicit acceptance promise ($A \xrightarrow{-x \mid \text{guard}} E$). Under T2 + T4, that guard MUST be enforced by **hard cryptography & kernel boundaries** (Lampson's Access Matrix) — and *who may mutate durable state* is simultaneously an Authority invariant and a CAP/FLP single-writer invariant.

---

## 2. Fork 3a — Cryptographic Identity & Authority Across Exposed Boundaries ($\Sigma$)

When an exterior agent $E$ (roaming laptop, AI agent, CI runner, Live USB installer, public HTTP client, or peer host) crosses boundary $\Sigma_A$ to read secrets, trigger deployment, push code, mount storage, or run remote builds, how is authorization modeled?

### Option L1 — Pure Static Identity ACLs *(Ambient Identity)*
- **Mechanics**: Each long-lived agent holds a static cryptographic keypair; each resource/boundary maintains a static ACL mapping `Identity → Permissions` (e.g., static host-key secret lists, `authorized_keys`, firewall/mesh ACLs).
- **Pros**: Trivially auditable statically; **100% offline-capable** (zero runtime dependency on an online auth server during boot, rescue, or train travel — honors `B` & `T4`).
- **Cons**:
  - **Broad Blast Radius & Confused Deputy**: Compromising one process under an ambient host/user identity inherits every ACL granted to that identity.
  - **Poor Ephemeral Delegation**: Hard to grant narrow one-off or scoped authority (an AI agent pushing *only* to `nixconf`, a Live ISO onboarding *only* one new host, a CI job pushing *only* to Attic).
  - **Painful Revocation**: If a roaming Chromebook or laptop is stolen, every static secret it could ever decrypt must be manually audited and rotated.

### Option L2 — Pure Dynamic Object Capabilities *(Zero Static ACLs, Online Mint)*
- **Mechanics**: No static ACLs on resources. Every cross-boundary call presents a short-lived, unforgeable, attenuated capability token minted dynamically by an always-on authority (e.g., SPIFFE/SPIRE, HashiCorp Vault, OIDC short-lived JWTs).
- **Pros**: Minimal blast radius (stolen devices auto-expire in minutes); clean ephemeral delegation; immune to Confused Deputy.
- **Cons**: **Violates Offline Self-Sufficiency (`T4`, `QA-07`) & Low Maintenance (`D`)!** An always-on HA Token Mint creates a catastrophic bootstrap deadlock during impermanent-root cold boots, total VPS outages, Live USB recovery, or offline laptop use.

### Option L3 — Dual-Layer Root Identity + Attenuated Capabilities + Mechanical Trust Tiers *(Recommended)*
- **Mechanics**: Combines L1's offline survivability with L2's least-privilege containment using three hard laws on Boundary $\Sigma$:
  1. **Offline-Capable Cryptographic Root Identity (Minimal Bootstrap ACLs Only)**: Every situated long-lived boundary (Host, Human Admin, Repo/Mirror) has a cryptographic keypair as its immutable Name. Static offline ACLs are permitted **strictly** for the irreducible offline/bootstrap core (a host's own boot/runtime secrets, mesh identity, break-glass human recovery) — *never* ambient fleet-wide admin rights.
  2. **Scoped / Attenuated Capabilities for All Active Delegation & Sub-Boundaries**: Crossing a boundary for delegated work — AI agents (`agy` deploy key scoped to one repo + systemd `InaccessiblePaths`), CI cache writers, automated update bots (PR-only, never direct `main` push), Live ISO single-host onboarding tokens, or process-level service credentials — MUST use a **narrow, revocable, least-privilege Capability** rather than inheriting the parent's ambient identity.
  3. **Mechanical Compromise Trust Tiers on Boundaries $\Sigma$**: Every situated Agent declares its physical **Compromise Trust Tier**, for example:
     - `T0: Offline-Root` *(human hardware/master recovery keys — never stored unencrypted on any networked host)*,
     - `T1: Hardened-Dedicated` *(24/7 VPS `astrolabe`, physically secured server)*,
     - `T2: Roaming-Personal` *(stealable laptops/tablets `x240`, ZenBook, TUF, Chromebook — full-disk encrypted, but physically capturable)*,
     - `T3: Bounded-Autonomous` *(AI agents, CI runners, automated update bots — zero production secret access, PR-gated mutations)*,
     - `T4: Ephemeral-Untrusted` *(Live USB ISO, public internet clients, unverified PRs)*.
     - **Hard Invariant**: Secret/authority promises declare a **minimum required Trust Tier** — attempting to statically grant a `T0`/`T1` secret or direct-push authority to a `T2`/`T3`/`T4` boundary is a **static check failure**!

---

## 3. Fork 3b — Proper-Time State Taxonomy & CAP/FLP Ownership Law

Every piece of data inside any Agent falls into **four irreducible persistence classes**:

| State Class | Physical Definition | Loss Cost | CAP / FLP Rule |
| :--- | :--- | :--- | :--- |
| **`Reconstructible`** | Pure outputs derived from source + pins (`/nix/store`, configs, binaries) | **Zero** (rebuild/refetch) | Stateless / content-addressed |
| **`Ephemeral`** | Runtime scratch, caches, RAM, `/tmp`, WAL buffers, Live ISO overlay | Performance only (safe to wipe on reboot) | Local to current boot/process |
| **`Durable-Local`** | Irreplaceable single-owner state (`vaultwarden` DB, `lldap`, host private keys, user work docs) | **Catastrophic** if lost | **Strict Single Authoritative Writer**; requires local `Hard` `-b: durable-volume` + `Soft` backup promise |
| **`Shared`** | Multi-agent state crossing network partitions (Git `main` + mirror, Attic cache, shared storage slices, telemetry) | High to medium | **MUST declare explicit distributed consistency mode**: *(a) Single-Primary + Async Replica/Mirror*, *(b) Content-Addressed / Append-Only Monotonic (CRDT)*, or *(c) Eventual Sync with Explicit Conflict Surfacing* |

### Competing Architectural Models for State Governance

- **State Model S1 — Implicit Host-Owned Filesystem *(Conventional NixOS)***:
  - Services write implicitly to `/var/lib/...`; impermanence bind-mounts and backup include-lists are maintained manually in separate host files.
  - **Pros**: Zero upfront state declarations in service agents.
  - **Cons**: **Structural data-loss hazard (`B` Reliability failure)**. Forgetting to register a new stateful service in impermanence or backups causes silent permanent data loss on reboot; deploying a stateful service to an ephemeral `Live-ISO` compiles cleanly and silently destroys data on shutdown.

- **State Model S2 — Mandatory Agent-Declared State-As-Promise *(Recommended)***:
  - Every Agent that owns non-reconstructible mutable state MUST emit a typed `-b` state promise specifying its **Class** (`Ephemeral`, `Durable-Local`, or `Shared(mode)`), **Backup/RPO Policy**, and **Owner**.
  - **How everything composes automatically via `ADR-0003`**:
    - Impermanence/volume agents (`Exclusive` `1:1`) bind automatically to every `Durable-Local` state promise (`O(N+M)` — zero forgotten bind-mounts!).
    - Backup agents (`Broadcast` `1:N`) bind automatically to every `Durable-Local` promise declaring backup policy (emitting a `Soft` conditional promise `+b: backed-up(rpo) | target-reachable` + assessment probe $\alpha$!).
    - Deploying `vaultwarden` (`-b: durable-volume`) into a `Live-ISO` (which only provides `Ephemeral` storage) triggers an **immediate static compile-time error**!
    - External platforms (GitHub, B2, DNS, Tailscale control plane) are modeled uniformly as exterior Agents with `Shared(Single-Primary + Async Mirror)` or `Soft` reconciled state, never pretending external APIs are synchronous local filesystems.
  - **Trade-off**: Requires wrapping upstream stateful NixOS services with explicit state declarations (plus an inspection/VM audit catching undeclared persistent writes outside declared volumes).

- **State Model S3 — Pure Stateless Agents + Mandatory External Data Stores *(Cloud-Native Extreme)***:
  - Forbid local durable state inside application agents entirely; force all state into external DB/object-store clusters.
  - **Pros**: Application nodes become purely stateless.
  - **Cons**: Violates `AUD-0003`/`AUD-0004` resource limits (11 GiB VPS, offline laptops, RPi) and `D` (low maintenance) by forcing heavy external cluster machinery onto simple local-first services (`vaultwarden` SQLite, `lldap`, desktop user files).

---

## 4. Preview of What Decision 3 Unlocks for Decision 4
Once Decision 3 fixes **Hard Boundaries** (Identity, Lampson Authority/Trust Tiers, and Proper-Time State Ownership), **Decision 4 (the final foundational decision)** completes the baseline architecture by deriving **Spacetime Dynamics**: how Semantic Spacetime's $\gamma(3,4)$ graph (`CONTAINS`, `FOLLOWS`, `EXPRESSES`, `NEAR`), proper-time **Calibration & Pull Convergence** (GitOps, atomic generation transitions, rollback), **Operational Trust & Bounded-Resource Assessment** ($\alpha$, observability), and **Human + LLM Narrative Context** emerge from the exact same model.
