---
id: ARCH-CHARTER
title: Nixconf v2 Redesign Charter, Design Axioms & Quality Scenarios
type: charter
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [charter, axioms, atam, quality-scenarios, goals, fleet, constraints]
assumptions: [A-001, A-002, A-003, A-004, A-005]
summary: Defines the fundamental goals, mathematical design axioms, ATAM quality attribute scenarios, and future fleet/capability horizon — completely free of assumptions about current nixconf implementation details.
---

<!-- abstract:start -->
## Executive Abstract

This Charter fixes the **fundamental goals and evaluation criteria** for the redesign of `nixconf` while leaving *every* architectural, structural, and tooling choice open to first-principles exploration. Its north star is a **mathematically elegant, long-lived declarative infrastructure & tooling platform** where concrete hosts and capabilities emerge cleanly from a minimal set of deep, orthogonal primitives — governed by structural invariants that prevent entropy and technical debt over years of evolution. It defines six core **Design Axioms**, an **ATAM Quality Attribute Utility Tree** with concrete testable scenarios, and the **Long-Term Capability & Fleet Horizon** (spanning `x86_64` VPS, laptops, 2-in-1s, tablets, WSL, live USB, and `aarch64` Raspberry Pi, plus mesh networking, GitOps auto-updates, distributed storage/compute, deep observability, and human/LLM knowledge systems).
<!-- abstract:end -->

# Nixconf Redesign Charter

## 1. Fundamental Mission

Build a declarative system, fleet, and personal-computing platform of genuinely high engineering standard — **not** a personal pile of ad-hoc scripts, but a coherent, maintainable, evolvable tool that:

1. Expresses complex multi-host infrastructure and desktop/edge computing through **minimal, orthogonal, maximally expressive fundamental primitives**.
2. Makes **good practices, correctness, and hygiene structural invariants** enforced by the architecture itself so technical debt cannot silently accumulate.
3. Remains **fast to iterate on, easy to reason about (for both humans and AI agents), and safe to evolve over years** across heterogeneous hardware and shifting upstream ecosystems.

> **Anti-Bias & Blank-Sheet Rule**: Everything in the current repository is an empirical artifact, **not** a constraint. "Primitives" does **not** refer to `primitives/` or even necessarily to Nix — it refers to whatever irreducible foundational concepts (across one or many categories/media: config/schema languages, Rust/compiled cores, trust/identity, network, state/lifecycle, verification, etc.) emerge from first-principles analysis of the problem.

---

## 2. Calibrated Design Axioms & Priority Policy

### Priority Policy (User-Calibrated 2026-11-23)
- **Operational reliability & safety** is the non-negotiable #1 baseline (hosts stay bootable, VPS stays healthy, failures degrade gracefully and recover cleanly).
- **True Elegance as a Reconciler**: Elegance is not a vanity axis traded against reliability or maintainability — a design that feels mathematically neat while causing fragility, friction, or bloat is *not* genuinely elegant.
- **Standalone Portability First**: As many tools, wrapped applications, and capabilities as possible must be usable **standalone from anywhere** (e.g., `nix run`, non-NixOS Linux/WSL/containers), cleanly decoupled from NixOS host wiring.
- **Graceful Degradation Over Rigid Isolation**: Hosts must remain fundamentally self-sufficient for core vitality (boot, local auth/core ops), while cross-host capabilities (mesh mounts, remote builders, shared storage/compute) may temporarily pause when peers vanish — provided degradation is bounded, non-blocking, self-healing, and clearly surfaced.
- **AI-First Behind Clean Human UX**: Human-facing user interfaces remain optimized for human clarity and ergonomics; everything behind the UI boundary welcomes AI-first design (determinism, structured introspection, token efficiency, safe PR-gated autonomy).
- **Anti-Entanglement Mandate**: Current pain point explicitly flagged by the user — too many subsystems feel entangled, opaque, and fragile; v2 must be both dramatically easier to understand and far more powerful to compose.

### Core Axioms

Every architectural proposal in `rfds/` is judged against these seven axioms:

