---
id: RES-0003
title: Research Dossier — Core Primitives, Authoring Languages, Composition Algebras & NixOS Fleet Paradigms
type: research
status: active
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [research, nickel, cue, snix, tvix, harmonia, clan-core, wrapper-modules, flake-parts, partitions, npins, ml-modules, concepts]
assumptions: [A-001, A-002, A-003, A-013]
summary: Expansive Phase 2 literature and ecosystem survey across configuration languages (Nix, Nickel, CUE), Rust Nix implementations (Tvix/Snix/Harmonia), fleet frameworks (clan-core), standalone wrapper paradigms (nix-wrapper-modules, Hjem, system-manager), and composition/pinning models.
---

<!-- abstract:start -->
## Executive Abstract

Expansive external survey supporting `RFD-0001`, mapping the full 2025–2026 design manifold for declarative multi-host infrastructure and standalone tooling primitives without bias toward current `nixconf`. Key empirical findings: (1) **Alternative config languages** — CUE (lattice unification) lacks Turing-completeness/lazy derivations needed by `nixpkgs` (only suited to pure data validation), while Nickel (`organist`) faces a steep, still-maturing impedance bridge into 80k+ dynamic `nixpkgs` modules; (2) **Rust-Nix ecosystem (`Tvix`/`Snix`/`Harmonia`)** — library-first bytecode Nix evaluators and CAS/binary caches are maturing rapidly, reinforcing a clean split where **Nix** handles lazy build/OS fixed-points and **Rust** handles statically typed orchestration/analysis/tooling over JSON manifests; (3) **Fleet frameworks (`clan-core`)** — Clan's *Inventory + Services + Roles + Instances* model is conceptually brilliant for multi-host topology and multi-instance services, **but** imposes heavy `clan.core` lock-in, Python CLI layers, and poor fit for WSL and standalone `nix run` packages; (4) **Standalone portability (`nix-wrapper-modules`)** — treating pre-configured apps as module-evaluated standalone package derivations ("homeless dotfiles") solves `QA-09` cleanly across NixOS, WSL, and non-NixOS Linux; (5) **Pinning & partitions** — `flake-parts.partitions` isolates heavy dev inputs into sub-flake lockfiles at the cost of multi-lock maintenance, whereas standard `flake.lock` maximizes GitOps/bot/consumer interoperability over `.tack` or `npins`.
<!-- abstract:end -->

# RES-0003: Core Primitives & Composition Manifold Dossier

## 1. Authoring & Schema Languages vs Native Nix

### 1.1 Pure Nix (`nixpkgs.lib.evalModules`)
- **Strengths**: 1st-party integration with `nixpkgs` (80k+ packages, `lib.types`, `submodule`, `deferredModule`, `mkMerge`, `mkIf`, `mkOverride`), zero translation boundary, lazy fixed-point resolution.
- **Weaknesses**: Dynamically typed (errors caught at evaluation time rather than static compile time), easy to create subtle infinite recursion in fixed-points if module option names depend on derived `config`, poor ergonomics for complex imperative orchestration, graph traversal, HTTP APIs, or structured CLI tools.

### 1.2 Nickel (`nickel-lang` + `organist`)
- **Strengths**: Gradual typing + first-class design-by-contract + clean record merging semantics designed by Tweag explicitly as a typed successor to Nix-the-language.
- **Weaknesses for NixOS (2025–2026)**: NixOS modules deeply rely on lazy `pkgs.*` derivations, `mkOverride` priority lattices, and dynamic module merging. Bridging Nickel into `nixpkgs` via `organist` adds a heavy external translation layer with small community adoption and high maintenance/dependency risk (violating priority `B > E > D`).

### 1.3 CUE (`cuelang.org`)
- **Strengths**: Mathematically gorgeous value-type unification lattice (commutative, associative, idempotent); unbeatable for validating pure structured data schemas.
- **Weaknesses for NixOS**: Deliberately non-Turing-complete (cannot express derivations, lazy package closures, or arbitrary higher-order module transformations). Can only serve as an auxiliary pure-data validator (which Rust `serde` + JSON Schema or Nix `lib.types` already covers without adding a third language toolchain).

### 1.4 Hybrid Split: Pure Data + Native Nix Module Core + Statically Typed Rust Control Plane
- **Core insight**: Separate the system cleanly along its natural mathematical seam:
  - **Pure Static Data** (Fleet Topology, Node Inventory, Capabilities/Manifests): Evaluates in milliseconds with zero `nixpkgs` dependency; serializes cleanly to JSON with a strict schema.
  - **Lazy Build & OS Configuration** (Nix): Uses native `nixpkgs.lib.evalModules` + NixOS + `nix-wrapper-modules` where Nix has zero impedance mismatch.
  - **Typed Imperative Control Plane & Analysis** (Rust): Consumes the exported JSON topology/manifests for CLI UX, graph/impact analysis, verification orchestration, provisioning, profiling, secret reconciliation, and LLM/MCP introspection — replacing fragile Bash wrappers and 5k-LOC pure-Nix graph code.

---

## 2. Rust-in-Nix Ecosystem (`Tvix`, `Snix`, `Harmonia`)
- **Tvix / Snix**: Modular, library-first Rust re-implementations of the Nix evaluator (bytecode VM instead of C++ AST walker), Content-Addressed Storage (CAS), and Landlock/seccomp-hardened microVM rootfs builders. Note: Still evolving as full drop-in replacements for production NixOS fleet evaluation (remember our earlier evaluator benchmarks where Classic Nix 2.34.9 beat Determinate Nix & Lix on our flake), **but** valuable to track as future library/evaluator backends if our architecture keeps clean standard flake boundaries!
- **Harmonia**: High-performance Rust Nix binary cache server (alternative to Attic/Cachix, serving `/nix/store` directly with HTTP range requests; unlike Attic, does not include content-defined chunking + multi-tenant push API out of the box).
- *(Detailed Rust build purity — `rustPlatform` vs `crane` vs `naersk` vs `fenix` vs Cargo workspaces — is investigated deeply in `RFD-0003`.)*

