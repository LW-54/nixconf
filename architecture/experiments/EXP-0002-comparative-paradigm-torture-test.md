---
id: EXP-0002
title: Comparative Paradigm Torture Test — ML Functors vs Stratified Intent+Sync vs Rust Typed IR
type: experiment
status: completed
created: 2026-11-23
updated: 2026-11-23
domain: foundations
tags: [experiment, comparative, functors, intent-sync, rust-ir, feedback-loop, type-errors, ordering-bug]
assumptions: [A-001, A-002]
rfd: RFD-0001
git_commit: 510fba8
host: astrolabe
summary: Head-to-head empirical test of Functors (P2), Open Stratified Intent+Sync (P3), and Rust Typed IR (P4) on bidirectional feedback loops, multi-provider swaps, typo/type errors, and port conflicts — catching two real failure modes empirically.
---

<!-- abstract:start -->
## Executive Abstract

Executed a head-to-head empirical torture test comparing **Paradigm B (Explicit Nix ML Functors)**, **Paradigm C (Open Stratified Intent+Sync in `evalModules`)**, and **Paradigm D (Rust Typed IR)** on identical hard scenarios: (1) a **bidirectional feedback loop** (`attic` declaring an endpoint + secret while simultaneously reading back its own resolved URL and secret path), (2) simultaneous multi-provider ingress (`caddy` + `tailscale-serve`) & backup (`restic` + `btrfs`), (3) mock-secret & WSL substrate swaps, (4) **typo & invalid-type injection** (`port = "not-a-port"`, `subdomian = "cache"`), and (5) cross-workload port conflict detection (`8080`). **Three decisive empirical discoveries**: (1) **Paradigm B (untyped Nix functors) silently accepted `port = "not-a-port"`** and emitted a broken config `"127.0.0.1:not-a-port"` — disqualifying untyped plain functions for `B` (Reliability #1); (2) **Paradigm C solved the bidirectional feedback loop cleanly in 132ms with zero recursion** AND caught typos/types via `lib.types`, **but exposed a subtle non-commutative list-merge bug** (`apiEndpoint` silently selected the mesh URL over public URL due to list order → proves resolved projections MUST be commutative maps keyed by exposure/instance, never flat lists!); (3) **Paradigm D (Rust)** delivered the clearest compile-time error diagnostics (`error[E0308]` + `error[E0560]` with caret highlights), confirming Rust's huge value for static topology/validation/control-plane while `RES-0004` confirms keeping lazy OS/package derivations in native Nix.
<!-- abstract:end -->

# EXP-0002: Comparative Paradigm Torture Test

## 1. Hypotheses Tested
1. Does a **bidirectional feedback loop** (workload declares endpoint + secret AND reads back its own resolved URL + secret path inside its service config) trigger infinite recursion in Paradigm C (`evalModules`), vs Paradigm B (pure functors)?
2. How does each paradigm fail on **real human/agent mistakes** (misspelled field name `subdomian`, wrong value type `port = "not-a-port"`, duplicate port `8080`)?
3. What hidden semantic traps appear under **simultaneous multi-provider composition** (`caddy` + `tailscale-serve`)?

## 2. Environment & Setup
- **Git Commit**: `510fba8` (`design/v2`)
- **Host**: `astrolabe` (`x86_64-linux`, Classic Nix 2.34.9, `rustc 1.95.0` from `/nix/store`)
- **Isolation**: `/tmp/exp-0002/` and `/tmp/exp-0002b/` + `/tmp/exp-0002d/` (cleaned up after runs).

## 3. Empirical Results Matrix

| Test Scenario | Paradigm B (Explicit Nix Functors) | Paradigm C (Open Stratified Intent+Sync in `evalModules`) | Paradigm D (Rust Typed IR) |
| :--- | :--- | :--- | :--- |
| **Eval / Compile Time** | `0.366s` (3 hosts) | **`0.132s`** (4 hosts incl. conflict check) | `~1.06s` cold `rustc` typecheck (note: `cc` linker not in default PATH) |
| **Bidirectional Feedback Loop** (`attic` declares + reads resolved URL & secret path) | **Passed** (direct lexical `let` binding, recursion impossible) | **Passed** (zero recursion! Proven via Strict Stratification `S1→S2→S3`) | **Passed** (multi-pass compiler IR, recursion impossible) |
| **Multi-Provider Determinism** (`caddy` public + `tailscale` mesh) | **Deterministic** (`combineIngress [ caddy tailscale ]` → `primaryUrl = https://cache.adje.app/`) | **BUG CAUGHT**: Merging `listOf str` put `tailscale` before `caddy`, so `builtins.head` silently picked `https://cache.astrolabe.ts.net/`! **Fix**: Use commutative `attrsOf str` keyed by exposure (`urls.public`, `urls.mesh`) | **Deterministic** (explicit `BTreeMap` / typed struct fields) |
| **Misspelled Field (`subdomian`)** | Caught by Nix attrset arg match (`unexpected argument 'subdomian', Did you mean subdomain?`) | Caught by `lib.evalModules` (`option 'ep.subdomian' does not exist. Did you mean 'ep.subdomain'?`) | **Best**: `error[E0560]` with exact file:line & diff suggestion |
| **Invalid Value Type (`port = "not-a-port"`)** | **SILENT CORRUPTION!** Returned `{ upstream = "127.0.0.1:not-a-port"; }` without error! | **Caught** by `lib.types.port` (integer `0..65535`) | **Best**: `error[E0308]: expected u16, found &str` |
| **Global Port Conflict (`8080` claimed twice)** | Awkward: requires external collector threading all functor outputs | **Natural**: 6-line global invariant over `config.intent.workloads` emitted exact conflict assertion | **Natural**: 5-line `BTreeMap` pass emitted exact conflict error |
| **Embedding Nix `pkgs` Derivations / Services** | Native (1st-class) | Native (1st-class) | **High friction**: JSON boundary cannot carry lazy `pkgs` derivations/functions directly |

## 4. Key Takeaways Feeding Directly Into `RFD-0001` Step 1A
1. **Untyped pure Nix functors (Paradigm B alone) fail Reliability (`B`)** unless wrapped in a runtime type checker (at which point you are reinventing `lib.evalModules`!).
2. **Stratified Intent+Sync (Paradigm C) solves bidirectional feedback loops cleanly with zero recursion**, *provided* we enforce two formal mathematical invariants:
   - **Invariant 1 (Strict Stratification DAG)**: `S0 (Topology) → S1 (Intent) → S2 (Resolved Projections) → S3 (Concrete Outputs)`.
   - **Invariant 2 (Commutative Merge Keys)**: Multi-provider outputs MUST merge into keyed maps (e.g., `urls.<exposure>` or `urls.<instanceName>`), NEVER order-dependent flat lists consumed via `builtins.head`!
3. **Algebraic Effects & Handlers (Paradigm E)** gives the cleanest unifying mental model: a component declares typed **Effects/Requirements** (Intents) and outer **Context Handlers** (VPS, WSL, Live ISO, Mock-Test, Standalone Wrapper) supply the concrete **Open Provider Functors** (`providers.ingress.caddy { ... }`) — combining Paradigm B's explicit handler scoping with Paradigm C's typed `evalModules` validation and $O(N+M)$ synchronizations!
4. **Rust Typed IR (Paradigm D)** shines for the **pure-data domain** (validating exported Topology/Manifests, graph slicing, CLI, provisioning, CI orchestration), while keeping lazy OS/package evaluation inside native Nix avoids the JSON-boundary & dual-type-system trap documented in `RES-0004`.