| Axiom | Statement | Anti-Pattern It Rejects |
| :--- | :--- | :--- |
| **X1 — Minimality & Orthogonality** | Primitives (across any layer or language) should be as few, fundamental, and mutually independent as possible; rich behavior must emerge from *composition*, not special-case flags baked into primitives. | Primitives handling 100 edge cases; monolithic god-abstractions. |
| **X2 — Ousterhout Depth & True Elegance** | Every abstraction must earn its existence through high `expressive power / interface surface` AND must harmonize reliability, clarity, and speed. Never wrap a clear standard interface in a shallow custom DSL or alias pile. | Premature abstraction; thin wrapper DSLs; "clever" fragility. |
| **X3 — Parnas Information Hiding & Polymorphism** | Draw boundaries around *volatile design decisions* (secret backends, home managers, proxies, storage engines, network meshes, OS targets) so components and sub-components can be swapped—or instantiated simultaneously in multiple backends—without cascading rewrites. | Hardcoded peer coupling; single-implementation assumptions leaking into consumers. |
| **X4 — Standalone Portability** | Separate portable capabilities (CLIs, wrapped apps, user configs, dev environments, verification tools) from host/OS wiring so they remain directly runnable anywhere (`nix run`, non-NixOS machines, rescue shells). | Locking reusable tools/apps inside NixOS host-only modules. |
| **X5 — Structural Enforcement (Make Bad States Unrepresentable)** | Prefer invariants enforced by types, schemas, graph/module structure, and build purity over prose conventions or after-the-fact lint hacks. Enforce uniformly across *all* layers (including auxiliary tooling and automation). | "Enforced in one directory, ignored in another"; tribal knowledge. |
| **X6 — Disciplined Standards Over Reinvention** | Build on rock-solid, well-maintained standards and tools when they solve hard problems reliably; avoid unmaintained or bloated dependencies; write clean owned implementations (e.g., pure Rust) only when the problem is crisp, core, and benefits from full control. | Not-invented-here bloat *and* careless dependency sprawl. |
| **X7 — Empirical & Graceful-Degradation Discipline** | Reliability, graceful degradation under network/peer loss, evaluation latency, binary cache isolation, and memory/storage footprint are first-class architectural properties—measured by reproducible benchmarks, not guessed. | Boot hangs on missing peers; accidental cache busting; heavyweight stacks on constrained hosts. |

---

## 3. Long-Term Capability & Fleet Horizon (Problem Boundaries)

The core primitives and system architecture MUST accommodate these real-world targets without ugly bolt-ons (even if individual hosts/services are added later):

### 3.1 Heterogeneous Fleet Taxonomy
| Target Form Factor | Architecture | Key Structural Characteristics |
| :--- | :--- | :--- |
| **Production VPS** (`astrolabe`) | `x86_64-linux` | Headless, 24/7 public edge, 6 vCPU / 11 GiB RAM + zram, impermanent root, strict resource/OOM isolation, self-hosted services. |
| **Primary ThinkPad Laptop** (`x240`) | `x86_64-linux` | Desktop GUI, battery/power-aware, Wi-Fi/roaming, local dev workstation. |
| **Asus ZenBook Duo** *(planned)* | `x86_64-linux` | Dual-screen laptop, specialized display/input/hardware quirks, workstation. |
| **Older TUF Gaming Laptop** *(planned)* | `x86_64-linux` | Hybrid GPU (dGPU/iGPU), higher thermal/compute capacity when plugged in (potential opportunistic compute/builder node). |
| **Lenovo Chromebook Tablet** *(planned)* | `x86_64-linux` or `aarch64-linux` *(TBD)* | Touch/tablet UX, constrained RAM/storage, specialized firmware/kernel/audio quirks. |
| **Raspberry Pi** *(planned)* | `aarch64-linux` | ARM64 cross-arch target! Low RAM, SD/NVMe storage, headless edge/LAN/home node, possible always-on relay/mirror/storage node. |
| **WSL Environment** *(planned)* | `x86_64-linux` | **No bootloader, no `disko`, no raw block devices, different systemd/network/interop lifecycle.** |
| **Live USB / Installer ISO** *(planned)* | `x86_64-linux` (+ `aarch64`?) | Ephemeral, read-only squashfs media, rescue + zero-friction new-host provisioning image. |

> **Architectural consequence**: Core host primitives CANNOT assume `x86_64-linux` only, CANNOT assume physical disk partitioning (`disko` / impermanence / bootloader), and CANNOT assume a single fixed desktop or server role.

### 3.2 Planned System Capabilities
1. **Mesh Networking as a First-Class Fabric**: Secure peer-to-peer connectivity across all hosts (exploring Tailscale and alternatives) enabling private admin access, cross-host telemetry, distributed compute/storage, and NAT traversal without exposing every service publicly.
2. **GitOps, Automated Updates & Repo Resilience**:
   - Source-of-truth Git workflow (e.g., GitHub PR-gated `main` for agents and automated update bots, hosts converging automatically to `main` with safe rollback).
   - Automated timely updates for security-sensitive services (e.g., Vaultwarden) and base OS inputs without manual babysitting.
   - Repository backup and potential self-hosted mirror so GitHub is never a single point of failure.