---

## 3. Fleet Composition Paradigms in the NixOS Ecosystem

### 3.1 `clan-core` (`clan.lol`) — Valuable Ideas vs Adoption Trade-offs
- **Brilliant concepts to learn from**:
  - Explicit **Inventory** separating fleet topology & hardware metadata (`nixos-facter`) from service logic.
  - **Services + Roles + Named Instances**: First-class multi-instance deployments (e.g., two Matrix or backup instances on one fleet) mapped onto machines by role.
  - **Vars / Generators**: Declarative secret generation/distribution layered over `sops-nix`.
- **Why adopting `clan-core` directly conflicts with our Charter**:
  - Heavy **`clan.core` lock-in**: Deeply couples machine modules, inventory format, Python CLI, and secrets into Clan's evolving API (migration back to vanilla NixOS is non-trivial).
  - **Poor fit for WSL & standalone `nix run` (`QA-03`, `QA-09`)**: Designed around bare-metal/VM `nixos-anywhere`/`disko` fleets, not WSL tarballs or standalone wrapped packages for non-NixOS environments.
- **Verdict**: Adopt the *mathematical concepts* (static Topology/Inventory + Named Multi-Instance Capabilities + Roles), **without** taking on `clan-core`'s framework lock-in or Python dependency layer!

### 3.2 Module-System Polymorphism: ML Modules vs Singleton Typeclasses
- **Why v1 hit 1:1 lock-in**: Modeling contracts as global singletons (`config.reverse-proxy`, `config.secrets`, `config.storage`) is isomorphic to global singleton typeclasses — two providers for the same contract inevitably collide.
- **First-principles solution (ML Signatures/Functors + Daniel Jackson Concepts & Synchronizations)**:
  - Separate **Workload Intent** (pure declarative facts: units, stateDirs, endpoints, secrets, metrics, resources) from **Named Capability Provider Instances** (`0..N` per capability, passed as open first-class modules/functors rather than a closed enum).
  - Each active Capability Provider owns a **Synchronization** projecting matching Workload Intents into concrete OS config — reducing wiring complexity from $O(N \times M)$ to $O(N + M)$ and making multi-provider execution, sub-component swapping, and mock-provider testing all instances of the exact same mechanism.

---

## 4. Standalone Portability & User Layer (`QA-09`)

- **`nix-community/nix-wrapper-modules`** (evolution of `lassulus/wrappers`):
  - Applies Nix's module system directly to **packages** — yielding immutable, self-contained, pre-configured executable derivations (preserving `.override` / `.overrideAttrs`) runnable via `nix run` on NixOS, WSL, macOS, containers, or any foreign Linux distro with zero home-directory symlink farm!
- **Thin User-Space File Layer (`hjem` vs `home-manager` vs `system-manager`)**:
  - For tools that cannot be cleanly wrapped (or desktop dotfiles/user systemd units): `hjem` stays minimal on NixOS, while `home-manager` (or standalone wrapper profile) supports non-NixOS Linux/Crostini/WSL.
  - **Key principle ("Artifact-First")**: Build every portable app/CLI as a standalone wrapped `Artifact` FIRST; OS/home modules merely include or bind that exact artifact instead of duplicating config logic!

---

## 5. Orchestration & Input Pinning Trade-offs

- **Raw `flake.nix` + `lib.evalModules` vs `flake-parts` vs `flake-parts.partitions` vs `blueprint`**:
  - `blueprint`: Great for tiny repos, outgrown by multi-substrate polymorphic fleets.
  - Raw `flake.nix` + explicit `lib.evalModules`: Zero framework dependency, explicit imports (eliminates `import-tree` + 226 `internal.*` globals!), tiny boilerplate (~40 LOC helper for `forAllSystems`), 100% transparent to both humans and LLMs.
  - `flake-parts` (+ optional `partitions`): Standard ecosystem module system for flakes; `partitions` isolates heavy dev/CI inputs into a sub-flake `dev/flake.lock`, at the cost of managing two `flake.lock` files and occasional `nix flake check` friction.
- **Standard `flake.lock` vs `.tack/` vs `npins`**:
  - Standard `flake.lock` is universally understood by `nix run github:...`, `nix flake update`, `comin`, `system.autoUpgrade`, Renovate/Dependabot, GitHub Actions, and every NixOS user.
  - `.tack/` offers clean recursive `[all_follow]` and commit `[signers]`, **but** breaks standard `nix flake metadata` / `nix flake update` / automated PR bots and depends on a young 1,082-LOC vendored Nix loader (`manic-systems/tack`) — conflicting with `B > E > D` (Reliability & Low Dependency Risk) and GitOps goals (`RFD-0005`).

---

## 6. Sources Consulted (2026-11-23)
- `clan.lol` / `clan-core` architecture docs & NixOS Discourse tradeoffs (2025–2026)
- Tweag Nickel (`nickel-lang.org`), `organist`, and CUE (`cuelang.org`) NixOS comparisons
- Tvix, Snix, and Harmonia Rust-Nix ecosystem documentation & architecture talks (2025–2026)
- `nix-community/nix-wrapper-modules`, `lassulus/wrappers`, `feel-co/hjem`, `numtide/system-manager`
- `hercules-ci/flake-parts` partitions documentation, `numtide/blueprint`, `andir/npins`