3. **Trivial Host Onboarding**: Minimal-friction commands and bootable installer media to provision, enroll secrets/mesh keys, and bring up any new host cleanly.
4. **Distributed Storage & Compute**: Thoughtful, robust utilization of idle compute and storage across the fleet (Nix builds, binary caching, storage/sync/compute substrates) that gracefully handles intermittent/mobile nodes without fragile distributed-systems failure modes.
5. **Deep Observability & Autonomous Analysis**: High-signal telemetry (metrics, logs, traces/profiles/events) within tight VPS storage/RAM constraints, powerful querying/visualization, and periodic automated agent-driven inspection (documenting system behavior, spotting anomalies/regressions, suggesting upgrades).
6. **Pure Native Tooling (Rust & Beyond)**: Clear, reproducible, cache-friendly method for writing and integrating native compiled components (especially Rust) while preserving purity and avoiding redundant tools.
7. **Human + LLM Knowledge & Documentation**: High-signal, enforced documentation across the *entire* system (including build/tooling layers), plus token-efficient, accurate context/query surfaces for LLM agents.

---

## 4. ATAM Quality Attribute Utility Tree (Testable Scenarios)

Each candidate architecture in Phases 2–4 is scored against these concrete scenarios:

| ID | Quality Attribute | Priority | Concrete Testable Scenario |
| :--- | :--- | :---: | :--- |
| **QA-01** | **Conceptual Elegance & Expressiveness** | H | A developer or LLM reading the core primitive definitions can deduce how any host, service, or cross-cutting concern composes without consulting hidden glue code; core primitives have minimal, orthogonal interfaces. |
| **QA-02** | **Component Swappability & Multi-Instance** | H | Swapping an underlying implementation (e.g., secret store, proxy, home manager, monitoring backend) — or running **two implementations concurrently** on the same host/fleet — requires zero edits to unrelated consumers. |
| **QA-03** | **Fleet & Form-Factor Portability** | H | Onboarding a radically different target (`aarch64` Raspberry Pi, WSL without bootloader/disks, or Live USB ISO) reuses the exact same core host/capability primitives without hacks or conditional sprawl. |
| **QA-04** | **Structural Invariant Enforcement** | H | Adding an undocumented component, broken schema, impure leak, or cache-busting input anywhere in the repository (including tooling/automation layers) is caught mechanically before merge. |
| **QA-05** | **Developer & Agent Iteration Speed** | H | Editing a single host or feature evaluates in <10s, triggers 0 unrelated derivation rebuilds (verified by cache-isolation checks), and lets agents navigate context with minimal wasted tokens. |
| **QA-06** | **Autonomous GitOps Safety & Currency** | M-H | Security updates (e.g., Vaultwarden) propagate via automated PR → CI verification → binary cache → host convergence, with automatic rollback and alerting if a host fails health checks. |
| **QA-07** | **Resource Efficiency & Graceful Degradation** | H | Core host vitality survives offline/peer loss without hangs or corruption; cross-host enhancements pause gracefully and self-heal on reconnect; observability/mesh fit comfortably within VPS limits (11 GiB RAM, bounded disk). |
| **QA-08** | **Long-Term Maintainability & Low Dependency Risk** | H | External dependencies are intentionally chosen, actively maintained, and cleanly bounded behind interfaces so upstream churn causes localized, low-effort updates over a 5+ year horizon. |
| **QA-09** | **Standalone Portability (`nix run` Anywhere)** | H | Portable tools, wrapped apps, user environments, and dev workflows can be invoked standalone via `nix run` / `nix shell` on any Nix-capable machine (including non-NixOS Linux/WSL) without dragging in NixOS host wiring. |
| **QA-10** | **AI Ergonomics Behind Clean Human UX** | M-H | Human UIs prioritize human clarity, while underlying interfaces provide deterministic, structured, token-efficient introspection and safe PR-gated autonomy for AI agents. |

---

## 5. Planned Research Domains (Bias-Free RFDs)

- **Phase 1 — Empirical Audit**: `audit/` (dissect current `nixconf` objectively + refine boundary constraints)
- **Phase 2 — Core Foundations**:
  - `RFD-0001`: Fundamental Ontology, Primitives & Composition Algebra
  - `RFD-0002`: Structural Invariants, Verification & Quality Enforcement
  - `RFD-0003`: Auxiliary Tooling, Language Strategy & Pure Native (Rust) Integration
- **Phase 3 — Domain Architectures**:
  - `RFD-0004`: Network Fabric (Tailscale & Alternatives) & Heterogeneous Fleet Provisioning
  - `RFD-0005`: Source of Truth, GitOps, Automated Updates & Repo Resilience
  - `RFD-0006`: Distributed Storage & Compute Substrate
  - `RFD-0007`: Deep Observability, Telemetry Storage & Autonomous Analysis
  - `RFD-0008`: Documentation & LLM Knowledge/Context Architecture
- **Phase 4 — Synthesis & ADRs**: Cross-Consistency Assessment + immutable `adrs/`
- **Phase 5 — Formal Spec & Migration**: `spec/` + safe incremental rollout plan
